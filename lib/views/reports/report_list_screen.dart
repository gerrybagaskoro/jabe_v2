// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:jabe/api/report_api.dart';
import 'package:jabe/models/report.dart';
import 'package:jabe/views/reports/report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<Report> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reportList = await ReportAPI.getReports();
      setState(() {
        reports = reportList;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat laporan: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Laporan')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(child: Text('Tidak ada laporan'))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportItem(report);
              },
            ),
    );
  }

  Widget _buildReportItem(Report report) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: report.imageUrl != null
            ? Image.network(
                report.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.report, size: 40),
        title: Text(
          report.judul ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.lokasi ?? 'No Location'),
            const SizedBox(height: 4),
            Text(
              report.status ?? 'No Status',
              style: TextStyle(
                color: _getStatusColor(report.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReportDetailScreen(reportId: report.id!, report: report),
            ),
          ).then((_) => _loadReports());
        },
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
