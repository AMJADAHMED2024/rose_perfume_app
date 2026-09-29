import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:share_plus/share_plus.dart';

import 'admin_analytics_repository.dart';

/// Produces a UTF-8-with-BOM CSV so Arabic labels open correctly in common
/// spreadsheet software. Sharing is delegated to the host OS, which works on
/// Android, iOS, desktop, and web without writing a sensitive admin report to
/// an app-visible permanent folder.
class AdminReportExporter {
  const AdminReportExporter();

  Future<void> shareCsv(AdminDashboard dashboard) async {
    final fileName =
        'rose-report-${_dateKey(dashboard.dateRange.start)}-to-${_dateKey(dashboard.dateRange.endExclusive.subtract(const Duration(days: 1)))}.csv';
    final bytes = utf8.encode('\uFEFF${_csv(_rows(dashboard))}');
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'text/csv')],
        fileNameOverrides: [fileName],
        subject: 'تقرير روز برفيوم',
        text:
            'تقرير المتجر للفترة ${_date(dashboard.dateRange.start)} إلى ${_date(dashboard.dateRange.endExclusive.subtract(const Duration(days: 1)))}',
      ),
    );
  }

  /// Builds the same data used by CSV as a polished, printable Arabic report.
  /// The bundled Cairo typeface avoids Arabic glyphs becoming squares on phones
  /// and on desktop printers.
  Future<void> sharePdf(AdminDashboard dashboard) async {
    final bytes = await _pdfBytes(dashboard);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'rose-report-${_dateKey(dashboard.dateRange.start)}.pdf',
    );
  }

  Future<void> printPdf(AdminDashboard dashboard) async {
    final bytes = await _pdfBytes(dashboard);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<Uint8List> _pdfBytes(AdminDashboard dashboard) async {
    final fontData = await rootBundle.load('assets/branding/Cairo-Regular.ttf');
    final boldData = await rootBundle.load('assets/branding/Cairo-Bold.ttf');
    final regular = pw.Font.ttf(fontData);
    final bold = pw.Font.ttf(boldData);
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      title: 'تقرير روز برفيوم',
      author: 'Rose Perfume',
    );
    final end = dashboard.dateRange.endExclusive.subtract(
      const Duration(days: 1),
    );
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: regular, bold: bold),
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.purple)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'روز برفيوم',
                style: pw.TextStyle(font: bold, fontSize: 20),
              ),
              pw.Text(
                'تقرير إداري',
                style: const pw.TextStyle(color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}'),
        ),
        build: (_) => [
          pw.SizedBox(height: 12),
          pw.Text(
            'الفترة: ${_date(dashboard.dateRange.start)} إلى ${_date(end)}',
          ),
          pw.SizedBox(height: 14),
          _pdfSection('ملخص الأداء', [
            ['المؤشر', 'الحالي', 'السابق', 'التغير'],
            _metricRow('الإيراد المؤكد', dashboard.revenue),
            _metricRow('الطلبات المؤكدة', dashboard.orders),
            _metricRow('متوسط قيمة الطلب', dashboard.averageOrderValue),
            _metricRow('القطع المباعة', dashboard.itemsSold),
          ], bold),
          _pdfSection('أداء المنتجات', [
            ['المنتج', 'التصنيف', 'الوحدات', 'الطلبات', 'الإيراد', 'المخزون'],
            ...dashboard.topProducts.map(
              (item) => [
                item.name,
                item.categoryName,
                item.unitsSold,
                item.orders,
                item.revenue,
                item.currentStock,
              ],
            ),
          ], bold),
          _pdfSection('حالات الطلبات', [
            ['الحالة', 'عدد الطلبات', 'القيمة'],
            ...dashboard.orderStatuses.map(
              (item) => [item.label, item.orders, item.totalOrderValue],
            ),
          ], bold),
          _pdfSection('أفضل العملاء', [
            ['العميل', 'الطلبات', 'الإيراد', 'مميز'],
            ...dashboard.topCustomers.map(
              (item) => [
                item.label,
                item.orders,
                item.revenue,
                item.isPremium ? 'نعم' : 'لا',
              ],
            ),
          ], bold),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _pdfSection(String title, List<List<Object?>> rows, pw.Font bold) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.SizedBox(height: 16),
          pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 14)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: rows.first.map((value) => '$value').toList(),
            data: rows
                .skip(1)
                .map((row) => row.map((value) => '$value').toList())
                .toList(),
            headerStyle: pw.TextStyle(font: bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
            cellAlignment: pw.Alignment.centerRight,
            cellStyle: const pw.TextStyle(fontSize: 8),
            border: pw.TableBorder.all(color: PdfColors.grey300),
          ),
        ],
      );

  List<List<Object?>> _rows(AdminDashboard dashboard) => [
    [
      'تقرير روز برفيوم',
      'من',
      _date(dashboard.dateRange.start),
      'إلى',
      _date(dashboard.dateRange.endExclusive.subtract(const Duration(days: 1))),
    ],
    [],
    ['المؤشر', 'القيمة الحالية', 'القيمة السابقة', 'نسبة التغير'],
    _metricRow('الإيراد المؤكد', dashboard.revenue),
    _metricRow('الطلبات المؤكدة', dashboard.orders),
    _metricRow('متوسط قيمة الطلب', dashboard.averageOrderValue),
    _metricRow('القطع المباعة', dashboard.itemsSold),
    [],
    ['الفترة', 'الإيراد المؤكد', 'عدد الطلبات'],
    ...dashboard.salesTrend.map(
      (item) => [_date(item.periodStart), item.revenue, item.orders],
    ),
    [],
    ['حالة الطلب', 'عدد الطلبات', 'قيمة الطلبات'],
    ...dashboard.orderStatuses.map(
      (item) => [item.label, item.orders, item.totalOrderValue],
    ),
    [],
    ['المنتج', 'التصنيف', 'الوحدات', 'الطلبات', 'الإيراد', 'المخزون'],
    ...dashboard.topProducts.map(
      (item) => [
        item.name,
        item.categoryName,
        item.unitsSold,
        item.orders,
        item.revenue,
        item.currentStock,
      ],
    ),
    [],
    ['التصنيف', 'الوحدات', 'الطلبات', 'الإيراد'],
    ...dashboard.topCategories.map(
      (item) => [item.label, item.unitsSold, item.orders, item.revenue],
    ),
    [],
    ['المدينة', 'الطلبات', 'الإيراد'],
    ...dashboard.topCities.map(
      (item) => [item.label, item.orders, item.revenue],
    ),
    [],
    ['طريقة الدفع', 'الطلبات', 'الإيراد'],
    ...dashboard.paymentMethods.map(
      (item) => [item.label, item.orders, item.revenue],
    ),
    [],
    ['الكوبون', 'الطلبات', 'الإيراد', 'قيمة الخصم'],
    ...dashboard.coupons.map(
      (item) => [item.label, item.orders, item.revenue, item.discountAmount],
    ),
    [],
    ['العميل', 'الطلبات', 'الإيراد', 'مميز', 'مسجل مكافآت'],
    ...dashboard.topCustomers.map(
      (item) => [
        item.label,
        item.orders,
        item.revenue,
        item.isPremium ? 'نعم' : 'لا',
        item.rewardEnrolled ? 'نعم' : 'لا',
      ],
    ),
  ];

  List<Object?> _metricRow(String label, AdminMetric metric) => [
    label,
    metric.current,
    metric.previous,
    metric.changePercentage ?? '',
  ];
}

String _csv(List<List<Object?>> rows) =>
    rows.map((row) => row.map(_escape).join(',')).join('\r\n');

String _escape(Object? value) =>
    '"${(value ?? '').toString().replaceAll('"', '""')}"';

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _dateKey(DateTime value) => _date(value);
