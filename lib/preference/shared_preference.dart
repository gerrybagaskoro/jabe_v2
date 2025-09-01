// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";

  static late SharedPreferences _prefs;

  // Tambahkan method init()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveLogin() async {
    await _prefs.setBool(loginKey, true);
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(tokenKey, token);
  }

  static bool? getLogin() {
    print(loginKey);
    return _prefs.getBool(loginKey);
  }

  static String? getToken() {
    return _prefs.getString(tokenKey);
  }

  static Future<void> removeLogin() async {
    await _prefs.remove(loginKey);
  }

  static Future<void> removeToken() async {
    await _prefs.remove(tokenKey);
  }
}
