// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:jabe/api/report_api.dart';
import 'package:jabe/models/report.dart';
import 'package:jabe/views/reports/edit_report_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Report? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      print('=== Loading report with ID: ${widget.reportId} ===');
      final report = await ReportAPI.getReportById(widget.reportId);
      print('Report loaded successfully: ${report.judul}');

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading report detail: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditReportScreen(report: _report!),
                ),
              ).then((_) => _loadReport());
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteReport),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
          ? const Center(child: Text('Laporan tidak ditemukan'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    _report!.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _report!.imageUrl != null
                      ? Image.network(_report!.imageUrl!)
                      : Container(),
                  const SizedBox(height: 16),
                  Text(
                    _report!.description ?? 'No Description',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 8),
                      Text(_report!.location ?? 'No Location'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _report!.createdAt != null
                            ? 'Dibuat: ${_report!.createdAt!.toString().split(' ')[0]}'
                            : 'No Date',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Status: ${_report!.status ?? 'No Status'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(_report!.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processed':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
