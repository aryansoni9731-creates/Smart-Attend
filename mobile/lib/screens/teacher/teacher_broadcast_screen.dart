import 'package:flutter/material.dart';
import '../../services/ble_broadcast_service.dart';

class TeacherBroadcastScreen extends StatefulWidget {
  const TeacherBroadcastScreen({super.key});

  @override
  State<TeacherBroadcastScreen> createState() => _TeacherBroadcastScreenState();
}

class _TeacherBroadcastScreenState extends State<TeacherBroadcastScreen> {
  bool isBroadcasting = false;

  final BleBroadcastService bleService = BleBroadcastService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Broadcast"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      isBroadcasting
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      size: 70,
                      color: isBroadcasting ? Colors.green : Colors.red,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      isBroadcasting ? "Broadcasting..." : "Not Broadcasting",
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

            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await bleService.startBroadcast();

                  setState(() {
                    isBroadcasting = true;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("BLE Broadcasting Started")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Broadcasting"),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () async {
                await bleService.stopBroadcast();

                setState(() {
                  isBroadcasting = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("BLE Broadcasting Stopped")),
                );
              },
              icon: const Icon(Icons.stop),
              label: const Text("Stop Broadcasting"),
            ),
          ],
        ),
      ),
    );
  }
}
