import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  List<BluetoothDevice> _devices = [];
  List<BluetoothDevice> _bondedDevices = [];
  bool _isScanning = false;
  String _statusText = 'Ready';
  bool _bluetoothEnabled = false;

  // Permissions
  _PermState _connectPerm = _PermState.unknown;
  _PermState _locationPerm = _PermState.unknown;
  bool get _allGranted =>
      _connectPerm == _PermState.granted &&
      _locationPerm == _PermState.granted;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkPermissions();
    await _checkBluetooth();
  }

  // -----------------------------------------------------------------------
  // Permissions
  // -----------------------------------------------------------------------
  Future<void> _checkPermissions() async {
    final connectStatus = await Permission.bluetoothConnect.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    setState(() {
      _connectPerm = _toPerm(connectStatus);
      _locationPerm = _toPerm(locationStatus);
    });

    // Request any denied permissions
    final toRequest = <Permission>[];
    if (connectStatus.isDenied) toRequest.add(Permission.bluetoothConnect);
    if (locationStatus.isDenied) toRequest.add(Permission.locationWhenInUse);

    if (toRequest.isNotEmpty) {
      final statuses = await toRequest.request();
      setState(() {
        if (statuses.containsKey(Permission.bluetoothConnect)) {
          _connectPerm = _toPerm(statuses[Permission.bluetoothConnect]!);
        }
        if (statuses.containsKey(Permission.locationWhenInUse)) {
          _locationPerm = _toPerm(statuses[Permission.locationWhenInUse]!);
        }
      });
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
  // Bluetooth state
  // -----------------------------------------------------------------------
  Future<void> _checkBluetooth() async {
    final enabled = await _bluetooth.isEnabled;
    setState(() => _bluetoothEnabled = enabled ?? false);

    // Load bonded devices immediately (from cache, no scan needed)
    if (_allGranted && enabled == true) {
      try {
        final bonded = await _bluetooth.getBondedDevices();
        setState(() => _bondedDevices = bonded);
      } catch (_) {}
    }
  }

  Future<void> _requestBluetooth() async {
    final result = await _bluetooth.requestEnable();
    if (result == true) {
      setState(() => _bluetoothEnabled = true);
      _checkBluetooth();
    }
  }

  // -----------------------------------------------------------------------
  // Discovery (scan)
  // -----------------------------------------------------------------------
  Future<void> _startScan() async {
    if (!_allGranted) {
      _showSnackbar('Please grant all permissions first', Colors.red);
      return;
    }

    if (!_bluetoothEnabled) {
      _showSnackbar('Please turn on Bluetooth', Colors.orange);
      return;
    }

    setState(() {
      _devices = [];
      _isScanning = true;
      _statusText = 'Scanning for Bluetooth devices…';
    });

    try {
      await for (final result in _bluetooth.startDiscovery()) {
        if (!mounted) break;
        final device = result.device;
        // Only show devices with a name (likely OBD adapters)
        if (device.name != null && device.name!.isNotEmpty) {
          setState(() {
            if (!_devices.any((d) => d.address == device.address)) {
              _devices.add(device);
              _statusText = 'Found ${_devices.length} device(s)';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Scan error: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          if (_devices.isEmpty) {
            _statusText = 'No devices found';
          } else {
            _statusText = 'Found ${_devices.length} device(s)';
          }
        });
      }
    }
  }

  void _stopScan() {
    _bluetooth.cancelDiscovery();
    setState(() => _isScanning = false);
  }

  // -----------------------------------------------------------------------
  // Connection
  // -----------------------------------------------------------------------
  void _connectToDevice(BluetoothDevice device) async {
    _stopScan();
    setState(() => _statusText = 'Connecting to ${device.name}…');

    try {
      await _obd2Connection.connect(device.address);
      if (!mounted) return;
      setState(() => _statusText = 'Connected to ${device.name}');
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConnectedScreen(
            obd2Connection: _obd2Connection,
            deviceName: device.name ?? device.address,
          ),
        ),
      );
      _disconnect();
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusText = 'Connection failed');
      _showSnackbar('Failed to connect: $e', Colors.red);
      _disconnect();
    }
  }

  void _disconnect() async {
    try {
      await _obd2Connection.disconnect();
    } catch (_) {}
    if (mounted) {
      setState(() => _statusText = 'Disconnected');
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
          if (_allGranted && _bluetoothEnabled && !_isScanning)
            IconButton(
              icon: const Icon(Icons.bluetooth_searching_rounded),
              onPressed: _startScan,
              tooltip: 'Scan for devices',
            ),
          if (_isScanning)
            IconButton(
              icon: const Icon(Icons.stop_rounded),
              onPressed: _stopScan,
              tooltip: 'Stop scan',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Permissions not yet checked
    if (_connectPerm == _PermState.unknown) {
      return const Center(child: CircularProgressIndicator());
    }

    // Permissions denied
    if (!_allGranted) {
      return _buildPermissionsCard();
    }

    // Bluetooth disabled
    if (!_bluetoothEnabled) {
      return _buildBluetoothOffCard();
    }

    // Normal UI
    return Column(
      children: [
        // Status bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _isScanning
              ? Colors.blue.shade50
              : Colors.grey.shade100,
          child: Row(
            children: [
              Icon(
                _isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                size: 20,
                color: _isScanning ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isScanning
                        ? Colors.blue.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ),
              if (_isScanning)
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        // --- Bonded (paired) devices section ---
        if (_bondedDevices.isNotEmpty && !_isScanning) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Paired Devices',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ..._bondedDevices.map(
            (d) => _deviceTile(d, isBonded: true),
          ),
          const Divider(indent: 16, endIndent: 16),
        ],

        // --- Discovered devices ---
        if (_devices.isNotEmpty)
          Expanded(
            child: ListView(
              children: [
                if (!_isScanning && _bondedDevices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Nearby Devices',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ..._devices.map((d) => _deviceTile(d)),
              ],
            ),
          ),

        // --- Empty state / scan button ---
        if (_devices.isEmpty && !_isScanning)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bluetooth_searching_rounded,
                        size: 72, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Scan for OBD-II Bluetooth adapters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure your OBD adapter is plugged into\nthe vehicle and powered on.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _startScan,
                      icon: const Icon(Icons.search),
                      label: const Text('Scan for Devices'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _checkBluetooth,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh paired devices'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Guidance footer
        if (!_isScanning && _devices.isNotEmpty)
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
  // Device tile
  // -----------------------------------------------------------------------
  Widget _deviceTile(BluetoothDevice device, {bool isBonded = false}) {
    final name = (device.name != null && device.name!.isNotEmpty)
        ? device.name!
        : 'Unknown Device';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (isBonded ? Colors.green : Colors.blue).shade100,
        child: Icon(
          isBonded ? Icons.bluetooth_connected : Icons.bluetooth,
          color: isBonded ? Colors.green : Colors.blue,
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(device.address, style: const TextStyle(fontSize: 12)),
      trailing: ElevatedButton(
        onPressed: _isScanning ? null : () => _connectToDevice(device),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Text(isBonded ? 'Connect' : 'Connect'),
      ),
      enabled: !_isScanning,
    );
  }

  // -----------------------------------------------------------------------
  // Permissions card
  // -----------------------------------------------------------------------
  Widget _buildPermissionsCard() {
    final anyPermanently = _connectPerm == _PermState.permanentlyDenied ||
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
                  'Garage OBD needs the following permissions to scan and connect\nto your OBD-II Bluetooth adapter.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 24),
                _permissionRow(
                  Icons.bluetooth_connected,
                  'Bluetooth Connect',
                  'Pair and communicate with OBD adapter',
                  _connectPerm,
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
                        onPressed: _checkPermissions,
                        child: const Text('Check again'),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    onPressed: _checkPermissions,
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
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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

  // -----------------------------------------------------------------------
  // Bluetooth off card
  // -----------------------------------------------------------------------
  Widget _buildBluetoothOffCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_disabled, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Bluetooth is Off',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enable Bluetooth to scan for OBD-II adapters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _requestBluetooth,
              icon: const Icon(Icons.bluetooth),
              label: const Text('Turn on Bluetooth'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _checkBluetooth,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Check again'),
            ),
          ],
        ),
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
