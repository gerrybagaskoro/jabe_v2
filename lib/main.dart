import 'package:flutter/material.dart';
import 'package:jabe/preference/shared_preference.dart';
import 'package:jabe/views/auth/login_screen.dart';
import 'package:jabe/views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init(); // Pastikan init() dipanggil pertama
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
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            final isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? const HomeScreen() : const LoginScreen02();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen02(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    final isLoggedIn = PreferenceHandler.getLogin();
    return isLoggedIn ?? false;
  }
}
