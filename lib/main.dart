import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'obd2/elm327_adapter.dart';
import 'obd2/obd_commands.dart';
import 'obd2/manufacturer_pids.dart';
import 'obd2/special_functions.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const DeviceScanScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Permissions state
// ---------------------------------------------------------------------------
enum _PermState { unknown, granted, denied, permanentlyDenied }

// ---------------------------------------------------------------------------
// Device Scan Screen
// ---------------------------------------------------------------------------
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

  _PermState _bluetoothScanPerm = _PermState.unknown;
  _PermState _bluetoothConnectPerm = _PermState.unknown;
  _PermState _locationPerm = _PermState.unknown;

  bool get _allGranted =>
      _bluetoothScanPerm == _PermState.granted &&
      _bluetoothConnectPerm == _PermState.granted &&
      _locationPerm == _PermState.granted;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  // -----------------------------------------------------------------------
  // Permissions
  // -----------------------------------------------------------------------
  Future<void> _checkAndRequestPermissions() async {
    // — 1. Check current status —
    final scanStatus = await Permission.bluetoothScan.status;
    final connectStatus = await Permission.bluetoothConnect.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    setState(() {
      _bluetoothScanPerm = _toPerm(scanStatus);
      _bluetoothConnectPerm = _toPerm(connectStatus);
      _locationPerm = _toPerm(locationStatus);
    });

    // — 2. If any are denied, request them —
    if (scanStatus.isDenied ||
        connectStatus.isDenied ||
        locationStatus.isDenied) {
      // Build the list of permissions to ask for (skip unknown ones on older API)
      final perms = <Permission>[];
      if (await Permission.bluetoothScan.status != PermissionStatus.restricted) {
        perms.add(Permission.bluetoothScan);
      }
      if (await Permission.bluetoothConnect.status != PermissionStatus.restricted) {
        perms.add(Permission.bluetoothConnect);
      }
      // Location may be needed on older Android; always try
      if (locationStatus.isDenied || locationStatus.isGranted) {
        perms.add(Permission.locationWhenInUse);
      }

      if (perms.isNotEmpty) {
        final statuses = await perms.request();
        setState(() {
          _bluetoothScanPerm = _toPerm(statuses[Permission.bluetoothScan] ?? scanStatus);
          _bluetoothConnectPerm = _toPerm(statuses[Permission.bluetoothConnect] ?? connectStatus);
          _locationPerm = _toPerm(statuses[Permission.locationWhenInUse] ?? locationStatus);
        });
      }
    }
  }

  _PermState _toPerm(PermissionStatus s) {
    if (s.isGranted) return _PermState.granted;
    if (s.isPermanentlyDenied) return _PermState.permanentlyDenied;
    return _PermState.denied;
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  // -----------------------------------------------------------------------
  // BLE Scan
  // -----------------------------------------------------------------------
  Future<void> _startScan() async {
    if (!_allGranted) {
      _showSnackbar('Please grant all permissions first', Colors.red);
      return;
    }

    // Turn on Bluetooth if off
    if (!(await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on)) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {
        _showSnackbar('Please turn on Bluetooth to scan', Colors.orange);
        return;
      }
    }

    setState(() {
      _scanResults = [];
      _isScanning = true;
      _connectionStatus = 'Scanning for OBD-II devices…';
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          if (!_scanResults.any((d) => d.remoteId == r.device.remoteId)) {
            setState(() => _scanResults.add(r.device));
          }
        }
      });

      FlutterBluePlus.isScanning.listen((state) {
        if (mounted) {
          setState(() {
            _isScanning = state;
            if (!state) {
              _connectionStatus =
                  _scanResults.isEmpty ? 'No devices found' : 'Scan complete';
            }
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectionStatus = 'Scan error';
          _isScanning = false;
        });
        _showSnackbar('Scan error: $e', Colors.red);
      }
    }
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
  }

  // -----------------------------------------------------------------------
  // Connection
  // -----------------------------------------------------------------------
  void _connectToDevice(BluetoothDevice device) async {
    _stopScan();
    setState(() => _connectionStatus = 'Connecting to ${device.platformName}…');

    try {
      await _obd2Connection.connect(device.remoteId.str);
      if (!mounted) return;
      setState(() {
        _connectedDevice = device;
        _connectionStatus = 'Connected to ${device.platformName}';
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConnectedScreen(
            obd2Connection: _obd2Connection,
            deviceName: device.platformName,
          ),
        ),
      );
      _disconnect();
    } catch (e) {
      if (!mounted) return;
      setState(() => _connectionStatus = 'Connection failed');
      _showSnackbar('Failed to connect: $e', Colors.red);
      _disconnect();
    }
  }

  void _disconnect() async {
    try {
      await _obd2Connection.disconnect();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _connectedDevice = null;
        _connectionStatus = 'Disconnected';
      });
    }
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------
  void _showSnackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage OBD App'),
        centerTitle: true,
        actions: [
          if (_allGranted)
            IconButton(
              icon: Icon(_isScanning ? Icons.stop_rounded : Icons.bluetooth_searching_rounded),
              onPressed: _isScanning ? _stopScan : _startScan,
              tooltip: _isScanning ? 'Stop scan' : 'Scan for devices',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // --- Permissions not yet checked — show loading ---
    if (_bluetoothScanPerm == _PermState.unknown) {
      return const Center(child: CircularProgressIndicator());
    }

    // --- Permissions denied ---
    if (!_allGranted) {
      return _buildPermissionsCard();
    }

    // --- Normal UI ---
    return Column(
      children: [
        // Status bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _isScanning
              ? Colors.blue.shade50
              : _connectedDevice != null
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
          child: Row(
            children: [
              Icon(
                _isScanning
                    ? Icons.bluetooth_searching
                    : _connectedDevice != null
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                size: 20,
                color: _isScanning
                    ? Colors.blue
                    : _connectedDevice != null
                        ? Colors.green
                        : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _connectionStatus,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isScanning
                        ? Colors.blue.shade700
                        : _connectedDevice != null
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                  ),
                ),
              ),
              if (_isScanning)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        // Scan button (when not scanning and no devices)
        if (!_isScanning && _scanResults.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
            child: Column(
              children: [
                Icon(Icons.bluetooth_searching_rounded,
                    size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Scan for nearby OBD-II devices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure your OBD-II adapter is plugged in and powered on.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.search),
                  label: const Text('Scan for Devices'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

        // Device list
        if (_scanResults.isNotEmpty)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _scanResults.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final device = _scanResults[i];
                final name = device.platformName.isNotEmpty
                    ? device.platformName
                    : 'Unknown Device';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.bluetooth, color: Colors.blue),
                  ),
                  title: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(device.remoteId.str, style: const TextStyle(fontSize: 12)),
                  trailing: ElevatedButton(
                    onPressed: _isScanning ? null : () => _connectToDevice(device),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('Connect'),
                  ),
                  enabled: !_isScanning,
                );
              },
            ),
          ),

        // No results message
        if (!_isScanning && _scanResults.isEmpty)
          const Spacer(),

        // Guidance footer
        if (!_isScanning && _scanResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tap Connect next to your OBD-II adapter.\n'
              'If you don\'t see it, make sure it\'s powered on and try scanning again.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Permissions card
  // -----------------------------------------------------------------------
  Widget _buildPermissionsCard() {
    final anyPermanently = _bluetoothScanPerm == _PermState.permanentlyDenied ||
        _bluetoothConnectPerm == _PermState.permanentlyDenied ||
        _locationPerm == _PermState.permanentlyDenied;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bluetooth_rounded, size: 64, color: Colors.blue.shade400),
                const SizedBox(height: 16),
                Text(
                  'Permissions Required',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Garage OBD needs the following permissions to scan and connect\n'
                  'to your OBD-II Bluetooth adapter.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 24),

                _permissionRow(
                  Icons.bluetooth_searching,
                  'Bluetooth Scan',
                  'Find nearby OBD-II adapters',
                  _bluetoothScanPerm,
                ),
                const SizedBox(height: 12),
                _permissionRow(
                  Icons.bluetooth_connected,
                  'Bluetooth Connect',
                  'Pair and communicate with adapter',
                  _bluetoothConnectPerm,
                ),
                const SizedBox(height: 12),
                _permissionRow(
                  Icons.location_on,
                  'Location',
                  'Required to discover Bluetooth devices',
                  _locationPerm,
                ),

                const SizedBox(height: 28),

                if (anyPermanently)
                  Column(
                    children: [
                      Text(
                        'Some permissions were permanently denied.\n'
                        'Please enable them in Settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Open Settings'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _checkAndRequestPermissions,
                        child: const Text('Check again'),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    onPressed: _checkAndRequestPermissions,
                    icon: const Icon(Icons.check),
                    label: const Text('Grant Permissions'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _permissionRow(IconData icon, String title, String subtitle, _PermState state) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade400, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Icon(
          state == _PermState.granted ? Icons.check_circle : Icons.cancel,
          color: state == _PermState.granted ? Colors.green : Colors.red.shade400,
        ),
      ],
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
                      initialValue: _selectedPidCommand,
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
                      ].where((item) => item.value != null || (item.child is Text && !(item.child as Text).data!.startsWith('--'))).cast<DropdownMenuItem<dynamic>>().toList(),
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
                      initialValue: _selectedSpecialFunction,
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
