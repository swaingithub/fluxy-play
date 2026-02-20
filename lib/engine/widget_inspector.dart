import 'package:flutter/material.dart';
import 'fluxy_engine.dart';

class FluxyWidgetInspector extends StatelessWidget {
  final String code;
  const FluxyWidgetInspector({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tree = FluxyEngine.getTree(code);

    if (tree.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: tree.map((node) => _TreeNodeView(node: node, depth: 0, isDark: isDark)).toList(),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_tree_outlined, size: 32, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 8),
          Text(
            'No widget tree detected',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _TreeNodeView extends StatelessWidget {
  final FluxyTreeNode node;
  final int depth;
  final bool isDark;

  const _TreeNodeView({required this.node, required this.depth, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0, bottom: 4),
          child: Row(
            children: [
              Text(node.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                node.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              if (node.properties.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${node.properties.entries.map((e) => "${e.key}: ${e.value}").join(", ")})',
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
        if (node.children.isNotEmpty)
          ...node.children.map((child) => _TreeNodeView(node: child, depth: depth + 1, isDark: isDark)),
      ],
    );
  }
}
