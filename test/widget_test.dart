// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:inform_project_exe/main.dart';

void main() {
  testWidgets('Login page renders key labels', (WidgetTester tester) async {
    await tester.pumpWidget(const InformDesktopApp());

    expect(find.text('inform typing photo copy'), findsWidgets);
    expect(find.text('إنفورم للطباعة والتصوير'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(find.text('نسيت الباسوورد'), findsOneWidget);
    expect(find.text('انشاء حساب'), findsOneWidget);
  });
}
