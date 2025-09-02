class Endpoint {
  static const String baseUrl = "http://applaporan.mobileprojp.com/api";

  // Authentication endpoints
  static String get register => "$baseUrl/register";
  static String get login => "$baseUrl/login";
  static String get logout => "$baseUrl/logout";

  // Report endpoints
  static String get reports => "$baseUrl/laporan";
  static String getReportById(int id) => "$baseUrl/laporan/$id";
  static String updateReport(int id) => "$baseUrl/laporan/$id";
  static String deleteReport(int id) => "$baseUrl/laporan/$id";

  // Statistik endpoint
  static String get reportStatistics => "$baseUrl/statistik";

  // Tambahkan endpoint untuk riwayat laporan
  static String get reportHistory => "$baseUrl/riwayat";
}
