import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jabe/api/endpoint.dart';
import 'package:jabe/models/report.dart';
import 'package:jabe/preference/shared_preference.dart';

class ReportAPI {
  static Future<List<Report>> getReports() async {
    final token = PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.reports);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return reportListFromJson(response.body);
    } else {
      throw Exception('Gagal mengambil data laporan');
    }
  }

  static Future<Report> getReportById(int id) async {
    final token = PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.getReportById(id));

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return reportFromJson(response.body);
    } else {
      throw Exception('Gagal mengambil detail laporan');
    }
  }

  static Future<Report> createReport({
    required String title,
    required String description,
    required String location,
    String? imagePath,
  }) async {
    final token = PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.reports);

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['location'] = location;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return reportFromJson(responseData);
    } else {
      throw Exception(
        'Gagal membuat laporan: ${json.decode(responseData)['message']}',
      );
    }
  }

  static Future<Report> updateReport({
    required int id,
    required String title,
    required String description,
    required String location,
    String? imagePath,
  }) async {
    final token = PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.updateReport(id));

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['_method'] = 'PUT';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['location'] = location;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return reportFromJson(responseData);
    } else {
      throw Exception(
        'Gagal mengupdate laporan: ${json.decode(responseData)['message']}',
      );
    }
  }

  static Future<void> deleteReport(int id) async {
    final token = PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.deleteReport(id));

    final response = await http.delete(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus laporan');
    }
  }

  static Future<ReportStatistics> getReportStatistics() async {
    try {
      final token = PreferenceHandler.getToken();
      final url = Uri.parse(Endpoint.reportStatistics);

      print('Mengambil statistik dari: $url');
      print('Token: $token');

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ReportStatistics.fromJson(jsonResponse["data"]);
      } else {
        throw Exception(
          'Gagal mengambil statistik laporan: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error dalam getReportStatistics: $e');
      rethrow;
    }
  }
}
