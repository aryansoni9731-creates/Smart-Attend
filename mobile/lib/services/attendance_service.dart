import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class AttendanceService {
  Future<Map<String, dynamic>> markAttendance({
    required String enrollmentId,
    required int rssi,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/attendance/mark"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"enrollmentId": enrollmentId, "rssi": rssi}),
    );

    return jsonDecode(response.body);
  }
}
