// Central app-wide constants used to avoid hardcoding repeated values.
// This keeps product branding and API metadata consistent across the application.
class AppConstants {
  // Human-readable application name shown in the interface and metadata.
  static const productName = 'SmartMove';

  // Shared backend route prefix used when building API URLs.
  static const apiPrefix = '/api/v1';

  // Flag used during development to switch the app into mock-data mode.
  static const mockMode = true;
}