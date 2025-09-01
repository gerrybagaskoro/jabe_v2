class Endpoint {
  static const String baseUrl = "http://applaporan.mobileprojp.com/api";

  // Authentication endpoints
  static String get register => "$baseUrl/register";
  static String get login => "$baseUrl/login";
  static String get logout => "$baseUrl/logout";

  // Report endpoints
  static String get reports => "$baseUrl/reports";
  static String getReportById(int id) => "$baseUrl/reports/$id";
  static String updateReport(int id) => "$baseUrl/reports/$id";
  static String deleteReport(int id) => "$baseUrl/reports/$id";
  static String get reportStatistics => "$baseUrl/statistik";
}
