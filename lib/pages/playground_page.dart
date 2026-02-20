import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluxy/fluxy.dart';

import '../widgets/fx_code_editor.dart';
import '../engine/fluxy_engine.dart';
import '../engine/fluxy_sandbox.dart';
import '../engine/stability_console.dart';
import '../data/code_snippets.dart';

import '../widgets/fluxy_logo.dart';

// ---------------------------------------------------------------------------
// Playground Page
// Industry-Standard IDE Interface for Fluxy & Flutter
// ---------------------------------------------------------------------------

class PlaygroundPage extends StatefulWidget {
  final String? initialSnippetId;
  const PlaygroundPage({super.key, this.initialSnippetId});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> with SingleTickerProviderStateMixin {
  // Reactive state
  late final Flux<String> codeSignal;
  late final Flux<String> activeSnippetId;
  late final Flux<String> activeCategoryId;
  late final Flux<bool> showConsole;
  late final Flux<PreviewMode> previewMode;
  late final Flux<FrameworkMode> framework;
  late final Flux<double> splitRatio;
  late final Flux<bool> showDeviceFrame;
  late final Flux<String> compiledCode;
  late final Flux<bool> isCompiling;
  late final Flux<int> runKey;
  late final Flux<String> activeSidebarTab;
  late final Flux<String> fileName;

  final _runtime = FluxySandboxRuntime.instance;

  @override
  void initState() {
    super.initState();
    final initialId = widget.initialSnippetId ?? 'hello_fluxy';
    final initialSnippet = FluxySnippetLibrary.findById(initialId) ?? FluxySnippetLibrary.categories.first.snippets.first;

    codeSignal = flux(initialSnippet.code);
    compiledCode = flux(initialSnippet.code);
    isCompiling = flux(false);
    activeSnippetId = flux(initialId);
    activeCategoryId = flux(initialSnippet.category.toLowerCase());
    showConsole = flux(true);
    previewMode = flux(PreviewMode.splitView);
    showDeviceFrame = flux(false);
    runKey = flux(0);
    splitRatio = flux(0.5);
    activeSidebarTab = flux('snippets');
    framework = flux(FrameworkMode.fluxy);
    fileName = flux('main.dart');

    fluxEffect(() {
      final code = codeSignal.value;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (codeSignal.value == code) {
          _runtime.currentCode.value = code;
        }
      });
    });

