import 'package:shared_preferences/shared_preferences.dart';

class LocalAuth {
  static const _adminEmailKey = 'admin_email';
  static const _adminPasswordKey = 'admin_password';
  static const _userEmailKey = 'user_email';
  static const _userPasswordKey = 'user_password';
  static const _sessionKey = 'is_logged_in';

  static const defaultAdminEmail = 'admin@peckpapers.local';
  static const defaultAdminPassword = 'Admin@12345';

  static Future<void> ensureAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_adminEmailKey) ||
        !prefs.containsKey(_adminPasswordKey)) {
      await prefs.setString(_adminEmailKey, defaultAdminEmail);
      await prefs.setString(_adminPasswordKey, defaultAdminPassword);
    }
  }

  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final adminEmail = prefs.getString(_adminEmailKey) ?? defaultAdminEmail;
    final adminPassword =
        prefs.getString(_adminPasswordKey) ?? defaultAdminPassword;
    final isAmin = email == adminEmail && password == adminPassword;
    
    final userEmail = prefs.getString(_userEmailKey);
    final userPassword = prefs.getString(_userPasswordKey);
    final isUser = email == userEmail && password == userPassword;

    if (isAmin || isUser) {
      await prefs.setBool(_sessionKey, true);
      return true;
    }
    return false;
  }

  static Future<void> signUp(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userPasswordKey, password);
    await prefs.setBool(_sessionKey, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
