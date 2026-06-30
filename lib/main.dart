import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'obd2/elm327_adapter.dart';
import 'obd2/obd_commands.dart';
import 'screens/live_data_screen.dart';
import 'widgets/rpm_gauge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// App entry point
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  runApp(const GarageOBDApp());
}

class GarageOBDApp extends StatelessWidget {
  const GarageOBDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage OBD',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const AppShell(),
    );
  }

  ThemeData _buildTheme() {
    const bg = Color(0xFF12121a);
    const card = Color(0xFF1a1a28);
    const border = Color(0xFF1e1e2e);
    const accent = Color(0xFF44aaff);
    const textDim = Color(0xFF667);
    const textWhite = Color(0xFFfff);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: bg,
        primary: accent,
        secondary: accent,
        onSurface: textWhite,
        onPrimary: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0e0e18),
        indicatorColor: accent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent);
          }
          return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textDim);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: textDim, size: 22);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(color: textWhite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App shell with bottom tab navigation
// ─────────────────────────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _elm327 = Elm327Adapter();
  bool _isConnected = false;

  void _onConnectionChanged(bool connected) {
    setState(() => _isConnected = connected);
  }

  @override
  void dispose() {
    _elm327.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DeviceScanShell(
            elm327: _elm327,
            onConnectionChanged: _onConnectionChanged,
          ),
          DashboardShell(
            elm327: _elm327,
            isConnected: _isConnected,
          ),
          const DtcScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bluetooth_outlined),
            selectedIcon: Icon(Icons.bluetooth),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed),
            label: 'Data',
          ),
          NavigationDestination(
            icon: Icon(Icons.error_outline_outlined),
            selectedIcon: Icon(Icons.error_outline),
            label: 'Codes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permissions helper
// ─────────────────────────────────────────────────────────────────────────────
enum _PermState { unknown, granted, denied, permanentlyDenied }

// ─────────────────────────────────────────────────────────────────────────────
// Device Scan Screen (embedded shell for tab)
// ─────────────────────────────────────────────────────────────────────────────
class DeviceScanShell extends StatefulWidget {
  final Elm327Adapter elm327;
  final ValueChanged<bool> onConnectionChanged;

  const DeviceScanShell({
    super.key,
    required this.elm327,
    required this.onConnectionChanged,
  });

  @override
  State<DeviceScanShell> createState() => _DeviceScanShellState();
}

class _DeviceScanShellState extends State<DeviceScanShell> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> _devices = [];
  List<BluetoothDevice> _bondedDevices = [];
  bool _isScanning = false;
  bool _bluetoothEnabled = false;
  String _statusText = 'Ready';

  _PermState _connectPerm = _PermState.unknown;
  _PermState _locationPerm = _PermState.unknown;
  bool get _allGranted =>
      _connectPerm == _PermState.granted &&
      _locationPerm == _PermState.granted;

  StreamSubscription? _discoverySub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkPermissions();
    await _checkBluetooth();
  }

  @override
  void dispose() {
    _discoverySub?.cancel();
    super.dispose();
  }

  // ── Permissions ──
  Future<void> _checkPermissions() async {
    final connectStatus = await Permission.bluetoothConnect.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    setState(() {
      _connectPerm = _toPerm(connectStatus);
      _locationPerm = _toPerm(locationStatus);
    });

    final toRequest = <Permission>[];
    if (connectStatus.isDenied) toRequest.add(Permission.bluetoothConnect);
    if (locationStatus.isDenied) toRequest.add(Permission.locationWhenInUse);

    if (toRequest.isNotEmpty) {
      final statuses = await toRequest.request();
      if (mounted) {
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
  }

  _PermState _toPerm(PermissionStatus s) {
    if (s.isGranted) return _PermState.granted;
    if (s.isPermanentlyDenied) return _PermState.permanentlyDenied;
    return _PermState.denied;
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  // ── Bluetooth state ──
  Future<void> _checkBluetooth() async {
    final enabled = await _bluetooth.isEnabled;
    if (mounted) setState(() => _bluetoothEnabled = enabled ?? false);

    if (_allGranted && enabled == true) {
      try {
        final bonded = await _bluetooth.getBondedDevices();
        if (mounted) setState(() => _bondedDevices = bonded);
      } catch (_) {}
    }
  }

  Future<void> _requestBluetooth() async {
    final result = await _bluetooth.requestEnable();
    if (result == true) {
      if (mounted) setState(() => _bluetoothEnabled = true);
      await _checkBluetooth();
    }
  }

  // ── Discovery ──
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
      _discoverySub?.cancel();
      _discoverySub = _bluetooth.startDiscovery().listen(
        (result) {
          if (mounted) {
            setState(() {
              final exists = _devices.any((d) => d.address == result.device.address);
              if (!exists) {
                _devices.add(result.device);
              }
              _statusText = 'Found ${_devices.length} device${_devices.length == 1 ? '' : 's'}';
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              _statusText = 'Scan error: $e';
              _isScanning = false;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isScanning = false;
              _statusText = _devices.isEmpty ? 'No devices found' : 'Scan complete';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusText = 'Scan failed: $e';
        });
      }
    }
  }

  void _stopScan() {
    _discoverySub?.cancel();
    setState(() {
      _isScanning = false;
      _statusText = 'Scan stopped';
    });
  }

  // ── Connection ──
  Future<void> _connectToDevice(BluetoothDevice device) async {
    _stopScan();
    setState(() => _statusText = 'Connecting to ${device.name}…');

    try {
      await widget.elm327.connect(device.address);
      if (!mounted) return;
      setState(() => _statusText = 'Connected to ${device.name}');
      widget.onConnectionChanged(true);
      _showSnackbar('Connected to ${device.name}', Colors.green);
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusText = 'Connection failed');
      _showSnackbar('Failed to connect: $e', Colors.red);
    }
  }

  void _showSnackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage OBD'),
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
    if (_connectPerm == _PermState.unknown) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF44aaff)));
    }
    if (!_allGranted) return _buildPermissions();
    if (!_bluetoothEnabled) return _buildBluetoothOff();
    return _buildScanUI();
  }

  // ── Permissions UI ──
  Widget _buildPermissions() {
    final anyPermanently = _connectPerm == _PermState.permanentlyDenied ||
        _locationPerm == _PermState.permanentlyDenied;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF44aaff).withValues(alpha: 0.1),
                  ),
                  child: const Icon(Icons.bluetooth_rounded, size: 44, color: Color(0xFF44aaff)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Permissions Required',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Garage OBD needs these permissions to scan and connect\nto your OBD-II Bluetooth adapter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
                ),
                const SizedBox(height: 28),
                _permissionRow(Icons.bluetooth_connected, 'Bluetooth Connect',
                    'Pair and communicate with OBD adapter', _connectPerm),
                const SizedBox(height: 12),
                _permissionRow(Icons.location_on, 'Location (While Using)',
                    'Required to discover Bluetooth devices', _locationPerm),
                const SizedBox(height: 28),
                if (anyPermanently)
                  Column(
                    children: [
                      const Text(
                        'Some permissions were permanently denied.\nPlease enable them in Settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Open Settings'),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    onPressed: _checkPermissions,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Grant Permissions'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _permissionRow(IconData icon, String title, String subtitle, _PermState state) {
    final isGranted = state == _PermState.granted;
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isGranted
                ? Colors.green.withValues(alpha: 0.1)
                : const Color(0xFF44aaff).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isGranted ? Colors.green : const Color(0xFF44aaff), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Icon(
          isGranted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isGranted ? Colors.green : const Color(0xFF556),
          size: 22,
        ),
      ],
    );
  }

  // ── Bluetooth Off UI ──
  Widget _buildBluetoothOff() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.bluetooth_disabled, size: 44, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bluetooth is Off',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enable Bluetooth to scan for\nyour OBD-II adapter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _requestBluetooth,
              icon: const Icon(Icons.bluetooth),
              label: const Text('Enable Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Scan UI ──
  Widget _buildScanUI() {
    return Column(
      children: [
        // Status bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _isScanning
              ? const Color(0xFF44aaff).withValues(alpha: 0.08)
              : const Color(0xFF1a1a28),
          child: Row(
            children: [
              Icon(
                _isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                size: 18,
                color: _isScanning ? const Color(0xFF44aaff) : const Color(0xFF556),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isScanning ? const Color(0xFF44aaff) : const Color(0xFF667),
                  ),
                ),
              ),
              if (_isScanning)
                SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFF44aaff),
                  ),
                ),
            ],
          ),
        ),

        // Paired devices
        if (_bondedDevices.isNotEmpty && !_isScanning) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Icon(Icons.bluetooth_connected, size: 14, color: Colors.green.shade400),
                const SizedBox(width: 6),
                Text(
                  'Paired Devices',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          ..._bondedDevices.map((d) => _deviceTile(d, isBonded: true)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
        ],

        // Discovered devices
        if (_devices.isNotEmpty)
          Expanded(
            child: ListView(
              children: [
                if (!_isScanning && _bondedDevices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.bluetooth_searching, size: 14, color: const Color(0xFF44aaff)),
                        const SizedBox(width: 6),
                        Text(
                          'Nearby Devices',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ..._devices.map((d) => _deviceTile(d)),
              ],
            ),
          ),

        // Empty state
        if (_devices.isEmpty && !_isScanning)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF44aaff).withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.bluetooth_searching_rounded,
                          size: 40, color: Color(0xFF44aaff)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Find Your OBD-II Adapter',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure your OBD adapter is plugged into\nthe vehicle and powered on.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _startScan,
                      icon: const Icon(Icons.search),
                      label: const Text('Scan for Devices'),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _checkBluetooth,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('Refresh paired devices',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ),
                    // Pairing guidance
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a1a28),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1e1e2e)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: const Color(0xFF44aaff)),
                          const SizedBox(height: 8),
                          Text(
                            'Need to pair first?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade300),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1. Put your OBD-II adapter in pairing mode\n'
                            '2. Go to your phone\'s Bluetooth settings\n'
                            '3. Pair with the device from there\n'
                            '4. Return here and tap Scan',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Footer guidance when devices found
        if (!_isScanning && _devices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tap Connect next to your OBD-II adapter.\n'
              'If you don\'t see it, make sure it\'s powered on and try scanning again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            ),
          ),
      ],
    );
  }

  // ── Device tile ──
  Widget _deviceTile(BluetoothDevice device, {bool isBonded = false}) {
    final name = (device.name != null && device.name!.isNotEmpty)
        ? device.name!
        : 'Unknown Device';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1e1e2e)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: (isBonded ? Colors.green : const Color(0xFF44aaff)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isBonded ? Icons.bluetooth_connected : Icons.bluetooth,
            color: isBonded ? Colors.green : const Color(0xFF44aaff),
            size: 22,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
        subtitle: Text(device.address, style: const TextStyle(fontSize: 11, color: Color(0xFF667))),
        trailing: SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: _isScanning ? null : () => _connectToDevice(device),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              backgroundColor: isBonded ? Colors.green : const Color(0xFF44aaff),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: Text(isBonded ? 'Connect' : 'Connect'),
          ),
        ),
        enabled: !_isScanning,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen (Data tab)
