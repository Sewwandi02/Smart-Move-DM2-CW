# SmartMove

SmartMove is organized as a multi-part project:

```text
SmartMove/
|-- frontend/             Flutter web application
|-- backend/              Spring Boot REST API
|-- database/
|   `-- oracle/           Oracle schema, seed data, and query scripts
`-- README.md
```

## Frontend

The Flutter application lives in `frontend/`.

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

The UI currently uses mock repositories by default. `frontend/lib/core/network/api_config.dart`
contains the API base URL and mock-data switch. The backend currently implements
vehicle CRUD at `/api/v1/vehicles`; other API modules remain documented contracts
and are not implemented in this initial backend.

## Spring Boot backend

The backend is a Java 17+ Spring Boot application in `backend/`. It implements
vehicle list/search, create, read, update, and delete endpoints using Spring Data
JPA and Oracle.

Set the Oracle connection values in the environment before starting the backend:
the JDBC URL must match your database's connection details. For a SID connection,
use `jdbc:oracle:thin:@HOST:PORT:SID`; for a service name, use
`jdbc:oracle:thin:@//HOST:PORT/SERVICE_NAME`.

```powershell
$env:ORACLE_URL = "jdbc:oracle:thin:@//localhost:1521/FREEPDB1"
$env:ORACLE_USERNAME = "your_schema"
$env:ORACLE_PASSWORD = "your_password"
```

`backend/src/main/resources/application.properties` is for local configuration
and is excluded from Git because it may contain credentials. The tracked
`application.properties.example` shows the expected settings; copy it to
`application.properties` when setting up a fresh checkout. Keep real credentials
out of the example file and out of commits.

The backend maps its vehicle entity to the finalized `Vehicle` table:
`vehicle_id`, `reg_no`, `vehicle_type`, `capacity`, `status`, and `admin_id`.
Oracle generates the numeric vehicle ID. Hibernate is configured to validate the
schema only; it does not create or alter database objects. Since your database
already exists, do not run the schema or seed scripts against it. `database/oracle/schema.sql`
is a reference copy of the finalized DDL, and `database/oracle/seed.sql` is only
for an empty development schema.

Start the API with:

```powershell
cd backend
mvn spring-boot:run
```

The API listens on `http://localhost:8080/api/v1`. Vehicle requests use the
schema's column concepts in JSON, for example:

```json
{
  "regNo": "SM-042",
  "vehicleType": "Volvo 9700",
  "capacity": 48,
  "status": "Available",
  "adminId": null
}
```

## Oracle scripts

`database/oracle/schema.sql` records the provided finalized schema.
`database/oracle/queries/vehicles.sql` contains parameterized examples for vehicle
operations. Use `database/oracle/seed.sql` only if you want sample vehicle rows in
a fresh development schema.
