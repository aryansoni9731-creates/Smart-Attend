import 'package:flutter/material.dart';

import '../../services/local_storage_service.dart';

import '../auth/role_selection_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../teacher/teacher_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalStorageService storage = LocalStorageService();

  @override
  void initState() {
    super.initState();

    checkUser();
  }

  Future<void> checkUser() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    bool loggedIn = await storage.isLoggedIn();
    String? role = await storage.getRole();
    final user = await storage.getUserData();

    print("Logged In: $loggedIn");
    print("Role: $role");
    print("User: $user");

    if (loggedIn && role != null) {
      if (!mounted) return;

      if (role == "student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboardScreen(student: user ?? {}),
          ),
        );
      } else if (role == "teacher") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.school, size: 100, color: Colors.white),

            SizedBox(height: 20),

            Text(
              "SmartAttend",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Smart Attendance System",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
