// lib/obd2/special_functions.dart

import 'package:flutter/foundation.dart';
import 'elm327_adapter.dart';

// Abstract class for any special function
abstract class SpecialFunction {
  final String name;
  final String description;
  final String manufacturer;

  const SpecialFunction({
    required this.name,
    required this.description,
    this.manufacturer = 'Generic',
  });

  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier);
}

// Oil Life Reset (example)
class OilLifeResetFunction extends SpecialFunction {
  const OilLifeResetFunction({String manufacturer = 'Generic'})
      : super(
          name: 'Oil Life Reset',
          description: 'Resets the engine oil life monitor.',
          manufacturer: manufacturer,
        );

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Oil Life Reset...';
    try {
      statusNotifier.value = 'Attempting to establish communication...';
      String response1 = await adapter.sendRawCommand('ATSH7E0');
      statusNotifier.value = 'Response 1: $response1';
      await Future.delayed(Duration(milliseconds: 200));

      statusNotifier.value = 'Sending reset command (example)...';
      String response2 = await adapter.sendRawCommand('22F007');
      statusNotifier.value = 'Response 2: $response2';
      await Future.delayed(Duration(milliseconds: 200));

      statusNotifier.value = 'Verifying reset...';
      String response3 = await adapter.sendRawCommand('22F007');
      statusNotifier.value = 'Response 3: $response3';
      await Future.delayed(Duration(milliseconds: 200));

      return 'Oil Life Reset Completed. (Verification needed from user)';
    } catch (e) {
      statusNotifier.value = 'Oil Life Reset Failed: $e';
      return 'Failed: $e';
    }
  }
}

// Placeholder for a multi-step command sequence, as SpecialFunction currently takes dynamic
class DummyObdCommand {
  final String command;
  final String mode;
  final String pid;
  final String description;
  final String unit;
  final Function parser;

  const DummyObdCommand(
      this.command, this.mode, this.pid, {this.description = '', this.unit = ''})
      : parser = _dummyParser;

  static String _dummyParser(String rawResponse) {
    return rawResponse.replaceAll(RegExp(r'[\s>]+'), '').trim();
  }
}

// --- Generated GM Special Functions ---

