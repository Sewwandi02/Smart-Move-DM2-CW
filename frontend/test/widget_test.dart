// Widget-level smoke test for the SmartMove entry screen.
// This test confirms the app boots and renders the expected sign-in UI.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartmove/main.dart';

void main() {
  testWidgets('SmartMove shows the sign-in workspace', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartMoveApp()));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Enter workspace'), findsOneWidget);
  });
}