    _runtime.addLog(SandboxLogEntry.info('Fluxy IDE Ready.'));
  }

  void _loadSnippet(PlaygroundSnippet snippet) {
    codeSignal.value = snippet.code;
    compiledCode.value = snippet.code;
    activeSnippetId.value = snippet.id;
    activeCategoryId.value = snippet.category.toLowerCase();
    runKey.value++;
    _runtime.addLog(SandboxLogEntry.info('Switched to: ${snippet.name}'));
  }

  void _runCode() {
    isCompiling.value = true;
    _runtime.addLog(SandboxLogEntry.info('Syncing state to kernel...'));
    Future.delayed(const Duration(milliseconds: 400), () {
      compiledCode.value = codeSignal.value;
      runKey.value++;
      isCompiling.value = false;
      _runtime.addLog(SandboxLogEntry.success('Build successful.'));
    });
  }

  void _resetCode() {
    final original = FluxySnippetLibrary.findById(activeSnippetId.value)?.code ?? '';
    codeSignal.value = original;
    _runCode();
  }

  void _toggleFramework(FrameworkMode m) {
    framework.value = m;
    _runtime.addLog(SandboxLogEntry.info('Framework context: ${m.name.toUpperCase()}'));
  }

  void _onShare() {
     showDialog(context: context, builder: (c) => _ShareDialog(code: codeSignal.value));
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: codeSignal.value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 800) return _buildMobileLayout(isDark);
        return _buildDesktopLayout(isDark);
      }),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Fx(() => _PlaygroundTopBar(
              isDark: isDark,
              onRun: _runCode,
              onReset: _resetCode,
              onCopy: _copyCode,
              onShare: _onShare,
              showConsole: showConsole,
              frameworkMode: framework.value,
              onFrameworkChange: _toggleFramework,
              previewMode: previewMode,
              fileName: fileName.value,
            )),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sidebar Icon Column
              Container(
                width: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D0D19) : const Color(0xFFF1F5F9),
                  border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                ),
                child: Fx(() => Column(
                  children: [
                    const SizedBox(height: 12),
                    _SidebarIcon(
                      icon: Icons.folder_outlined,
                      isActive: activeSidebarTab.value == 'snippets',
                      onTap: () => activeSidebarTab.value = (activeSidebarTab.value == 'snippets' ? 'none' : 'snippets'),
                      tooltip: 'Explorer',
                    ),
                    _SidebarIcon(
                      icon: Icons.search_rounded,
                      isActive: false,
                      onTap: () => _runtime.addLog(SandboxLogEntry.info('Global Search alpha coming soon')),
                      tooltip: 'Search',
                    ),
                    _SidebarIcon(
                      icon: Icons.bug_report_outlined,
                      isActive: activeSidebarTab.value == 'debug',
                      onTap: () {
                        activeSidebarTab.value = 'debug';
                        showConsole.value = true;
                        _runtime.consoleTab.value = 'WIDGETS';
                      },
                      tooltip: 'Debugger',
                    ),
                    _SidebarIcon(
                      icon: Icons.terminal_rounded,
                      isActive: showConsole.value && activeSidebarTab.value != 'debug',
                      onTap: () => showConsole.value = !showConsole.value,
                      tooltip: 'Terminal',
                    ),
                  ],
                )),
              ),
              // File Explorer Panel
              Fx(() => activeSidebarTab.value == 'snippets' 
                ? SizedBox(width: 240, child: _SnippetPanel(
                    isDark: isDark,
                    activeCategoryId: activeCategoryId,
                    activeSnippetId: activeSnippetId,
                    onSnippetSelected: _loadSnippet,
                  ))
                : const SizedBox.shrink()),
              // Editor & Preview Split View
              Expanded(
                child: Fx(() {
                  final mode = previewMode.value;
                  if (mode == PreviewMode.editorOnly) return _buildEditorOnly(isDark);
                  if (mode == PreviewMode.previewOnly) return _buildPreviewOnly(isDark);
                  return _buildSplitView(isDark);
                }),
              ),
            ],
          ),
        ),
        // Stability Console
        Fx(() => showConsole.value 
          ? Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: StabilityConsole(onClose: () => showConsole.value = false),
              ),
            )
          : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildSplitView(bool isDark) {
    return LayoutBuilder(builder: (context, constraints) {
      return Fx(() {
        final ratio = splitRatio.value;
        final editorWidth = constraints.maxWidth * ratio;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: editorWidth, child: _EditorPanel(codeSignal: codeSignal, isDark: isDark)),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                final newRatio = (editorWidth + details.delta.dx) / constraints.maxWidth;
                splitRatio.value = newRatio.clamp(0.2, 0.8);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D0D19) : const Color(0xFFF1F5F9),
                    border: Border(left: BorderSide(color: isDark ? Colors.white10 : Colors.black12), right: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                  ),
                  child: Center(
                    child: Container(width: 2, height: 24, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black26, borderRadius: BorderRadius.circular(1))),
                  ),
                ),
              ),
            ),
            Expanded(child: _PreviewPanel(
              isDark: isDark,
              compiledCode: compiledCode,
              runKey: runKey,
              isCompiling: isCompiling,
              showDeviceFrame: showDeviceFrame,
            )),
          ],
        );
      });
    });
  }

  Widget _buildEditorOnly(bool isDark) => _EditorPanel(codeSignal: codeSignal, isDark: isDark);
  Widget _buildPreviewOnly(bool isDark) => _PreviewPanel(isDark: isDark, compiledCode: compiledCode, runKey: runKey, isCompiling: isCompiling, showDeviceFrame: showDeviceFrame);

  Widget _buildMobileLayout(bool isDark) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fx(() => _PlaygroundTopBar(
                isDark: isDark,
                onRun: _runCode,
                onReset: _resetCode,
                onCopy: _copyCode,
                onShare: _onShare,
                showConsole: showConsole,
                frameworkMode: framework.value,
                onFrameworkChange: _toggleFramework,
                previewMode: previewMode,
                fileName: fileName.value,
              )),
          Container(
            color: isDark ? const Color(0xFF0D0D19) : Colors.white,
            child: const TabBar(
              tabs: [
                Tab(text: 'Explorer', icon: Icon(Icons.folder_outlined, size: 16)),
                Tab(text: 'Code', icon: Icon(Icons.code_rounded, size: 16)),
                Tab(text: 'Preview', icon: Icon(Icons.phonelink_rounded, size: 16)),
              ],
              labelColor: Color(0xFF6366F1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF6366F1),
              labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SnippetPanel(isDark: isDark, activeCategoryId: activeCategoryId, activeSnippetId: activeSnippetId, onSnippetSelected: _loadSnippet),
                _EditorPanel(codeSignal: codeSignal, isDark: isDark),
                _PreviewPanel(isDark: isDark, compiledCode: compiledCode, runKey: runKey, isCompiling: isCompiling, showDeviceFrame: showDeviceFrame),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header & Top Bar
// ---------------------------------------------------------------------------

enum PreviewMode { splitView, editorOnly, previewOnly }
enum FrameworkMode { fluxy, flutter }

class _PlaygroundTopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRun;
  final VoidCallback onReset;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final Flux<bool> showConsole;
  final FrameworkMode frameworkMode;
  final Function(FrameworkMode) onFrameworkChange;
  final Flux<PreviewMode> previewMode;
  final String fileName;

  const _PlaygroundTopBar({
    required this.isDark,
    required this.onRun,
    required this.onReset,
    required this.onCopy,
    required this.onShare,
    required this.showConsole,
    required this.frameworkMode,
    required this.onFrameworkChange,
    required this.previewMode,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D19) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          const FluxyLogo(size: 20),
          const SizedBox(width: 8),
          const Text('IDE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey)),
          const SizedBox(width: 24),
          _FrameworkTab(mode: FrameworkMode.fluxy, active: frameworkMode == FrameworkMode.fluxy, onSelect: () => onFrameworkChange(FrameworkMode.fluxy)),
          _FrameworkTab(mode: FrameworkMode.flutter, active: frameworkMode == FrameworkMode.flutter, onSelect: () => onFrameworkChange(FrameworkMode.flutter)),
          const Spacer(),
          _ActionButton(icon: Icons.play_arrow_rounded, label: 'Run', color: const Color(0xFF6366F1), onTap: onRun),
          const SizedBox(width: 8),
          _ActionButton(icon: Icons.refresh_rounded, label: 'Reset', color: Colors.grey, onTap: onReset),
          const SizedBox(width: 16),
          _ViewToggle(mode: previewMode),
          const SizedBox(width: 16),
          IconButton(icon: Icon(Icons.ios_share_rounded, size: 18, color: isDark ? Colors.white70 : Colors.black87), onPressed: onShare),
          IconButton(icon: Icon(Icons.copy_rounded, size: 18, color: isDark ? Colors.white70 : Colors.black87), onPressed: onCopy),
        ],
      ),
    );
  }
}