class GmBrakePedalPositionSensorLearnFunction extends SpecialFunction {
  const GmBrakePedalPositionSensorLearnFunction() : super(name: 'Brake Pedal Position Sensor Learn', description: 'Brake Pedal Position Sensor Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Brake Pedal Position Sensor Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 11 24', '07 AE 20 00 00 00 00 02', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Brake Pedal Position Sensor Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Brake Pedal Position Sensor Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmEngineOilPressureValveOffFunction extends SpecialFunction {
  const GmEngineOilPressureValveOffFunction() : super(name: 'Engine Oil Pressure Valve Off', description: 'Engine Oil Pressure Valve Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Engine Oil Pressure Valve Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 00 02 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Engine Oil Pressure Valve Off completed.';
    } catch (e) {
      statusNotifier.value = 'Engine Oil Pressure Valve Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmEngineOilPressureValveOnFunction extends SpecialFunction {
  const GmEngineOilPressureValveOnFunction() : super(name: 'Engine Oil Pressure Valve On', description: 'Engine Oil Pressure Valve On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Engine Oil Pressure Valve On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 00 03 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Engine Oil Pressure Valve On completed.';
    } catch (e) {
      statusNotifier.value = 'Engine Oil Pressure Valve On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmEngineOilPressureValveReleaseFunction extends SpecialFunction {
  const GmEngineOilPressureValveReleaseFunction() : super(name: 'Engine Oil Pressure Valve Release', description: 'Engine Oil Pressure Valve Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Engine Oil Pressure Valve Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Engine Oil Pressure Valve Release completed.';
    } catch (e) {
      statusNotifier.value = 'Engine Oil Pressure Valve Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmEvapServiceBayTestFunction extends SpecialFunction {
  const GmEvapServiceBayTestFunction() : super(name: 'EVAP Service Bay Test', description: 'EVAP Service Bay Test for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting EVAP Service Bay Test...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 20 66', '07 AE 18 00 00 40 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'EVAP Service Bay Test completed.';
    } catch (e) {
      statusNotifier.value = 'EVAP Service Bay Test Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmFuelRailPressureReliefValveLearnFunction extends SpecialFunction {
  const GmFuelRailPressureReliefValveLearnFunction() : super(name: 'Fuel Rail Pressure Relief Valve Learn', description: 'Fuel Rail Pressure Relief Valve Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Fuel Rail Pressure Relief Valve Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 1A 04 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Fuel Rail Pressure Relief Valve Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Fuel Rail Pressure Relief Valve Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmGeneratorTerminalOffFunction extends SpecialFunction {
  const GmGeneratorTerminalOffFunction() : super(name: 'Generator Terminal Off', description: 'Generator Terminal Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Generator Terminal Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 08 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Generator Terminal Off completed.';
    } catch (e) {
      statusNotifier.value = 'Generator Terminal Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmGeneratorTerminalOnFunction extends SpecialFunction {
  const GmGeneratorTerminalOnFunction() : super(name: 'Generator Terminal On', description: 'Generator Terminal On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Generator Terminal On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 0C 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Generator Terminal On completed.';
    } catch (e) {
      statusNotifier.value = 'Generator Terminal On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmGeneratorTerminalReleaseFunction extends SpecialFunction {
  const GmGeneratorTerminalReleaseFunction() : super(name: 'Generator Terminal Release', description: 'Generator Terminal Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Generator Terminal Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Generator Terminal Release completed.';
    } catch (e) {
      statusNotifier.value = 'Generator Terminal Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmHeatedO2SensorHeaterLearnFunction extends SpecialFunction {
  const GmHeatedO2SensorHeaterLearnFunction() : super(name: 'Heated O2 Sensor Heater Learn', description: 'Heated O2 Sensor Heater Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Heated O2 Sensor Heater Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 00 03', '07 AE 1E 08 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Heated O2 Sensor Heater Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Heated O2 Sensor Heater Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmIdleLearnFunction extends SpecialFunction {
  const GmIdleLearnFunction() : super(name: 'Idle Learn', description: 'Idle Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Idle Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 20 66', '07 AE 14 10 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Idle Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Idle Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmIgnitionTimingOnFunction extends SpecialFunction {
  const GmIgnitionTimingOnFunction() : super(name: 'Ignition Timing On', description: 'Ignition Timing On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Ignition Timing On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 20 00 02 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Ignition Timing On completed.';
    } catch (e) {
      statusNotifier.value = 'Ignition Timing On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmIgnitionTimingReleaseFunction extends SpecialFunction {
  const GmIgnitionTimingReleaseFunction() : super(name: 'Ignition Timing Release', description: 'Ignition Timing Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Ignition Timing Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Ignition Timing Release completed.';
    } catch (e) {
      statusNotifier.value = 'Ignition Timing Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmMilLampOffFunction extends SpecialFunction {
  const GmMilLampOffFunction() : super(name: 'MIL Lamp Off', description: 'MIL Lamp Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting MIL Lamp Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 80 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'MIL Lamp Off completed.';
    } catch (e) {
      statusNotifier.value = 'MIL Lamp Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmMilLampOnFunction extends SpecialFunction {
  const GmMilLampOnFunction() : super(name: 'MIL Lamp On', description: 'MIL Lamp On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting MIL Lamp On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 C0 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'MIL Lamp On completed.';
    } catch (e) {
      statusNotifier.value = 'MIL Lamp On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmMilLampReleaseFunction extends SpecialFunction {
  const GmMilLampReleaseFunction() : super(name: 'MIL Lamp Release', description: 'MIL Lamp Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting MIL Lamp Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'MIL Lamp Release completed.';
    } catch (e) {
      statusNotifier.value = 'MIL Lamp Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmRemoteVehicleStartDisableHistoryResetFunction extends SpecialFunction {
  const GmRemoteVehicleStartDisableHistoryResetFunction() : super(name: 'Remote Start Disable History Reset', description: 'Remote Start Disable History Reset for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Remote Start Disable History Reset...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 01 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Remote Start Disable History Reset completed.';
    } catch (e) {
      statusNotifier.value = 'Remote Start Disable History Reset Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmStarterRelayOffFunction extends SpecialFunction {
  const GmStarterRelayOffFunction() : super(name: 'Starter Relay Off', description: 'Starter Relay Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Starter Relay Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 08 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Starter Relay Off completed.';
    } catch (e) {
      statusNotifier.value = 'Starter Relay Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmStarterRelayOnFunction extends SpecialFunction {
  const GmStarterRelayOnFunction() : super(name: 'Starter Relay On', description: 'Starter Relay On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Starter Relay On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 0C 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Starter Relay On completed.';
    } catch (e) {
      statusNotifier.value = 'Starter Relay On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmStarterRelayReleaseFunction extends SpecialFunction {
  const GmStarterRelayReleaseFunction() : super(name: 'Starter Relay Release', description: 'Starter Relay Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Starter Relay Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Starter Relay Release completed.';
    } catch (e) {
      statusNotifier.value = 'Starter Relay Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSuperchargerBypassSolenoidValveDecreaseFunction extends SpecialFunction {
  const GmSuperchargerBypassSolenoidValveDecreaseFunction() : super(name: 'Supercharger Bypass Solenoid Valve Decrease', description: 'Supercharger Bypass Solenoid Valve Decrease for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Supercharger Bypass Solenoid Valve Decrease...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 14 00 00 00 80 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Supercharger Bypass Solenoid Valve Decrease completed.';
    } catch (e) {
      statusNotifier.value = 'Supercharger Bypass Solenoid Valve Decrease Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSuperchargerBypassSolenoidValveIncreaseFunction extends SpecialFunction {
  const GmSuperchargerBypassSolenoidValveIncreaseFunction() : super(name: 'Supercharger Bypass Solenoid Valve Increase', description: 'Supercharger Bypass Solenoid Valve Increase for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Supercharger Bypass Solenoid Valve Increase...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 14 00 00 00 80 19', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Supercharger Bypass Solenoid Valve Increase completed.';
    } catch (e) {
      statusNotifier.value = 'Supercharger Bypass Solenoid Valve Increase Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSuperchargerBypassSolenoidValveReleaseFunction extends SpecialFunction {
  const GmSuperchargerBypassSolenoidValveReleaseFunction() : super(name: 'Supercharger Bypass Solenoid Valve Release', description: 'Supercharger Bypass Solenoid Valve Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Supercharger Bypass Solenoid Valve Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Supercharger Bypass Solenoid Valve Release completed.';
    } catch (e) {
      statusNotifier.value = 'Supercharger Bypass Solenoid Valve Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmInjCodeFunction extends SpecialFunction {
  const GmInjCodeFunction() : super(name: 'Inj Code', description: 'Inj Code for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Inj Code...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT SH 7E0', 'AT CRA 7E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '3E', '01 30', '01 33', '01 31', '01 32', '01 34'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Inj Code completed.';
    } catch (e) {
      statusNotifier.value = 'Inj Code Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmInjReadFunction extends SpecialFunction {
  const GmInjReadFunction() : super(name: 'Inj Read', description: 'Inj Read for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Inj Read...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT SH 7E0', 'AT CRA 7E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '3E', '01 11'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Inj Read completed.';
    } catch (e) {
      statusNotifier.value = 'Inj Read Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnAcRelayOffFunction extends SpecialFunction {
  const GmSaturnAcRelayOffFunction() : super(name: 'Saturn Ac Relay Off', description: 'Saturn Ac Relay Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Ac Relay Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 20 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Ac Relay Off completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Ac Relay Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnAcRelayOnFunction extends SpecialFunction {
  const GmSaturnAcRelayOnFunction() : super(name: 'Saturn Ac Relay On', description: 'Saturn Ac Relay On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Ac Relay On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 30 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Ac Relay On completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Ac Relay On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnCoolingFanRelayOffFunction extends SpecialFunction {
  const GmSaturnCoolingFanRelayOffFunction() : super(name: 'Saturn Cooling Fan Relay Off', description: 'Saturn Cooling Fan Relay Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Cooling Fan Relay Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 80 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Cooling Fan Relay Off completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Cooling Fan Relay Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnCoolingFanRelayOnFunction extends SpecialFunction {
  const GmSaturnCoolingFanRelayOnFunction() : super(name: 'Saturn Cooling Fan Relay On', description: 'Saturn Cooling Fan Relay On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Cooling Fan Relay On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 F0 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Cooling Fan Relay On completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Cooling Fan Relay On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnIdleSparkDecreaseFunction extends SpecialFunction {
  const GmSaturnIdleSparkDecreaseFunction() : super(name: 'Saturn Idle Spark Decrease', description: 'Saturn Idle Spark Decrease for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Idle Spark Decrease...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 00 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Idle Spark Decrease completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Idle Spark Decrease Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnIdleSparkIncreaseFunction extends SpecialFunction {
  const GmSaturnIdleSparkIncreaseFunction() : super(name: 'Saturn Idle Spark Increase', description: 'Saturn Idle Spark Increase for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Idle Spark Increase...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 10 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Idle Spark Increase completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Idle Spark Increase Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnRvsDisplayHistoryResetFunction extends SpecialFunction {
  const GmSaturnRvsDisplayHistoryResetFunction() : super(name: 'Saturn Rvs Display History Reset', description: 'Saturn Rvs Display History Reset for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Rvs Display History Reset...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 01 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Rvs Display History Reset completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Rvs Display History Reset Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnSparkRetardDecreaseFunction extends SpecialFunction {
  const GmSaturnSparkRetardDecreaseFunction() : super(name: 'Saturn Spark Retard Decrease', description: 'Saturn Spark Retard Decrease for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Spark Retard Decrease...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 20 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Spark Retard Decrease completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Spark Retard Decrease Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnSparkRetardIncreaseFunction extends SpecialFunction {
  const GmSaturnSparkRetardIncreaseFunction() : super(name: 'Saturn Spark Retard Increase', description: 'Saturn Spark Retard Increase for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Spark Retard Increase...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 20 00 03 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Spark Retard Increase completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Spark Retard Increase Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnThrottlePositionDecreaseFunction extends SpecialFunction {
  const GmSaturnThrottlePositionDecreaseFunction() : super(name: 'Saturn Throttle Position Decrease', description: 'Saturn Throttle Position Decrease for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Throttle Position Decrease...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '06 2C FE 00 0C 00 0D', '07 AE 14 80 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Throttle Position Decrease completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Throttle Position Decrease Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmSaturnThrottlePositionIncreaseFunction extends SpecialFunction {
  const GmSaturnThrottlePositionIncreaseFunction() : super(name: 'Saturn Throttle Position Increase', description: 'Saturn Throttle Position Increase for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Saturn Throttle Position Increase...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '06 2C FE 00 0C 00 0D', '07 AE 14 80 1A 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Saturn Throttle Position Increase completed.';
    } catch (e) {
      statusNotifier.value = 'Saturn Throttle Position Increase Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmThrottleResetFunction extends SpecialFunction {
  const GmThrottleResetFunction() : super(name: 'Throttle Reset', description: 'Throttle Reset for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Throttle Reset...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT SH 7E0', 'AT CRA 7E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '3E', 'AA 00', 'AE 14 10 00 00 00 00', 'AE 01 00 00 10 00 00 ', 'AE B3 00 04', 'AE 14 01 00 00 00 00', 'AE FE 10', 'AE FE 10 00 00 00 00', 'AE 14 10 00 00 00 00', 'AE 14 20 00 00 00 00', '3E'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Throttle Reset completed.';
    } catch (e) {
      statusNotifier.value = 'Throttle Reset Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmTransmissionPressureFunction extends SpecialFunction {
  const GmTransmissionPressureFunction() : super(name: 'Transmission Pressure', description: 'Transmission Pressure for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Transmission Pressure...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT SH 7E2', 'AT CRA 7EA', 'AT FC SH 7E2', 'AT FC SD 30', 'AT FC SM 1', '3E', 'AE 30 00 00 C0 00 00'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Transmission Pressure completed.';
    } catch (e) {
      statusNotifier.value = 'Transmission Pressure Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmTransmissionValuesFunction extends SpecialFunction {
  const GmTransmissionValuesFunction() : super(name: 'Transmission Values', description: 'Transmission Values for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Transmission Values...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT SH 7E2', 'AT CRA 7EA', 'AT FC SH 7E2', 'AT FC SD 30', 'AT FC SM 1', '3E', '2C FE 19 40'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Transmission Values completed.';
    } catch (e) {
      statusNotifier.value = 'Transmission Values Failed: $e';
      return 'Failed: $e';
    }
  }
}

// Add these to SpecialFunctionsManager:

// --- Manager for Special Functions ---
class SpecialFunctionsManager {
  static final List<SpecialFunction> _availableFunctions = [
    const OilLifeResetFunction(),
    const GmBrakePedalPositionSensorLearnFunction(),
    const GmEngineOilPressureValveOffFunction(),
    const GmEngineOilPressureValveOnFunction(),
    const GmEngineOilPressureValveReleaseFunction(),
    const GmEvapServiceBayTestFunction(),
    const GmFuelRailPressureReliefValveLearnFunction(),
    const GmGeneratorTerminalOffFunction(),
    const GmGeneratorTerminalOnFunction(),
    const GmGeneratorTerminalReleaseFunction(),
    const GmHeatedO2SensorHeaterLearnFunction(),
    const GmIdleLearnFunction(),
    const GmIgnitionTimingOnFunction(),
    const GmIgnitionTimingReleaseFunction(),
    const GmMilLampOffFunction(),
    const GmMilLampOnFunction(),
    const GmMilLampReleaseFunction(),
    const GmRemoteVehicleStartDisableHistoryResetFunction(),
    const GmStarterRelayOffFunction(),
    const GmStarterRelayOnFunction(),
    const GmStarterRelayReleaseFunction(),
    const GmSuperchargerBypassSolenoidValveDecreaseFunction(),
    const GmSuperchargerBypassSolenoidValveIncreaseFunction(),
    const GmSuperchargerBypassSolenoidValveReleaseFunction(),
    const GmInjCodeFunction(),
    const GmInjReadFunction(),
    const GmSaturnAcRelayOffFunction(),
    const GmSaturnAcRelayOnFunction(),
    const GmSaturnCoolingFanRelayOffFunction(),
    const GmSaturnCoolingFanRelayOnFunction(),
    const GmSaturnIdleSparkDecreaseFunction(),
    const GmSaturnIdleSparkIncreaseFunction(),
    const GmSaturnRvsDisplayHistoryResetFunction(),
    const GmSaturnSparkRetardDecreaseFunction(),
    const GmSaturnSparkRetardIncreaseFunction(),
    const GmSaturnThrottlePositionDecreaseFunction(),
    const GmSaturnThrottlePositionIncreaseFunction(),
    const GmThrottleResetFunction(),
    const GmTransmissionPressureFunction(),
    const GmTransmissionValuesFunction(),
  ];

  static List<SpecialFunction> getAvailableFunctions() {
    return _availableFunctions;
  }
}
