import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../obd2/elm327_adapter.dart';
import '../obd2/obd_commands.dart';
import '../services/data_logger.dart';

class LiveDataScreen extends StatefulWidget {
  final Elm327Adapter obd2Connection;
  final ObdCommand command;

  const LiveDataScreen({
    super.key,
    required this.obd2Connection,
    required this.command,
  });

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  final List<FlSpot> _spots = [];
  double _xValue = 0;
  String _latestValue = '0';
  final DataLogger _logger = DataLogger();
  late StreamSubscription _parsedDataSubscription;

  @override
  void initState() {
    super.initState();
    _parsedDataSubscription = widget.obd2Connection.parsedDataStream.listen((data) {
      if (data.containsKey(widget.command.description)) {
        final valStr = data[widget.command.description];
        final val = double.tryParse(valStr ?? '0') ?? 0;
        
        setState(() {
          _latestValue = valStr ?? '0';
          _spots.add(FlSpot(_xValue, val));
          _xValue++;
          if (_spots.length > 50) _spots.removeAt(0); // Keep last 50 points
        });
        
        // Log the data
        _logger.logPid(
          description: widget.command.description,
          value: _latestValue,
          unit: widget.command.unit,
        );
      }
    });
  }

  @override
  void dispose() {
    _parsedDataSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.command.description)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${widget.command.description}: $_latestValue ${widget.command.unit}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
