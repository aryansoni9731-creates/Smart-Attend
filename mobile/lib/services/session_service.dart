import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class SessionService {
  // ===========================
  // START SESSION
  // ===========================
  Future<Map<String, dynamic>> startSession({
    required String teacherId,
    required String department,
    required int semester,
    required String section,
    required String subject,
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/api/session/start");

    final response = await http.post(
      url,

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "teacherId": teacherId,
        "department": department,
        "semester": semester,
        "section": section,
        "subject": subject,
      }),
    );

    return {
      "statusCode": response.statusCode,

      "data": jsonDecode(response.body),
    };
  }

  // ===========================
  // END SESSION
  // ===========================
  Future<Map<String, dynamic>> endSession({required String sessionId}) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/session/end"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({"sessionId": sessionId}),
    );

    return {
      "statusCode": response.statusCode,

      "data": jsonDecode(response.body),
    };
  }

  // ===========================
  // ACTIVE SESSION
  // ===========================
  Future<List<dynamic>> getActiveSession() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/session/active"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }

  // ===========================
  // SESSION ATTENDANCE COUNT
  // ===========================
  Future<Map<String, dynamic>> getSessionAttendance(String sessionId) async {
    print(
      "COUNT URL: ${ApiConstants.baseUrl}/api/attendance/session/$sessionId",
    );
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/attendance/session/$sessionId"),
    );

    return {
      "statusCode": response.statusCode,

      "data": jsonDecode(response.body),
    };
  }
}
