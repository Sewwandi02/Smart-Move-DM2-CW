// Stores the server configuration for the app.
// These values act as the base settings for all backend communication and help
// switch between live and mocked environments during development.
class ApiConfig {
  // Base URL for the backend API. All endpoint routes are appended to this value.
  static const baseUrl = 'http://localhost:8080/api/v1';

  // Indicates whether sample or mock data should be used instead of live API calls.
  static const useMockData = true;
}