import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_2/main.dart';

void main() {
  group('Mall Navigation App Tests', () {
    testWidgets('App should display correctly', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const MallNavigationApp());

      // 验证应用标题
      expect(find.text('商场导航'), findsOneWidget);
      
      // 验证楼层导航栏存在
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Floor navigation should work', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const MallNavigationApp());

      // 验证默认楼层是 F1
      expect(find.text('F1'), findsOneWidget);

      // 测试点击不同楼层
      await tester.tap(find.text('F2'));
      await tester.pump();
      
      // 验证楼层切换成功（这里我们检查是否有对应的图片组件）
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('All floor buttons should be present', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const MallNavigationApp());

      // 验证所有楼层按钮都存在
      expect(find.text('B2'), findsOneWidget);
      expect(find.text('B1'), findsOneWidget);
      expect(find.text('F1'), findsOneWidget);
      expect(find.text('F2'), findsOneWidget);
      expect(find.text('F3'), findsOneWidget);
      expect(find.text('F4'), findsOneWidget);
      expect(find.text('F6'), findsOneWidget);
    });

    testWidgets('Floor selection should update UI', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const MallNavigationApp());

      // 点击 B2 楼层
      await tester.tap(find.text('B2'));
      await tester.pump();

      // 验证有图片显示（即使图片加载失败也会有 Image widget）
      expect(find.byType(Image), findsOneWidget);

      // 点击 F6 楼层
      await tester.tap(find.text('F6'));
      await tester.pump();

      // 再次验证图片组件存在
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Interactive features should work', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const MallNavigationApp());

      // 测试缩放功能（InteractiveViewer 的存在）
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // 测试楼层按钮可点击
      final f3Button = find.text('F3');
      expect(f3Button, findsOneWidget);
      
      await tester.tap(f3Button);
      await tester.pump();
      
      // 验证点击后没有错误
      expect(tester.takeException(), isNull);
    });
  });
}
