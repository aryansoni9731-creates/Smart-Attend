import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// The result of verifying that the teacher's BLE beacon is nearby.
///
/// RSSI is a proximity estimate only; it varies by phone and environment.
class BleVerification {
  const BleVerification._({
    required this.detected,
    this.rssi,
    this.deviceId,
    this.detectedAt,
  });

  const BleVerification.notDetected() : this._(detected: false);

  const BleVerification.detected({
    required int rssi,
    required String deviceId,
    required DateTime detectedAt,
  }) : this._(
         detected: true,
         rssi: rssi,
         deviceId: deviceId,
         detectedAt: detectedAt,
       );

  final bool detected;
  final int? rssi;
  final String? deviceId;
  final DateTime? detectedAt;
}

class BleVerificationException implements Exception {
  const BleVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SmartBluetoothService {
  SmartBluetoothService({this.teacherServiceUuid = defaultTeacherServiceUuid});

  /// Must match the UUID advertised by BleBroadcastService on the teacher app.
  static const defaultTeacherServiceUuid =
      '12345678-1234-1234-1234-1234567890ab';

  final String teacherServiceUuid;
  BleVerification _lastVerification = const BleVerification.notDetected();
  List<ScanResult> _lastTeacherDevices = const [];
  Future<BleVerification>? _activeVerification;

  Future<void> _requestScanPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses.values.any((status) => !status.isGranted)) {
      throw const BleVerificationException(
        'Bluetooth permission is required to verify attendance. '
        'Grant it in Settings and try again.',
      );
    }
  }

  Future<bool> isBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  /// Scans for the teacher beacon and chooses the strongest matching result.
  /// Calls that overlap share the same scan, so they cannot stop each other.
  Future<BleVerification> verifyTeacher({
    Duration timeout = const Duration(seconds: 6),
  }) {
    final active = _activeVerification;
    if (active != null) return active;

    late final Future<BleVerification> operation;
    operation = _scanForTeacher(timeout).whenComplete(() {
      if (identical(_activeVerification, operation)) {
        _activeVerification = null;
      }
    });
    _activeVerification = operation;
    return operation;
  }

  Future<BleVerification> _scanForTeacher(Duration timeout) async {
    if (!await isBluetoothOn()) {
      throw const BleVerificationException('Bluetooth is turned off.');
    }

    await _requestScanPermissions();
    await FlutterBluePlus.stopScan();

    final teacherResults = <String, ScanResult>{};
    StreamSubscription<List<ScanResult>>? subscription;

    try {
      subscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final isTeacher = result.advertisementData.serviceUuids.any(
            (uuid) =>
                uuid.toString().toLowerCase() ==
                teacherServiceUuid.toLowerCase(),
          );
          if (!isTeacher) continue;

          final id = result.device.remoteId.toString();
          final previous = teacherResults[id];
          if (previous == null || result.rssi > previous.rssi) {
            teacherResults[id] = result;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: timeout);
      await Future<void>.delayed(timeout);

      _lastTeacherDevices = List.unmodifiable(teacherResults.values);
      if (_lastTeacherDevices.isEmpty) {
        _lastVerification = const BleVerification.notDetected();
        return _lastVerification;
      }

      final teacher = _lastTeacherDevices.reduce(
        (strongest, result) =>
            result.rssi > strongest.rssi ? result : strongest,
      );
      _lastVerification = BleVerification.detected(
        rssi: teacher.rssi,
        deviceId: teacher.device.remoteId.toString(),
        detectedAt: DateTime.now().toUtc(),
      );
      debugPrint(
        'Teacher beacon verified: ${_lastVerification.deviceId}; '
        'RSSI ${_lastVerification.rssi}',
      );
      return _lastVerification;
    } on BleVerificationException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('BLE scan failed: $error\n$stackTrace');
      throw const BleVerificationException(
        'Unable to scan for the teacher beacon. Please try again.',
      );
    } finally {
      await FlutterBluePlus.stopScan();
      await subscription?.cancel();
    }
  }

  /// Returns teacher-beacon results from a completed verification scan.
  Future<List<ScanResult>> scanDevices() async {
    await verifyTeacher();
    return _lastTeacherDevices;
  }

  /// Kept for the existing attendance API. New callers should use
  /// BleVerification.rssi from verifyTeacher.
  int getRssi() => _lastVerification.rssi ?? -100;
}
