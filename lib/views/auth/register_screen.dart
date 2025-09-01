// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:jabe/api/authentication.dart';
// import 'package:jabe/views/auth/draft02/login_screen02.dart';
import 'package:jabe/views/auth/login_screen.dart';

class RegisterScreen02 extends StatefulWidget {
  const RegisterScreen02({super.key});

  @override
  State<RegisterScreen02> createState() => _RegisterScreen02State();
}

class _RegisterScreen02State extends State<RegisterScreen02> {
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthenticationAPI.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen02()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registrasi gagal: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Daftarkan diri Anda untuk mulai melaporkan kebersihan lingkungan',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                hintText: 'Nama Lengkap',
                icon: Icons.person,
                controller: _nameController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: 'Email',
                icon: Icons.email,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: 'Password',
                icon: Icons.lock,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: 'Konfirmasi Password',
                icon: Icons.lock,
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sudah memiliki akun?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen02(),
                        ),
                      );
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
