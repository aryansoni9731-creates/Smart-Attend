import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class StudentService {
  Future<Map<String, dynamic>> registerStudent({
    required String rollNo,
    required String name,
    required String enrollmentId,
    required String password,
    required String department,
    required int semester,
    required String section,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/student/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "rollNo": rollNo,
        "name": name,
        "enrollmentId": enrollmentId,
        "password": password,
        "department": department,
        "semester": semester,
        "section": section,
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.body.isEmpty) {
      return {
        "success": false,
        "message": "Server returned an empty response.",
      };
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> loginStudent({
    required String enrollmentId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/student/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"enrollmentId": enrollmentId, "password": password}),
    );

    return jsonDecode(response.body);
  }
}
