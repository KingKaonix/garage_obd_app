// lib/obd2/manufacturer_pids.dart

class ManufacturerPid {
  final String manufacturer;
  final String mode;
  final String pid;
  final String description;
  final String unit;
  final Function parser;

  const ManufacturerPid({
    required this.manufacturer,
    required this.mode,
    required this.pid,
    required this.description,
    this.unit = '',
    required this.parser,
  });

  String get command => '$mode$pid';
}

class ManufacturerPids {
  // This list will be populated with PIDs specific to various manufacturers.
  // Real-world values require extensive reverse engineering or access to manufacturer documentation.
  static final List<ManufacturerPid> _pids = [
    // --- Ford Specific PIDs (Mode 22) ---
    ManufacturerPid(
      manufacturer: 'Ford',
      mode: '22',
      pid: '03B1',
      description: 'Fuel Rail Pressure (Gauge)',
      unit: 'kPa',
      parser: (String rawResponse) {
        final String cleaned = rawResponse.replaceAll(RegExp(r'[\s>]+'), '').trim();
        if (cleaned.startsWith('6203B1') && cleaned.length >= 8) {
          final hexValue = cleaned.substring(6, 10);
          final int decimalValue = int.parse(hexValue, radix: 16);
          return (decimalValue * 0.703).toStringAsFixed(2);
        }
        return 'N/A';
      },
    ),
    ManufacturerPid(
      manufacturer: 'Ford',
      mode: '22',
      pid: '166E',
      description: 'Injector Pulse Width',
      unit: 'ms',
      parser: (String rawResponse) {
        final String cleaned = rawResponse.replaceAll(RegExp(r'[\s>]+'), '').trim();
        if (cleaned.startsWith('62166E') && cleaned.length >= 8) {
          final hexValue = cleaned.substring(6, 10);
          final int decimalValue = int.parse(hexValue, radix: 16);
          return (decimalValue * 0.001).toStringAsFixed(3); // Example
        }
        return 'N/A';
      },
    ),
    // --- GM Specific PIDs (Mode 22) ---
    ManufacturerPid(
      manufacturer: 'GM',
      mode: '22',
      pid: '2001',
      description: 'Engine Oil Life Remaining',
      unit: '%',
      parser: (String rawResponse) {
        final String cleaned = rawResponse.replaceAll(RegExp(r'[\s>]+'), '').trim();
        if (cleaned.startsWith('622001') && cleaned.length >= 8) {
          final hexValue = cleaned.substring(6, 8); // Single byte
          final int decimalValue = int.parse(hexValue, radix: 16);
          return decimalValue.toString();
        }
        return 'N/A';
      },
    ),
    ManufacturerPid(
      manufacturer: 'GM',
      mode: '22',
      pid: '1116',
      description: 'Transmission Fluid Temperature',
      unit: '°C',
      parser: (String rawResponse) {
        final String cleaned = rawResponse.replaceAll(RegExp(r'[\s>]+'), '').trim();
        if (cleaned.startsWith('621116') && cleaned.length >= 8) {
          final hexValue = cleaned.substring(6, 8);
          final int decimalValue = int.parse(hexValue, radix: 16);
          return (decimalValue - 40).toString(); // (A-40)
        }
        return 'N/A';
      },
    ),
    // --- Toyota Specific PIDs (Mode 21) ---
    ManufacturerPid(
      manufacturer: 'Toyota',
      mode: '21', // Toyota often uses Mode 21 for enhanced data
      pid: '80',
      description: 'Hybrid Battery SOC',
      unit: '%',
      parser: (String rawResponse) {
        final String cleaned = rawResponse.replaceAll(RegExp(r'[\s>]+'), '').trim();
        if (cleaned.startsWith('6180') && cleaned.length >= 6) {
          final hexValue = cleaned.substring(4, 6);
          final int decimalValue = int.parse(hexValue, radix: 16);
          return (decimalValue * 100 / 255).toStringAsFixed(1); // Example
        }
        return 'N/A';
      },
    ),
    // --- Chrysler/Stellantis Specific PIDs (Mode 22) ---
    ManufacturerPid(
      manufacturer: 'Chrysler',
      mode: '22',
      pid: 'C410',
      description: 'Transfer Case Temp',
      unit: '°C',
      parser: (String rawResponse) {
        final String cleaned = rawResponse.replaceAll(RegExp(r'[\s>]+'), '').trim();
        if (cleaned.startsWith('62C410') && cleaned.length >= 8) {
          final hexValue = cleaned.substring(6, 8);
          final int decimalValue = int.parse(hexValue, radix: 16);
          return (decimalValue - 40).toString(); // (A-40)
        }
        return 'N/A';
      },
    ),
  ];

  static List<ManufacturerPid> getPidsForManufacturer(String manufacturer) {
    return _pids.where((p) => p.manufacturer.toLowerCase() == manufacturer.toLowerCase()).toList();
  }

  static ManufacturerPid? getPidByCommand(String mode, String pid) {
    try {
      return _pids.firstWhere((p) => p.mode == mode && p.pid == pid);
    } catch (e) {
      return null; // Or throw a more specific exception
    }
  }

  static List<String> getSupportedManufacturers() {
    return _pids.map((p) => p.manufacturer).toSet().toList();
  }
}
