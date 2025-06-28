import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syonan_app/utils/responsive_utils.dart';

void main() {
  group('ResponsiveUtils Tests', () {
    testWidgets('should return mobile device type for narrow screens', (WidgetTester tester) async {
      // Set up narrow screen
      await tester.binding.setSurfaceSize(const Size(360, 640));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getDeviceType(context), DeviceType.mobile);
              expect(ResponsiveUtils.isMobile(context), true);
              expect(ResponsiveUtils.getScreenWidth(context), 360.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return tablet device type for medium screens', (WidgetTester tester) async {
      // Set up tablet screen
      await tester.binding.setSurfaceSize(const Size(600, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getDeviceType(context), DeviceType.tablet);
              expect(ResponsiveUtils.isTablet(context), true);
              expect(ResponsiveUtils.getScreenWidth(context), 600.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return desktop device type for wide screens', (WidgetTester tester) async {
      // Set up desktop screen
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getDeviceType(context), DeviceType.desktop);
              expect(ResponsiveUtils.isDesktop(context), true);
              expect(ResponsiveUtils.getScreenWidth(context), 1024.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should provide responsive spacing values', (WidgetTester tester) async {
      // Test mobile spacing
      await tester.binding.setSurfaceSize(const Size(360, 640));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSpacing(context), 12.0);
              expect(ResponsiveUtils.getHorizontalPadding(context), 16.0);
              expect(ResponsiveUtils.getVerticalPadding(context), 12.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet spacing
      await tester.binding.setSurfaceSize(const Size(600, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSpacing(context), 16.0);
              expect(ResponsiveUtils.getHorizontalPadding(context), 24.0);
              expect(ResponsiveUtils.getVerticalPadding(context), 16.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should provide responsive grid columns', (WidgetTester tester) async {
      // Mobile: 2 columns
      await tester.binding.setSurfaceSize(const Size(360, 640));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridColumns(context), 2);
              return const SizedBox();
            },
          ),
        ),
      );

      // Tablet: 3 columns
      await tester.binding.setSurfaceSize(const Size(600, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridColumns(context), 3);
              return const SizedBox();
            },
          ),
        ),
      );

      // Desktop: 4 columns
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridColumns(context), 4);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should calculate appropriate mini game button width', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final singleWidth = ResponsiveUtils.getMiniGameButtonWidth(context, isSingle: true);
              final doubleWidth = ResponsiveUtils.getMiniGameButtonWidth(context);
              
              // Single button should be 60% of screen width but clamped
              expect(singleWidth, 200.0); // 360 * 0.6 = 216, clamped to 200
              
              // Double button should consider padding and spacing
              expect(doubleWidth, (360 - 16*2 - 12) / 2); // (width - horizontal padding - spacing) / 2
              
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}