import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rose_perfume_app/app/theme/app_theme.dart';
import 'package:rose_perfume_app/core/widgets/app_page_components.dart';
import 'package:rose_perfume_app/core/widgets/app_skeleton.dart';

void main() {
  test('uses the Rose Perfume light theme', () {
    expect(AppTheme.light.colorScheme.brightness, Brightness.light);
  });

  testWidgets('renders reusable skeleton layouts without a nested viewport', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: SkeletonPage(layout: SkeletonLayout.grid)),
      ),
    );

    expect(find.byType(AppSkeleton), findsWidgets);
    expect(find.byType(SkeletonBox), findsWidgets);
  });

  testWidgets('renders the shared page components', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppSectionCard(
            title: 'تفاصيل الحساب',
            icon: Icons.person_outline,
            child: AppPageHeader(
              title: 'طلباتي',
              subtitle: 'آخر تحديثات طلباتك',
            ),
          ),
        ),
      ),
    );

    expect(find.text('تفاصيل الحساب'), findsOneWidget);
    expect(find.text('طلباتي'), findsOneWidget);
  });
}
