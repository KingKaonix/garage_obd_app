import 'dart:async';
import 'dart:convert';
import 'connection_interface.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Elm327Adapter implements Obd2Connection {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _tx;
  BluetoothCharacteristic? _rx;
  final _rawDataController = StreamController<String>.broadcast();
  final _parsedDataController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<String> get rawDataStream => _rawDataController.stream;
  Stream<Map<String, dynamic>> get parsedDataStream => _parsedDataController.stream;

  @override
  Future<void> connect(String deviceId) async {
    _device = null;
    final List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
    try {
      _device = connectedDevices.firstWhere((d) => d.remoteId.str == deviceId);
    } catch (e) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      await for (List<ScanResult> results in FlutterBluePlus.scanResults) {
        for (ScanResult r in results) {
          if (r.device.remoteId.str == deviceId) {
            _device = r.device;
            FlutterBluePlus.stopScan();
            break;
          }
        }
        if (_device != null) break;
      }
    }

    if (_device == null) throw Exception('Device with ID $deviceId not found.');
    await _device!.connect(license: License.nonprofit);
    List<BluetoothService> services = await _device!.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write && _tx == null) _tx = characteristic;
        if (characteristic.properties.notify && _rx == null) {
          _rx = characteristic;
          _rx!.setNotifyValue(true);
          _rx!.lastValueStream.listen((value) => _rawDataController.add(utf8.decode(value)));
        }
      }
    }
    if (_tx == null || _rx == null) throw Exception('Required Bluetooth characteristics not found.');
    
    await sendCommand('ATZ'); await Future.delayed(Duration(milliseconds: 500));
    await sendCommand('ATE0'); await Future.delayed(Duration(milliseconds: 500));
    await sendCommand('ATL0'); await Future.delayed(Duration(milliseconds: 500));
    await sendCommand('ATS0'); await Future.delayed(Duration(milliseconds: 500));
    await sendCommand('ATH0'); await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> disconnect() async {
    _rawDataController.close();
    _parsedDataController.close();
    await _device?.disconnect();
    _device = null; _tx = null; _rx = null;
  }

  @override
  Future<void> sendCommand(String command) async {
    if (_tx == null) throw Exception('Bluetooth TX characteristic not available.');
    await _tx!.write(utf8.encode('$command\r'), withoutResponse: _tx!.properties.writeWithoutResponse);
  }

  /// Sends an OBD command and returns the parsed value.
  Future<String> sendObdCommand(dynamic obdCommand) async {
    String rawResponse = await sendRawCommand(obdCommand.command);
    String parsed = obdCommand.parser(rawResponse);
    _parsedDataController.add({
      obdCommand.description: parsed,
      'unit': obdCommand.unit,
    });
    return parsed;
  }

  /// Sends a raw command and returns the raw ELM327 response string.
  Future<String> sendRawCommand(String command) async {
    if (_tx == null || _rx == null) throw Exception('Not connected to an ELM327 device.');

    String response = '';
    Completer<String> completer = Completer();
    final subscription = _rawDataController.stream.listen((data) {
      response += data;
      if (response.trim().endsWith('>') || response.contains('\r')) {
        if (!completer.isCompleted) completer.complete(response);
      }
    });

    await sendCommand(command);

    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } finally {
      subscription.cancel();
    }
  }
}
