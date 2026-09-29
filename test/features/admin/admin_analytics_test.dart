import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/features/admin/data/admin_analytics_repository.dart';

void main() {
  test('maps the administrative analytics response used by the API', () {
    final dashboard = AdminDashboard.fromJson({
      'sales': {
        'confirmedRevenue': {
          'current': 1234.5,
          'previous': 1000,
          'changePercentage': 23.45,
        },
        'confirmedOrders': {
          'current': 9,
          'previous': 8,
          'changePercentage': 12.5,
        },
        'averageOrderValue': {
          'current': 137.17,
          'previous': 125,
          'changePercentage': 9.7,
        },
        'itemsSold': {'current': 14, 'previous': 10, 'changePercentage': 40},
      },
      'customers': {'newCustomers': 3, 'returningCustomers': 6},
      'operations': {
        'newOrders': 2,
        'awaitingPaymentOrders': 1,
        'paymentFailureOrders': 1,
        'inPreparationOrders': 3,
        'inTransitOrders': 2,
        'lowStockProducts': 4,
        'outOfStockProducts': 1,
      },
      'topProducts': [
        {
          'productId': 11,
          'nameAr': 'ورد الطائف',
          'categoryNameAr': 'عطور',
          'unitsSold': 8,
          'orders': 6,
          'revenue': 720,
          'currentStock': 12,
        },
      ],
      'stockAlerts': [
        {
          'productId': 9,
          'nameAr': 'مسك أبيض',
          'currentStock': 1,
          'minimumStock': 4,
          'labelAr': 'مخزون منخفض',
        },
      ],
    });

    expect(dashboard.revenue.current, 1234.5);
    expect(dashboard.orders.changePercentage, 12.5);
    expect(dashboard.newCustomers, 3);
    expect(dashboard.operations.lowStock, 4);
    expect(dashboard.topProducts.single.name, 'ورد الطائف');
    expect(dashboard.stockAlerts.single.currentStock, 1);
  });

  test('retains every detailed reporting breakdown from the API', () {
    final dashboard = AdminDashboard.fromJson({
      'dateRange': {
        'startUtc': '2026-09-01T00:00:00Z',
        'endExclusiveUtc': '2026-10-01T00:00:00Z',
        'groupBy': 'day',
      },
      'sales': {
        'confirmedRevenue': {},
        'confirmedOrders': {},
        'averageOrderValue': {},
        'itemsSold': {},
      },
      'customers': {
        'purchasingCustomers': 8,
        'repeatPurchaseRate': 25,
        'premiumCustomers': 2,
        'rewardEnrolledCustomers': 3,
        'inactiveCustomersLast90Days': 4,
      },
      'salesTrend': [
        {'periodStartUtc': '2026-09-01T00:00:00Z', 'revenue': 140, 'orders': 2},
      ],
      'orderStatuses': [
        {
          'code': 'Completed',
          'labelAr': 'مكتمل',
          'orders': 2,
          'totalOrderValue': 140,
        },
      ],
      'paymentMethods': [
        {
          'paymentType': 'card',
          'paymentMethod': 'mada',
          'orders': 2,
          'revenue': 140,
        },
      ],
      'topCities': [
        {'city': 'عدن', 'orders': 2, 'revenue': 140},
      ],
      'shippingCompanies': [
        {'shippingCompany': 'أرامكس', 'orders': 2, 'revenue': 140},
      ],
      'coupons': [
        {'code': 'ROSE10', 'orders': 1, 'revenue': 70, 'discountAmount': 10},
      ],
      'salesLeakage': {
        'rejectedOrders': 1,
        'rejectedValue': 20,
        'paymentFailureOrders': 2,
        'paymentFailureValue': 30,
      },
      'topCategories': [
        {'nameAr': 'عطور', 'unitsSold': 2, 'orders': 2, 'revenue': 140},
      ],
      'slowMovingProducts': [
        {
          'productId': 3,
          'nameAr': 'عنبر',
          'categoryNameAr': 'عطور',
          'unitsSold': 0,
          'currentStock': 8,
        },
      ],
      'topCustomers': [
        {
          'customerId': 7,
          'name': 'مريم',
          'orders': 2,
          'revenue': 140,
          'isPremium': true,
          'rewardEnrolled': true,
        },
      ],
      'couponComparison': {
        'ordersWithCoupon': 1,
        'revenueWithCoupon': 70,
        'discountAmountWithCoupon': 10,
        'ordersWithoutCoupon': 1,
        'revenueWithoutCoupon': 70,
      },
      'productDiscountPerformance': [
        {
          'segmentAr': 'منتجات مخفضة',
          'orders': 1,
          'unitsSold': 1,
          'revenue': 70,
        },
      ],
    });

    expect(dashboard.salesTrend.single.orders, 2);
    expect(dashboard.paymentMethods.single.label, 'card · mada');
    expect(dashboard.topCities.single.label, 'عدن');
    expect(dashboard.salesLeakage.paymentFailureValue, 30);
    expect(dashboard.slowMovingProducts.single.currentStock, 8);
    expect(dashboard.topCustomers.single.isPremium, isTrue);
    expect(dashboard.couponComparison.discountAmountWithCoupon, 10);
  });
}
