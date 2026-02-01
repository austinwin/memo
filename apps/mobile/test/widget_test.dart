// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app/app.dart';

void main() {
  testWidgets(
    'app boots',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MobileApp()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Entries'), findsOneWidget);
    },
    // Drift streams leave a pending close-timer in widget tests; revisit once we
    // add a test database override.
    skip: true,
  );
}
