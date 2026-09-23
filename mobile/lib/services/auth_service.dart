import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'device_service.dart';

class AuthService {
  final DeviceService _deviceService = DeviceService();

  Future<Map<String, dynamic>> studentLogin({
    required String enrollmentId,
    required String password,
  }) async {
    print("Login started");

    final String deviceId = await _deviceService.getDeviceId();

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/login/student"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "enrollmentId": enrollmentId,
        "password": password,
        "deviceId": deviceId,
      }),
    );

    print("Device ID: $deviceId");
    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");

    return {
      "statusCode": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }
}
