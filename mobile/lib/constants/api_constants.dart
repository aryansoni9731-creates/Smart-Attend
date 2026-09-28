import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String defaultUrl = "https://smart-attend-y44c.onrender.com";
  static const String _prefKey = "smart_attend_server_url";
  static String _baseUrl = defaultUrl;

  static String get baseUrl => _baseUrl;

  static String cleanUrl(String url) {
    var u = url.trim();
    if (!u.startsWith("http://") && !u.startsWith("https://")) {
      u = "http://$u";
    }
    return u.replaceAll(RegExp(r'/+$'), '');
  }

  static Future<void> loadBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _baseUrl = cleanUrl(saved);
      }
    } catch (_) {}
  }

  static Future<void> setBaseUrl(String newUrl) async {
    final clean = cleanUrl(newUrl);
    _baseUrl = clean;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, clean);
    } catch (_) {}
  }
}
