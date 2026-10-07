// Documents the expected REST contract for the SmartMove backend.
// These endpoint definitions are not HTTP calls themselves; they act as a
// developer-facing contract to show the request and response shape for each API.
/// Assumed Spring Boot contract for backend confirmation.
class ApiEndpoints {
  // Authentication operations for login, registration, logout and current-user checks.
  static const auth = {'POST /auth/login': '{email,password} -> {token,user}', 'POST /auth/register': '{name,email,password,role} -> user', 'POST /auth/logout': '{} -> message', 'GET /auth/me': '-> user'};

  // Vehicle management endpoints for fleet listing, creation, updating and media upload.
  static const vehicles = {'GET /vehicles': '?search&status -> [vehicle]', 'POST /vehicles': '{plateNumber,model,capacity,status} -> vehicle', 'GET /vehicles/{id}': '-> {vehicle,images[],documents[]}', 'PUT /vehicles/{id}': '{vehicle} -> vehicle', 'DELETE /vehicles/{id}': '-> message', 'POST /vehicles/{id}/media': 'multipart file -> media'};

  // Driver operations for roster lookup and assignment changes.
  static const drivers = {'GET /drivers': '?search -> [driver]', 'POST /drivers': '{name,phone,licenseNumber,licenseExpiry} -> driver', 'GET /drivers/{id}': '-> {driver,trips[],averageRating}', 'PUT /drivers/{id}': '{driver} -> driver', 'DELETE /drivers/{id}': '-> message', 'PATCH /drivers/{id}/assignments': '{vehicleId,routeId,tripId} -> driver'};

  // Route definitions and route-level analytics.
  static const routes = {'GET /routes': '?search -> [route]', 'POST /routes': '{origin,destination,stops[],distance,fare} -> route', 'GET /routes/{id}': '-> {route,reviews[],mostUsedCount}', 'PUT /routes/{id}': '{route} -> route', 'DELETE /routes/{id}': '-> message'};

  // Passenger CRUD and travel history endpoints.
  static const passengers = {'GET /passengers': '?search -> [passenger]', 'GET /passengers/{id}': '-> {passenger,bookings[]}', 'GET /passengers/me/history': '-> [booking]', 'PUT /passengers/me': '{name,phone} -> passenger'};

  // Trip scheduling and status updates.
  static const trips = {'GET /trips': '?from&to&status -> [trip]', 'POST /trips': '{vehicleId,driverId,routeId,departure,capacity} -> trip', 'PUT /trips/{id}': '{trip} -> trip', 'DELETE /trips/{id}': '-> message', 'PATCH /trips/{id}/status': '{status} -> trip'};

  // Booking search, reservation creation and cancellation flow.
  static const bookings = {'GET /bookings/search': '?origin&destination&date -> [trip]', 'POST /bookings': '{tripId,seatNumber} -> {booking,payment}', 'GET /bookings': '-> [booking]', 'GET /bookings/{id}': '-> {booking,qrCode}', 'PATCH /bookings/{id}/cancel': '-> {booking,refund}'};

  // Payment processing endpoints used for transaction records.
  static const payments = {'POST /payments': '{bookingId,cardToken,amount} -> transaction', 'GET /payments': '?mine -> [transaction]', 'GET /payments/{id}': '-> transaction'};

  // Maintenance events for scheduled repairs and inspections.
  static const maintenance = {'GET /maintenance': '?vehicleId -> [record]', 'POST /maintenance': '{vehicleId,date,type,cost,notes} -> record', 'PUT /maintenance/{id}': '{record} -> record', 'DELETE /maintenance/{id}': '-> message'};

  // Review collection and leaderboard summaries.
  static const reviews = {'GET /reviews': '?entityType&entityId&keyword -> [review]', 'POST /reviews': '{tripId,rating,comment} -> review', 'GET /reviews/leaderboard': '-> [{entity,averageRating}]'};

  // Staff and passenger announcement content management.
  static const announcements = {'GET /announcements': '-> [announcement]', 'POST /announcements': '{title,body,publishedAt} -> announcement', 'PUT /announcements/{id}': '{announcement} -> announcement', 'DELETE /announcements/{id}': '-> message'};

  // Report endpoints for operational analytics and performance summaries.
  static const reports = {'GET /reports/most-used-routes': '?from&to -> [{route,count}]', 'GET /reports/revenue': '?from&to -> [{date,amount}]', 'GET /reports/passenger-history': '?search&from&to -> [booking]'};

  // Aggregates all domain contracts into a single dictionary keyed by module name.
  static const all = <String, Map<String, String>>{'Auth': auth, 'Vehicles': vehicles, 'Drivers': drivers, 'Routes': routes, 'Passengers': passengers, 'Trips': trips, 'Bookings': bookings, 'Payments': payments, 'Maintenance': maintenance, 'Reviews': reviews, 'Announcements': announcements, 'Reports': reports};
}