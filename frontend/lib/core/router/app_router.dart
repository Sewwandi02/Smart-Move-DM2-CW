import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/entities.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'auth_screens.dart';
import '../theme/app_theme.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) {
    final auth = ref.watch(authProvider);
    final router = GoRouter(
      initialLocation: '/loading',
      redirect: (context, state) {
        final path = state.matchedLocation;
        const publicPaths = {'/login', '/register'};
        if (auth.isLoading || auth.hasError) {
          return path == '/loading' ? null : '/loading';
        }
        final signedIn = auth.valueOrNull != null;
        if (!signedIn && !publicPaths.contains(path)) return '/login';
        if (signedIn && (publicPaths.contains(path) || path == '/loading')) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/loading',
          builder: (context, state) => auth.hasError
              ? AuthRestoreErrorScreen(error: auth.error!)
              : const AuthLoadingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const AppShell(
            title: 'Overview',
            child: DashboardBody(),
          ),
        ),
        GoRoute(
          path: '/:module',
          builder: (context, state) {
            final module = state.pathParameters['module'] ?? 'vehicles';
            return AppShell(
              title: labels[module] ?? 'Not found',
              child: ModuleBody(module: module),
            );
          },
        ),
      ],
    );
    ref.onDispose(router.dispose);
    return router;
  },
);

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final user = ref.watch(authProvider).valueOrNull;
    final items = navigationFor(user?.role ?? 'PASSENGER');

    Widget navigation() => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 24),
              child: Row(
                children: [
                  Icon(Icons.route_rounded, color: AppTheme.teal, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'SmartMove',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            ...items.map(
              (item) => ListTile(
                leading: Icon(item.$2),
                title: Text(item.$3),
                selected: title == item.$3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () => context.go('/${item.$1}'),
              ),
            ),
          ],
        );

    return Scaffold(
      drawer: compact ? Drawer(child: navigation()) : null,
      body: Row(
        children: [
          if (!compact)
            SizedBox(
              width: 230,
              child: ColoredBox(color: Colors.white, child: navigation()),
            ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 78,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      if (compact)
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(Icons.menu),
                          ),
                        ),
                      Text(title, style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      if (user != null) ...[
                        Text(user.name),
                        IconButton(
                          tooltip: 'Sign out',
                          onPressed: () async {
                            await ref.read(authProvider.notifier).logout();
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 16 : 30),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          const Text(
            'Live dashboard metrics are not available because the backend '
            'does not provide a dashboard endpoint yet.',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.go('/vehicles'),
            icon: const Icon(Icons.directions_bus_outlined),
            label: const Text('View vehicles'),
          ),
        ],
      );
}

class ModuleBody extends StatelessWidget {
  const ModuleBody({super.key, required this.module});

  final String module;

  @override
  Widget build(BuildContext context) {
    if (module == 'vehicles') return const VehicleListBody();

    final label = labels[module];
    if (label == null) {
      return const Text('This page does not exist.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text('$label data is not available: this API is not implemented yet.'),
      ],
    );
  }
}

class VehicleListBody extends ConsumerWidget {
  const VehicleListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Vehicles',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            IconButton(
              tooltip: 'Refresh vehicles',
              onPressed: () => ref.invalidate(vehiclesProvider),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Vehicles loaded from the connected backend.'),
        const SizedBox(height: 24),
        vehicles.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Could not load vehicles from the backend.'),
                  const SizedBox(height: 8),
                  SelectableText(error.toString()),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(vehiclesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) => items.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No vehicles found in the database.'),
                  ),
                )
              : Card(
                  child: Column(
                    children: items
                        .map((vehicle) => VehicleTile(vehicle: vehicle))
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class VehicleTile extends StatelessWidget {
  const VehicleTile({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFDDF1EB),
          child: Icon(Icons.directions_bus_outlined, color: AppTheme.teal),
        ),
        title: Text(
          vehicle.plateNumber,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${vehicle.model} · ${vehicle.capacity} seats'),
        trailing: Chip(label: Text(statusLabel(vehicle.status))),
      );
}

String statusLabel(VehicleStatus status) => switch (status) {
      VehicleStatus.active => 'Available',
      VehicleStatus.maintenance => 'Maintenance',
      VehicleStatus.retired => 'Retired',
    };

const labels = {
  'vehicles': 'Vehicles',
  'drivers': 'Drivers',
  'routes': 'Routes',
  'passengers': 'Passengers',
  'trips': 'Trips',
  'bookings': 'Bookings',
  'payments': 'Payments',
  'maintenance': 'Maintenance',
  'reviews': 'Reviews',
  'announcements': 'Announcements',
  'reports': 'Reports',
};

const navigationItems = <(String, IconData, String)>[
  ('dashboard', Icons.grid_view_rounded, 'Overview'),
  ('trips', Icons.calendar_month_outlined, 'Trips'),
  ('bookings', Icons.confirmation_number_outlined, 'Bookings'),
  ('routes', Icons.alt_route, 'Routes'),
  ('vehicles', Icons.directions_bus_outlined, 'Vehicles'),
  ('drivers', Icons.badge_outlined, 'Drivers'),
  ('passengers', Icons.people_outline, 'Passengers'),
  ('payments', Icons.payments_outlined, 'Payments'),
  ('maintenance', Icons.build_outlined, 'Maintenance'),
  ('reviews', Icons.star_border, 'Reviews'),
  ('announcements', Icons.campaign_outlined, 'Announcements'),
  ('reports', Icons.analytics_outlined, 'Reports'),
];

List<(String, IconData, String)> navigationFor(String role) => switch (role) {
      'ADMIN' => navigationItems,
      'DRIVER' => navigationItems
          .where((item) => {'dashboard', 'trips', 'vehicles'}.contains(item.$1))
          .toList(),
      _ => navigationItems
          .where((item) => {'dashboard', 'trips', 'bookings', 'payments'}.contains(item.$1))
          .toList(),
    };
