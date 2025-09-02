// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:jabe/preference/shared_preference.dart';
import 'package:jabe/utils/navigations.dart';
import 'package:jabe/views/auth/login_screen.dart';
import 'package:jabe/views/home/home_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreenAlt extends StatefulWidget {
  const WelcomeScreenAlt({super.key});

  @override
  State<WelcomeScreenAlt> createState() => _WelcomeScreenAltState();
}

class _WelcomeScreenAltState extends State<WelcomeScreenAlt> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> carousaleSlide = [
    {
      'image': 'assets/images/welcome/slide01.png',
      'title': 'Selamat Datang di Aplikasi JaBe (Jakarta Bersih)',
      'description': 'Mewujudkan lingkungan yang bersih dan sehat',
    },
    {
      'image': 'assets/images/welcome/slide02.png',
      'title': 'Laporkan Sampah dengan Mudah',
      'description': 'Foto dan laporkan titik sampah dengan cepat dan akurat',
    },
    {
      'image': 'assets/images/welcome/slide03.png',
      'title': 'Pantau Progress Kebersihan',
      'description': 'Lihat perkembangan kebersihan lingkungan RT/RW Anda',
    },
  ];

  void _goToNextScreen() async {
    // Tandai bahwa welcome screen sudah ditampilkan
    await PreferenceHandler.setWelcomeShown();

    // Cek apakah user sudah login
    final isLoggedIn = PreferenceHandler.getLogin() ?? false;

    if (isLoggedIn) {
      context.pushReplacement(const DashboardScreen());
    } else {
      context.pushReplacement(const LoginScreen02());
    }
  }

  void _nextPage() {
    if (_currentIndex < carousaleSlide.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _goToNextScreen();
    }
  }

  // Skip welcome screen
  void _skipWelcome() {
    _goToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView sebagai alternatif CarouselSlider
          PageView.builder(
            controller: _pageController,
            itemCount: carousaleSlide.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = carousaleSlide[index];
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(slide['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          slide['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['description']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Tombol Skip (hanya ditampilkan di slide pertama)
          if (_currentIndex < carousaleSlide.length - 1)
            Positioned(
              top: 40,
              right: 16,
              child: TextButton(
                onPressed: _skipWelcome,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Indicator
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: carousaleSlide.length,
                effect: const WormEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                  dotHeight: 12,
                  dotWidth: 12,
                  spacing: 8,
                ),
              ),
            ),
          ),

          // Tombol Next/Mulai
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentIndex == carousaleSlide.length - 1
                    ? Colors.green
                    : Colors.white,
                foregroundColor: _currentIndex == carousaleSlide.length - 1
                    ? Colors.white
                    : Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _currentIndex == carousaleSlide.length - 1
                    ? 'Mulai Sekarang'
                    : 'Selanjutnya',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