class _FrameworkTab extends StatelessWidget {
  final FrameworkMode mode;
  final bool active;
  final VoidCallback onSelect;
  const _FrameworkTab({required this.mode, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFF6366F1) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mode.name.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: active ? const Color(0xFF6366F1) : Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final Flux<PreviewMode> mode;
  const _ViewToggle({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Fx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleBtn(icon: Icons.splitscreen_rounded, active: mode.value == PreviewMode.splitView, onTap: () => mode.value = PreviewMode.splitView),
        _ToggleBtn(icon: Icons.code_rounded, active: mode.value == PreviewMode.editorOnly, onTap: () => mode.value = PreviewMode.editorOnly),
        _ToggleBtn(icon: Icons.remove_red_eye_rounded, active: mode.value == PreviewMode.previewOnly, onTap: () => mode.value = PreviewMode.previewOnly),
      ],
    ));
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: active ? const Color(0xFF6366F1).withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: active ? const Color(0xFF6366F1) : Colors.grey),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File Explorer
// ---------------------------------------------------------------------------

class _SnippetPanel extends StatefulWidget {
  final bool isDark;
  final Flux<String> activeCategoryId;
  final Flux<String> activeSnippetId;
  final Function(PlaygroundSnippet) onSnippetSelected;

  const _SnippetPanel({required this.isDark, required this.activeCategoryId, required this.activeSnippetId, required this.onSnippetSelected});

