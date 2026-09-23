import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class TeacherService {
  Future<Map<String, dynamic>> registerTeacher({
    required String teacherId,
    required String name,
    required String password,
    required String department,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/teacher/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "teacherId": teacherId,
        "name": name,
        "password": password,
        "department": department,
      }),
    );

    if (response.body.isEmpty) {
      return {"success": false, "message": "Empty server response."};
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> loginTeacher({
    required String teacherId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/teacher/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"teacherId": teacherId, "password": password}),
    );

    if (response.body.isEmpty) {
      return {"success": false, "message": "Empty server response."};
    }

    return jsonDecode(response.body);
  }
}
