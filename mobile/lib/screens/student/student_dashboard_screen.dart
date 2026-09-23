import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../services/attendance_service.dart';
import '../../services/bluetooth_service.dart';
import '../../services/local_storage_service.dart';
import '../auth/role_selection_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentDashboardScreen({super.key, required this.student});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final SessionService sessionService = SessionService();
  final AttendanceService attendanceService = AttendanceService();
  final SmartBluetoothService bluetoothService = SmartBluetoothService();
  final LocalStorageService storage = LocalStorageService();

  List activeSession = [];

  bool isLoading = true;
  bool attendanceMarked = false;

  String? currentSessionId;

  String bluetoothStatus = "Searching for Teacher...";

  @override
  void initState() {
    super.initState();
    loadSession();
    scanForTeacher();
  }

  Future loadSession() async {
    try {
      final sessions = await sessionService.getActiveSession();

      if (sessions.isNotEmpty) {
        String newSessionId = sessions[0]["_id"].toString();

        if (currentSessionId != newSessionId) {
          attendanceMarked = false;
          currentSessionId = newSessionId;
        }
      } else {
        attendanceMarked = false;
        currentSessionId = null;
      }

      setState(() {
        activeSession = sessions;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  Future scanForTeacher() async {
    try {
      final devices = await bluetoothService.scanDevices();

      if (!mounted) return;

      setState(() {
        bluetoothStatus = devices.isNotEmpty
            ? "Teacher Found ✅"
            : "Teacher Not Found ❌";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        bluetoothStatus = "Teacher Not Found ❌";
      });
    }
  }

  Future markAttendance() async {
    await scanForTeacher();
    // Check Bluetooth before allowing attendance
    if (bluetoothStatus != "Teacher Found ✅") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Teacher not detected. Turn on Bluetooth and move closer.",
          ),
        ),
      );
      return;
    }
    debugPrint("Sending RSSI: ${bluetoothService.getRssi()}");
    final response = await attendanceService.markAttendance(
      enrollmentId: widget.student["enrollmentId"],
      rssi: bluetoothService.getRssi(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response["message"])));

    if (response["success"] == true) {
      setState(() {
        attendanceMarked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasSession = activeSession.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.student["name"]} 👋",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "${widget.student["department"]} • Semester ${widget.student["semester"]} • Section ${widget.student["section"]}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.blue),
                title: const Text("Bluetooth Status"),
                subtitle: Text(bluetoothStatus),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    bluetoothStatus = "Searching for Teacher...";
                    isLoading = true;
                  });

                  await scanForTeacher();
                  await loadSession();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hasSession
                    ? Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 60,
                          ),

                          const SizedBox(height: 15),

                          Text(
                            activeSession[0]["subject"],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text("Teacher ID : ${activeSession[0]["teacherId"]}"),

                          Text("Semester : ${activeSession[0]["semester"]}"),

                          Text("Section : ${activeSession[0]["section"]}"),
                        ],
                      )
                    : const Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 60,
                          ),

                          SizedBox(height: 15),

                          Text(
                            "No Active Attendance Session",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Please wait for your teacher to start attendance.",
                            textAlign: TextAlign.center,
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
                onPressed: (!hasSession || attendanceMarked)
                    ? null
                    : markAttendance,
                child: Text(
                  attendanceMarked ? "✓ Attendance Marked" : "Mark Attendance",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
