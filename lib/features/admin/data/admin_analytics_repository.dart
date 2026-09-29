import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminMetric {
  const AdminMetric({
    required this.current,
    required this.previous,
    this.changePercentage,
  });

  final double current;
  final double previous;
  final double? changePercentage;

  factory AdminMetric.fromJson(Map<String, dynamic> json) => AdminMetric(
    current: _asDouble(json['current']),
    previous: _asDouble(json['previous']),
    changePercentage: json['changePercentage'] == null
        ? null
        : _asDouble(json['changePercentage']),
  );
}

class AdminDateRange {
  const AdminDateRange({
    required this.start,
    required this.endExclusive,
    required this.groupBy,
  });

  final DateTime start;
  final DateTime endExclusive;
  final String groupBy;

  factory AdminDateRange.fromJson(Map<String, dynamic> json) => AdminDateRange(
    start: _asDate(json['startUtc']),
    endExclusive: _asDate(json['endExclusiveUtc']),
    groupBy: _text(json['groupBy'], fallback: 'day'),
  );
}

class AdminCustomerSummary {
  const AdminCustomerSummary({
    required this.newCustomers,
    required this.returningCustomers,
    required this.purchasingCustomers,
    required this.repeatPurchaseRate,
    required this.premiumCustomers,
    required this.rewardEnrolledCustomers,
    required this.inactiveCustomersLast90Days,
  });

  final int newCustomers;
  final int returningCustomers;
  final int purchasingCustomers;
  final double? repeatPurchaseRate;
  final int premiumCustomers;
  final int rewardEnrolledCustomers;
  final int inactiveCustomersLast90Days;

  factory AdminCustomerSummary.fromJson(Map<String, dynamic> json) =>
      AdminCustomerSummary(
        newCustomers: _asInt(json['newCustomers']),
        returningCustomers: _asInt(json['returningCustomers']),
        purchasingCustomers: _asInt(json['purchasingCustomers']),
        repeatPurchaseRate: json['repeatPurchaseRate'] == null
            ? null
            : _asDouble(json['repeatPurchaseRate']),
        premiumCustomers: _asInt(json['premiumCustomers']),
        rewardEnrolledCustomers: _asInt(json['rewardEnrolledCustomers']),
        inactiveCustomersLast90Days: _asInt(
          json['inactiveCustomersLast90Days'],
        ),
      );
}

class AdminSalesTrendPoint {
  const AdminSalesTrendPoint({
    required this.periodStart,
    required this.revenue,
    required this.orders,
  });

  final DateTime periodStart;
  final double revenue;
  final int orders;

  factory AdminSalesTrendPoint.fromJson(Map<String, dynamic> json) =>
      AdminSalesTrendPoint(
        periodStart: _asDate(json['periodStartUtc']),
        revenue: _asDouble(json['revenue']),
        orders: _asInt(json['orders']),
      );
}

class AdminOrderStatus {
  const AdminOrderStatus({
    required this.code,
    required this.label,
    required this.orders,
    required this.totalOrderValue,
  });

  final String code;
  final String label;
  final int orders;
  final double totalOrderValue;

  factory AdminOrderStatus.fromJson(Map<String, dynamic> json) =>
      AdminOrderStatus(
        code: _text(json['code']),
        label: _text(json['labelAr'], fallback: 'غير محدد'),
        orders: _asInt(json['orders']),
        totalOrderValue: _asDouble(json['totalOrderValue']),
      );
}

class AdminTopProduct {
  const AdminTopProduct({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.unitsSold,
    required this.orders,
    required this.revenue,
    required this.currentStock,
  });

  final int id;
  final String name;
  final String categoryName;
  final int unitsSold;
  final int orders;
  final double revenue;
  final int currentStock;

  factory AdminTopProduct.fromJson(Map<String, dynamic> json) =>
      AdminTopProduct(
        id: _asInt(json['productId']),
        name: _text(json['nameAr'], fallback: _text(json['nameEn'])),
        categoryName: _text(json['categoryNameAr']),
        unitsSold: _asInt(json['unitsSold']),
        orders: _asInt(json['orders']),
        revenue: _asDouble(json['revenue']),
        currentStock: _asInt(json['currentStock']),
      );
}

