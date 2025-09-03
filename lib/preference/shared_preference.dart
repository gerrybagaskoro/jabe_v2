// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";
  static const String userNameKey = "user_name";
  static const String userEmailKey = "user_email";
  static const String welcomeShownKey = "welcome_shown";

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences _getPrefs() {
    if (_prefs == null) {
      throw Exception(
        'PreferenceHandler not initialized. Call PreferenceHandler.init() first.',
      );
    }
    return _prefs!;
  }

  // === LOGIN & TOKEN ===
  static Future<void> saveLogin() async {
    await _getPrefs().setBool(loginKey, true);
  }

  static bool? getLogin() {
    return _getPrefs().getBool(loginKey);
  }

  static Future<void> saveToken(String token) async {
    await _getPrefs().setString(tokenKey, token);
  }

  static String? getToken() {
    return _getPrefs().getString(tokenKey);
  }

  static Future<void> removeLogin() async {
    await _getPrefs().remove(loginKey);
  }

  static Future<void> removeToken() async {
    await _getPrefs().remove(tokenKey);
  }

  // === USER DATA ===
  static Future<void> saveUserData(String name, String email) async {
    await _getPrefs().setString(userNameKey, name);
    await _getPrefs().setString(userEmailKey, email);
  }

  static String? getUserName() {
    return _getPrefs().getString(userNameKey);
  }

  static String? getUserEmail() {
    return _getPrefs().getString(userEmailKey);
  }

  static Future<void> removeUserData() async {
    await _getPrefs().remove(userNameKey);
    await _getPrefs().remove(userEmailKey);
  }

  // === WELCOME SCREEN ===
  static Future<void> setWelcomeShown() async {
    await _getPrefs().setBool(welcomeShownKey, true);
  }

  static bool? isWelcomeShown() {
    return _getPrefs().getBool(welcomeShownKey);
  }

  static Future<void> removeWelcomeShown() async {
    await _getPrefs().remove(welcomeShownKey);
  }

  // === LOGOUT COMPLETE ===
  static Future<void> logout() async {
    await removeLogin();
    await removeToken();
    await removeUserData();
  }
}
