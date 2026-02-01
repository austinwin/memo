// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app/app.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/data/local/app_db.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    final db = AppDb.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDbProvider.overrideWithValue(db)],
        child: const MobileApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Entries'), findsOneWidget);

    // Clean shutdown: dispose widgets, then flush microtasks/timers used by drift
    // when streams are canceled.
    await db.close();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
