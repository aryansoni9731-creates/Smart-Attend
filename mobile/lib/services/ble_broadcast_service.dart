import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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

    final isBluetoothOn =
        await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    if (!isBluetoothOn) {
      throw StateError(
        'Bluetooth is turned off on this phone. Please turn on Bluetooth.',
      );
    }

    final isSupported = await _ble.isSupported;
    if (!isSupported) {
      throw StateError(
        'This device hardware does not support BLE Peripheral advertising.',
      );
    }

    try {
      final advertiseData = AdvertiseData(
        serviceUuid: serviceUuid,
        includeDeviceName: false,
      );

      await _ble.start(
        advertiseData: advertiseData,
        advertiseSettings: AdvertiseSettings(
          advertiseSet: false,
          advertiseMode: AdvertiseMode.advertiseModeLowLatency,
          connectable: true,
          timeout: 0, // 0 = continuous advertising (default was 400ms!)
          txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
        ),
      );

      _isBroadcasting = true;
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
