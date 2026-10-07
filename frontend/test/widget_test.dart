// Widget-level smoke test for the SmartMove application.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartmove/main.dart';
import 'package:smartmove/models/auth_user.dart';
import 'package:smartmove/providers/auth_provider.dart';

void main() {
  testWidgets('SmartMove requires sign-in when no user is authenticated', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_UnauthenticatedController.new),
        ],
        child: const SmartMoveApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Create a Passenger or Driver account'), findsOneWidget);
    expect(find.text('admin@smartmove.io'), findsNothing);
    expect(find.text('password'), findsNothing);
  });

  testWidgets('public registration cannot select the Admin role', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_UnauthenticatedController.new),
        ],
        child: const SmartMoveApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create a Passenger or Driver account'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Passenger'), findsWidgets);
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
  });
}

class _UnauthenticatedController extends AuthController {
  @override
  Future<AuthUser?> build() async => null;
}
