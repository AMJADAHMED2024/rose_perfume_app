import 'package:flutter/widgets.dart';

/// Small, dependency-free UI copy layer for screens that are progressively
/// migrated to full localization.  Keeping this in one place prevents locale
/// checks from being scattered through widgets and works on every Flutter
/// platform without a network request.
class AppCopy {
  const AppCopy._(this.isEnglish);

  factory AppCopy.of(BuildContext context) =>
      AppCopy._(Localizations.localeOf(context).languageCode == 'en');

  final bool isEnglish;

  String pair(String arabic, String english) => isEnglish ? english : arabic;

  String get viewAll => pair('عرض الكل', 'View all');
  String get shop => pair('المتجر', 'Shop');
  String get all => pair('الكل', 'All');
  String get offers => pair('العروض', 'Offers');
  String get filters => pair('تصفية وترتيب المنتجات', 'Filter & sort products');
  String get resetFilters => pair('إعادة ضبط التصفية', 'Reset filters');
  String get noMatchingProducts =>
      pair('لا توجد منتجات مطابقة', 'No matching products');
  String get cart => pair('سلة التسوق', 'Shopping cart');
  String itemsInCart(int count) => pair(
    '$count منتج في سلتك',
    '$count item${count == 1 ? '' : 's'} in your cart',
  );
  String get total => pair('الإجمالي', 'Total');
  String get checkout => pair('إتمام الطلب', 'Checkout');
  String get emptyCart => pair('سلتك ما زالت فارغة', 'Your cart is empty');
  String get emptyCartMessage => pair(
    'اكتشف مجموعتنا وأضف ما يعجبك.',
    'Discover our collection and add your favourites.',
  );
  String get shopNow => pair('تسوّق الآن', 'Shop now');
  String get orders => pair('طلباتي', 'My orders');
  String get signInToOrders =>
      pair('سجّل الدخول لعرض طلباتك', 'Sign in to view your orders');
  String get ordersSubtitle => pair(
    'تابع حالة طلباتك وتفاصيلها بسهولة.',
    'Track the status and details of your orders.',
  );
  String get emptyOrders => pair('لا توجد طلبات بعد', 'No orders yet');
  String get emptyOrdersMessage => pair(
    'ابدأ باكتشاف مجموعتنا وسيظهر سجل طلباتك هنا.',
    'Start exploring our collection and your order history will appear here.',
  );
  String get browseFragrances => pair('تصفح العطور', 'Browse fragrances');
  String get retry => pair('إعادة المحاولة', 'Try again');
  String get searchStore => pair('ابحث في المتجر', 'Search the store');
  String get searchHint =>
      pair('ابحث باسم العطر أو الفئة', 'Search by fragrance or category');
  String get search => pair('بحث', 'Search');
  String get add => pair('أضف', 'Add');
  String get sale => pair('خصم', 'Sale');
  String get outOfStock => pair('نفد المخزون', 'Out of stock');
  String lowStock(int count) => pair('متبقي $count فقط', 'Only $count left');
  String get customerStories => pair('تجارب عملائنا', 'Customer stories');
  String get quickLinks => pair('روابط سريعة', 'Quick links');
  String get contactUs => pair('تواصل معنا', 'Contact us');
  String get storeInfo => pair('معلومات المتجر', 'Store information');
  String get aboutUs => pair('من نحن', 'About us');
  String get branches => pair('فروعنا', 'Our branches');
  String get privacy => pair('الخصوصية', 'Privacy');
  String get terms => pair('الشروط والأحكام', 'Terms & conditions');
  String get returns => pair('سياسة الاسترجاع', 'Return policy');
  String get country => pair('المملكة العربية السعودية', 'Saudi Arabia');
}
