import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:controletv/main.dart';

void main() {
  testWidgets('Discovery screen has scan button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TV Discovery'), findsOneWidget);
    expect(find.text('Scan for TVs'), findsOneWidget);
  });
}