  @override
  State<_SnippetPanel> createState() => _SnippetPanelState();
}

class _SnippetPanelState extends State<_SnippetPanel> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final Flux<String> searchQuery;

  @override
  void initState() {
    super.initState();
    searchQuery = flux('');
    _searchCtrl.addListener(() => searchQuery.value = _searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F0F1A) : Colors.white,
        border: Border(right: BorderSide(color: widget.isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearch(),
          Expanded(child: Fx(() {
            final query = searchQuery.value.toLowerCase();
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: FluxySnippetLibrary.categories.map((cat) {
                final filtered = cat.snippets.where((s) => s.name.toLowerCase().contains(query)).toList();
                if (query.isNotEmpty && filtered.isEmpty) return const SizedBox.shrink();
                return _CategoryFolder(cat: cat, snippets: filtered, isDark: widget.isDark, activeSnippetId: widget.activeSnippetId.value, onSnippetTap: widget.onSnippetSelected);
              }).toList(),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    height: 40, padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerLeft,
    child: Text('EXPLORER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: widget.isDark ? Colors.white38 : Colors.black38, letterSpacing: 1.2)),
  );

  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: Container(
      height: 28, decoration: BoxDecoration(color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
      child: TextField(
        controller: _searchCtrl,
        style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white70 : Colors.black87),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, size: 12, color: Colors.grey),
          hintText: 'Search files...', hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
          border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    ),
  );
}

class _CategoryFolder extends StatefulWidget {
  final PlaygroundCategory cat;
  final List<PlaygroundSnippet> snippets;
  final bool isDark;
  final String activeSnippetId;
  final Function(PlaygroundSnippet) onSnippetTap;

  const _CategoryFolder({required this.cat, required this.snippets, required this.isDark, required this.activeSnippetId, required this.onSnippetTap});

  @override
  State<_CategoryFolder> createState() => _CategoryFolderState();
}

class _CategoryFolderState extends State<_CategoryFolder> {
  bool isExpanded = true;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: () => setState(() => isExpanded = !isExpanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(children: [
            Icon(isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Icon(Icons.folder_rounded, size: 14, color: isExpanded ? const Color(0xFF6366F1) : Colors.grey),
            const SizedBox(width: 8),
            Text(widget.cat.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: widget.isDark ? Colors.white70 : Colors.black87)),
          ]),
        ),
      ),
      if (isExpanded) ...widget.snippets.map((s) => _FileItem(snippet: s, isDark: widget.isDark, isActive: s.id == widget.activeSnippetId, onTap: () => widget.onSnippetTap(s))),
    ]);
  }
}

