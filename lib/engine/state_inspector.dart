import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class StateInspector extends StatelessWidget {
  const StateInspector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Fx(() {
      final allFluxes = FluxRegistry.all;
      
      if (allFluxes.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: allFluxes.length,
        itemBuilder: (context, index) {
          final s = allFluxes[index];
          return _StateEntry(flux: s, isDark: isDark);
        },
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 32, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 8),
          Text(
            'No active state found',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _StateEntry extends StatelessWidget {
  final Flux flux;
  final bool isDark;

  const _StateEntry({required this.flux, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final type = flux is FluxComputed ? 'Computed' : 'Flux';
    final color = flux is FluxComputed ? const Color(0xFF6366F1) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141423) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  flux.label ?? flux.id,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Value: ', style: TextStyle(color: Colors.grey, fontSize: 11)),
              Expanded(
                child: SelectableText(
                  flux.toString(),
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CDCFE) : const Color(0xFF0056B3),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (flux is! FluxComputed)
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _editValue(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _editValue(BuildContext context) {
    final ctrl = TextEditingController(text: flux.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${flux.label ?? 'State'}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Enter new value'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = ctrl.text;
              dynamic typedVal = val;
              if (int.tryParse(val) != null) typedVal = int.parse(val);
              else if (double.tryParse(val) != null) typedVal = double.parse(val);
              else if (val.toLowerCase() == 'true') typedVal = true;
              else if (val.toLowerCase() == 'false') typedVal = false;
              
              (flux as dynamic).value = typedVal;
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
