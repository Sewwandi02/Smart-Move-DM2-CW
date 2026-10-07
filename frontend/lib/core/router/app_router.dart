// Defines the app's routing, authentication state, and dashboard navigation UI.
// This file controls screen transitions, login/session behavior, and the overall
// layout used across the SmartMove operations workspace.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

// Available roles for the app. The role determines which dashboard modules are
// visible and which user profile is shown after login.
enum UserRole { admin, driver, passenger }

// Represents the currently logged-in user session.
class Session { const Session({required this.name, required this.role}); final String name; final UserRole role; }

// Tracks whether a user is currently signed in and stores their display profile.
final sessionProvider = StateProvider<Session?>((ref) => null);

// Central router configuration for the entire app. It protects certain routes and
// forwards users to the login page when no session is active.
final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/login',
  redirect: (context, state) => ref.read(sessionProvider) == null && state.matchedLocation != '/login' ? '/login' : null,
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/:module', builder: (_, state) => ModuleScreen(module: state.pathParameters['module'] ?? 'vehicles')),
  ],
));

class LoginScreen extends ConsumerStatefulWidget { const LoginScreen({super.key}); @override ConsumerState<LoginScreen> createState() => _LoginState(); }
class _LoginState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(text: 'admin@smartmove.io');
  final password = TextEditingController(text: 'password');
  final formKey = GlobalKey<FormState>();
  UserRole role = UserRole.admin;
  @override Widget build(BuildContext context) {
    return Scaffold(body: Row(children: [
      Expanded(flex: 5, child: Container(color: AppTheme.ink, padding: const EdgeInsets.all(56), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.route_rounded, color: Color(0xFF6ED2C4), size: 50), const SizedBox(height: 28),
        Text('Move people\nforward.', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 18),
        Text('One calm workspace for every journey,\nvehicle and passenger.', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFFB7C9C2), height: 1.5)), const SizedBox(height: 46),
        const Text('2,486', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)), const Text('Trips this month', style: TextStyle(color: Color(0xFFB7C9C2))),
      ]))),
      Expanded(flex: 4, child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), const Text('Sign in to your operations workspace.'), const SizedBox(height: 30),
        TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Work email', prefixIcon: Icon(Icons.alternate_email)), validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email'), const SizedBox(height: 14),
        TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)), validator: (v) => v != null && v.length >= 6 ? null : 'At least 6 characters'), const SizedBox(height: 22),
        const Text('Continue as'), const SizedBox(height: 8), Wrap(spacing: 8, children: UserRole.values.map((item) => ChoiceChip(label: Text(item.name), selected: role == item, onSelected: (_) => setState(() => role = item))).toList()), const SizedBox(height: 26),
        SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.arrow_forward), label: const Text('Enter workspace'))), const SizedBox(height: 18), Center(child: TextButton(onPressed: () {}, child: const Text('Create a new account'))),
      ])))))) ,
    ]));
  }
  void _submit() { if (!formKey.currentState!.validate()) return; final name = role == UserRole.admin ? 'Maya Chen' : role == UserRole.driver ? 'Daniel Okafor' : 'Aisha Patel'; ref.read(sessionProvider.notifier).state = Session(name: name, role: role); context.go('/dashboard'); }
}

