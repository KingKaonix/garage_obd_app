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

class GmCadillacCadillacBrakePedalPositionSensorLearnFunction extends SpecialFunction {
  const GmCadillacCadillacBrakePedalPositionSensorLearnFunction() : super(name: 'Cadillac Cadillac Brake Pedal Position Sensor Learn', description: 'Cadillac Cadillac Brake Pedal Position Sensor Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Cadillac Brake Pedal Position Sensor Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 11 24', '07 AE 20 00 00 00 00 02', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Cadillac Brake Pedal Position Sensor Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Cadillac Brake Pedal Position Sensor Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacEngineOilPressureValveOffFunction extends SpecialFunction {
  const GmCadillacEngineOilPressureValveOffFunction() : super(name: 'Cadillac Engine Oil Pressure Valve Off', description: 'Cadillac Engine Oil Pressure Valve Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Engine Oil Pressure Valve Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 00 02 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Engine Oil Pressure Valve Off completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Engine Oil Pressure Valve Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacEngineOilPressureValveOnFunction extends SpecialFunction {
  const GmCadillacEngineOilPressureValveOnFunction() : super(name: 'Cadillac Engine Oil Pressure Valve On', description: 'Cadillac Engine Oil Pressure Valve On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Engine Oil Pressure Valve On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 00 03 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Engine Oil Pressure Valve On completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Engine Oil Pressure Valve On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacEngineOilPressureValveReleaseFunction extends SpecialFunction {
  const GmCadillacEngineOilPressureValveReleaseFunction() : super(name: 'Cadillac Engine Oil Pressure Valve Release', description: 'Cadillac Engine Oil Pressure Valve Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Engine Oil Pressure Valve Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Engine Oil Pressure Valve Release completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Engine Oil Pressure Valve Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacEvapServiceBayTestFunction extends SpecialFunction {
  const GmCadillacEvapServiceBayTestFunction() : super(name: 'Cadillac Evap Service Bay Test', description: 'Cadillac Evap Service Bay Test for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Evap Service Bay Test...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 20 66', '07 AE 18 00 00 40 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Evap Service Bay Test completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Evap Service Bay Test Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacFuelRailPressureReliefValveLearnFunction extends SpecialFunction {
  const GmCadillacFuelRailPressureReliefValveLearnFunction() : super(name: 'Cadillac Fuel Rail Pressure Relief Valve Learn', description: 'Cadillac Fuel Rail Pressure Relief Valve Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Fuel Rail Pressure Relief Valve Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 1A 04 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Fuel Rail Pressure Relief Valve Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Fuel Rail Pressure Relief Valve Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacGeneratorTerminalOffFunction extends SpecialFunction {
  const GmCadillacGeneratorTerminalOffFunction() : super(name: 'Cadillac Generator Terminal Off', description: 'Cadillac Generator Terminal Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Generator Terminal Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 08 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Generator Terminal Off completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Generator Terminal Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacGeneratorTerminalOnFunction extends SpecialFunction {
  const GmCadillacGeneratorTerminalOnFunction() : super(name: 'Cadillac Generator Terminal On', description: 'Cadillac Generator Terminal On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Generator Terminal On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 0C 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Generator Terminal On completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Generator Terminal On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacGeneratorTerminalReleaseFunction extends SpecialFunction {
  const GmCadillacGeneratorTerminalReleaseFunction() : super(name: 'Cadillac Generator Terminal Release', description: 'Cadillac Generator Terminal Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Generator Terminal Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Generator Terminal Release completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Generator Terminal Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacHeatedO2SensorHeaterLearnFunction extends SpecialFunction {
  const GmCadillacHeatedO2SensorHeaterLearnFunction() : super(name: 'Cadillac Heated O2 Sensor Heater Learn', description: 'Cadillac Heated O2 Sensor Heater Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Heated O2 Sensor Heater Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 00 03', '07 AE 1E 08 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Heated O2 Sensor Heater Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Heated O2 Sensor Heater Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacIdleLearnFunction extends SpecialFunction {
  const GmCadillacIdleLearnFunction() : super(name: 'Cadillac Idle Learn', description: 'Cadillac Idle Learn for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Idle Learn...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '03 22 20 66', '07 AE 14 10 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Idle Learn completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Idle Learn Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacIgnitionTimingOnFunction extends SpecialFunction {
  const GmCadillacIgnitionTimingOnFunction() : super(name: 'Cadillac Ignition Timing On', description: 'Cadillac Ignition Timing On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Ignition Timing On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 10 20 00 02 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Ignition Timing On completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Ignition Timing On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacIgnitionTimingReleaseFunction extends SpecialFunction {
  const GmCadillacIgnitionTimingReleaseFunction() : super(name: 'Cadillac Ignition Timing Release', description: 'Cadillac Ignition Timing Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Ignition Timing Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Ignition Timing Release completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Ignition Timing Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacMilLampOffFunction extends SpecialFunction {
  const GmCadillacMilLampOffFunction() : super(name: 'Cadillac Mil Lamp Off', description: 'Cadillac Mil Lamp Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Mil Lamp Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 80 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Mil Lamp Off completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Mil Lamp Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacMilLampOnFunction extends SpecialFunction {
  const GmCadillacMilLampOnFunction() : super(name: 'Cadillac Mil Lamp On', description: 'Cadillac Mil Lamp On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Mil Lamp On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 C0 00 00 00 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Mil Lamp On completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Mil Lamp On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacMilLampReleaseFunction extends SpecialFunction {
  const GmCadillacMilLampReleaseFunction() : super(name: 'Cadillac Mil Lamp Release', description: 'Cadillac Mil Lamp Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Mil Lamp Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Mil Lamp Release completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Mil Lamp Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacRemoteVehicleStartDisableHistoryResetFunction extends SpecialFunction {
  const GmCadillacRemoteVehicleStartDisableHistoryResetFunction() : super(name: 'Cadillac Remote Vehicle Start Disable History Reset', description: 'Cadillac Remote Vehicle Start Disable History Reset for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Remote Vehicle Start Disable History Reset...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 01 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Remote Vehicle Start Disable History Reset completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Remote Vehicle Start Disable History Reset Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacStarterRelayOffFunction extends SpecialFunction {
  const GmCadillacStarterRelayOffFunction() : super(name: 'Cadillac Starter Relay Off', description: 'Cadillac Starter Relay Off for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Starter Relay Off...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 08 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Starter Relay Off completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Starter Relay Off Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacStarterRelayOnFunction extends SpecialFunction {
  const GmCadillacStarterRelayOnFunction() : super(name: 'Cadillac Starter Relay On', description: 'Cadillac Starter Relay On for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Starter Relay On...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 20 00 00 00 0C 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Starter Relay On completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Starter Relay On Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacStarterRelayReleaseFunction extends SpecialFunction {
  const GmCadillacStarterRelayReleaseFunction() : super(name: 'Cadillac Starter Relay Release', description: 'Cadillac Starter Relay Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Starter Relay Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Starter Relay Release completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Starter Relay Release Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacSuperchargerBypassSolenoidValveDecreaseFunction extends SpecialFunction {
  const GmCadillacSuperchargerBypassSolenoidValveDecreaseFunction() : super(name: 'Cadillac Supercharger Bypass Solenoid Valve Decrease', description: 'Cadillac Supercharger Bypass Solenoid Valve Decrease for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Supercharger Bypass Solenoid Valve Decrease...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 14 00 00 00 80 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Supercharger Bypass Solenoid Valve Decrease completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Supercharger Bypass Solenoid Valve Decrease Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacSuperchargerBypassSolenoidValveIncreaseFunction extends SpecialFunction {
  const GmCadillacSuperchargerBypassSolenoidValveIncreaseFunction() : super(name: 'Cadillac Supercharger Bypass Solenoid Valve Increase', description: 'Cadillac Supercharger Bypass Solenoid Valve Increase for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Supercharger Bypass Solenoid Valve Increase...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '07 AE 14 00 00 00 80 19', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Supercharger Bypass Solenoid Valve Increase completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Supercharger Bypass Solenoid Valve Increase Failed: $e';
      return 'Failed: $e';
    }
  }
}

class GmCadillacSuperchargerBypassSolenoidValveReleaseFunction extends SpecialFunction {
  const GmCadillacSuperchargerBypassSolenoidValveReleaseFunction() : super(name: 'Cadillac Supercharger Bypass Solenoid Valve Release', description: 'Cadillac Supercharger Bypass Solenoid Valve Release for GM vehicles.', manufacturer: 'GM');

  @override
  Future<String> execute(Elm327Adapter adapter, ValueNotifier<String> statusNotifier) async {
    statusNotifier.value = 'Starting Cadillac Supercharger Bypass Solenoid Valve Release...';
    try {
      List<String> commands = ['AT Z', 'AT H1', 'AT L1', 'AT S0', 'AT SP 6', 'AT AL', 'AT CAF 0', 'AT SH 7E0', 'AT CRA 5E8', 'AT FC SH 7E0', 'AT FC SD 30', 'AT FC SM 1', '01 3E', '02 AE 00', 'AT CAF 1'];
      for (String command in commands) {
        statusNotifier.value = 'Sending: $command';
        await adapter.sendCommand(command);
        await Future.delayed(Duration(milliseconds: 50));
      }
      return 'Cadillac Supercharger Bypass Solenoid Valve Release completed.';
    } catch (e) {
      statusNotifier.value = 'Cadillac Supercharger Bypass Solenoid Valve Release Failed: $e';
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
    const GmCadillacCadillacBrakePedalPositionSensorLearnFunction(),
    const GmCadillacEngineOilPressureValveOffFunction(),
    const GmCadillacEngineOilPressureValveOnFunction(),
    const GmCadillacEngineOilPressureValveReleaseFunction(),
    const GmCadillacEvapServiceBayTestFunction(),
    const GmCadillacFuelRailPressureReliefValveLearnFunction(),
    const GmCadillacGeneratorTerminalOffFunction(),
    const GmCadillacGeneratorTerminalOnFunction(),
    const GmCadillacGeneratorTerminalReleaseFunction(),
    const GmCadillacHeatedO2SensorHeaterLearnFunction(),
    const GmCadillacIdleLearnFunction(),
    const GmCadillacIgnitionTimingOnFunction(),
    const GmCadillacIgnitionTimingReleaseFunction(),
    const GmCadillacMilLampOffFunction(),
    const GmCadillacMilLampOnFunction(),
    const GmCadillacMilLampReleaseFunction(),
    const GmCadillacRemoteVehicleStartDisableHistoryResetFunction(),
    const GmCadillacStarterRelayOffFunction(),
    const GmCadillacStarterRelayOnFunction(),
    const GmCadillacStarterRelayReleaseFunction(),
    const GmCadillacSuperchargerBypassSolenoidValveDecreaseFunction(),
    const GmCadillacSuperchargerBypassSolenoidValveIncreaseFunction(),
    const GmCadillacSuperchargerBypassSolenoidValveReleaseFunction(),
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