class AdminStockAlert {
  const AdminStockAlert({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minimumStock,
    required this.unitsSold,
    required this.label,
  });

  final int id;
  final String name;
  final int currentStock;
  final int minimumStock;
  final int unitsSold;
  final String label;

  factory AdminStockAlert.fromJson(Map<String, dynamic> json) =>
      AdminStockAlert(
        id: _asInt(json['productId']),
        name: _text(json['nameAr'], fallback: _text(json['nameEn'])),
        currentStock: _asInt(json['currentStock']),
        minimumStock: _asInt(json['minimumStock']),
        unitsSold: _asInt(json['unitsSoldInPeriod']),
        label: _text(json['labelAr'], fallback: 'تنبيه مخزون'),
      );
}

class AdminBreakdown {
  const AdminBreakdown({
    required this.label,
    required this.orders,
    required this.revenue,
  });

  final String label;
  final int orders;
  final double revenue;
}

class AdminCoupon extends AdminBreakdown {
  const AdminCoupon({
    required super.label,
    required super.orders,
    required super.revenue,
    required this.discountAmount,
  });

  final double discountAmount;

  factory AdminCoupon.fromJson(Map<String, dynamic> json) => AdminCoupon(
    label: _text(json['code'], fallback: 'غير محدد'),
    orders: _asInt(json['orders']),
    revenue: _asDouble(json['revenue']),
    discountAmount: _asDouble(json['discountAmount']),
  );
}

class AdminSalesLeakage {
  const AdminSalesLeakage({
    required this.rejectedOrders,
    required this.rejectedValue,
    required this.paymentFailureOrders,
    required this.paymentFailureValue,
  });

  final int rejectedOrders;
  final double rejectedValue;
  final int paymentFailureOrders;
  final double paymentFailureValue;

  factory AdminSalesLeakage.fromJson(Map<String, dynamic> json) =>
      AdminSalesLeakage(
        rejectedOrders: _asInt(json['rejectedOrders']),
        rejectedValue: _asDouble(json['rejectedValue']),
        paymentFailureOrders: _asInt(json['paymentFailureOrders']),
        paymentFailureValue: _asDouble(json['paymentFailureValue']),
      );
}

class AdminCategoryPerformance extends AdminBreakdown {
  const AdminCategoryPerformance({
    required super.label,
    required super.orders,
    required super.revenue,
    required this.unitsSold,
  });

  final int unitsSold;

  factory AdminCategoryPerformance.fromJson(Map<String, dynamic> json) =>
      AdminCategoryPerformance(
        label: _text(json['nameAr'], fallback: 'بدون تصنيف'),
        orders: _asInt(json['orders']),
        revenue: _asDouble(json['revenue']),
        unitsSold: _asInt(json['unitsSold']),
      );
}

class AdminSlowMovingProduct {
  const AdminSlowMovingProduct({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.unitsSold,
    required this.currentStock,
  });

  final int id;
  final String name;
  final String categoryName;
  final int unitsSold;
  final int currentStock;

  factory AdminSlowMovingProduct.fromJson(Map<String, dynamic> json) =>
      AdminSlowMovingProduct(
        id: _asInt(json['productId']),
        name: _text(json['nameAr'], fallback: _text(json['nameEn'])),
        categoryName: _text(json['categoryNameAr'], fallback: 'بدون تصنيف'),
        unitsSold: _asInt(json['unitsSold']),
        currentStock: _asInt(json['currentStock']),
      );
}

class AdminTopCustomer extends AdminBreakdown {
  const AdminTopCustomer({
    required this.id,
    required super.label,
    required super.orders,
    required super.revenue,
    required this.isPremium,
    required this.rewardEnrolled,
  });

  final int id;
  final bool isPremium;
  final bool rewardEnrolled;

  factory AdminTopCustomer.fromJson(Map<String, dynamic> json) =>
      AdminTopCustomer(
        id: _asInt(json['customerId']),
        label: _text(json['name'], fallback: 'عميل'),
        orders: _asInt(json['orders']),
        revenue: _asDouble(json['revenue']),
        isPremium: json['isPremium'] == true,
        rewardEnrolled: json['rewardEnrolled'] == true,
      );
}

