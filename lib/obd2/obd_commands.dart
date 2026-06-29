// lib/obd2/obd_commands.dart

class ObdCommand {
  final String mode;
  final String pid;
  final String description;
  final String unit;
  final Function? parser;

  const ObdCommand({
    required this.mode,
    required this.pid,
    required this.description,
    this.unit = '',
    this.parser,
  });

  String get command => '$mode$pid';
}

class ObdCommands {
  // --- Mode 01: Current Data ---
  static final ENGINE_COOLANT_TEMP = ObdCommand(
    mode: '01', pid: '05', description: 'Engine Coolant Temp', unit: '°C',
    parser: (raw) => _parseCoolant(raw),
  );
  static final ENGINE_RPM = ObdCommand(
    mode: '01', pid: '0C', description: 'Engine RPM', unit: 'rpm',
    parser: (raw) => _parseRpm(raw),
  );
  static final VEHICLE_SPEED = ObdCommand(
    mode: '01', pid: '0D', description: 'Vehicle Speed', unit: 'km/h',
    parser: (raw) => _parseSpeed(raw),
  );
  static final CALC_ENGINE_LOAD = ObdCommand(
    mode: '01', pid: '04', description: 'Engine Load', unit: '%',
    parser: (raw) => _parsePercentage(raw),
  );
  static final TIMING_ADVANCE = ObdCommand(
    mode: '01', pid: '0A', description: 'Timing Advance', unit: 'deg',
    parser: (raw) => _parseTiming(raw),
  );
  static final MAP_PRESSURE = ObdCommand(
    mode: '01', pid: '0B', description: 'Intake Manifold Absolute Pressure', unit: 'kPa',
    parser: (raw) => _parseKpa(raw),
  );
  static final MAF_FLOW_RATE = ObdCommand(
    mode: '01', pid: '10', description: 'MAF Air Flow Rate', unit: 'g/s',
    parser: (raw) => _parseMaf(raw),
  );
  static final THROTTLE_POSITION = ObdCommand(
    mode: '01', pid: '11', description: 'Throttle Position', unit: '%',
    parser: (raw) => _parsePercentage(raw),
  );
  static final INTAKE_AIR_TEMP = ObdCommand(
    mode: '01', pid: '0F', description: 'Intake Air Temp', unit: '°C',
    parser: (raw) => _parseCoolant(raw), // Same as coolant formula
  );
  static final SHORT_TERM_FUEL_TRIM_B1 = ObdCommand(
    mode: '01', pid: '16', description: 'Short Term Fuel Trim (B1)', unit: '%',
    parser: (raw) => _parseFuelTrim(raw),
  );
  static final SHORT_TERM_FUEL_TRIM_B2 = ObdCommand(
    mode: '01', pid: '17', description: 'Short Term Fuel Trim (B2)', unit: '%',
    parser: (raw) => _parseFuelTrim(raw),
  );
  static final LONG_TERM_FUEL_TRIM_B1 = ObdCommand(
    mode: '01', pid: '18', description: 'Long Term Fuel Trim (B1)', unit: '%',
    parser: (raw) => _parseFuelTrim(raw),
  );
  static final LONG_TERM_FUEL_TRIM_B2 = ObdCommand(
    mode: '01', pid: '19', description: 'Long Term Fuel Trim (B2)', unit: '%',
    parser: (raw) => _parseFuelTrim(raw),
  );
  static final FUEL_RAIL_PRESSURE = ObdCommand(
    mode: '01', pid: '1A', description: 'Fuel Rail Pressure', unit: 'kPa',
    parser: (raw) => _parseKpa(raw),
  );
  static final ENGINE_OIL_TEMP = ObdCommand(
    mode: '01', pid: '1C', description: 'Engine Oil Temp', unit: '°C',
    parser: (raw) => _parseCoolant(raw),
  );
  static final CONTROL_MODULE_VOLTAGE = ObdCommand(
    mode: '01', pid: '42', description: 'Control Module Voltage', unit: 'V',
    parser: (raw) => _parseVoltage(raw),
  );

