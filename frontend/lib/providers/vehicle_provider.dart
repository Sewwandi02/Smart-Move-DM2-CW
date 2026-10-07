// Exposes vehicle data through Riverpod providers.
// This keeps the repository behind an abstraction so the app can request
// vehicles without depending directly on a concrete implementation.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../repositories/vehicle_repository.dart';

final vehicleRepositoryProvider =
    Provider<VehicleRepository>((ref) => ApiVehicleRepository(ref.watch(apiClientProvider)));

// Loads the list of vehicles as an async provider so screens can watch it.
final vehiclesProvider = FutureProvider((ref) => ref.watch(vehicleRepositoryProvider).list());
