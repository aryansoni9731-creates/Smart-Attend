import 'package:flutter/material.dart';

import '../../services/local_storage_service.dart';
import '../../services/teacher_service.dart';
import 'teacher_dashboard_screen.dart';
import '../../constants/department_constants.dart';

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  State<TeacherRegisterScreen> createState() => _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final teacherIdController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  final TeacherService teacherService = TeacherService();
  final LocalStorageService storage = LocalStorageService();

  String? department;

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    teacherIdController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final response = await teacherService.registerTeacher(
        teacherId: teacherIdController.text.trim(),
        name: nameController.text.trim(),
        password: passwordController.text,
        department: department!,
      );

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      if (response["success"] == true) {
        await storage.saveRole("teacher");
        await storage.setLoggedIn(true);
        await storage.saveUserData(response["teacher"]);
        print("Saved Teacher: ${response["teacher"]}");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response["message"])));
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Registration"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person, size: 90, color: Colors.blue),

              const SizedBox(height: 20),

              TextFormField(
                controller: teacherIdController,
                decoration: const InputDecoration(
                  labelText: "Teacher ID",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter Teacher ID" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Teacher Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter Teacher Name" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                    value!.length < 6 ? "Minimum 6 characters" : null,
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: department,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
                items: DepartmentConstants.departments.map((dept) {
                  return DropdownMenuItem<String>(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    department = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Select Department" : null,
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : registerTeacher,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTER", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
