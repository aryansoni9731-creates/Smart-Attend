import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // ==========================
  // SAVE ROLE
  // ==========================
  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("role", role);
  }

  // ==========================
  // GET ROLE
  // ==========================
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  // ==========================
  // LOGIN STATUS
  // ==========================
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  // ==========================
  // SAVE USER DATA
  // ==========================
  Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userData", jsonEncode(user));
  }

  // ==========================
  // GET USER DATA
  // ==========================
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("userData");

    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(jsonDecode(data));
  }

  // ==========================
  // LOGOUT
  // ==========================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