class DashboardScreen extends ConsumerWidget { const DashboardScreen({super.key}); @override Widget build(BuildContext context, WidgetRef ref) => AppShell(title: 'Overview', child: DashboardBody(role: ref.watch(sessionProvider)?.role ?? UserRole.admin)); }
class ModuleScreen extends ConsumerWidget { const ModuleScreen({super.key, required this.module}); final String module; @override Widget build(BuildContext context, WidgetRef ref) => AppShell(title: labels[module] ?? 'Vehicles', child: ModuleBody(module: module)); }

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.title, required this.child}); final String title; final Widget child;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider); final compact = MediaQuery.sizeOf(context).width < 900; final items = navFor(session?.role ?? UserRole.admin);
    Widget navigation(bool drawer) => ListView(padding: const EdgeInsets.all(16), children: [Padding(padding: const EdgeInsets.only(left: 8, bottom: 24), child: Row(children: [const Icon(Icons.route_rounded, color: AppTheme.teal, size: 30), if (!drawer) ...[const SizedBox(width: 10), const Text('smartmove', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]])), ...items.map((item) => ListTile(leading: Icon(item.$2), title: Text(item.$3), selected: title == item.$3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onTap: () => context.go(item.$1 == 'dashboard' ? '/dashboard' : '/${item.$1}'))), const Divider(height: 24), ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: () { ref.read(sessionProvider.notifier).state = null; context.go('/login'); })]);
    return Scaffold(drawer: compact ? Drawer(child: navigation(false)) : null, body: Row(children: [if (!compact) SizedBox(width: 230, child: ColoredBox(color: Colors.white, child: navigation(false))), Expanded(child: Column(children: [Container(height: 78, color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 28), child: Row(children: [if (compact) Builder(builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.menu))), Text(title, style: Theme.of(context).textTheme.titleLarge), const Spacer(), const Icon(Icons.notifications_none_rounded), const SizedBox(width: 18), CircleAvatar(backgroundColor: const Color(0xFFD5ECE5), child: Text((session?.name ?? 'G')[0])), if (!compact) ...[const SizedBox(width: 10), Text(session?.name ?? 'Guest')]])), Expanded(child: SingleChildScrollView(padding: EdgeInsets.all(compact ? 16 : 30), child: child))]))]));
  }
}

class DashboardBody extends StatelessWidget { const DashboardBody({super.key, required this.role}); final UserRole role;
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good morning, ${role == UserRole.admin ? 'Maya' : role == UserRole.driver ? 'Daniel' : 'Aisha'}', style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 8), const Text('Here is what is moving across your network today.'), const SizedBox(height: 28), GridView.count(crossAxisCount: MediaQuery.sizeOf(context).width > 1100 ? 4 : 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.8, children: const [Kpi(label: 'Active trips', value: '38', delta: '+12%', icon: Icons.directions_bus), Kpi(label: 'Ticket revenue', value: '€24,680', delta: '+8.4%', icon: Icons.payments_outlined), Kpi(label: 'Passengers', value: '1,284', delta: '+6.2%', icon: Icons.people_outline), Kpi(label: 'Fleet health', value: '94%', delta: 'On track', icon: Icons.eco_outlined)]), const SizedBox(height: 22), LayoutBuilder(builder: (context, c) => Flex(direction: c.maxWidth > 760 ? Axis.horizontal : Axis.vertical, children: [Expanded(flex: 3, child: ChartCard(title: 'Revenue pulse', subtitle: 'Last 7 days', child: SizedBox(height: 220, child: LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(isCurved: true, color: AppTheme.teal, barWidth: 4, dotData: const FlDotData(show: false), spots: const [FlSpot(0, 3), FlSpot(1, 5), FlSpot(2, 4), FlSpot(3, 8), FlSpot(4, 7), FlSpot(5, 10), FlSpot(6, 12)])]))))), const SizedBox(width: 18, height: 18), Expanded(flex: 2, child: ChartCard(title: 'Most used routes', subtitle: 'This month', child: SizedBox(height: 220, child: BarChart(BarChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), barGroups: [0, 1, 2, 3].map((i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: [8, 6, 10, 5][i].toDouble(), color: i == 2 ? AppTheme.coral : AppTheme.teal, width: 18)])).toList()))))) ])), const SizedBox(height: 22), const ChartCard(title: "Today's movement", subtitle: 'Live trip activity', child: Column(children: [TripRow(code: 'SM-204', route: 'Central Station → Airport', time: '08:40', status: 'On route'), TripRow(code: 'SM-219', route: 'North Park → Riverside', time: '09:15', status: 'Boarding'), TripRow(code: 'SM-231', route: 'Old Town → Central Station', time: '10:05', status: 'Scheduled')]))]);
}

