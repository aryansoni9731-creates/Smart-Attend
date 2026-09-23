import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanService {
  static const String teacherServiceUuid =
      "12345678-1234-1234-1234-1234567890ab";

  Future<bool> scanForTeacher() async {
    bool teacherFound = false;

    // Stop any previous scan
    await FlutterBluePlus.stopScan();

    // Start scanning
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    final completer = Completer<bool>();

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        final advertisement = result.advertisementData;

        for (Guid uuid in advertisement.serviceUuids) {
          if (uuid.toString().toLowerCase() ==
              teacherServiceUuid.toLowerCase()) {
            teacherFound = true;
            break;
          }
        }

        if (teacherFound) {
          FlutterBluePlus.stopScan();

          if (!completer.isCompleted) {
            completer.complete(true);
          }
          break;
        }
      }
    });

    // Timeout
    Future.delayed(const Duration(seconds: 10), () async {
      await FlutterBluePlus.stopScan();

      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    final found = await completer.future;

    await subscription.cancel();

    return found;
  }
}
