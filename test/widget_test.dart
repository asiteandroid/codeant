// Smoke test — verifies the app boots without crashing.
// More detailed tests live in test/unit/ and test/widget/.

import 'package:flutter_test/flutter_test.dart';

import 'package:codeant/main.dart';

void main() {
  testWidgets('App builds and shows Task Manager title', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    await tester.pump(); // allow first frame

    expect(find.text('Task Manager'), findsOneWidget);
  });
}
