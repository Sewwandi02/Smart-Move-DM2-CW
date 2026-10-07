// Entry point for the SmartMove application.
// This file boots the Flutter app, wraps it in Riverpod for state management,
// and configures the app-level router and custom theme before rendering the UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// The app launcher. It registers the provider scope so all screens can access
// shared state and then starts the root SmartMoveApp widget.
void main() => runApp(const ProviderScope(child: SmartMoveApp()));

// Root application widget. It creates the MaterialApp with the custom theme and
// sets up navigation using GoRouter so page transitions are handled centrally.
class SmartMoveApp extends ConsumerWidget {
  const SmartMoveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'SmartMove Transport Solutions',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: ref.watch(appRouterProvider),
      );
}