class ModuleBody extends StatelessWidget { const ModuleBody({super.key, required this.module}); final String module;
  @override Widget build(BuildContext context) { final data = moduleData[module] ?? moduleData['vehicles']!; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.$1, style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 8), Text(data.$2)])), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: Text('Add ${data.$1.substring(0, data.$1.length - 1)}'))]), const SizedBox(height: 24), Row(children: [Expanded(child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search ${data.$1.toLowerCase()}'))), const SizedBox(width: 12), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list), label: const Text('Filter'))]), const SizedBox(height: 18), Card(child: Column(children: data.$3.map((item) => ListTile(leading: CircleAvatar(backgroundColor: item.$3 == 'Active' ? const Color(0xFFDDF1EB) : const Color(0xFFFFE4DA), child: Icon(data.$4, color: item.$3 == 'Active' ? AppTheme.teal : AppTheme.coral)), title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(item.$2), trailing: Chip(label: Text(item.$3)))).toList()))]); }
}
class Kpi extends StatelessWidget { const Kpi({super.key, required this.label, required this.value, required this.delta, required this.icon}); final String label, value, delta; final IconData icon; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: AppTheme.teal), const Spacer(), Text(delta, style: const TextStyle(color: AppTheme.teal))]), const Spacer(), Text(value, style: Theme.of(context).textTheme.headlineMedium), Text(label)]))); }
class ChartCard extends StatelessWidget { const ChartCard({super.key, required this.title, required this.subtitle, required this.child}); final String title, subtitle; final Widget child; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4), Text(subtitle), const SizedBox(height: 16), child]))); }
class TripRow extends StatelessWidget { const TripRow({super.key, required this.code, required this.route, required this.time, required this.status}); final String code, route, time, status; @override Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.directions_bus_outlined, color: AppTheme.teal), title: Text(route), subtitle: Text('$code  •  $time'), trailing: Text(status, style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w700))); }

