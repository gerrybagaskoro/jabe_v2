// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jabe/api/endpoint.dart';
import 'package:jabe/api/report_api.dart';
import 'package:jabe/models/report.dart';
import 'package:jabe/preference/shared_preference.dart';
import 'package:jabe/views/reports/edit_report_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;
  final Report report;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.report,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Report? _report;
  bool _isLoading = true;
  bool _imageLoading = false;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    // _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      print('=== Loading report with ID: ${widget.reportId} ===');

      final report = await ReportAPI.getReportById(widget.reportId);
      print('Report loaded successfully: ${report.toJson()}');

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading report detail: $e');

      try {
        print('Trying fallback to history endpoint...');
        await _tryLoadFromHistory();
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail laporan: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _tryLoadFromHistory() async {
    try {
      final token = PreferenceHandler.getToken();
      final url = Uri.parse(Endpoint.reportHistory);

      print('Trying history endpoint: $url');

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('History response: $jsonResponse');

        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('data') &&
            jsonResponse['data'] is List) {
          final reports = jsonResponse['data'] as List;
          final foundReport = reports.firstWhere(
            (report) => report['id'] == widget.reportId,
            orElse: () => null,
          );

          if (foundReport != null) {
            setState(() {
              _report = Report.fromJson(foundReport);
              _isLoading = false;
            });
            return;
          }
        }
      }

      throw Exception('Laporan tidak ditemukan dalam riwayat');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _deleteReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReportAPI.deleteReport(widget.reportId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dihapus')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus laporan: $e')));
      }
    }
  }

  // bool get _hasValidImage {
  //   final imageUrl = _report?.imageUrl;
  //   if (imageUrl == null || imageUrl.isEmpty) return false;

  //   // Pastikan URL adalah URL absolut yang valid
  //   final uri = Uri.tryParse(imageUrl);
  //   return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: _report != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditReportScreen(report: _report!),
                      ),
                    ).then((_) => _loadReport());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteReport,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
          ? const Center(child: Text('Laporan tidak ditemukan'))
          : _buildReportDetails(),
    );
  }

  Widget _buildReportDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Judul Laporan
          Text(
            _report?.judul ?? _report?.title ?? 'Tidak Ada Judul',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Gambar
          _buildImageSection(),

          // Deskripsi
          if (_report?.isi != null && _report!.isi!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(_report!.isi!, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
            ),

          // Informasi Laporan
          _buildInfoSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    String imageUrl = widget.report.imageUrl!;

    // Jika URL relatif, konversi ke absolut
    // if (!imageUrl.startsWith('http')) {
    //   imageUrl = 'http://applaporan.mobileprojp.com/storage/$imageUrl';
    // }
    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              headers: {
                "Authorization": "Bearer ${PreferenceHandler.getToken() ?? ''}",
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _imageLoading = false;
                        _imageError = false;
                      });
                    }
                  });
                  return child;
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _imageLoading = true;
                    });
                  }
                });
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                print('Image URL: $imageUrl');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _imageLoading = false;
                      _imageError = true;
                    });
                  }
                });
                return _buildErrorImage(imageUrl);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Status loading/error image
        if (_imageLoading)
          const Text(
            'Memuat gambar...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        if (_imageError)
          Text(
            'Gambar tidak dapat dimuat',
            style: TextStyle(color: Colors.red[600], fontSize: 12),
          ),
      ],
    );
  }

  // Widget _buildErrorImage() {
  //   return Container(
  //     color: Colors.grey[200],
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Icon(Icons.broken_image, size: 50, color: Colors.grey),
  //         const SizedBox(height: 8),
  //         const Text(
  //           'Gambar tidak dapat dimuat',
  //           style: TextStyle(color: Colors.grey),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           'URL: ${_report!.imageUrl}',
  //           style: const TextStyle(fontSize: 10, color: Colors.grey),
  //           overflow: TextOverflow.ellipsis,
  //           maxLines: 1,
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildErrorImage(String imageUrl) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'Gambar tidak dapat dimuat',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'URL: ${_report!.imageUrl}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _imageError = false;
                _imageLoading = true;
              });
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Laporan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Lokasi
          if (_report?.lokasi != null && _report!.lokasi!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Lokasi',
              value: _report!.lokasi!,
            ),

          // Tanggal Dibuat
          if (_report?.createdAt != null)
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Dibuat',
              value: _formatDate(_report!.createdAt!),
            ),

          // Status
          _buildInfoRow(
            icon: Icons.info,
            label: 'Status',
            value: _report?.status ?? 'Tidak diketahui',
            valueColor: _getStatusColor(_report?.status),
            isStatus: true,
          ),

          // ID Laporan
          _buildInfoRow(
            icon: Icons.numbers,
            label: 'ID Laporan',
            value: widget.reportId.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                    color: valueColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'masuk':
        return Colors.orange;
      case 'processed':
      case 'proses':
        return Colors.purple;
      case 'completed':
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
