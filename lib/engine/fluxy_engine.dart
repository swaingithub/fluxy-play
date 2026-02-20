import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

/// Represents a node in the Fluxy UI tree for inspection.
class FluxyTreeNode {
  final String name;
  final String icon;
  final Map<String, String> properties;
  final List<FluxyTreeNode> children;

  FluxyTreeNode({
    required this.name,
    this.icon = '🧱',
    this.properties = const {},
    this.children = const [],
  });
}

/// An Enhanced Simulation Engine for Fluxy Playground.
/// Uses sophisticated pattern matching to simulate a reactive runtime.
class FluxyEngine extends StatelessWidget {
  final String code;

  const FluxyEngine({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(code.hashCode),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: _parseAndRender(code, context),
        ),
      ),
    );
  }

  /// Extracts a tree structure for the inspector without rendering.
  static List<FluxyTreeNode> getTree(String code) {
    try {
      final clean = code.replaceAll('\n', '').replaceAll('  ', ' ').trim();
      if (clean.isEmpty) return [];

      if (clean.contains('Fx.col')) return [_parseFlexTree(clean, 'Column', 'vertical')];
      if (clean.contains('Fx.row')) return [_parseFlexTree(clean, 'Row', 'horizontal')];
      
      return [_parseSingleNode(clean)];
    } catch (_) {
      return [FluxyTreeNode(name: 'Error', icon: '⚠️')];
    }
  }

  static FluxyTreeNode _parseSingleNode(String code) {
    if (code.contains('Fx.button')) return FluxyTreeNode(name: 'FxButton', icon: '🔘', properties: {'label': _staticGetStr(code, 'button') ?? 'Button'});
    if (code.contains('Fx.box')) return FluxyTreeNode(name: 'FxBox', icon: '📦', properties: {'size': '${_staticGetVal(code, 'size') ?? 150}'});
    if (code.contains('Fx.text')) return FluxyTreeNode(name: 'FxText', icon: '📝', properties: {'text': _staticGetStr(code, 'text') ?? '...'});
    if (code.contains('Fx.avatar')) return FluxyTreeNode(name: 'FxAvatar', icon: '👤');
    if (code.contains('Fx.badge')) return FluxyTreeNode(name: 'FxBadge', icon: '🏷️');
    return FluxyTreeNode(name: code.split('(').first, icon: '🧱');
  }

  static List<String> _splitSmart(String input) {
    final result = <String>[];
    var start = 0;
    var b1 = 0; // ()
    var b2 = 0; // []
    var b3 = 0; // {}
    
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '(') b1++;
      if (char == ')') b1--;
      if (char == '[') b2++;
      if (char == ']') b2--;
      if (char == '{') b3++;
      if (char == '}') b3--;
      
      if (char == ',' && b1 == 0 && b2 == 0 && b3 == 0) {
        result.add(input.substring(start, i).trim());
        start = i + 1;
      }
    }
    result.add(input.substring(start).trim());
    return result.where((s) => s.isNotEmpty).toList();
  }

  static FluxyTreeNode _parseFlexTree(String code, String name, String direction) {
    final body = code.split('children: [').last.split(']').first;
    final childCodes = _splitSmart(body);
    return FluxyTreeNode(
      name: name,
      icon: direction == 'vertical' ? '🔃' : '↔️',
      properties: {'gap': '${_staticGetVal(code, 'gap') ?? 12}'},
      children: childCodes
          .map((c) => _parseSingleNode(c))
          .toList(),
    );
  }

  Widget _parseAndRender(String code, BuildContext context) {
    try {
      final clean = _sanitize(code);
      if (clean.isEmpty) return const _EmptyState();

      // Top-level structure detection
      if (clean.contains('Fx.col')) return _buildFlex(clean, Axis.vertical, context);
      if (clean.contains('Fx.row')) return _buildFlex(clean, Axis.horizontal, context);
      
      // Single components
      return _renderSingleComponent(clean, context);
    } catch (e) {
      return _ErrorWidget(error: e.toString());
    }
  }

  Widget _renderSingleComponent(String code, BuildContext context) {
    if (code.contains('Fx.button')) return _buildButton(code);
    if (code.contains('Fx.box')) return _buildBox(code, context);
    if (code.contains('Fx.text')) return _buildText(code);
    if (code.contains('Fx.avatar')) return _buildAvatar(code);
    if (code.contains('Fx.badge')) return _buildBadge(code);
    
    // Flutter native fallbacks
    if (code.startsWith('Container')) return _buildFlutterContainer(code);
    if (code.startsWith('Center')) return Center(child: _renderSingleComponent(_extractChild(code), context));
    if (code.startsWith('Padding')) return Padding(padding: _parsePadding(code), child: _renderSingleComponent(_extractChild(code), context));

    return _ErrorWidget(error: 'Symbol not recognized: ${code.split("(").first}');
  }

  // --- Real-world Component Parsers ---

  Widget _buildButton(String code) {
    final label = _getStr(code, 'button') ?? 'Button';
    final isOutline = code.contains('Outline');
    final color = _getColor(code) ?? const Color(0xFF6366F1);
    final r = _getVal(code, 'radius') ?? 12;
    final px = _getVal(code, 'px') ?? 20;
    final py = _getVal(code, 'py') ?? 12;

    FxButton btn = Fx.button(label, onTap: () {})
        .bg(color)
        .applyStyle(                
          FxStyle(
            borderRadius: BorderRadius.circular(r),
            padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
          ),
        );

    if (isOutline) {
      btn = btn.applyStyle(
        FxStyle(
          border: Border.all(color: color),
          backgroundColor: Colors.transparent,
        ),
      );
    }

    return btn.shadowMd();
  }

  Widget _buildBox(String code, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(code) ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white);
    final size = _getVal(code, 'size') ?? 150;
    
    return Fx.box()
      .size(size)
      .radius(_getVal(code, 'radius') ?? 24)
      .background(color)
      .shadow.lg;
  }

  Widget _buildText(String code) {
    final content = _getStr(code, 'text') ?? 'Fluxy Text';
    var text = Fx.text(content).fontSize(_getVal(code, 'fontSize') ?? 14);
    if (code.contains('.bold()')) text = text.bold();
    return text;
  }

  Widget _buildAvatar(String code) {
    final lg = code.contains('lg');
    return Fx.avatar(size: lg ? FxAvatarSize.lg : FxAvatarSize.md, fallback: 'FX')
      .radius(_getVal(code, 'radius') ?? 999).shadow.md;
  }

  Widget _buildBadge(String code) {
    final label = _getStr(code, 'label') ?? '99';
    final color = _getColor(code) ?? Colors.green;
    return Fx.badge(label: label, color: color, child: Fx.box().size(60).radius(12).bg(color.withValues(alpha: 0.1)));
  }

  Widget _buildFlex(String code, Axis axis, BuildContext context) {
    final gap = _getVal(code, 'gap') ?? 12;
    final body = code.split('children: [').last.split(']').first;
    final childCodes = _splitSmart(body);
    final List<Widget> children = childCodes
        .map((c) => _renderSingleComponent(c, context))
        .take(8)
        .toList();

    if (children.isEmpty) children.add(_buildBox('', context));

    return axis == Axis.horizontal 
      ? Fx.row(gap: gap, children: children)
      : Fx.col(gap: gap, children: children);
  }


  Widget _buildFlutterContainer(String code) {
    final color = _getColor(code) ?? Colors.blue.withValues(alpha: 0.1);
    return Container(
      width: _getVal(code, 'width') ?? 100,
      height: _getVal(code, 'height') ?? 100,
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(_getVal(code, 'radius') ?? 12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
    );
  }

  // --- Helper Parsers ---

  // --- Pre-compiled RegEx cache for performance ---
  static final _strRegex = <String, RegExp>{};
  static final _valRegex = <String, RegExp>{};
  static final _hexRegex = RegExp(r'0x([0-9A-Fa-f]{8})');
  static final _childRegex = RegExp(r'child:\s*(.*)');

  String _sanitize(String code) => code.replaceAll('\n', '').replaceAll('  ', ' ').trim();

  String? _getStr(String code, String marker) => _staticGetStr(code, marker);
  static String? _staticGetStr(String code, String marker) {
    final regex = _strRegex.putIfAbsent(marker, () => RegExp('$marker\\(\'([^\']*)\''));
    final altRegex = RegExp('$marker\\s*:\\s*\'([^\']*)\'');
    final match = regex.firstMatch(code) ?? altRegex.firstMatch(code);
    return match?.group(1);
  }

  double? _getVal(String code, String modifier) => _staticGetVal(code, modifier);
  static double? _staticGetVal(String code, String modifier) {
    final regex = _valRegex.putIfAbsent(modifier, () => RegExp('\\.$modifier\\(([\\d\\.]+)\\)'));
    final altRegex = RegExp('$modifier\\s*:\\s*([\\d\\.]+)');
    final match = regex.firstMatch(code) ?? altRegex.firstMatch(code);
    return match != null ? double.parse(match.group(1)!) : null;
  }

  Color? _getColor(String code) {
    final hex = _hexRegex.firstMatch(code);
    if (hex != null) return Color(int.parse(hex.group(1)!, radix: 16));
    if (code.contains('Colors.white')) return Colors.white;
    if (code.contains('Colors.black')) return Colors.black;
    if (code.contains('Colors.blue')) return Colors.blue;
    return null;
  }

  String _extractChild(String code) {
    final match = _childRegex.firstMatch(code);
    return match?.group(1) ?? '';
  }

  EdgeInsets _parsePadding(String code) {
    final val = _getVal(code, 'all') ?? 16;
    return EdgeInsets.all(val);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.code_rounded, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Fluxy Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const Text('Enter some code to see it come to life', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  const _ErrorWidget({required this.error});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.red.withValues(alpha: 0.1),
      child: SelectableText('Parser Error: $error', style: const TextStyle(color: Colors.redAccent, fontFamily: 'monospace')),
    );
  }
}