  // --- Mode 03: DTCs ---
  static final READ_DTC = ObdCommand(
    mode: '03', pid: '', description: 'Read Stored DTCs',
    parser: (raw) => _parseDTCs(raw),
  );

  // --- Mode 04: Clear DTCs ---
  static final CLEAR_DTC = ObdCommand(
    mode: '04', pid: '', description: 'Clear Stored DTCs',
  );

  // --- Parser Helpers ---
  static String _clean(String raw, String header) {
    String cleaned = raw.replaceAll(RegExp(r'[\s>]+'), '').trim().toUpperCase();
    if (cleaned.startsWith(header.toUpperCase())) {
      return cleaned.substring(header.length);
    }
    return cleaned;
  }

  static String _parseCoolant(String raw) {
    final val = _clean(raw, '4105'); // Simplified header
    if (val.length < 2) return 'N/A';
    return (int.parse(val.substring(0, 2), radix: 16) - 40).toString();
  }

  static String _parseRpm(String raw) {
    final val = _clean(raw, '410C');
    if (val.length < 4) return 'N/A';
    return ((int.parse(val.substring(0, 2), radix: 16) * 256 + int.parse(val.substring(2, 4), radix: 16)) / 4).toStringAsFixed(0);
  }

  static String _parseSpeed(String raw) {
    final val = _clean(raw, '410D');
    if (val.length < 2) return 'N/A';
    return int.parse(val.substring(0, 2), radix: 16).toString();
  }

  static String _parsePercentage(String raw) {
    final val = _clean(raw, '41'); // Generic percentage parse
    if (val.length < 2) return 'N/A';
    return (int.parse(val.substring(0, 2), radix: 16) * 100 / 255).toStringAsFixed(1);
  }

  static String _parseKpa(String raw) {
    final val = _clean(raw, '41');
    if (val.length < 2) return 'N/A';
    return int.parse(val.substring(0, 2), radix: 16).toString();
  }

  static String _parseMaf(String raw) {
    final val = _clean(raw, '4110');
    if (val.length < 4) return 'N/A';
    return ((int.parse(val.substring(0, 2), radix: 16) * 256 + int.parse(val.substring(2, 4), radix: 16)) / 100).toStringAsFixed(2);
  }

  static String _parseTiming(String raw) {
    final val = _clean(raw, '410A');
    if (val.length < 2) return 'N/A';
    return (int.parse(val.substring(0, 2), radix: 16) - 128).toString(); // Timing can be negative
  }

  static String _parseFuelTrim(String raw) {
    final val = _clean(raw, '41');
    if (val.length < 2) return 'N/A';
    int v = int.parse(val.substring(0, 2), radix: 16);
    return (v > 127 ? (v - 256) : v).toString();
  }

  static String _parseVoltage(String raw) {
    final val = _clean(raw, '4142');
    if (val.length < 2) return 'N/A';
    return (int.parse(val.substring(0, 2), radix: 16) / 10).toStringAsFixed(1);
  }

  static String _parseDTCs(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[\s>]+'), '').trim().toUpperCase();
    if (!cleaned.startsWith('43')) return 'No DTCs found.';
    final data = cleaned.substring(2);
    if (data.length < 4) return 'No DTCs found.';
    List<String> dtcs = [];
    for (int i = 0; i < data.length - 3; i += 4) {
      String hex = data.substring(i, i + 4);
      dtcs.add(_decodeDTC(hex));
    }
    return dtcs.join(', ');
  }

  static String _decodeDTC(String hex) {
    String cat = 'P';
    int first = int.parse(hex[0], radix: 16);
    if (first >= 4) cat = (first >= 8) ? 'U' : (first >= 6 ? 'C' : 'B');
    return '$cat${hex.substring(1)}';
  }
}