const labels = {'dashboard': 'Overview', 'vehicles': 'Vehicles', 'drivers': 'Drivers', 'routes': 'Routes', 'passengers': 'Passengers', 'trips': 'Trips', 'bookings': 'Bookings', 'payments': 'Payments', 'maintenance': 'Maintenance', 'reviews': 'Reviews', 'announcements': 'Announcements', 'reports': 'Reports'};
List<(String, IconData, String)> navFor(UserRole role) { final list = <(String, IconData, String)>[('dashboard', Icons.grid_view_rounded, 'Overview'), ('trips', Icons.calendar_month_outlined, 'Trips'), ('bookings', Icons.confirmation_number_outlined, 'Bookings'), ('routes', Icons.alt_route, 'Routes'), ('vehicles', Icons.directions_bus_outlined, 'Vehicles'), ('drivers', Icons.badge_outlined, 'Drivers')]; if (role == UserRole.admin) list.addAll([('passengers', Icons.people_outline, 'Passengers'), ('maintenance', Icons.build_outlined, 'Maintenance'), ('reviews', Icons.star_border, 'Reviews'), ('announcements', Icons.campaign_outlined, 'Announcements'), ('reports', Icons.analytics_outlined, 'Reports')]); if (role == UserRole.passenger) list.addAll([('payments', Icons.payments_outlined, 'Payments'), ('reviews', Icons.star_border, 'Reviews'), ('announcements', Icons.campaign_outlined, 'Announcements')]); return list; }
final moduleData = <String, (String, String, List<(String, String, String)>, IconData)>{
 'vehicles': ('Vehicles', 'Keep your fleet ready for every departure.', [('SM-042 · Volvo 9700', '48 seats · Last service 12 Aug', 'Active'), ('SM-018 · Mercedes Sprinter', '16 seats · Service due in 4 days', 'Maintenance'), ('SM-031 · Iveco Daily', '22 seats · Last service 28 Jul', 'Active')], Icons.directions_bus_outlined),
 'drivers': ('Drivers', 'People who keep every trip moving.', [('Daniel Okafor', 'License D · 4 assigned trips', 'Available'), ('Sofia Marin', 'License D · 2 assigned trips', 'On trip'), ('Jon Bell', 'License D · Renewal 20 Sep', 'Available')], Icons.person_outline),
 'routes': ('Routes', 'Manage stops, fares and network performance.', [('R-01 · Central Station → Airport', '18 km · €4.50 · 12 stops', 'Popular'), ('R-07 · North Park → Riverside', '11 km · €3.20 · 8 stops', 'Active'), ('R-12 · Old Town → University', '7 km · €2.80 · 5 stops', 'Active')], Icons.alt_route),
 'passengers': ('Passengers', 'Search profiles and travel history.', [('Aisha Patel', 'aisha@example.com · 12 trips', 'Verified'), ('Marco Ruiz', 'marco@example.com · 8 trips', 'Verified'), ('Nora Williams', 'nora@example.com · 3 trips', 'New')], Icons.person_outline),
 'trips': ('Trips', 'Schedule, assign and monitor every journey.', [('SM-204 · Central Station → Airport', 'Today, 08:40 · Volvo 9700', 'On route'), ('SM-219 · North Park → Riverside', 'Today, 09:15 · Sprinter', 'Boarding'), ('SM-231 · Old Town → Central Station', 'Today, 10:05 · Volvo 9700', 'Scheduled')], Icons.calendar_month_outlined),
 'bookings': ('Bookings', 'Search trips and manage passenger tickets.', [('BK-20481 · Aisha Patel', 'Central Station → Airport · Seat 12', 'Confirmed'), ('BK-20479 · Marco Ruiz', 'North Park → Riverside · Seat 04', 'Confirmed'), ('BK-20470 · Nora Williams', 'Old Town → University · Seat 08', 'Refunded')], Icons.confirmation_number_outlined),
 'payments': ('Payments', 'Track gateway transactions tied to bookings.', [('TX-9381 · BK-20481', 'Aisha Patel · 12 Aug 2026', '€4.50 Paid'), ('TX-9378 · BK-20479', 'Marco Ruiz · 12 Aug 2026', '€3.20 Paid'), ('TX-9360 · BK-20470', 'Nora Williams · 11 Aug 2026', '€2.80 Refunded')], Icons.payments_outlined),
 'maintenance': ('Maintenance', 'Keep vehicles safe and scheduling honest.', [('SM-018 · Brake inspection', '14 Aug 2026 · €420 · Workshop A', 'Scheduled'), ('SM-042 · Oil change', '12 Aug 2026 · €180 · Complete', 'Complete'), ('SM-031 · Tire replacement', '22 Aug 2026 · €680 · Workshop B', 'Scheduled')], Icons.build_outlined),
 'reviews': ('Reviews', 'Listen to the people riding with you.', [('R-01 · 4.9 average', '284 reviews · Most used route', 'Top rated'), ('SM-042 · 4.8 average', '96 reviews · Volvo 9700', 'Excellent'), ('Daniel Okafor · 4.9', '118 reviews · Driver', 'Excellent')], Icons.star_border),
 'announcements': ('Announcements', 'Keep passengers and teams informed.', [('Summer timetable update', 'Published 12 Aug · Passenger feed', 'Published'), ('Platform 3 moving to Platform 5', 'Published 10 Aug · Central Station', 'Published'), ('Maintenance window', 'Draft · Internal team', 'Draft')], Icons.campaign_outlined),
 'reports': ('Reports', 'Turn movement data into clearer decisions.', [('Most-used routes', 'R-01 leads with 1,284 passengers', 'View chart'), ('Revenue over time', '€24,680 collected this month', 'View chart'), ('Passenger travel history', 'Searchable booking activity', 'Open table')], Icons.analytics_outlined),
};
