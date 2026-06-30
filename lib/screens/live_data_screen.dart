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
          if (_spots.length > 50) _spots.removeAt(0);
        });

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
      backgroundColor: const Color(0xFF12121a),
      appBar: AppBar(
        title: Text(widget.command.description),
        backgroundColor: const Color(0xFF12121a),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a28),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1e1e2e)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.command.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFccc),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _latestValue,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF44aaff),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (widget.command.unit.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3, left: 4),
                        child: Text(
                          widget.command.unit,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: const Color(0xFF2a2a3e),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  value.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF556),
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots,
                          isCurved: true,
                          preventCurveOverShooting: true,
                          color: const Color(0xFF44aaff),
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF44aaff).withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(1)} ${widget.command.unit}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
