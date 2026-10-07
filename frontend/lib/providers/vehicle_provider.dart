// Exposes vehicle data through Riverpod providers.
// This keeps the repository behind an abstraction so the app can request
// vehicles without depending directly on a concrete implementation.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/vehicle_repository.dart';

// Provides the current vehicle repository instance to the app.
// At the moment it points to the mock repository, which is useful for demo data.
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) => MockVehicleRepository());

// Loads the list of vehicles as an async provider so screens can watch it.
final vehiclesProvider = FutureProvider((ref) => ref.watch(vehicleRepositoryProvider).list());
