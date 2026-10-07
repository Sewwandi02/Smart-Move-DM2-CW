// Repository for vehicle data access.
import '../core/network/api_client.dart';
import '../models/entities.dart';

// Abstract contract for all vehicle data sources.
abstract class VehicleRepository {
  Future<List<Vehicle>> list({String? search});
  Future<Vehicle> save(Vehicle vehicle);
  Future<void> delete(String id);
}

class ApiVehicleRepository implements VehicleRepository {
  ApiVehicleRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Vehicle>> list({String? search}) async {
    final response = await _client.dio.get<List<dynamic>>(
      '/vehicles',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final items = response.data;
    if (items == null) {
      throw const FormatException('Vehicle list response was empty.');
    }
    return items
        .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  @override
  Future<Vehicle> save(Vehicle vehicle) async {
    final id = int.tryParse(vehicle.id);
    final response = id == null
        ? await _client.dio.post<Map<String, dynamic>>(
            '/vehicles',
            data: vehicle.toJson(),
          )
        : await _client.dio.put<Map<String, dynamic>>(
            '/vehicles/$id',
            data: vehicle.toJson(),
          );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Vehicle save response was empty.');
    }
    return Vehicle.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    final numericId = int.tryParse(id);
    if (numericId == null) {
      throw ArgumentError.value(id, 'id', 'Must be a numeric Oracle vehicle ID.');
    }
    await _client.dio.delete<void>('/vehicles/$numericId');
  }
}
