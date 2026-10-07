// Defines the core domain objects used by the vehicle, route, and trip flows.
// These immutable model classes represent the business entities the app works
// with across repositories, providers, and screens.
enum VehicleStatus { active, maintenance, retired }
enum TripStatus { scheduled, ongoing, completed, cancelled }

// Represents a vehicle in the fleet and its operational state.
class Vehicle {
  const Vehicle({required this.id, required this.plateNumber, required this.model, required this.capacity, required this.status});

  final String id;
  final String plateNumber;
  final String model;
  final int capacity;
  final VehicleStatus status;
}

// Represents a route between two locations, including its stops and fare.
class RouteModel {
  const RouteModel({required this.id, required this.origin, required this.destination, required this.stops, required this.distance, required this.fare});

  final String id, origin, destination;
  final List<String> stops;
  final double distance, fare;
}

// Represents a scheduled trip with route details and operating status.
class Trip {
  const Trip({required this.id, required this.route, required this.departure, required this.status, required this.capacity});

  final String id, route, departure;
  final TripStatus status;
  final int capacity;
}
