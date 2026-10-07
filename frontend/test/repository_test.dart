// Verifies the mock vehicle repository behaves like the application expects.
// This ensures filtering and persistence logic continue to work as the data layer evolves.
import 'package:flutter_test/flutter_test.dart';
import 'package:smartmove/models/entities.dart';
import 'package:smartmove/repositories/vehicle_repository.dart';

void main() {
  test('mock vehicle repository filters and persists records', () async {
    final repository = MockVehicleRepository();
    expect((await repository.list(search: 'Volvo')).single.model, 'Volvo 9700');
    await repository.save(const Vehicle(id: 'SM-100', plateNumber: 'SM-100', model: 'Iveco', capacity: 22, status: VehicleStatus.active));
    expect((await repository.list()).length, 3);
  });
}
