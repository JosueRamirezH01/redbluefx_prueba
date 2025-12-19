import 'package:shared_preferences/shared_preferences.dart';

class LoginStorage {
  static const _keyEmail = 'remember_email';
  static const _keyPassword = 'remember_password';
  static const _keyRemember = 'remember_me';

  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyRemember, true);
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyRemember, false);
  }
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemember) ?? false;
  }

  static Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_keyRemember) ?? false;

    if (!remember) return null;

    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);

    if (email != null && password != null) {
      return {
        'email': email,
        'password': password,
      };
    }
    return null;
  }
}
