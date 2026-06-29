import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'obd2/elm327_adapter.dart';
import 'obd2/obd_commands.dart';
import 'obd2/manufacturer_pids.dart';
import 'obd2/special_functions.dart'; // Import special functions
import 'screens/live_data_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage OBD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DeviceScanScreen(),
    );
  }
}

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  final Elm327Adapter _obd2Connection = Elm327Adapter();
  List<BluetoothDevice> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  String _connectionStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _startScan(); // Start scanning automatically when screen opens
  }

  void _startScan() async {
    setState(() {
      _scanResults = [];
      _isScanning = true;
      _connectionStatus = 'Scanning...';
    });
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8)); // Increased timeout
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (!_scanResults.any((d) => d.remoteId == r.device.remoteId)) {
            setState(() {
              _scanResults.add(r.device);
            });
          }
        }
      });
      FlutterBluePlus.isScanning.listen((state) {
        setState(() {
          _isScanning = state;
          if (!state && _connectedDevice == null) {
            _connectionStatus = 'Scan Finished';
          }
        });
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Scan Error: $e';
        _isScanning = false;
      });
      _showSnackbar('Scan Error: $e', Colors.red);
    }
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
  }

  void _connectToDevice(BluetoothDevice device) async {
    _stopScan();
    setState(() {
      _connectionStatus = 'Connecting to ${device.platformName}...';
    });
    try {
      await _obd2Connection.connect(device.remoteId.str);
      setState(() {
        _connectedDevice = device;
        _connectionStatus = 'Connected to ${device.platformName}';
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectedScreen(
            obd2Connection: _obd2Connection,
            deviceName: device.platformName,
          ),
        ),
      ).then((_) => _disconnect());
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: $e';
      });
      _showSnackbar('Connection failed: $e', Colors.red);
      _disconnect();
    }
  }

  void _disconnect() async {
    try {
      await _obd2Connection.disconnect();
    } catch (e) {
      _showSnackbar('Disconnect Error: $e', Colors.orange);
    } finally {
      setState(() {
        _connectedDevice = null;
        _connectionStatus = 'Disconnected';
      });
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage OBD App'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? _stopScan : _startScan,
            tooltip: _isScanning ? 'Stop Scan' : 'Start Scan',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.bluetooth_connected, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Status: $_connectionStatus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_isScanning)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _scanResults.isEmpty && !_isScanning
                ? const Center(child: Text('No devices found. Tap refresh to scan.'))
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      BluetoothDevice device = _scanResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          leading: const Icon(Icons.bluetooth_device_sharp),
                          title: Text(device.platformName.isEmpty ? 'Unknown Device' : device.platformName),
                          subtitle: Text(device.remoteId.str),
                          trailing: ElevatedButton.icon(
                            onPressed: _connectedDevice == null
                                ? () => _connectToDevice(device)
                                : null,
                            icon: const Icon(Icons.link),
                            label: const Text('Connect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ConnectedScreen extends StatefulWidget {
  final Elm327Adapter obd2Connection;
  final String deviceName;
  const ConnectedScreen({super.key, required this.obd2Connection, required this.deviceName});
  @override
  State<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends State<ConnectedScreen> {
  dynamic _selectedPidCommand = ObdCommands.ENGINE_COOLANT_TEMP;
  SpecialFunction _selectedSpecialFunction = SpecialFunctionsManager.getAvailableFunctions().first;
  ValueNotifier<String> _specialFunctionStatus = ValueNotifier<String>('Idle');

  @override
  void dispose() {
    _specialFunctionStatus.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${widget.deviceName}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(context, 'Live PID Data', Icons.speed),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<dynamic>(
                      value: _selectedPidCommand,
                      decoration: const InputDecoration(
                        labelText: 'Select PID',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (c) => setState(() => _selectedPidCommand = c!),
                      items: [
                        DropdownMenuItem(
                            value: null,
                            child: const Text('--- Standard PIDs ---',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        ...[
                          ObdCommands.ENGINE_COOLANT_TEMP,
                          ObdCommands.ENGINE_RPM,
                          ObdCommands.VEHICLE_SPEED,
                          ObdCommands.CALC_ENGINE_LOAD,
                          ObdCommands.TIMING_ADVANCE,
                          ObdCommands.MAF_FLOW_RATE,
                          ObdCommands.THROTTLE_POSITION,
                          ObdCommands.INTAKE_AIR_TEMP,
                          ObdCommands.SHORT_TERM_FUEL_TRIM_B1,
                          ObdCommands.LONG_TERM_FUEL_TRIM_B1,
                          ObdCommands.FUEL_RAIL_PRESSURE,
                          ObdCommands.ENGINE_OIL_TEMP,
                          ObdCommands.CONTROL_MODULE_VOLTAGE,
                        ].map((c) => DropdownMenuItem(value: c, child: Text(c.description))),
                        DropdownMenuItem(
                            value: null,
                            child: const Text('--- Manufacturer PIDs ---',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        ...ManufacturerPids.getSupportedManufacturers().expand((manufacturer) => [
                              DropdownMenuItem(value: null, child: Text('-- $manufacturer --')),
                              ...ManufacturerPids.getPidsForManufacturer(manufacturer)
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c.description))),
                            ]),
                      ].where((item) => item?.value != null || (item?.child is Text && !(item!.child as Text).data!.startsWith('--'))).cast<DropdownMenuItem<dynamic>>().toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveDataScreen(
                              obd2Connection: widget.obd2Connection,
                              command: _selectedPidCommand,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text('View Live Data Chart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildSectionTitle(context, 'Diagnostic Trouble Codes', Icons.warning),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        _specialFunctionStatus.value = 'Reading DTCs...';
                        try {
                          String dtcs = await widget.obd2Connection.sendObdCommand(ObdCommands.READ_DTC);
                          _specialFunctionStatus.value = 'DTCs: $dtcs';
                          _showSnackbar('DTCs Read: $dtcs', Colors.blue);
                        } catch (e) {
                          _specialFunctionStatus.value = 'Error reading DTCs: $e';
                          _showSnackbar('Error reading DTCs: $e', Colors.red);
                        }
                      },
                      icon: const Icon(Icons.sync_problem),
                      label: const Text('Read DTCs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        _specialFunctionStatus.value = 'Clearing DTCs...';
                        try {
                          String result = await widget.obd2Connection.sendObdCommand(ObdCommands.CLEAR_DTC);
                          _specialFunctionStatus.value = 'Clear DTC Result: $result';
                          _showSnackbar('DTCs Cleared: $result', Colors.green);
                        } catch (e) {
                          _specialFunctionStatus.value = 'Error clearing DTCs: $e';
                          _showSnackbar('Error clearing DTCs: $e', Colors.red);
                        }
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear DTCs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildSectionTitle(context, 'Special Functions', Icons.build),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<SpecialFunction>(
                      value: _selectedSpecialFunction,
                      decoration: const InputDecoration(
                        labelText: 'Select Special Function',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (sf) => setState(() => _selectedSpecialFunction = sf!),
                      items: SpecialFunctionsManager.getAvailableFunctions().map((sf) =>
                          DropdownMenuItem(value: sf, child: Text(sf.name))).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        _specialFunctionStatus.value = 'Executing ${_selectedSpecialFunction.name}...';
                        _showSnackbar('Executing ${_selectedSpecialFunction.name}...', Colors.blue);
                        String result = await _selectedSpecialFunction.execute(
                            widget.obd2Connection, _specialFunctionStatus);
                        _showSnackbar('Function Result: $result', Colors.green);
                        _specialFunctionStatus.value = 'Result: $result';
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text('Execute ${_selectedSpecialFunction.name}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<String>(
                      valueListenable: _specialFunctionStatus,
                      builder: (context, status, child) {
                        return Text(
                          'Status: $status',
                          style: Theme.of(context).textTheme.titleSmall,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to scan screen
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Disconnect and Exit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