class AdminCouponComparison {
  const AdminCouponComparison({
    required this.ordersWithCoupon,
    required this.revenueWithCoupon,
    required this.discountAmountWithCoupon,
    required this.ordersWithoutCoupon,
    required this.revenueWithoutCoupon,
  });

  final int ordersWithCoupon;
  final double revenueWithCoupon;
  final double discountAmountWithCoupon;
  final int ordersWithoutCoupon;
  final double revenueWithoutCoupon;

  factory AdminCouponComparison.fromJson(Map<String, dynamic> json) =>
      AdminCouponComparison(
        ordersWithCoupon: _asInt(json['ordersWithCoupon']),
        revenueWithCoupon: _asDouble(json['revenueWithCoupon']),
        discountAmountWithCoupon: _asDouble(json['discountAmountWithCoupon']),
        ordersWithoutCoupon: _asInt(json['ordersWithoutCoupon']),
        revenueWithoutCoupon: _asDouble(json['revenueWithoutCoupon']),
      );
}

class AdminOperations {
  const AdminOperations({
    required this.newOrders,
    required this.awaitingPayment,
    required this.paymentFailures,
    required this.inPreparation,
    required this.inTransit,
    required this.rejectedOrders,
    required this.lowStock,
    required this.outOfStock,
  });

  final int newOrders;
  final int awaitingPayment;
  final int paymentFailures;
  final int inPreparation;
  final int inTransit;
  final int rejectedOrders;
  final int lowStock;
  final int outOfStock;

  factory AdminOperations.fromJson(Map<String, dynamic> json) =>
      AdminOperations(
        newOrders: _asInt(json['newOrders']),
        awaitingPayment: _asInt(json['awaitingPaymentOrders']),
        paymentFailures: _asInt(json['paymentFailureOrders']),
        inPreparation: _asInt(json['inPreparationOrders']),
        inTransit: _asInt(json['inTransitOrders']),
        rejectedOrders: _asInt(json['rejectedOrders']),
        lowStock: _asInt(json['lowStockProducts']),
        outOfStock: _asInt(json['outOfStockProducts']),
      );
}

class AdminDashboard {
  const AdminDashboard({
    required this.dateRange,
    required this.revenue,
    required this.orders,
    required this.averageOrderValue,
    required this.itemsSold,
    required this.customers,
    required this.operations,
    required this.salesTrend,
    required this.orderStatuses,
    required this.topProducts,
    required this.stockAlerts,
    required this.paymentMethods,
    required this.topCities,
    required this.shippingCompanies,
    required this.coupons,
    required this.salesLeakage,
    required this.topCategories,
    required this.slowMovingProducts,
    required this.topCustomers,
    required this.couponComparison,
    required this.productDiscountPerformance,
  });

  final AdminDateRange dateRange;
  final AdminMetric revenue;
  final AdminMetric orders;
  final AdminMetric averageOrderValue;
  final AdminMetric itemsSold;
  final AdminCustomerSummary customers;
  final AdminOperations operations;
  final List<AdminSalesTrendPoint> salesTrend;
  final List<AdminOrderStatus> orderStatuses;
  final List<AdminTopProduct> topProducts;
  final List<AdminStockAlert> stockAlerts;
  final List<AdminBreakdown> paymentMethods;
  final List<AdminBreakdown> topCities;
  final List<AdminBreakdown> shippingCompanies;
  final List<AdminCoupon> coupons;
  final AdminSalesLeakage salesLeakage;
  final List<AdminCategoryPerformance> topCategories;
  final List<AdminSlowMovingProduct> slowMovingProducts;
  final List<AdminTopCustomer> topCustomers;
  final AdminCouponComparison couponComparison;
  final List<AdminBreakdown> productDiscountPerformance;

