# SmartMove

SmartMove is organized as a multi-part project:

```text
SmartMove/
|-- frontend/             Flutter web application
|-- backend/              Spring Boot REST API
|-- database/
|   `-- oracle/           Oracle schema and query scripts
`-- README.md
```

## Frontend

The Flutter application lives in `frontend/`.

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

The frontend reads vehicle data from the backend. The backend currently
implements vehicle CRUD at `/api/v1/vehicles`; other API modules remain
unimplemented.

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

## Authentication

The API uses stateless JWT authentication. Sign-in is for accounts already in
Oracle. Public registration creates only Passenger or Driver accounts; the
registrant chooses between those two roles, and a Driver must supply a license.
Admin accounts must be created manually in Oracle and cannot be requested
through registration. Vehicle changes (create, update, delete) require Admin;
reading vehicles requires a signed-in account.

Add a private JWT signing secret of at least 32 random bytes to the ignored local
`backend/src/main/resources/application.properties` file:

```properties
app.jwt.secret=<a unique random secret of at least 32 bytes>
app.jwt.expiration-ms=3600000
```

Do not commit this secret or use an example/default value. Use your PL/SQL setup
in `database/oracle/setup_auth_roles.sql` to add `ADMIN`, `DRIVER`, and
`PASSENGER` rows to Oracle's `ROLE` table before registering accounts. The
script is safe to rerun and is not run automatically by the backend. Existing
manually-created admin accounts must have a BCrypt password hash in
`APP_USER.PASSWORD` (never a plain-text password), a matching `USER_ROLE`
assignment, and an `ADMIN` row referencing the same user.

To generate a BCrypt hash for the manually provisioned admin password, build
the backend and run the helper from the `backend` directory in PowerShell:

```powershell
mvn -DskipTests package
mvn dependency:build-classpath "-Dmdep.outputFile=target\dependency-classpath.txt"
$classpath = "target\classes;" + (Get-Content target\dependency-classpath.txt -Raw).Trim()
java -cp $classpath com.smartmove.auth.PasswordHashTool
```

Enter the password at the prompt and use the printed hash in your manual Oracle
setup. The helper does not insert users or print the password. Use HTTPS and
protect the signing secret before exposing the API beyond local development.

The backend maps its vehicle entity to the finalized `Vehicle` table:
`vehicle_id`, `reg_no`, `vehicle_type`, `capacity`, `status`, and `admin_id`.
Oracle generates the numeric vehicle ID. Hibernate is configured to validate the
schema only; it does not create or alter database objects. Since your database
already exists, do not run the schema script against it.

Start the API with:

```powershell
cd backend
mvn spring-boot:run
```

The API listens on `http://localhost:8080/api/v1`. Vehicle request JSON uses
`regNo`, `vehicleType`, `capacity`, `status`, and `adminId`; the database
generates the vehicle ID.

## Oracle scripts

`database/oracle/schema.sql` records the provided finalized schema.
`database/oracle/queries/vehicles.sql` contains parameterized examples for vehicle
operations. No sample records are included or inserted automatically.

## Set up this project on another machine

Follow these steps for a fresh development machine. Keep the **Oracle database
schema account** separate from the app's **Admin account**: the schema account
owns the tables and is used by Spring Boot to connect; the Admin account is an
application user stored in `APP_USER`.

### 1. Install the tools

Install and verify:

- Oracle Database (or access to an Oracle server), plus SQL Developer or SQL*Plus.
- Java 17 or newer and Maven.
- Flutter and a supported browser such as Chrome.

Make sure the Oracle listener is running and note the database host, listener
port, and SID or service name.

### 2. Create or select the Oracle schema account

Ask the Oracle DBA to create a dedicated database user for SmartMove, or use an
existing dedicated schema account. This is **not** the app Admin login and
should not be `SYS`. The account needs permission to connect and create/use the
SmartMove tables (including sufficient tablespace quota) if it will own a new
schema. Do not put this account's password in a committed file.

### 3. Create the tables only for a new, empty schema

In SQL Developer, connect as the dedicated SmartMove schema account. Open
`database/oracle/schema.sql` and run the whole file with **F5**. It creates the
tables for a new schema. Do not run it against an existing SmartMove database:
the DDL is not an upgrade script and will fail if those tables already exist.

### 4. Create the application roles

Still connected as the SmartMove schema account, open
`database/oracle/setup_auth_roles.sql` and run the whole file with **F5**. This
PL/SQL script adds missing `ADMIN`, `DRIVER`, and `PASSENGER` role rows, then
commits. It does not create users. It is safe to run again.

### 5. Provision the first application Admin

Create the first Admin manually in Oracle after the tables and roles exist. The
Admin setup must:

1. Insert a row into `APP_USER` using a BCrypt password hash, not a plain-text
   password.
2. Link that user's `USER_ID` to the `ADMIN` role in `USER_ROLE`.
3. Insert the same `USER_ID` into `ADMIN`.

To generate the BCrypt hash, use the `PasswordHashTool` commands in the
Authentication section above from the `backend` directory. Run the helper in an
interactive terminal; it prompts without echoing the password and prints only
the hash. Use the intended email consistently when inserting the account and
when signing in. Public registration cannot create Admin accounts.

### 6. Configure the backend locally

From the project root, copy the example configuration:

```powershell
Copy-Item backend\src\main\resources\application.properties.example `
  backend\src\main\resources\application.properties
```

Open the new, Git-ignored `application.properties`. Set the database URL,
schema username, and schema password to the values for the Oracle connection.
Use the SID syntax `jdbc:oracle:thin:@HOST:PORT:SID` or service syntax
`jdbc:oracle:thin:@//HOST:PORT/SERVICE_NAME`. Replace the datasource placeholder
lines in the example with those actual local settings.

Set `app.jwt.secret` to a newly generated random secret of at least 32 bytes.
For example, generate a Base64 secret in PowerShell (do not commit its output):

```powershell
$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
$jwtSecret = [Convert]::ToBase64String($bytes)
[Array]::Clear($bytes, 0, $bytes.Length)
$jwtSecret
```

Put that output in the local properties file:

```properties
app.jwt.secret=<paste the generated secret here>
app.jwt.expiration-ms=3600000
```

Never commit `application.properties`, a real database password, or the JWT
secret. The example file contains placeholders only.

### 7. Start the application

In one PowerShell window:

```powershell
cd backend
mvn spring-boot:run
```

After the backend starts, in a second window:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

Sign in with the Admin account provisioned in step 5, or register as Passenger
or Driver. The first Admin must exist before Admin sign-in; vehicle create,
update, and delete actions require that role.