// ─────────────────────────────────────────────────────────────────────────────
class DashboardShell extends StatefulWidget {
  final Elm327Adapter elm327;
  final bool isConnected;

  const DashboardShell({
    super.key,
    required this.elm327,
    required this.isConnected,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  Timer? _pollTimer;
  double _rpm = 0;
  double _speed = 0;
  double _coolantTemp = 0;
  double _engineLoad = 0;
  double _intakeAirTemp = 0;
  double _throttlePos = 0;
  String _dtcCount = '0';

  @override
  void didUpdateWidget(DashboardShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected && !oldWidget.isConnected) {
      _startPolling();
    } else if (!widget.isConnected && oldWidget.isConnected) {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollOnce();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollOnce());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollOnce() async {
    if (!widget.isConnected) return;
    try {
      final rpmStr = await widget.elm327.sendObdCommand(ObdCommands.ENGINE_RPM);
      final speedStr = await widget.elm327.sendObdCommand(ObdCommands.VEHICLE_SPEED);
      final coolStr = await widget.elm327.sendObdCommand(ObdCommands.ENGINE_COOLANT_TEMP);
      final loadStr = await widget.elm327.sendObdCommand(ObdCommands.CALC_ENGINE_LOAD);
      final intakeStr = await widget.elm327.sendObdCommand(ObdCommands.INTAKE_AIR_TEMP);
      final throttleStr = await widget.elm327.sendObdCommand(ObdCommands.THROTTLE_POSITION);
      final dtcStr = await widget.elm327.sendObdCommand(ObdCommands.READ_DTC);

      if (mounted) {
        setState(() {
          _rpm = double.tryParse(rpmStr) ?? 0;
          _speed = double.tryParse(speedStr) ?? 0;
          _coolantTemp = double.tryParse(coolStr) ?? 0;
          _engineLoad = double.tryParse(loadStr) ?? 0;
          _intakeAirTemp = double.tryParse(intakeStr) ?? 0;
          _throttlePos = double.tryParse(throttleStr) ?? 0;
          _dtcCount = dtcStr.contains('No DTC') ? '0' : '${dtcStr.split(',').length}';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data'),
        actions: [
          if (widget.isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                    const SizedBox(width: 4),
                    const Text('Connected', style: TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: widget.isConnected ? _buildDashboard() : _buildNotConnected(),
    );
  }

  Widget _buildNotConnected() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF44aaff).withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.speed, size: 40, color: Color(0xFF44aaff)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Not Connected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect to an OBD-II adapter from the\nScan tab to see live data.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          // ── Engine section ──
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ENGINE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  RpmGauge(rpm: _rpm, maxRpm: 8000, segmentCount: 36),
                  const SizedBox(height: 16),
                  // Quick stats row
                  Row(
                    children: [
                      _statTile('${_speed.toStringAsFixed(0)}', 'km/h', 'Speed'),
                      _statTile('${_coolantTemp.toStringAsFixed(0)}°', '', 'Coolant'),
                      _statTile('${_engineLoad.toStringAsFixed(0)}%', '', 'Load'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Live Data Grid ──
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LIVE DATA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _dataRow('Intake Air Temp', '${_intakeAirTemp.toStringAsFixed(0)}°C', Icons.thermostat),
                  const Divider(),
                  _dataRow('Throttle Position', '${_throttlePos.toStringAsFixed(1)}%', Icons.tune),
                  const Divider(),
                  _dataRow('Stored DTCs', _dtcCount, Icons.error_outline),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Quick Actions ──
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ACTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _showLiveData(context, ObdCommands.ENGINE_RPM),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.show_chart, color: const Color(0xFF44aaff), size: 28),
                          const SizedBox(height: 6),
                          Text('RPM Chart', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _showLiveData(context, ObdCommands.VEHICLE_SPEED),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.show_chart, color: const Color(0xFF44aaff), size: 28),
                          const SizedBox(height: 6),
                          Text('Speed Chart', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _showLiveData(context, ObdCommands.ENGINE_COOLANT_TEMP),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.show_chart, color: const Color(0xFF44aaff), size: 28),
                          const SizedBox(height: 6),
                          Text('Temp Chart', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String value, String unit, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 2),
                  child: Text(
                    unit,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF44aaff)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFFccc))),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showLiveData(BuildContext context, ObdCommand command) {
    if (!widget.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to a device')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveDataScreen(
          obd2Connection: widget.elm327,
          command: command,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DTC Screen
// ─────────────────────────────────────────────────────────────────────────────
class DtcScreen extends StatelessWidget {
  const DtcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Codes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF44aaff).withValues(alpha: 0.08),
                ),
                child: const Icon(Icons.error_outline, size: 40, color: Color(0xFF44aaff)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Diagnostic Trouble Codes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect to an OBD-II adapter and navigate to\nthe Data tab to read DTCs.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Screen
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'CONNECTION',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: Color(0xFF667), letterSpacing: 2,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                _settingTile(Icons.bluetooth, 'Bluetooth Settings',
                    'Manage paired devices'),
                const Divider(),
                _settingTile(Icons.info_outline, 'About OBD-II Adapter',
                    'Connection info & status'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'DATA',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: Color(0xFF667), letterSpacing: 2,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                _settingTile(Icons.storage, 'Logging',
                    'Manage OBD-II data logs'),
                const Divider(),
                _settingTile(Icons.delete_outline, 'Clear Logs',
                    'Delete all stored PID logs'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: Color(0xFF667), letterSpacing: 2,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                _settingTile(Icons.code, 'App Version',
                    '1.0.0+1'),
                const Divider(),
                _settingTile(Icons.favorite_outline, 'Garage OBD',
                    'Open-source OBD-II diagnostics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF44aaff).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF44aaff), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF556), size: 20),
    );
  }
}