  // Compatibility getters keep existing dashboard consumers decoupled from
  // the expanded customer-summary model used by the detailed reports page.
  int get newCustomers => customers.newCustomers;
  int get returningCustomers => customers.returningCustomers;

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    final sales = _asMap(json['sales']);
    return AdminDashboard(
      dateRange: AdminDateRange.fromJson(_asMap(json['dateRange'])),
      revenue: AdminMetric.fromJson(_asMap(sales['confirmedRevenue'])),
      orders: AdminMetric.fromJson(_asMap(sales['confirmedOrders'])),
      averageOrderValue: AdminMetric.fromJson(
        _asMap(sales['averageOrderValue']),
      ),
      itemsSold: AdminMetric.fromJson(_asMap(sales['itemsSold'])),
      customers: AdminCustomerSummary.fromJson(_asMap(json['customers'])),
      operations: AdminOperations.fromJson(_asMap(json['operations'])),
      salesTrend: _asList(
        json['salesTrend'],
      ).map(AdminSalesTrendPoint.fromJson).toList(),
      orderStatuses: _asList(
        json['orderStatuses'],
      ).map(AdminOrderStatus.fromJson).toList(),
      topProducts: _asList(
        json['topProducts'],
      ).map(AdminTopProduct.fromJson).toList(),
      stockAlerts: _asList(
        json['stockAlerts'],
      ).map(AdminStockAlert.fromJson).toList(),
      paymentMethods: _asList(json['paymentMethods'])
          .map(
            (item) => AdminBreakdown(
              label: _joinLabels(item['paymentType'], item['paymentMethod']),
              orders: _asInt(item['orders']),
              revenue: _asDouble(item['revenue']),
            ),
          )
          .toList(),
      topCities: _asList(json['topCities'])
          .map(
            (item) => AdminBreakdown(
              label: _text(item['city'], fallback: 'غير محدد'),
              orders: _asInt(item['orders']),
              revenue: _asDouble(item['revenue']),
            ),
          )
          .toList(),
      shippingCompanies: _asList(json['shippingCompanies'])
          .map(
            (item) => AdminBreakdown(
              label: _text(item['shippingCompany'], fallback: 'غير محدد'),
              orders: _asInt(item['orders']),
              revenue: _asDouble(item['revenue']),
            ),
          )
          .toList(),
      coupons: _asList(json['coupons']).map(AdminCoupon.fromJson).toList(),
      salesLeakage: AdminSalesLeakage.fromJson(_asMap(json['salesLeakage'])),
      topCategories: _asList(
        json['topCategories'],
      ).map(AdminCategoryPerformance.fromJson).toList(),
      slowMovingProducts: _asList(
        json['slowMovingProducts'],
      ).map(AdminSlowMovingProduct.fromJson).toList(),
      topCustomers: _asList(
        json['topCustomers'],
      ).map(AdminTopCustomer.fromJson).toList(),
      couponComparison: AdminCouponComparison.fromJson(
        _asMap(json['couponComparison']),
      ),
      productDiscountPerformance: _asList(json['productDiscountPerformance'])
          .map(
            (item) => AdminBreakdown(
              label: _text(item['segmentAr'], fallback: 'غير محدد'),
              orders: _asInt(item['orders']),
              revenue: _asDouble(item['revenue']),
            ),
          )
          .toList(),
    );
  }
}

class AdminAnalyticsRepository {
  const AdminAnalyticsRepository(this._dio);
  final Dio _dio;

  Future<AdminDashboard> fetchDashboard({required int rangeDays}) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    return fetchReport(
      from: end.subtract(Duration(days: rangeDays - 1)),
      to: end,
      topProductsTake: 5,
      breakdownTake: 5,
    );
  }

  Future<AdminDashboard> fetchReport({
    required DateTime from,
    required DateTime to,
    int topProductsTake = 10,
    int breakdownTake = 10,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/admin/analytics/dashboard',
      queryParameters: {
        'from': _dateValue(from),
        'to': _dateValue(to),
        'topProductsTake': topProductsTake,
        'breakdownTake': breakdownTake,
      },
    );
    final envelope = _asMap(response.data);
    return AdminDashboard.fromJson(_asMap(envelope['data']));
  }
}

final adminAnalyticsRepositoryProvider = Provider<AdminAnalyticsRepository>(
  (ref) => AdminAnalyticsRepository(ref.watch(dioProvider)),
);

String _dateValue(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> _asList(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

double _asDouble(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

DateTime _asDate(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '')?.toLocal() ?? DateTime.now();

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String _joinLabels(dynamic first, dynamic second) {
  final values = [
    _text(first),
    _text(second),
  ].where((value) => value.isNotEmpty && value != 'unknown').toSet();
  return values.isEmpty ? 'غير محدد' : values.join(' · ');
}
