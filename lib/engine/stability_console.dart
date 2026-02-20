import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'fluxy_sandbox.dart'; // for FluxySandboxRuntime + SandboxLogLevel
import 'state_inspector.dart';
import 'widget_inspector.dart';

// ---------------------------------------------------------------------------
// Stability Console
// Displays real-time logs, stability metrics, and kernel events.
// ---------------------------------------------------------------------------

class StabilityConsole extends StatelessWidget {
  final VoidCallback? onClose;

  const StabilityConsole({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final runtime = FluxySandboxRuntime.instance;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF8F8FF),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Column(
        children: [
          // Console Header
          _ConsoleHeader(isDark: isDark, onClose: onClose),

          // Metrics Bar
          _MetricsBar(runtime: runtime, isDark: isDark),

          // Log Area
          Expanded(
            child: Fx(() {
              final tab = runtime.consoleTab.value;
              if (tab == 'STATE') return const StateInspector();
              if (tab == 'WIDGETS') return FluxyWidgetInspector(code: runtime.currentCode.value);
              
              final entries = runtime.logs.value;
              return entries.isEmpty
                  ? _EmptyConsole(isDark: isDark)
                  : _LogList(entries: entries, isDark: isDark);
            }),
          ),

          // Console Input Area
          _ConsoleInput(isDark: isDark, runtime: runtime),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Console Header
// ---------------------------------------------------------------------------

class _ConsoleHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onClose;

  const _ConsoleHeader({required this.isDark, this.onClose});

  @override
  Widget build(BuildContext context) {
    final runtime = FluxySandboxRuntime.instance;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141423) : const Color(0xFFF1F5F9),
        border: Border(
          bottom:
              BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Fx(() => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tab buttons
          _ConsoleTab(
              label: 'CONSOLE', 
              isActive: runtime.consoleTab.value == 'CONSOLE', 
              isDark: isDark,
              onTap: () => runtime.consoleTab.value = 'CONSOLE'),
          const SizedBox(width: 2),
          _ConsoleTab(
              label: 'STABILITY', 
              isActive: runtime.consoleTab.value == 'STABILITY', 
              isDark: isDark,
              onTap: () => runtime.consoleTab.value = 'STABILITY'),
          const SizedBox(width: 2),
          _ConsoleTab(
              label: 'STATE', 
              isActive: runtime.consoleTab.value == 'STATE', 
              isDark: isDark,
              onTap: () => runtime.consoleTab.value = 'STATE'),
          const SizedBox(width: 2),
          _ConsoleTab(
              label: 'WIDGETS', 
              isActive: runtime.consoleTab.value == 'WIDGETS', 
              isDark: isDark,
              onTap: () => runtime.consoleTab.value = 'WIDGETS'),
          const Spacer(),
          // Clear button
          if (runtime.consoleTab.value == 'CONSOLE')
            GestureDetector(
              onTap: () => runtime.clearLogs(),
              child: Tooltip(
                message: 'Clear console',
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          const SizedBox(width: 12),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
        ],
      )),
    );
  }
}

class _ConsoleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _ConsoleTab(
      {required this.label, required this.isActive, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6366F1).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isActive
              ? Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive
                ? const Color(0xFF6366F1)
                : (isDark ? Colors.white38 : Colors.black38),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// Metrics Bar
// ---------------------------------------------------------------------------

class _MetricsBar extends StatelessWidget {
  final FluxySandboxRuntime runtime;
  final bool isDark;

  const _MetricsBar({required this.runtime, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark
          ? const Color(0xFF0F0F1A)
          : const Color(0xFFF8FAFC),
      child: Fx(() => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _MetricChip(
                icon: Icons.shield_rounded,
                label: 'Layout',
                value: runtime.layoutSaves.value.toString(),
                color: const Color(0xFF6366F1),
              ),
              _MetricChip(
                icon: Icons.settings_backup_restore_rounded,
                label: 'State',
                value: runtime.stateSaves.value.toString(),
                color: const Color(0xFF10B981),
              ),
              _MetricChip(
                icon: Icons.timer_rounded,
                label: 'Async',
                value: runtime.asyncSaves.value.toString(),
                color: const Color(0xFFF59E0B),
              ),
              _MetricChip(
                icon: Icons.monitor_heart_rounded,
                label: 'Render',
                value: runtime.renderSaves.value.toString(),
                color: const Color(0xFFEC4899),
              ),
              const Spacer(),
              // FPS indicator
              Fx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      runtime.fpsLabel.value,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                        fontFamily: 'monospace',
                      ),
                    ),
                  )),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'KERNEL ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Log List
// ---------------------------------------------------------------------------

class _LogList extends StatefulWidget {
  final List<SandboxLogEntry> entries;
  final bool isDark;

  const _LogList({required this.entries, required this.isDark});

  @override
  State<_LogList> createState() => _LogListState();
}

class _LogListState extends State<_LogList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_LogList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries.length != oldWidget.entries.length) {
      // Auto-scroll to bottom on new entries
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.entries.length,
      itemBuilder: (context, index) {
        final entry = widget.entries[index];
        return _LogLine(entry: entry, isDark: widget.isDark);
      },
    );
  }
}

class _LogLine extends StatelessWidget {
  final SandboxLogEntry entry;
  final bool isDark;

  const _LogLine({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            entry.timeStr,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
          const SizedBox(width: 8),
          // Prefix
          Text(
            entry.prefix,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 6),
          // Message
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: entry.color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyConsole extends StatelessWidget {
  final bool isDark;

  const _EmptyConsole({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.terminal_rounded,
            size: 32,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 8),
          Text(
            'Stability Console Ready',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Run a snippet to see kernel activity',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Console Input
// ---------------------------------------------------------------------------

class _ConsoleInput extends StatefulWidget {
  final bool isDark;
  final FluxySandboxRuntime runtime;

  const _ConsoleInput({required this.isDark, required this.runtime});

  @override
  State<_ConsoleInput> createState() => _ConsoleInputState();
}

class _ConsoleInputState extends State<_ConsoleInput> {
  final _ctrl = TextEditingController();

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // Simple built-in commands
    switch (text.toLowerCase()) {
      case 'clear':
        widget.runtime.clearLogs();
        break;
      case 'help':
        widget.runtime.addLog(SandboxLogEntry.info(
            'Commands: clear, stats, fps, version, help'));
        break;
      case 'stats':
        final s = FluxyStabilityMetrics.getSummary();
        widget.runtime.addLog(SandboxLogEntry.info(
            'Stability Kernel: Layout=${s['layout_fixes']} State=${s['state_fixes']} Async=${s['async_fixes']} Viewport=${s['viewport_fixes']}'));
        break;
      case 'fps':
        widget.runtime.addLog(
            SandboxLogEntry.info('UI Thread: ${widget.runtime.fpsLabel.value}'));
        break;
      case 'version':
        widget.runtime
            .addLog(SandboxLogEntry.info('Fluxy v0.2.4 • Dart SDK 3.x'));
        break;
      default:
        widget.runtime
            .addLog(SandboxLogEntry.warning('Unknown command: "$text"'));
    }
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF141423)
            : const Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(
            color: widget.isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '>',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: const Color(0xFF6366F1).withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onSubmitted: (_) => _submit(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: widget.isDark ? Colors.white70 : Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Type a command... (help, stats, clear)',
                hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
