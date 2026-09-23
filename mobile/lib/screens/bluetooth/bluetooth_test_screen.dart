import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/bluetooth_service.dart';

class BluetoothTestScreen extends StatefulWidget {
  const BluetoothTestScreen({super.key});

  @override
  State<BluetoothTestScreen> createState() => _BluetoothTestScreenState();
}

class _BluetoothTestScreenState extends State<BluetoothTestScreen> {
  final SmartBluetoothService bluetoothService = SmartBluetoothService();

  List<ScanResult> devices = [];

  bool scanning = false;
  String? errorMessage;

  Future<void> scanDevices() async {
    setState(() {
      scanning = true;
      errorMessage = null;
      devices = [];
    });

    try {
      final results = await bluetoothService.scanDevices();
      if (!mounted) return;

      setState(() {
        devices = results;
      });
    } on BleVerificationException catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => errorMessage = 'Bluetooth scan failed. Please try again.');
    } finally {
      if (mounted) setState(() => scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: scanning ? null : scanDevices,
                child: Text(scanning ? "Scanning..." : "Scan Devices"),
              ),
            ),

            const SizedBox(height: 20),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (!scanning && errorMessage == null && devices.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('No teacher beacon found.'),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].device;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.bluetooth, color: Colors.blue),

                      title: Text(
                        device.platformName.isEmpty
                            ? "Unknown Device"
                            : device.platformName,
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ID: ${device.remoteId}"),
                          Text("RSSI: ${devices[index].rssi}"),
                          Text(
                            "Connectable: ${devices[index].advertisementData.connectable}",
                          ),

                          const SizedBox(height: 6),

                          Text("Service UUIDs:"),
                          Text(
                            devices[index].advertisementData.serviceUuids
                                .toString(),
                          ),

                          const SizedBox(height: 6),

                          Text("Manufacturer Data:"),
                          Text(
                            devices[index].advertisementData.manufacturerData
                                .toString(),
                          ),

                          const SizedBox(height: 6),

                          Text("Service Data:"),
                          Text(
                            devices[index].advertisementData.serviceData
                                .toString(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
