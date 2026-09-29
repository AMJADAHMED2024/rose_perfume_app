# Rose Perfume Flutter Architecture

The application uses a feature-first, offline-first structure.

```
lib/
  app/                 App composition, theme and routes
  core/                Cross-feature configuration, network and state
  features/
    home/
      data/            API and cache orchestration
      domain/          Storefront entities
      application/     Riverpod controllers
      presentation/    Flutter screens and widgets
    catalog/           Search, filtering and product details
    cart/              Offline-persistent cart
```

## Offline-first flow

1. Read the latest storefront snapshot from the local Drift/SQLite database.
2. Render it immediately when available.
3. Refresh from the API in the background.
4. Write the refreshed snapshot back to the local cache.
5. Keep the cart locally, including product and quantity data.
6. Queue offline writes in the persistent outbox and replay them when online.

The sync coordinator starts when the app opens, whenever it returns to the foreground, and when the device reports an available network transport. It processes due operations in creation order. A failed operation stays in the outbox and receives exponential backoff (1, 2, 4, …, maximum 60 minutes); operations for a feature whose handler is not available are preserved, never discarded. Transport availability only starts a sync attempt: the real API call still decides whether Internet access is valid.

## Local data ownership

| Local table | Contents | Why it is local |
| --- | --- | --- |
| `storefront_cache` | The last valid API snapshot: sliders, categories and products | The catalogue opens immediately without a network connection. |
| `local_cart_items` | Product snapshot and quantity per cart line | The cart is usable offline and does not disappear on restart. |
| `sync_operations` | Future operations awaiting the server, with retry count | A checkout, favourite or account update can be queued instead of lost while offline. |
| `payment_sessions` | Gateway invoice ID, order ID, non-sensitive status and shipment reference | The user can resume payment and shipment tracking after returning from an external gateway or restarting the app. |
| `order_history_snapshots` | Last successful order-history response, keyed by customer ID | The customer can still see their last known order history without Internet; one customer's snapshot is never shown to another. |
| `notification_snapshots` | Last successful notification inbox, keyed by customer ID | The customer can read their last received notification history offline without exposing it to another account. |

`AppDatabase` uses Drift over SQLite. Native builds write `rose_perfume.sqlite` inside the operating system's application-documents directory. The web build uses Drift's SQLite WebAssembly worker with browser-backed persistent storage. The two required worker files are versioned in `web/` and are deliberately wired in the database constructor.

Only non-sensitive business data is stored here. A future authenticated session must store its refresh token in platform secure storage, never in the catalogue cache or cart table.

On logout, the app clears the cart, payment sessions and cached order histories in one database transaction, then clears the secure token and in-memory cart. The public storefront cache deliberately remains so the catalog can still open offline before another customer signs in.

## Authentication boundary

The access token is stored separately through `flutter_secure_storage`; it is never written into Drift, SharedPreferences, logs or the sync outbox. The Dio client reads it only when a request is made and sends it as a Bearer token. Login and registration use the existing `/api/Auth/login` and `/api/Auth/register` contracts from the React storefront. Android API 23 is the minimum supported version so the platform secure-storage implementation can be used. The deployed web app must use HTTPS (localhost is suitable for development) before it can persist a secure session.

When an authenticated API request returns `401`, the network client removes the secure token and broadcasts a session-expired event. Authentication state then returns to signed-out and clears customer-specific local data; the public storefront cache remains available. Login and registration deliberately opt out of this event so an invalid password is shown as a form error and does not disturb a current local session.

Password recovery sends the email address to the Auth API and then submits the short-lived reset code with the new password. The code and the new password remain only in the active form controllers; neither is persisted to the local database, preferences or logs.

An authenticated customer can separately change their password from the profile screen. The current password is required, and the API derives the customer identity from the access token rather than accepting a customer ID from the device.

## Checkout boundary

Checkout is online-only because it creates an external payment invoice. It requires a signed-in customer, a saved delivery address, a quoted shipping option, payment choice and shipping phone number before calling `/api/order/create-order`. The cart is cleared only after the server creates the order; the returned invoice URL then opens through the platform browser. Draft data and payment URLs are never put into the offline sync queue, which prevents accidentally creating duplicate paid orders after reconnection.

Coupon validation is also online-only. Checkout verifies a code with the existing Coupon API, displays the capped discount against merchandise only, re-quotes shipping using the discounted merchandise amount, and sends the accepted code with the final order request. The server remains the authority for accepting the code and for the payment amount; an offline client never treats a locally remembered code as valid.

