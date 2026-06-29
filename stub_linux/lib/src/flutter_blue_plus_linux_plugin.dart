import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';

class FlutterBluePlusLinuxPlugin extends FlutterBluePlusPlatformInterface {
  // Stub implementation - Linux not supported
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<bool> get isOn async => false;

  @override
  Future<void> turnOn() async {
    throw UnimplementedError('Linux BLE not supported in this build');
  }

  @override
  Future<void> turnOff() async {
    throw UnimplementedError('Linux BLE not supported in this build');
  }

  @override
  Stream<ScanResult> scan({ScanSettings? settings}) {
    throw UnimplementedError('Linux BLE not supported in this build');
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<List<BluetoothDevice>> get connectedDevices async => [];

  @override
  Future<BluetoothDevice> connect(String deviceId,
      {Duration? timeout, bool? autoConnect}) async {
    throw UnimplementedError('Linux BLE not supported in this build');
  }

  @override
  Future<void> disconnect(String deviceId) async {}

  @override
  Future<int> readRssi(String deviceId) async => 0;

  @override
  Future<void> setNotifyValue(
      String deviceId, String serviceId, String characteristicId, bool enabled,
      {int? mtu}) async {
    throw UnimplementedError('Linux BLE not supported in this build');
  }

  @override
  Stream<List<int>> onValueReceived(
          String deviceId, String characteristicId) =>
      const Stream.empty();

  @override
  Future<List<int>> readValue(
      String deviceId, String serviceId, String characteristicId) async {
    throw UnimplementedError('Linux BLE not supported in this build');
  }

  @override
  Future<void> writeValue(String deviceId, String serviceId,
      String characteristicId, List<int> value,
      {bool? withoutResponse}) async {
    throw UnimplementedError('Linux BLE not supported in this build');
  }

  @override
  Future<List<BluetoothService>> discoverServices(String deviceId) async => [];
}
