import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluxy/fluxy.dart';

class FluxyCodeEditor extends StatefulWidget {
  final Flux<String> codeSignal;

  const FluxyCodeEditor({
    super.key,
    required this.codeSignal,
  });

  @override
  State<FluxyCodeEditor> createState() => _FluxyCodeEditorState();
}

class _FluxyCodeEditorState extends State<FluxyCodeEditor> {
  late final _CodeController _controller;
  final ScrollController _contentScrollController = ScrollController();
  final ScrollController _gutterScrollController = ScrollController();
  final LayerLink _layerLink = LayerLink();
  
  OverlayEntry? _suggestionOverlay;
  List<String> _suggestions = [];
  int _selectedSuggestionIndex = 0;
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = _CodeController(text: widget.codeSignal.value);
    _controller.addListener(_handleTextChange);

    _contentScrollController.addListener(() {
      if (_gutterScrollController.hasClients) {
        _gutterScrollController.jumpTo(_contentScrollController.offset);
      }
      if (_isOverlayVisible) _hideOverlay();
    });
  }

  void _handleTextChange() {
    if (widget.codeSignal.value != _controller.text) {
      widget.codeSignal.value = _controller.text;
      setState(() {}); // Update line count
    }
    _updateSuggestions();
  }

  void _updateSuggestions() {
    final text = _controller.text;
    final selection = _controller.selection;
    if (!selection.isCollapsed) {
      _hideOverlay();
      return;
    }

    final offset = selection.baseOffset;
    if (offset <= 0) {
      _hideOverlay();
      return;
    }

    // Look back for trigger
    final sub = text.substring(0, offset);
    final lastDot = sub.lastIndexOf('.');
    final lastSpace = sub.lastIndexOf(RegExp(r'\s'));
    final triggerIndex = lastDot > lastSpace ? lastDot : -1;

    if (triggerIndex != -1) {
      final prefix = sub.substring(triggerIndex + 1).toLowerCase();
      final isFx = triggerIndex >= 2 && sub.substring(triggerIndex - 2, triggerIndex) == 'Fx';
      
      final candidates = isFx ? _fxKeywords : _modifierKeywords;
      _suggestions = candidates.where((s) => s.toLowerCase().startsWith(prefix)).toList();

      if (_suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (_isOverlayVisible) {
      _suggestionOverlay?.markNeedsBuild();
      return;
    }

    _suggestionOverlay = OverlayEntry(
      builder: (context) => Positioned(
        width: 220,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 24), // Approx below cursor line
          child: Material(
            elevation: 8,
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedSuggestionIndex;
                  return InkWell(
                    onTap: () => _applySuggestion(_suggestions[index]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.3) : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            _suggestions[index].contains('(') ? Icons.settings_input_component_rounded : Icons.auto_awesome_rounded,
                            size: 14,
                            color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _suggestions[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_suggestionOverlay!);
    _isOverlayVisible = true;
  }

  void _hideOverlay() {
    _suggestionOverlay?.remove();
    _suggestionOverlay = null;
    _isOverlayVisible = false;
    _selectedSuggestionIndex = 0;
  }

  void _applySuggestion(String suggestion) {
    final text = _controller.text;
    final selection = _controller.selection;
    final offset = selection.baseOffset;
    final sub = text.substring(0, offset);
    final lastDot = sub.lastIndexOf('.');
    
    // Smart Snippet logic
    String insertText = suggestion;
    int cursorOffset = suggestion.length;
    
    if (suggestion == 'col()' || suggestion == 'row()') {
      insertText = '${suggestion.substring(0, suggestion.length - 1)}children: [\n  \n])';
      cursorOffset = suggestion.length + 12; // Inside the children list
    } else if (suggestion.endsWith('()')) {
      cursorOffset = suggestion.length - 1; // Inside the parentheses
    }

    final newText = text.replaceRange(lastDot + 1, offset, insertText);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: lastDot + 1 + cursorOffset),
    );
    _hideOverlay();
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _contentScrollController.dispose();
    _gutterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lines = _controller.text.split('\n').length;

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter && !_isOverlayVisible) {
          final text = _controller.text;
          final selection = _controller.selection;
          if (selection.isCollapsed && selection.baseOffset > 0) {
            final offset = selection.baseOffset;
            final prevChar = text[offset - 1];
            if (prevChar == '{' || prevChar == '[' || prevChar == '(') {
              // Basic auto-indent
              final currentLine = text.substring(0, offset).split('\n').last;
              final indent = RegExp(r'^\s*').stringMatch(currentLine) ?? '';
              final newIndent = '$indent  ';
              final newText = text.replaceRange(offset, offset, '\n$newIndent');
              _controller.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: offset + 1 + newIndent.length),
              );
              return KeyEventResult.handled;
            }
          }
        }

        if (!_isOverlayVisible) return KeyEventResult.ignored;

        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() => _selectedSuggestionIndex = (_selectedSuggestionIndex + 1) % _suggestions.length);
            _suggestionOverlay?.markNeedsBuild();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() => _selectedSuggestionIndex = (_selectedSuggestionIndex - 1 + _suggestions.length) % _suggestions.length);
            _suggestionOverlay?.markNeedsBuild();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.tab) {
            _applySuggestion(_suggestions[_selectedSuggestionIndex]);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _hideOverlay();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141423) : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line Numbers Gutter
            Container(
              width: 44,
              padding: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D0D19) : const Color(0xFFF1F5F9),
                border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
              ),
              child: ListView.builder(
                controller: _gutterScrollController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lines,
                itemBuilder: (context, index) => Container(
                  height: 21,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
            
            // Editor Section
            Expanded(
              child: CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  controller: _controller,
                  scrollController: _contentScrollController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  cursorColor: const Color(0xFF6366F1),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _fxKeywords = [
    'box()', 'col()', 'row()', 'text()', 'button()', 'image()', 'stack()', 'scroll()', 'scrollCenter()', 'spacer()', 'divider()'
  ];

  static const _modifierKeywords = [
    'bg()', 'radius()', 'px()', 'py()', 'p()', 'mx()', 'my()', 'm()', 'size()', 'w()', 'h()', 'wFull()', 'hFull()', 'bold()', 'italic()', 'fontSize()', 'color()', 'onTap()', 'shadow', 'border()', 'animate()', 'fadeIn()', 'slideIn()', 'zoomIn()'
  ];
}

class _CodeController extends TextEditingController {
  _CodeController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<TextSpan> children = [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final keywords = RegExp(r'\b(final|class|import|extends|void|return|if|else|const|static|new|var|async|await|super|this)\b');
    final types = RegExp(r'\b(String|int|double|bool|List|Map|Widget|Signal|Flux|FluxyApp|FxRoute|BuildContext|StatelessWidget|StatefulWidget|State)\b');
    final dsl = RegExp(r'\b(Fx|FxStyle|Border|Color|EdgeInsets|BorderRadius|BoxShadow|Icons|MainAxisAlignment|CrossAxisAlignment|Axis)\b');
    final strings = RegExp(r"'.*?'" r'|".*?"');
    final comments = RegExp(r'//.*');
    final methods = RegExp(r'\b([a-zA-Z0-9_]+)\(');
    final punctuations = RegExp(r'[(){}\[\].,]');

    text.splitMapJoin(
      RegExp('${keywords.pattern}|${types.pattern}|${dsl.pattern}|${strings.pattern}|${comments.pattern}|${methods.pattern}|${punctuations.pattern}'),
      onMatch: (m) {
        final match = m[0]!;
        Color color = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
        FontWeight weight = FontWeight.w400;

        if (keywords.hasMatch(match)) {
          color = const Color(0xFFC678DD);
          weight = FontWeight.bold;
        } else if (types.hasMatch(match)) {
          color = const Color(0xFF61AFEF);
        } else if (dsl.hasMatch(match)) {
          color = const Color(0xFFD19A66);
          weight = FontWeight.w600;
        } else if (strings.hasMatch(match)) {
          color = const Color(0xFF98C379);
        } else if (comments.hasMatch(match)) {
          color = isDark ? Colors.white38 : Colors.black26;
        } else if (methods.hasMatch(match)) {
          color = const Color(0xFF61AFEF);
        } else if (punctuations.hasMatch(match)) {
          color = const Color(0xFFABB2BF);
        }

        children.add(TextSpan(text: match, style: style?.copyWith(color: color, fontWeight: weight)));
        return '';
      },
      onNonMatch: (n) {
        children.add(TextSpan(text: n, style: style));
        return '';
      },
    );

    return TextSpan(children: children, style: style);
  }
}



