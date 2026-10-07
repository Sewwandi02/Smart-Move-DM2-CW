// Repository for vehicle data access.
// It defines the contract for retrieving and mutating vehicles while providing a
// mock implementation for local development and a placeholder for real API use.
import '../models/entities.dart';

// Abstract contract for all vehicle data sources.
abstract class VehicleRepository {
  Future<List<Vehicle>> list({String? search});
  Future<Vehicle> save(Vehicle vehicle);
  Future<void> delete(String id);
}

// In-memory vehicle repository used for local testing and demo screens.
class MockVehicleRepository implements VehicleRepository {
  final List<Vehicle> _items = [
    const Vehicle(id: 'SM-042', plateNumber: 'SM-042', model: 'Volvo 9700', capacity: 48, status: VehicleStatus.active),
    const Vehicle(id: 'SM-018', plateNumber: 'SM-018', model: 'Mercedes Sprinter', capacity: 16, status: VehicleStatus.maintenance),
  ];

  @override
  Future<List<Vehicle>> list({String? search}) async =>
      search == null || search.isEmpty
          ? List.unmodifiable(_items)
          : _items.where((item) => item.model.toLowerCase().contains(search.toLowerCase())).toList();

  @override
  Future<Vehicle> save(Vehicle vehicle) async {
    _items.removeWhere((item) => item.id == vehicle.id);
    _items.add(vehicle);
    return vehicle;
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((item) => item.id == id);
}

// Placeholder repository for connecting to the live backend using ApiClient.
class ApiVehicleRepository implements VehicleRepository {
  @override
  Future<List<Vehicle>> list({String? search}) async => throw UnimplementedError('Connect GET /vehicles through ApiClient');

  @override
  Future<Vehicle> save(Vehicle vehicle) async => throw UnimplementedError('Connect POST/PUT /vehicles through ApiClient');

  @override
  Future<void> delete(String id) async => throw UnimplementedError('Connect DELETE /vehicles/{id} through ApiClient');
}
