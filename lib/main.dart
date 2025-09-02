import 'package:flutter/material.dart';
import 'package:jabe/preference/shared_preference.dart';
import 'package:jabe/views/auth/login_screen.dart';
import 'package:jabe/views/home/home_screen.dart';
import 'package:jabe/views/home/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JaBe - Jakarta Bersih',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data ?? const SizedBox();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen02(),
        '/dashboard': (context) => const DashboardScreen(),
        '/welcome': (context) => const WelcomeScreenAlt(),
      },
    );
  }

  Future<Widget> _getInitialScreen() async {
    // Cek apakah user sudah login
    final isLoggedIn = PreferenceHandler.getLogin() ?? false;

    if (isLoggedIn) {
      return const DashboardScreen();
    }

    // Cek apakah welcome screen sudah ditampilkan
    final isWelcomeShown = PreferenceHandler.isWelcomeShown() ?? false;

    if (!isWelcomeShown) {
      return const WelcomeScreenAlt();
    }

    // Jika welcome sudah ditampilkan tapi belum login, tampilkan login screen
    return const LoginScreen02();
  }
}
