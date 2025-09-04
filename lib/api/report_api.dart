// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jabe/api/endpoint.dart';
import 'package:jabe/models/report.dart';
import 'package:jabe/preference/shared_preference.dart';

class ReportAPI {
  static Future<List<Report>> getReports() async {
    try {
      final token = PreferenceHandler.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak valid, silakan login kembali');
      }
      final url = Uri.parse(Endpoint.reports);

      print('=== DEBUG: Mengambil laporan ===');
      print('URL: $url');
      print('Token: $token');

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('JSON Response: $jsonResponse');

        if (jsonResponse['data'] is List) {
          final reports = reportListFromJson(response.body);
          print('Berhasil memparsing ${reports.length} laporan');
          return reports;
        } else {
          throw Exception('Format response tidak valid: data bukan array');
        }
      } else {
        throw Exception(
          'Gagal mengambil data laporan: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error dalam getReports: $e');
      rethrow;
    }
  }

  static Future<Report> getReportById(int id) async {
    try {
      final token = PreferenceHandler.getToken();
      final url = Uri.parse(Endpoint.getReportById(id));

      print('=== DEBUG: Mengambil detail laporan ===');
      print('URL: $url');
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
        print('JSON Response: $jsonResponse');

        // Handle berbagai format response
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            // Jika response memiliki format {message: "...", data: {...}}
            return Report.fromJson(jsonResponse['data']);
          } else {
            // Jika response langsung object report
            return Report.fromJson(jsonResponse);
          }
        } else {
          throw Exception('Format response tidak valid');
        }
      } else {
        throw Exception(
          'Gagal mengambil detail laporan: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error dalam getReportById: $e');
      rethrow;
    }
  }

  // Dalam method createReport, pastikan response handling benar
  static Future<Report> createReport({
    required String judul,
    required String isi,
    required String lokasi,
    required String imageBase64,
  }) async {
    try {
      final token = PreferenceHandler.getToken();
      final url = Uri.parse(Endpoint.reports);

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "judul": judul,
          "isi": isi,
          "lokasi": lokasi,
          "image_base64": imageBase64,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        // Pastikan URL gambar absolut
        final report = reportFromJson(response.body);
        if (report.imageUrl != null && !report.imageUrl!.startsWith('http')) {
          report.imageUrl =
              'http://applaporan.mobileprojp.com/storage/${report.imageUrl}';
        }

        return report;
      } else {
        final error = json.decode(response.body);
        throw Exception(error["message"] ?? "Gagal membuat laporan");
      }
    } catch (e) {
      print('Error dalam createReport: $e');
      rethrow;
    }
  }

  static Future<Report> updateReport({
    required int id,
    required String judul,
    required String isi,
    required String lokasi,
    String? imageBase64,
  }) async {
    try {
      final token = PreferenceHandler.getToken();
      final url = Uri.parse(Endpoint.updateReport(id));

      final Map<String, dynamic> body = {
        "judul": judul,
        "isi": isi,
        "lokasi": lokasi,
        "_method": "PUT",
      };

      if (imageBase64 != null) {
        body["image_base64"] = imageBase64;
      }

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return reportFromJson(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error["message"] ?? "Gagal mengupdate laporan");
      }
    } catch (e) {
      print('Error dalam updateReport: $e');
      rethrow;
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