class _FileItem extends StatelessWidget {
  final PlaygroundSnippet snippet;
  final bool isDark;
  final bool isActive;
  final VoidCallback onTap;
  const _FileItem({required this.snippet, required this.isDark, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
        decoration: BoxDecoration(color: isActive ? const Color(0xFF6366F1).withValues(alpha: 0.15) : Colors.transparent),
        child: Row(children: [
          const Icon(Icons.description_rounded, size: 14, color: Color(0xFF60CDFF)),
          const SizedBox(width: 8),
          Expanded(child: Text('${snippet.id.replaceAll('_', '')}.dart', style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF6366F1) : (isDark ? Colors.white70 : Colors.black87), fontWeight: isActive ? FontWeight.w700 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Editor & Preview
// ---------------------------------------------------------------------------

class _EditorPanel extends StatelessWidget {
  final Flux<String> codeSignal;
  final bool isDark;
  const _EditorPanel({required this.codeSignal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        _EditorTabBar(isDark: isDark),
        _EditorBreadcrumbs(isDark: isDark),
        Expanded(child: FluxyCodeEditor(codeSignal: codeSignal)),
        _EditorStatusBar(isDark: isDark, codeSignal: codeSignal),
      ]),
    );
  }
}

class _EditorBreadcrumbs extends StatelessWidget {
  final bool isDark;
  const _EditorBreadcrumbs({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22, padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8FAFC), border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)))),
      child: Row(children: [
        const Icon(Icons.folder_open_rounded, size: 10, color: Colors.grey),
        const SizedBox(width: 4),
        const Text('lib', style: TextStyle(fontSize: 10, color: Colors.grey)),
        const Icon(Icons.chevron_right_rounded, size: 10, color: Colors.grey),
        const Icon(Icons.description_rounded, size: 10, color: Color(0xFF60CDFF)),
        const SizedBox(width: 4),
        Text('main.dart', style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _EditorTabBar extends StatelessWidget {
  final bool isDark;
  const _EditorTabBar({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34, decoration: BoxDecoration(color: isDark ? const Color(0xFF0D0D19) : const Color(0xFFF1F5F9), border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12))),
      child: Row(children: [
        _buildTab('main.dart', isDark, true),
        _buildTab('styles.flux', isDark, false),
      ]),
    );
  }
  Widget _buildTab(String title, bool isDark, bool active) => Container(
    height: 34, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: active ? (isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8FAFC)) : Colors.transparent, border: Border(top: active ? const BorderSide(color: Color(0xFF6366F1), width: 2) : BorderSide.none, right: BorderSide(color: isDark ? Colors.white10 : Colors.black12))),
    child: Row(children: [
      Icon(Icons.hexagon_rounded, size: 11, color: active ? const Color(0xFF60CDFF) : Colors.grey),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? (isDark ? Colors.white : Colors.black) : Colors.grey)),
    ]),
  );
}

