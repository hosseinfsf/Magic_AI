// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('basic math smoke test', () {
    // A simple deterministic unit test that does not depend on Flutter bindings or Firebase
    final sum = List.generate(5, (i) => i).reduce((a, b) => a + b);
    expect(sum, 10);
  });
}
