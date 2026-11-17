import 'package:shared_preferences/shared_preferences.dart';

// Menyimpan status login dan nama akun di penyimpanan lokal.
class SessionService {
  static const String _usernameKey = 'logged_in_username';

  static Future<void> saveLogin(String username) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_usernameKey, username);
  }

  static Future<String?> getUsername() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_usernameKey);
  }

  static Future<void> clearLogin() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_usernameKey);
  }
}
