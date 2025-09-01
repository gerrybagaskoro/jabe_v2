import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jabe/api/endpoint.dart';
import 'package:jabe/models/users.dart';
import 'package:jabe/preference/shared_preference.dart';

class AuthenticationAPI {
  static Future<RegisterUserModel> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final url = Uri.parse(Endpoint.register);
    final response = await http.post(
      url,
      body: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
      },
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return RegisterUserModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }

  static Future<RegisterUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final response = await http.post(
      url,
      body: {"email": email, "password": password},
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final registerUserModel = RegisterUserModel.fromJson(
        json.decode(response.body),
      );

      final token = registerUserModel.data?.token;
      if (token != null && token.isNotEmpty) {
        await PreferenceHandler.saveToken(token);
        await PreferenceHandler.saveLogin();
      }

      return registerUserModel;
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Login gagal");
    }
  }

  static Future<void> logout() async {
    final token = await PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.logout);

    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      await PreferenceHandler.removeLogin();
      await PreferenceHandler.removeToken();
    } else {
      throw Exception('Logout gagal');
    }
  }
}
