// Generic repository layer for the app's domain modules.
// This file provides a reusable CRUD contract and mock/API implementations that
// can be reused for drivers, routes, passengers, trips, bookings and reports.
abstract class CrudRepository<T> {
  Future<List<T>> list({String? search});
  Future<T> save(T value);
  Future<void> delete(String id);
}

// A simple in-memory implementation for testing and local demo states.
class MockCrudRepository<T> implements CrudRepository<T> {
  MockCrudRepository(this.items);
  final List<T> items;

  @override
  Future<List<T>> list({String? search}) async => List.unmodifiable(items);

  @override
  Future<T> save(T value) async {
    items.add(value);
    return value;
  }

  @override
  Future<void> delete(String id) async {}
}

// API-backed repository placeholder for real backend integration.
class ApiCrudRepository<T> implements CrudRepository<T> {
  ApiCrudRepository(this.endpoint);
  final String endpoint;

  @override
  Future<List<T>> list({String? search}) async => throw UnimplementedError('Connect GET $endpoint');

  @override
  Future<T> save(T value) async => throw UnimplementedError('Connect POST/PUT $endpoint');

  @override
  Future<void> delete(String id) async => throw UnimplementedError('Connect DELETE $endpoint/{id}');
}

// Concrete repositories for each domain area. These classes act as typed
// entry points to the backend or local mock data for the corresponding module.
class DriverRepository extends ApiCrudRepository<Map<String, dynamic>> { DriverRepository() : super('/drivers'); }
class MockDriverRepository extends MockCrudRepository<Map<String, dynamic>> { MockDriverRepository() : super([]); }
class RouteRepository extends ApiCrudRepository<Map<String, dynamic>> { RouteRepository() : super('/routes'); }
class MockRouteRepository extends MockCrudRepository<Map<String, dynamic>> { MockRouteRepository() : super([]); }
class PassengerRepository extends ApiCrudRepository<Map<String, dynamic>> { PassengerRepository() : super('/passengers'); }
class MockPassengerRepository extends MockCrudRepository<Map<String, dynamic>> { MockPassengerRepository() : super([]); }
class TripRepository extends ApiCrudRepository<Map<String, dynamic>> { TripRepository() : super('/trips'); }
class MockTripRepository extends MockCrudRepository<Map<String, dynamic>> { MockTripRepository() : super([]); }
class BookingRepository extends ApiCrudRepository<Map<String, dynamic>> { BookingRepository() : super('/bookings'); }
class MockBookingRepository extends MockCrudRepository<Map<String, dynamic>> { MockBookingRepository() : super([]); }
class PaymentRepository extends ApiCrudRepository<Map<String, dynamic>> { PaymentRepository() : super('/payments'); }
class MockPaymentRepository extends MockCrudRepository<Map<String, dynamic>> { MockPaymentRepository() : super([]); }
class MaintenanceRepository extends ApiCrudRepository<Map<String, dynamic>> { MaintenanceRepository() : super('/maintenance'); }
class MockMaintenanceRepository extends MockCrudRepository<Map<String, dynamic>> { MockMaintenanceRepository() : super([]); }
class ReviewRepository extends ApiCrudRepository<Map<String, dynamic>> { ReviewRepository() : super('/reviews'); }
class MockReviewRepository extends MockCrudRepository<Map<String, dynamic>> { MockReviewRepository() : super([]); }
class AnnouncementRepository extends ApiCrudRepository<Map<String, dynamic>> { AnnouncementRepository() : super('/announcements'); }
class MockAnnouncementRepository extends MockCrudRepository<Map<String, dynamic>> { MockAnnouncementRepository() : super([]); }
class ReportRepository extends ApiCrudRepository<Map<String, dynamic>> { ReportRepository() : super('/reports'); }
class MockReportRepository extends MockCrudRepository<Map<String, dynamic>> { MockReportRepository() : super([]); }