The invoice identifier returned by the server is instead saved in `payment_sessions`, alongside no card details, tokens or gateway credentials. The payment-status screen calls `/api/order/check-pay-order` only to read the outcome; it refreshes while visible and can reopen the external payment or shipment URL. It never calls the create-order endpoint again.

Android and iOS also register the `roseperfume://payment-status` return URL. A payment provider can return, for example, `roseperfume://payment-status?invoiceId={invoiceId}` and the app will open the already-existing payment-status screen. The return URL is never trusted as a payment result: the screen still verifies the invoice through the authenticated API. Browser builds retain the payment-status page as a manual fallback; production HTTPS universal links require a deployed domain and its platform association files before they can be configured as the provider callback.

## Order access boundary

Customer order history uses the authenticated `POST /api/order/my-orders` endpoint. The API derives the customer identity from the validated JWT claim; it does not accept a customer ID from Flutter. The same rule now applies when creating an order and checking a payment invoice. The legacy React order-history route remains compatible: it honors a requested customer ID only for an administrator and otherwise returns the JWT owner's orders. Approval and broad administrative lookup endpoints require the `Admin` role.

The Flutter orders controller reads its customer-scoped local snapshot first, then requests the current server data and atomically replaces the snapshot only after a successful response. An offline banner clearly indicates when the displayed list is cached; local data never triggers any payment or order mutation.

Customer notifications use the same model through `POST /api/Notification/my-notifications`. The inbox renders its customer-scoped local snapshot first and refreshes it only after a successful server response. The API derives the recipient from the JWT, while notification-management endpoints are restricted to administrators. The existing backend schema does not record a read receipt, so the Flutter inbox deliberately presents the server's actual delivery history without an unreliable unread badge.

## Address ownership

`DeliveryAddress` is a shared core model used by both the address book and checkout. Every address operation uses the authenticated Address API, whose server side derives ownership from the JWT. The address book supports create, update, delete and selecting a default address; checkout reloads the same server-owned list when it opens, so shipping quotes always use a current address.

## Product reviews

Product review listing is public and paginated. Creating, editing or deleting a review requires an authenticated session; the server overwrites the submitted user ID with the JWT owner and rejects edits or deletes of another customer's review. Soft-deleted reviews are excluded from public product responses.

## Customer profile

Profile editing is an authenticated feature separate from session management. The UI reads and updates only the currently supported profile fields (name, email, phone and nationality) via the server-owned `/api/User/user-profile` contract. Credentials remain confined to secure session storage and are never exposed in the profile state.

The default API URL is `https://api.roseperfume.com.sa`. Override it per environment without changing source code:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-api.example
```

The presentation adapts navigation and grid density by available screen width; business rules and data sources remain shared across Android, iOS, web, Windows, macOS and Linux.

Product payloads retain their complete ordered `imageUrls` collection in the local storefront snapshot. The product-detail gallery uses that collection for swipe navigation, thumbnail selection and desktop-safe zoom; the primary image remains available to compact product cards.

The customer dashboard is a presentation composition over the existing customer-scoped order repository. It performs no new order mutation and honors the same offline snapshot and visible-cache state as the full order history.

## Administration boundary

The `/admin` route is a separate responsive administration dashboard. It reads the signed JWT role only to decide whether to show the entry point; the server is still the authority and protects `GET /api/admin/analytics/dashboard` with the `Admin` role. The dashboard requests live sales, order, inventory and product indicators for 7, 30 or 90 days. `/admin/orders` provides a searchable, paginated, server-backed order list and read-only order details using the existing admin-only `POST /api/order/get-all` contract. `/admin/products` provides a searchable, paginated product catalogue with role-protected create, update and delete operations, and `/admin/products/:id/images` uploads, replaces and deletes product images through a single file-picker flow for mobile, web and desktop. Product, category, image and inventory mutations now require the same `Admin` server role. Administrative analytics and order data are intentionally never written to Drift or another device cache: they can contain operational information that must disappear with the current server session.

Public trust and support content is grouped into the support feature. Its routes are independent of an authenticated session and work across device sizes; contact actions intentionally delegate to the operating system's phone or email application.

The selected light or dark theme is a device-local presentation preference. It is stored separately from customer records, so changing accounts does not reveal or modify another customer's data.
