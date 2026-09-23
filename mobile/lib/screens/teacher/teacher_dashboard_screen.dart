import '../auth/role_selection_screen.dart';
import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../services/ble_broadcast_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/excel_export_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final SessionService sessionService = SessionService();
  final BleBroadcastService bleService = BleBroadcastService();
  final LocalStorageService storage = LocalStorageService();
  final ExcelExportService excelExportService = ExcelExportService();
  Map<String, dynamic>? teacher;

  String? selectedSubject;
  int? selectedSemester;
  String? selectedSection;

  bool attendanceRunning = false;

  String sessionId = "";

  int totalPresent = 0;

  @override
  void initState() {
    super.initState();
    loadTeacher();
  }

  Future<void> loadTeacher() async {
    final data = await storage.getUserData();

    print("Loaded Teacher: $data");

    if (!mounted) return;

    setState(() {
      teacher = data;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartAttend"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {
              await storage.logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${teacher?["name"] ?? "Teacher"} 👋",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Computer Science Department",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: const InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Operating System",
                  child: Text("Operating System"),
                ),
                DropdownMenuItem(
                  value: "Data Structures",
                  child: Text("Data Structures"),
                ),
                DropdownMenuItem(
                  value: "Engineering Mathematics",
                  child: Text("Engineering Mathematics"),
                ),
                DropdownMenuItem(
                  value: "Digital Electronics",
                  child: Text("Digital Electronics"),
                ),
                DropdownMenuItem(value: "OOPS", child: Text("OOPS")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              value: selectedSemester,
              decoration: const InputDecoration(
                labelText: "Semester",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 3, child: Text("Semester 3")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSemester = value;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedSection,
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
                  selectedSection = value;
                });
              },
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      attendanceRunning
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: attendanceRunning ? Colors.green : Colors.red,
                      size: 70,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      attendanceRunning
                          ? "Attendance Running"
                          : "Attendance Not Started",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: attendanceRunning
                      ? Colors.red
                      : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // End Attendance Session
                  if (attendanceRunning) {
                    await bleService.stopBroadcast();

                    final result = await sessionService.endSession(
                      sessionId: sessionId,
                    );

                    if (result["statusCode"] == 200) {
                      final attendance = await sessionService
                          .getSessionAttendance(sessionId);
                      final students = attendance["data"]["students"] ?? [];

                      print("Students List:");
                      print(students);

                      print("Total Students:");
                      print(students.length);

                      int count = 0;

                      if (attendance["statusCode"] == 200) {
                        count =
                            attendance["data"]["totalPresent"] ??
                            attendance["data"]["data"]["totalPresent"] ??
                            0;
                      }

                      setState(() {
                        attendanceRunning = false;

                        totalPresent = count;
                      });
                      debugPrint("FINAL COUNT BEFORE SUMMARY: $totalPresent");
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("📋 Session Summary"),

                            content: Text(
                              "Subject : ${selectedSubject ?? "-"}\n\n"
                              "Semester : ${selectedSemester ?? "-"}\n\n"
                              "Section : ${selectedSection ?? "-"}\n\n"
                              "Present Students : $totalPresent",
                            ),

                            actions: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.table_view),
                                label: const Text("Excel"),
                                onPressed: () async {
                                  await excelExportService.exportAttendance(
                                    subject: selectedSubject!,
                                    semester: selectedSemester!,
                                    section: selectedSection!,
                                    students: students,
                                  );
                                },
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Close"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result["data"]["message"])),
                      );
                    }

                    return;
                  }

                  // Start Attendance Session
                  try {
                    if (selectedSubject == null ||
                        selectedSemester == null ||
                        selectedSection == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select Subject, Semester and Section",
                          ),
                        ),
                      );

                      return;
                    }

                    final result = await sessionService.startSession(
                      teacherId: teacher?["teacherId"] ?? "",
                      department: "Computer Science",
                      semester: selectedSemester!,
                      section: selectedSection!,
                      subject: selectedSubject!,
                    );

                    if (result["statusCode"] == 201) {
                      sessionId = result["data"]["session"]["_id"];

                      try {
                        await bleService.startBroadcast();
                      } catch (_) {
                        await sessionService.endSession(sessionId: sessionId);
                        sessionId = "";
                        rethrow;
                      }

                      setState(() {
                        attendanceRunning = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Attendance Started")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result["data"]["message"])),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: Text(
                  attendanceRunning ? "END ATTENDANCE" : "START ATTENDANCE",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
