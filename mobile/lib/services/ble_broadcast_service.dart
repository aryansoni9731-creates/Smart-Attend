import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';

class BleBroadcastService {
  final FlutterBlePeripheral _ble = FlutterBlePeripheral();

  bool _isBroadcasting = false;

  bool get isBroadcasting => _isBroadcasting;

  static const String serviceUuid = "12345678-1234-1234-1234-1234567890ab";

  Future<void> startBroadcast() async {
    final permissions = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
    if (permissions.values.any((status) => !status.isGranted)) {
      throw StateError(
        'Bluetooth advertising permission is required to start attendance.',
      );
    }

    try {
      print("STARTING BLE BROADCAST");

      final advertiseData = AdvertiseData(
        serviceUuid: serviceUuid,
        includeDeviceName: true,
      );

      await _ble.start(advertiseData: advertiseData);

      _isBroadcasting = true;

      print("BLE BROADCAST STARTED");
    } catch (e) {
      _isBroadcasting = false;
      throw StateError('Could not start the Bluetooth attendance beacon: $e');
    }
  }

  Future<void> stopBroadcast() async {
    if (!_isBroadcasting) return;

    await _ble.stop();

    _isBroadcasting = false;
  }
}