class _EditorStatusBar extends StatelessWidget {
  final bool isDark;
  final Flux<String> codeSignal;
  const _EditorStatusBar({required this.isDark, required this.codeSignal});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22, padding: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF6366F1),
      child: Fx(() => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.sync_rounded, size: 10, color: Colors.white),
          const SizedBox(width: 6),
          const Text('Ready', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('Characters: ${codeSignal.value.length}', style: const TextStyle(fontSize: 9, color: Colors.white, fontFamily: 'monospace')),
          const SizedBox(width: 16),
          const Text('UTF-8', style: TextStyle(fontSize: 9, color: Colors.white70)),
        ],
      )),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final bool isDark;
  final Flux<String> compiledCode;
  final Flux<int> runKey;
  final Flux<bool> isCompiling;
  final Flux<bool> showDeviceFrame;

  const _PreviewPanel({required this.isDark, required this.compiledCode, required this.runKey, required this.isCompiling, required this.showDeviceFrame});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF0D0D19) : const Color(0xFFF0F2F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        _buildHeader(),
        Expanded(child: Stack(children: [
          Center(child: Fx(() => showDeviceFrame.value ? _buildPhoneFrame(context) : _buildCanvas())),
          Positioned(bottom: 16, right: 16, child: _FloatingToolbar(showDeviceFrame: showDeviceFrame)),
        ])),
        _buildFooter(),
      ]),
    );
  }

  Widget _buildHeader() => Container(
    height: 38, padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF141430) : const Color(0xFFF1F5F9), border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12))),
    child: Row(children: [
      const Text('CANVAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.8)),
      const Spacer(),
      Fx(() => _StatusIndicator(isCompiling: isCompiling.value)),
    ]),
  );

  Widget _buildCanvas() => Fx(() => FluxySandbox(
    key: ValueKey(runKey.value),
    snippetName: 'Playground',
    childBuilder: () => FluxyEngine(code: compiledCode.value),
  ).zoomIn(scale: 0.98, duration: 40).fadeIn(duration: 40));

  Widget _buildPhoneFrame(BuildContext context) => Container(
    width: 320, height: 640,
    decoration: BoxDecoration(color: isDark ? const Color(0xFF0D0D14) : Colors.white, borderRadius: BorderRadius.circular(40), border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 8), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: const Offset(0, 10))]),
    clipBehavior: Clip.antiAlias,
    child: Stack(children: [
      Positioned.fill(child: _buildCanvas()),
      Align(alignment: Alignment.topCenter, child: Container(margin: const EdgeInsets.only(top: 12), width: 100, height: 20, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)))),
    ]),
  );

  Widget _buildFooter() => Container(
    height: 28, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF141430) : const Color(0xFFF1F5F9), border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12))),
    child: const Row(children: [
      Text('Zoom: 100%', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
      Spacer(),
      Text('Inspect Mode', style: TextStyle(fontSize: 9, color: Colors.grey)),
    ]),
  );
}

class _StatusIndicator extends StatelessWidget {
  final bool isCompiling;
  const _StatusIndicator({required this.isCompiling});
  @override
  Widget build(BuildContext context) {
    if (isCompiling) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1))),
          ),
          const SizedBox(width: 8),
          const Text('BUILDING', style: TextStyle(fontSize: 10, color: Color(0xFF6366F1), fontWeight: FontWeight.w900)),
        ],
      );
    }
    final hasError = FluxySandboxRuntime.instance.hasError.value;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: hasError ? Colors.redAccent : const Color(0xFF10B981), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          hasError ? 'ERROR' : 'LIVE',
          style: TextStyle(fontSize: 10, color: hasError ? Colors.redAccent : const Color(0xFF10B981), fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _FloatingToolbar extends StatelessWidget {
  final Flux<bool> showDeviceFrame;
  const _FloatingToolbar({required this.showDeviceFrame});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Fx(() => GestureDetector(onTap: () => showDeviceFrame.value = !showDeviceFrame.value, child: Icon(showDeviceFrame.value ? Icons.phone_iphone_rounded : Icons.crop_square_rounded, size: 16, color: Colors.white70))),
        const SizedBox(width: 12),
        const Icon(Icons.fullscreen_rounded, size: 16, color: Colors.white70),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers & Dialogs
// ---------------------------------------------------------------------------

class _SidebarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;
  const _SidebarIcon({required this.icon, required this.isActive, required this.onTap, required this.tooltip});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(message: tooltip, child: GestureDetector(onTap: onTap, child: Container(width: 48, height: 48, child: Center(child: Icon(icon, size: 20, color: isActive ? const Color(0xFF6366F1) : (isDark ? Colors.white38 : Colors.black38))))));
  }
}

class _ShareDialog extends StatelessWidget {
  final String code;
  const _ShareDialog({required this.code});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Share Code', style: TextStyle(color: Colors.white)),
      content: const Text('Permanent share link has been copied to your clipboard.', style: TextStyle(color: Colors.white70)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done', style: TextStyle(color: Color(0xFF6366F1))))],
    );
  }
}
