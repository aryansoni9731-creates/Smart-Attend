import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/local_storage_service.dart';
import '../student/student_dashboard_screen.dart';
import 'package:flutter/services.dart';
import '../../constants/department_constants.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController rollNoController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController enrollmentController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final StudentService studentService = StudentService();
  final LocalStorageService storage = LocalStorageService();

  String? department;
  int semester = 3;
  String? section;

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    rollNoController.dispose();
    nameController.dispose();
    enrollmentController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Registration"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const Icon(Icons.school, size: 90, color: Colors.blue),

              const SizedBox(height: 15),

              const Text(
                "SmartAttend",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: rollNoController,
                decoration: const InputDecoration(
                  labelText: "Roll Number",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter Roll Number" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Student Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter Student Name" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: enrollmentController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  labelText: "Enrollment ID",
                  border: OutlineInputBorder(),
                  hintText: "Enter 11-digit Enrollment ID",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Enrollment ID";
                  }

                  if (value.length != 11) {
                    return "Enrollment ID must be exactly 11 digits";
                  }

                  return null;
                },
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
                initialValue: department,
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

              const SizedBox(height: 20),

              TextFormField(
                initialValue: "Semester 3",
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Semester",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: section,

                decoration: const InputDecoration(
                  labelText: "Section",
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(value: "A", child: Text("Section A")),
                  DropdownMenuItem(value: "B", child: Text("Section B")),
                  DropdownMenuItem(value: "C", child: Text("Section C")),
                  DropdownMenuItem(value: "D", child: Text("Section D")),
                  DropdownMenuItem(value: "G", child: Text("Section G")),
                  DropdownMenuItem(value: "H", child: Text("Section H")),
                ],

                onChanged: (value) {
                  setState(() {
                    section = value;
                  });
                },

                validator: (value) => value == null ? "Select Section" : null,
              ),

              const SizedBox(height: 35),

              SizedBox(
                height: 55,

                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          setState(() {
                            loading = true;
                          });

                          try {
                            final response = await studentService
                                .registerStudent(
                                  rollNo: rollNoController.text.trim(),
                                  name: nameController.text.trim(),
                                  enrollmentId: enrollmentController.text
                                      .trim(),
                                  password: passwordController.text,
                                  department: department!,
                                  semester: semester,
                                  section: section!,
                                );

                            if (!mounted) return;

                            setState(() {
                              loading = false;
                            });

                            if (response["success"] == true) {
                              await storage.saveRole("student");
                              await storage.setLoggedIn(true);
                              await storage.saveUserData(response["student"]);

                              if (!context.mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentDashboardScreen(
                                    student: response["student"],
                                  ),
                                ),
                                (route) => false,
                              );
                            } else {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response["message"])),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;

                            setState(() {
                              loading = false;
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Registration failed: $e"),
                              ),
                            );
                          }
                        },

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "REGISTER",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
