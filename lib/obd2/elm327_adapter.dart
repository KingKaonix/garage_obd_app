import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'connection_interface.dart';

class Elm327Adapter implements Obd2Connection {
  BluetoothConnection? _connection;
  final _rawDataController = StreamController<String>.broadcast();
  final _parsedDataController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<String> get rawDataStream => _rawDataController.stream;
  Stream<Map<String, dynamic>> get parsedDataStream => _parsedDataController.stream;

  /// Whether the adapter is currently connected.
  bool _connected = false;
  bool get isConnected => _connected;

  @override
  Future<void> connect(String address) async {
    // Close any previous connection
    await disconnect();

    try {
      _connection = await BluetoothConnection.toAddress(address);
      _connected = true;

      // Listen for incoming data
      _connection!.input!.listen(
        (Uint8List data) {
          final decoded = utf8.decode(data);
          _rawDataController.add(decoded);
        },
        onError: (error) {
          _rawDataController.addError(error);
        },
        onDone: () {
          _connected = false;
        },
      );

      // Initialize ELM327 with AT commands
      await sendCommand('ATZ');
      await Future.delayed(const Duration(milliseconds: 500));
      await sendCommand('ATE0');
      await Future.delayed(const Duration(milliseconds: 200));
      await sendCommand('ATL0');
      await Future.delayed(const Duration(milliseconds: 200));
      await sendCommand('ATS0');
      await Future.delayed(const Duration(milliseconds: 200));
      await sendCommand('ATH0');
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _connected = false;
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    _rawDataController.close();
    _parsedDataController.close();
    try {
      await _connection?.finish();
    } catch (_) {}
    _connection = null;
    _connected = false;
  }

  @override
  Future<void> sendCommand(String command) async {
    if (_connection == null || !_connected) {
      throw Exception('Not connected to an ELM327 device.');
    }
    _connection!.output.add(utf8.encode('$command\r'));
    await _connection!.output.allSent;
  }

  /// Sends a raw OBD command and returns the raw ELM327 response.
  Future<String> sendRawCommand(String command) async {
    if (_connection == null || !_connected) {
      throw Exception('Not connected to an ELM327 device.');
    }

    final completer = Completer<String>();
    String response = '';
    StreamSubscription? sub;

    sub = _rawDataController.stream.listen(
      (data) {
        response += data;
        // ELM327 typically ends responses with '>' prompt
        if (response.contains('>')) {
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        } else if (response.contains('\r') || response.contains('\n')) {
          // Some responses end with CR/LF (no prompt in some modes)
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        }
      },
      onError: (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
    );

    await sendCommand(command);

    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } finally {
      sub.cancel();
    }
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
}
