import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../services/teacher_service.dart';
import '../teacher/teacher_dashboard_screen.dart';
import '../teacher/teacher_register_screen.dart';
import '../../widgets/server_settings_dialog.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final LocalStorageService storage = LocalStorageService();
  final TeacherService teacherService = TeacherService();

  final TextEditingController teacherIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    teacherIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginTeacher() async {
    final teacherId = teacherIdController.text.trim();
    final password = passwordController.text;

    if (teacherId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Teacher ID and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await teacherService.loginTeacher(
        teacherId: teacherId,
        password: password,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response["success"] == true) {
        final teacherData = response["teacher"] ?? {
          "teacherId": teacherId,
          "name": response["name"] ?? "Teacher",
          "department": response["department"] ?? "Computer Science",
        };

        await storage.saveRole("teacher");
        await storage.setLoggedIn(true);
        await storage.saveUserData(teacherData);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Login"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Server Settings",
            icon: const Icon(Icons.settings),
            onPressed: () => ServerSettingsDialog.show(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school, size: 72, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                "Welcome Back",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to start and monitor attendance",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: teacherIdController,
                decoration: const InputDecoration(
                  labelText: "Teacher ID",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginTeacher,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("LOGIN", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeacherRegisterScreen(),
                    ),
                  );
                },
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
