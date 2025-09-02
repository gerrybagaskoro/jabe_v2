// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:jabe/api/report_api.dart';
import 'package:jabe/models/report.dart';
import 'package:jabe/preference/shared_preference.dart';
import 'package:jabe/views/reports/create_report_screen.dart';
import 'package:jabe/views/reports/report_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _currentCarouselIndex = 0;
  ReportStatistics? statistics;
  String userName = "Pengguna";

  final List<Map<String, dynamic>> _services = [
    {'title': 'Laporan', 'icon': Icons.report, 'route': '/reports'},
    {'title': 'Status', 'icon': Icons.article, 'route': '/status'},
    {'title': 'Semua', 'icon': Icons.apps, 'route': '/all'},
    {'title': 'Statistik', 'icon': Icons.bar_chart, 'route': '/stats'},
  ];

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Panduan penggunaan',
      'subtitle': 'Mempelajari penggunaan aplikasi secara optimal',
      'action': 'Baca Selengkapnya',
      'color': Colors.blue,
    },
    {
      'title': 'Limbah Elektronik',
      'subtitle': 'Pelajari cara membuang peralatan elektronik dengan benar.',
      'action': 'Baca Selengkapnya',
      'color': Colors.teal,
    },
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Lapor Sampah',
      'icon': Icons.add,
      'color': Colors.green,
      'route': '/create',
    },
    {
      'title': 'Lihat Laporan',
      'icon': Icons.list_alt,
      'color': Colors.blue,
      'route': '/reports',
    },
    {
      'title': 'Statistik',
      'icon': Icons.bar_chart,
      'color': Colors.orange,
      'route': '/stats',
    },
    {
      'title': 'Panduan',
      'icon': Icons.help,
      'color': Colors.purple,
      'route': '/guide',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
  }

  // Method untuk mengambil data user dari SharedPreferences
  void _loadUserData() {
    final userNameFromPrefs = PreferenceHandler.getUserName();
    setState(() {
      userName = userNameFromPrefs ?? "Warga";
    });
  }

  Future<void> _loadData() async {
    try {
      final stats = await ReportAPI.getReportStatistics();
      setState(() {
        statistics = stats;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat statistik: $e')));
      setState(() {
        statistics = ReportStatistics(masuk: 0, proses: 0, selesai: 0);
      });
    }
  }

  void _handleFeatureTap(String route) {
    switch (route) {
      case '/create':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateReportScreen()),
        ).then((_) => _loadData());
        break;
      case '/reports':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportListScreen()),
        );
        break;
      case '/stats':
        // Tampilkan statistik dalam dialog atau bottom sheet
        _showStatisticsDialog();
        break;
      case '/guide':
        // Navigasi ke halaman panduan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur panduan akan segera hadir')),
        );
        break;
    }
  }

  void _showStatisticsDialog() {
    if (statistics == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Statistik Laporan'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatItem('Total Laporan', statistics!.total, Colors.blue),
                _buildStatItem('Masuk', statistics!.masuk, Colors.orange),
                _buildStatItem('Proses', statistics!.proses, Colors.purple),
                _buildStatItem('Selesai', statistics!.selesai, Colors.green),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String title, int count, Color color) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(title),
      trailing: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JABE', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await PreferenceHandler.removeLogin();
              await PreferenceHandler.removeToken();
              await PreferenceHandler.removeUserData();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan informasi pengguna
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green[700],
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mari jaga kebersihan lingkungan',
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Statistik Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistik Laporan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  statistics != null
                      ? _buildStatisticsCards()
                      : const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),

            // Grid Layanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => _handleFeatureTap(_services[index]['route']),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _services[index]['icon'],
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _services[index]['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Carousel Slider
            SizedBox(
              height: 160,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 160,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 22 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.9,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
                items: _carouselItems.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item['subtitle'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item['action'],
                                    style: TextStyle(
                                      color: item['color'],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _carouselItems.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(
                      _currentCarouselIndex == entry.key ? 0.9 : 0.4,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Fitur-fitur utama
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Layanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                ),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => _handleFeatureTap(_features[index]['route']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _features[index]['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _features[index]['color'].withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            _features[index]['icon'],
                            color: _features[index]['color'],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _features[index]['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _features[index]['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleBottomNavTap(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatCard('Total', statistics!.total, Colors.blue),
        _buildStatCard('Masuk', statistics!.masuk, Colors.orange),
        _buildStatCard('Proses', statistics!.proses, Colors.purple),
        _buildStatCard('Selesai', statistics!.selesai, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0: // Beranda
        // Already on home
        break;
      case 1: // Aktivitas
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportListScreen()),
        );
        break;
      case 2: // Lapor
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateReportScreen()),
        ).then((_) => _loadData());
        break;
      case 3: // Notifikasi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur notifikasi akan segera hadir')),
        );
        break;
      case 4: // Profil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur profil akan segera hadir')),
        );
        break;
    }
  }
}
