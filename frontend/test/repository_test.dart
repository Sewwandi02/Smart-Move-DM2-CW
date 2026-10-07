// Verifies vehicle JSON mapping between the app and backend.
import 'package:flutter_test/flutter_test.dart';
import 'package:smartmove/models/entities.dart';
void main() {
  test('vehicle JSON maps Oracle API fields and statuses', () {
    final vehicle = Vehicle.fromJson({
      'id': 42,
      'regNo': 'SM-042',
      'vehicleType': 'Volvo 9700',
      'capacity': 48,
      'status': 'Available',
      'adminId': 7,
    });

    expect(vehicle.id, '42');
    expect(vehicle.plateNumber, 'SM-042');
    expect(vehicle.model, 'Volvo 9700');
    expect(vehicle.capacity, 48);
    expect(vehicle.status, VehicleStatus.active);
    expect(vehicle.adminId, 7);
    expect(vehicle.toJson(), {
      'regNo': 'SM-042',
      'vehicleType': 'Volvo 9700',
      'capacity': 48,
      'status': 'Available',
      'adminId': 7,
    });
  });
}
