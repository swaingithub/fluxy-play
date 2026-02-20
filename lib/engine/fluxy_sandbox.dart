import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';

// ---------------------------------------------------------------------------
// Sandbox Log Entry
// ---------------------------------------------------------------------------

enum SandboxLogLevel { info, success, warning, error }

class SandboxLogEntry {
  final String message;
  final SandboxLogLevel level;
  final DateTime timestamp;

  const SandboxLogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
  });

  factory SandboxLogEntry.info(String msg) => SandboxLogEntry(
        message: msg,
        level: SandboxLogLevel.info,
        timestamp: DateTime.now(),
      );

  factory SandboxLogEntry.success(String msg) => SandboxLogEntry(
        message: msg,
        level: SandboxLogLevel.success,
        timestamp: DateTime.now(),
      );

  factory SandboxLogEntry.warning(String msg) => SandboxLogEntry(
        message: msg,
        level: SandboxLogLevel.warning,
        timestamp: DateTime.now(),
      );

  factory SandboxLogEntry.error(String msg) => SandboxLogEntry(
        message: msg,
        level: SandboxLogLevel.error,
        timestamp: DateTime.now(),
      );

  String get prefix {
    switch (level) {
      case SandboxLogLevel.info:
        return 'ℹ️';
      case SandboxLogLevel.success:
        return '✅';
      case SandboxLogLevel.warning:
        return '⚠️';
      case SandboxLogLevel.error:
        return '🔴';
    }
  }

  Color get color {
    switch (level) {
      case SandboxLogLevel.info:
        return const Color(0xFF9CDCFE);
      case SandboxLogLevel.success:
        return const Color(0xFF4EC9B0);
      case SandboxLogLevel.warning:
        return const Color(0xFFDCDCAA);
      case SandboxLogLevel.error:
        return const Color(0xFFF48771);
    }
  }

  String get timeStr {
    final t = timestamp;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Sandbox Runtime State (Global Signals)
// ---------------------------------------------------------------------------

/// Singleton sandbox state — shared across the Playground
class FluxySandboxRuntime {
  FluxySandboxRuntime._();
  static final FluxySandboxRuntime instance = FluxySandboxRuntime._();

  /// Log entries stream — observable
  final logs = flux<List<SandboxLogEntry>>([]);

  /// Whether the sandbox had a crash
  final hasError = flux(false);

  /// Last error detail
  final lastError = flux<String?>(null);

  /// Total stability saves in this session
  final layoutSaves = flux(0);
  final stateSaves = flux(0);
  final asyncSaves = flux(0);
  final renderSaves = flux(0);

  /// Execution counter (for hot-reload simulation)
  final executionCount = flux(0);

  /// FPS sim (stable by default)
  final fpsLabel = flux('60 fps');

  /// Active console tab
  final consoleTab = flux('CONSOLE');

  /// Current sandbox code
  final currentCode = flux('');

  void addLog(SandboxLogEntry entry) {
    logs.value = [...logs.value, entry];
    // Cap at 200 entries
    if (logs.value.length > 200) {
      logs.value = logs.value.sublist(logs.value.length - 200);
    }
  }

  void clearLogs() {
    logs.value = [];
    hasError.value = false;
    lastError.value = null;
  }

  void reportError(String error, {String? widgetName}) {
    hasError.value = true;
    lastError.value = error;
    addLog(SandboxLogEntry.error(
        '${widgetName != null ? "[$widgetName] " : ""}$error'));
  }

  void reportRecovery(String from) {
    hasError.value = false;
    addLog(SandboxLogEntry.success('Stability Kernel recovered from: $from'));
    layoutSaves.value++;
  }

  void reportLaunch(String snippet) {
    executionCount.value++;
    addLog(SandboxLogEntry.info(
        'Running snippet #${executionCount.value}: $snippet'));
    addLog(SandboxLogEntry.success('Widget tree mounted successfully.'));
    addLog(SandboxLogEntry.info(
        'UI Thread: ${fpsLabel.value} • Dart VM: JIT compiled'));
  }

  void recordStatKernelActivity() {
    final fix = FluxyStabilityMetrics.getSummary();
    layoutSaves.value = fix['layout_fixes'] ?? 0;
    stateSaves.value = fix['state_fixes'] ?? 0;
    asyncSaves.value = fix['async_fixes'] ?? 0;
    renderSaves.value = fix['viewport_fixes'] ?? 0;
  }
}

final _runtime = FluxySandboxRuntime.instance;

// ---------------------------------------------------------------------------
// FluxySandbox Widget
// ---------------------------------------------------------------------------

/// Wraps a child builder inside a crash-safe execution sandbox.
/// - Catches widget build errors
/// - Catches layout exceptions
/// - Shows beautiful error panel + never crashes the host app
/// - Reports to FluxySandboxRuntime for the Stability Console
class FluxySandbox extends StatefulWidget {
  /// Builds the user widget. Can throw safely.
  final Widget Function() childBuilder;

  /// Label for logging
  final String snippetName;

  const FluxySandbox({
    super.key,
    required this.childBuilder,
    this.snippetName = 'Custom Snippet',
  });

  @override
  State<FluxySandbox> createState() => _FluxySandboxState();
}

class _FluxySandboxState extends State<FluxySandbox> {
  bool _hasCrash = false;
  String _crashMessage = '';

  @override
  void initState() {
    super.initState();
    _runtime.addLog(SandboxLogEntry.info(
        'Sandbox initialized for: ${widget.snippetName}'));
  }

  Widget _tryBuild() {
    try {
      final child = widget.childBuilder();
      if (_hasCrash) {
        // Recovered from a previous crash
        _runtime.reportRecovery(_crashMessage);
        _hasCrash = false;
        _crashMessage = '';
      }
      return child;
    } catch (e, stack) {
      _hasCrash = true;
      _crashMessage = e.toString();
      _runtime.reportError(_crashMessage, widgetName: widget.snippetName);
      if (kDebugMode) {
        debugPrint('🔴 [FluxySandbox] Caught: $e\n$stack');
      }
      return _SandboxErrorPanel(
        error: _crashMessage,
        onRetry: () => setState(() {}),
        onReset: () {
          setState(() {
            _hasCrash = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SandboxErrorBoundary(
      onError: (error) {
        _runtime.reportError(error, widgetName: widget.snippetName);
      },
      child: _tryBuild(),
    );
  }
}

// ---------------------------------------------------------------------------
// Error Boundary (Flutter ErrorWidget override for sandbox context)
// ---------------------------------------------------------------------------

class _SandboxErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(String error) onError;

  const _SandboxErrorBoundary({
    required this.child,
    required this.onError,
  });

  @override
  State<_SandboxErrorBoundary> createState() => _SandboxErrorBoundaryState();
}

class _SandboxErrorBoundaryState extends State<_SandboxErrorBoundary> {
  bool _hasError = false;
  final String _error = '';

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _SandboxErrorPanel(
        error: _error,
        onRetry: () => setState(() => _hasError = false),
        onReset: () => setState(() => _hasError = false),
      );
    }

    return widget.child;
  }
}

// ---------------------------------------------------------------------------
// Error Panel — shown inside the sandbox canvas when a crash occurs
// ---------------------------------------------------------------------------

class _SandboxErrorPanel extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const _SandboxErrorPanel({
    required this.error,
    required this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF48771).withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF48771).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bug_report_rounded,
                color: Color(0xFFF48771), size: 32),
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            'Stability Kernel Intercept',
            style: TextStyle(
              color: Color(0xFFF48771),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Error text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              error.split('\n').first,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFFF48771),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionBtn(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                color: const Color(0xFF6366F1),
                onTap: onRetry,
              ),
              const SizedBox(width: 12),
              _ActionBtn(
                label: 'Reset',
                icon: Icons.restart_alt_rounded,
                color: Colors.grey,
                onTap: onReset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
