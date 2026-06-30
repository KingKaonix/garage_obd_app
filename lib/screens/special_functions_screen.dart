import 'dart:async';
import 'package:flutter/material.dart';
import '../obd2/elm327_adapter.dart';
import '../obd2/special_functions.dart';

class SpecialFunctionsScreen extends StatefulWidget {
  final Elm327Adapter? elm327;

  const SpecialFunctionsScreen({super.key, this.elm327});

  @override
  State<SpecialFunctionsScreen> createState() => _SpecialFunctionsScreenState();
}

class _SpecialFunctionsScreenState extends State<SpecialFunctionsScreen> {
  final ValueNotifier<String> _statusNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _resultNotifier = ValueNotifier<String>('');
  bool _isRunning = false;
  String _selectedManufacturer = 'All';

  List<SpecialFunction> get _functions {
    final all = SpecialFunctionsManager.getAvailableFunctions();
    if (_selectedManufacturer == 'All') return all;
    return all.where((f) => f.manufacturer == _selectedManufacturer).toList();
  }

  List<String> get _manufacturers {
    final all = SpecialFunctionsManager.getAvailableFunctions();
    final manufacturers = all.map((f) => f.manufacturer).toSet().toList()
      ..sort();
    return ['All', ...manufacturers];
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
    _resultNotifier.dispose();
    super.dispose();
  }

  Future<void> _executeFunction(SpecialFunction function) async {
    if (_isRunning) return;
    if (widget.elm327 == null || !widget.elm327!.isConnected) {
      _resultNotifier.value = 'Not connected to an OBD-II adapter.';
      return;
    }

    setState(() => _isRunning = true);
    _resultNotifier.value = '';
    _statusNotifier.value = '';

    try {
      final result = await function.execute(widget.elm327!, _statusNotifier);
      _resultNotifier.value = result;
    } catch (e) {
      _resultNotifier.value = 'Error: $e';
    } finally {
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Functions'),
        actions: [
          if (_isRunning)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF44aaff),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: widget.elm327 != null && widget.elm327!.isConnected
                  ? Colors.green.withValues(alpha: 0.06)
                  : const Color(0xFF442200).withValues(alpha: 0.15),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF1e1e32), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.elm327 != null && widget.elm327!.isConnected
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.elm327 != null && widget.elm327!.isConnected
                      ? 'Connected'
                      : 'Not connected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.elm327 != null && widget.elm327!.isConnected
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                if (!(widget.elm327 != null && widget.elm327!.isConnected))
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      ' — connect from Scan tab first',
                      style: TextStyle(fontSize: 11, color: Color(0xFF556677)),
                    ),
                  ),
              ],
            ),
          ),

          // Manufacturer filter
          if (_manufacturers.length > 2)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _manufacturers
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              m,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: _selectedManufacturer == m,
                            onSelected: (sel) {
                              setState(() => _selectedManufacturer = m);
                            },
                            selectedColor: const Color(
                              0xFF44aaff,
                            ).withValues(alpha: 0.2),
                            checkmarkColor: const Color(0xFF44aaff),
                            backgroundColor: const Color(0xFF13131f),
                            side: BorderSide(
                              color: _selectedManufacturer == m
                                  ? const Color(
                                      0xFF44aaff,
                                    ).withValues(alpha: 0.5)
                                  : const Color(0xFF1e1e32),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

          // Status / result
          ValueListenableBuilder<String>(
            valueListenable: _statusNotifier,
            builder: (ctx, status, _) {
              if (status.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: const Color(0xFF44aaff).withValues(alpha: 0.06),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF44aaff),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF44aaff),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          ValueListenableBuilder<String>(
            valueListenable: _resultNotifier,
            builder: (ctx, result, _) {
              if (result.isEmpty) return const SizedBox.shrink();
              final isError =
                  result.startsWith('Error') || result.startsWith('Failed');
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: isError
                    ? Colors.red.withValues(alpha: 0.06)
                    : Colors.green.withValues(alpha: 0.06),
                child: Row(
                  children: [
                    Icon(
                      isError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 16,
                      color: isError ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result,
                        style: TextStyle(
                          fontSize: 12,
                          color: isError
                              ? Colors.red.shade300
                              : Colors.green.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Function list
          Expanded(
            child: _functions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 48,
                            color: const Color(0xFF556677),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No functions available',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF778899),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: _functions.length,
                    itemBuilder: (ctx, i) {
                      final fn = _functions[i];
                      return _functionTile(fn);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _functionTile(SpecialFunction fn) {
    final canRun =
        widget.elm327 != null && widget.elm327!.isConnected && !_isRunning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13131f),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1e1e32), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: canRun ? () => _executeFunction(fn) : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF44aaff).withValues(alpha: 0.12),
                        const Color(0xFF44aaff).withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF44aaff).withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.build,
                    color: Color(0xFF44aaff),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fn.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFFf0f0f0),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        fn.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF556677),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: canRun
                        ? const Color(0xFF44aaff).withValues(alpha: 0.15)
                        : const Color(0xFF556677).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    canRun ? Icons.play_arrow_rounded : Icons.lock_outline,
                    size: 18,
                    color: canRun
                        ? const Color(0xFF44aaff)
                        : const Color(0xFF556677),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
