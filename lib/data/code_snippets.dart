/// Fluxy Snippet Library
/// Full scenario library for the Fluxy Playground.
/// Each snippet is a category with multiple examples.
library fluxy_snippets;

class PlaygroundSnippet {
  final String id;
  final String name;
  final String category;
  final String description;
  final String code;
  final String icon; // emoji icon

  const PlaygroundSnippet({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.code,
    required this.icon,
  });
}

class PlaygroundCategory {
  final String id;
  final String name;
  final String icon;
  final List<PlaygroundSnippet> snippets;

  const PlaygroundCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.snippets,
  });
}

class FluxySnippetLibrary {
  static const List<PlaygroundCategory> categories = [
    _basics,
    _components,
    _layouts,
    _animations,
    _reactive,
    _stability,
    _showcase,
  ];

  static PlaygroundSnippet? findById(String id) {
    for (final cat in categories) {
      for (final snippet in cat.snippets) {
        if (snippet.id == id) return snippet;
      }
    }
    return null;
  }

  static List<PlaygroundSnippet> allSnippets() =>
      categories.expand((c) => c.snippets).toList();
}

// ---------------------------------------------------------------------------
// BASICS
// ---------------------------------------------------------------------------

const _basics = PlaygroundCategory(
  id: 'basics',
  name: 'Basics',
  icon: '⚡',
  snippets: [
    PlaygroundSnippet(
      id: 'hello_fluxy',
      name: 'Hello Fluxy',
      category: 'Basics',
      icon: '👋',
      description: 'Your first Fluxy widget',
      code: '''Fx.col(
  gap: 16,
  children: [
    Fx.text('Hello, Fluxy!').fontSize(28).bold(),
    Fx.text('Build Premium UIs with Atomic Precision.')
      .fontSize(14)
      .color(0xFF9CA3AF),
    Fx.button('Get Started', onTap: () {})
      .bg(const Color(0xFF6366F1))
      .px(32).py(14).radius(12),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'fx_box',
      name: 'Fx.box',
      category: 'Basics',
      icon: '📦',
      description: 'Atomic box builder',
      code: '''Fx.box()
  .size(180)
  .radius(24)
  .bg(const Color(0xFF6366F1))
  .shadow.xl''',
    ),
    PlaygroundSnippet(
      id: 'fx_text',
      name: 'Text Styling',
      category: 'Basics',
      icon: '✏️',
      description: 'Atomic text modifiers',
      code: '''Fx.col(
  gap: 12,
  children: [
    Fx.text('Display Text').fontSize(32).bold(),
    Fx.text('Subheading').fontSize(20).color(0xFF6366F1),
    Fx.text('Body text with semantic styling')
      .fontSize(14)
      .color(0xFF9CA3AF),
    Fx.text('LABEL').fontSize(10).bold().color(0xFF10B981),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'fx_row_col',
      name: 'Row & Column',
      category: 'Basics',
      icon: '↔️',
      description: 'Flex layouts with gap',
      code: '''Fx.col(
  gap: 16,
  children: [
    Fx.row(
      gap: 12,
      children: [
        Fx.box().size(56).radius(12).bg(const Color(0xFF6366F1)),
        Fx.box().size(56).radius(12).bg(const Color(0xFF8B5CF6)),
        Fx.box().size(56).radius(12).bg(const Color(0xFFEC4899)),
      ]
    ),
    Fx.row(
      gap: 12,
      children: [
        Fx.box().size(56).radius(12).bg(const Color(0xFF10B981)),
        Fx.box().size(56).radius(12).bg(const Color(0xFFF59E0B)),
        Fx.box().size(56).radius(12).bg(const Color(0xFFF43F5E)),
      ]
    ),
  ]
)''',
    ),
  ],
);

// ---------------------------------------------------------------------------
// COMPONENTS
// ---------------------------------------------------------------------------

const _components = PlaygroundCategory(
  id: 'components',
  name: 'Components',
  icon: '🧩',
  snippets: [
    PlaygroundSnippet(
      id: 'buttons',
      name: 'Buttons',
      category: 'Components',
      icon: '🔘',
      description: 'Button variants and styles',
      code: '''Fx.col(
  gap: 16,
  children: [
    Fx.button('Primary Action', onTap: () {})
      .bg(const Color(0xFF6366F1))
      .px(32).py(14).radius(12).shadowMd(),
    Fx.button('Outline Variant', onTap: () {})
      .applyStyle(FxStyle(
        border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        borderRadius: BorderRadius.circular(12),
      )),
    Fx.row(
      gap: 12,
      children: [
        Fx.button('Small', onTap: () {})
          .bg(const Color(0xFF10B981))
          .px(20).py(10).radius(8),
        Fx.button('Danger', onTap: () {})
          .bg(const Color(0xFFF43F5E))
          .px(20).py(10).radius(8),
      ]
    ),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'badges',
      name: 'Badges & Tags',
      category: 'Components',
      icon: '🏷️',
      description: 'Status indicators',
      code: '''Fx.row(
  gap: 20,
  children: [
    Fx.badge(
      label: 'LIVE',
      color: const Color(0xFF10B981),
      child: Fx.box().size(64).radius(16).bg(const Color(0xFF10B981).withValues(alpha: 0.1)),
    ),
    Fx.badge(
      label: 'HOT',
      color: const Color(0xFFF43F5E),
      child: Fx.box().size(64).radius(16).bg(const Color(0xFFF43F5E).withValues(alpha: 0.1)),
    ),
    Fx.badge(
      label: '99+',
      color: const Color(0xFF6366F1),
      child: Fx.avatar(size: FxAvatarSize.lg, fallback: 'A').radius(32),
    ),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'avatars',
      name: 'Avatars',
      category: 'Components',
      icon: '👤',
      description: 'Avatar components',
      code: '''Fx.row(
  gap: 16,
  items: CrossAxisAlignment.end,
  children: [
    Fx.col(
      gap: 8,
      items: CrossAxisAlignment.center,
      children: [
        Fx.avatar(size: FxAvatarSize.sm, fallback: 'SM').radius(999),
        Fx.text('sm').fontSize(10).color(0xFF9CA3AF),
      ]
    ),
    Fx.col(
      gap: 8,
      items: CrossAxisAlignment.center,
      children: [
        Fx.avatar(size: FxAvatarSize.md, fallback: 'MD').radius(999),
        Fx.text('md').fontSize(10).color(0xFF9CA3AF),
      ]
    ),
    Fx.col(
      gap: 8,
      items: CrossAxisAlignment.center,
      children: [
        Fx.avatar(size: FxAvatarSize.lg, fallback: 'LG').radius(999).shadow.lg,
        Fx.text('lg').fontSize(10).color(0xFF9CA3AF),
      ]
    ),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'card',
      name: 'Card Component',
      category: 'Components',
      icon: '🃏',
      description: 'Glass + gradient cards',
      code: '''Fx.box(
  child: Fx.col(
    gap: 16,
    children: [
      // Card header gradient bar
      Fx.box().wFull().h(4).radius(4).bg(const Color(0xFF6366F1)),
      Fx.row(
        gap: 12,
        children: [
          Fx.avatar(size: FxAvatarSize.md, fallback: 'FX').radius(12),
          Fx.col(
            gap: 4,
            children: [
              Fx.text('Fluxy Component').fontSize(16).bold(),
              Fx.text('Production-ready UI').fontSize(12).color(0xFF9CA3AF),
            ]
          ),
        ]
      ),
      Fx.box()
        .wFull().h(1)
        .bg(const Color(0xFF6366F1).withValues(alpha: 0.1)),
      Fx.text('Beautiful, atomic components built with Fluxy DSL. Each component composes cleanly with modifiers.')
        .fontSize(13).color(0xFF6B7280),
      Fx.button('View Docs', onTap: () {})
        .bg(const Color(0xFF6366F1)).px(20).py(10).radius(8),
    ]
  )
).p(24).radius(20).bg(const Color(0XFF1A1A2E)).shadow.xl''',
    ),
  ],
);

// ---------------------------------------------------------------------------
// LAYOUTS
// ---------------------------------------------------------------------------

const _layouts = PlaygroundCategory(
  id: 'layouts',
  name: 'Layouts',
  icon: '📐',
  snippets: [
    PlaygroundSnippet(
      id: 'dashboard_layout',
      name: 'Dashboard',
      category: 'Layouts',
      icon: '🖥️',
      description: 'Sidebar + content layout',
      code: '''Fx.row(
  gap: 0,
  children: [
    // Sidebar
    Fx.col(
      gap: 8,
      items: CrossAxisAlignment.center,
      children: [
        Fx.box().size(32).radius(8).bg(const Color(0xFF6366F1)),
        Fx.box().size(32).radius(8).bg(const Color(0xFF6366F1).withValues(alpha: 0.2)),
        Fx.box().size(32).radius(8).bg(const Color(0xFF6366F1).withValues(alpha: 0.2)),
        Fx.box().size(32).radius(8).bg(const Color(0xFF6366F1).withValues(alpha: 0.2)),
      ]
    ).px(12).py(16).bg(const Color(0xFF0F0F1A)),
    // Content
    Expanded(
      child: Fx.col(
        gap: 12,
        children: [
          // Stats row
          Fx.row(
            gap: 12,
            children: [
              Expanded(child: Fx.box().h(60).radius(12).bg(const Color(0xFF6366F1).withValues(alpha: 0.15))),
              Expanded(child: Fx.box().h(60).radius(12).bg(const Color(0xFF10B981).withValues(alpha: 0.15))),
              Expanded(child: Fx.box().h(60).radius(12).bg(const Color(0xFFF59E0B).withValues(alpha: 0.15))),
            ]
          ),
          // Main content
          Expanded(
            child: Fx.box().wFull().radius(12).bg(const Color(0xFF1A1A2E)),
          ),
        ]
      ).p(12),
    ),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'stat_cards',
      name: 'Stat Cards',
      category: 'Layouts',
      icon: '📊',
      description: 'Metric display grid',
      code: '''Fx.col(
  gap: 16,
  children: [
    Fx.text('Analytics Overview').fontSize(20).bold(),
    Fx.row(
      gap: 12,
      children: [
        Expanded(
          child: Fx.col(
            gap: 4,
            children: [
              Fx.text('USERS').fontSize(10).bold().color(0xFF9CA3AF),
              Fx.text('24,521').fontSize(24).bold().color(0xFF6366F1),
              Fx.text('+12.5% from last month').fontSize(10).color(0xFF10B981),
            ]
          ).p(16).radius(16).bg(const Color(0xFF6366F1).withValues(alpha: 0.1)),
        ),
        Expanded(
          child: Fx.col(
            gap: 4,
            children: [
              Fx.text('REVENUE').fontSize(10).bold().color(0xFF9CA3AF),
              Fx.text('\$98.4K').fontSize(24).bold().color(0xFF10B981),
              Fx.text('+8.1% from last month').fontSize(10).color(0xFF10B981),
            ]
          ).p(16).radius(16).bg(const Color(0xFF10B981).withValues(alpha: 0.1)),
        ),
      ]
    ),
  ]
)''',
    ),
  ],
);

// ---------------------------------------------------------------------------
// ANIMATIONS
// ---------------------------------------------------------------------------

const _animations = PlaygroundCategory(
  id: 'animations',
  name: 'Animations',
  icon: '✨',
  snippets: [
    PlaygroundSnippet(
      id: 'fade_slide',
      name: 'Fade + Slide',
      category: 'Animations',
      icon: '🎬',
      description: 'Enter animations with Fx.animate',
      code: '''Fx.col(
  gap: 16,
  children: [
    Fx.box(
      child: Fx.text('Fade In').fontSize(18).bold()
    ).p(20).radius(12).bg(const Color(0xFF6366F1))
     .animate(fade: 0, slide: const Offset(0, 30), duration: 0.5),
    Fx.box(
      child: Fx.text('Scale In').fontSize(18).bold()
    ).p(20).radius(12).bg(const Color(0xFF8B5CF6))
     .animate(fade: 0, scale: 0.5, delay: 0.2, duration: 0.5),
    Fx.box(
      child: Fx.text('Slide Right').fontSize(18).bold()
    ).p(20).radius(12).bg(const Color(0xFFEC4899))
     .animate(fade: 0, slide: const Offset(-30, 0), delay: 0.4, duration: 0.5),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'stagger',
      name: 'Stagger List',
      category: 'Animations',
      icon: '🌊',
      description: 'Staggered item entrance',
      code: '''Fx.col(
  gap: 12,
  children: List.generate(5, (i) =>
    Fx.row(
      gap: 12,
      children: [
        Fx.box().size(48).radius(12).bg(
          Color.lerp(const Color(0xFF6366F1), const Color(0xFFEC4899), i / 4)!
        ),
        Fx.col(
          gap: 4,
          children: [
            Fx.text('Item \${i + 1}').fontSize(14).bold(),
            Fx.text('Stagger delay: \${i * 100}ms').fontSize(11).color(0xFF9CA3AF),
          ]
        ),
      ]
    ).p(12).radius(12).bg(const Color(0xFF1A1A2E))
     .animate(fade: 0, slide: const Offset(20, 0), delay: i * 0.1, duration: 0.4)
  )
)''',
    ),
  ],
);

// ---------------------------------------------------------------------------
// REACTIVE
// ---------------------------------------------------------------------------

const _reactive = PlaygroundCategory(
  id: 'reactive',
  name: 'Reactive',
  icon: '⚡',
  snippets: [
    PlaygroundSnippet(
      id: 'counter',
      name: 'Signal Counter',
      category: 'Reactive',
      icon: '🔢',
      description: 'Fine-grained reactivity with flux()',
      code: '''// Signal state — fine-grained reactivity
final count = flux(0);

Fx(() => Fx.col(
  gap: 24,
  items: CrossAxisAlignment.center,
  children: [
    Fx.text('Reactive Counter').fontSize(18).bold(),
    Fx.box(
      child: Fx.text('\${count.value}').fontSize(48).bold().color(0xFF6366F1)
    ).p(32).radius(20).bg(const Color(0xFF6366F1).withValues(alpha: 0.1)),
    Fx.row(
      gap: 16,
      children: [
        Fx.button('-', onTap: () => count.value--)
          .bg(const Color(0xFFF43F5E)).size(48).radius(12),
        Fx.button('Reset', onTap: () => count.value = 0)
          .bg(const Color(0xFF6B7280)).px(20).py(12).radius(12),
        Fx.button('+', onTap: () => count.value++)
          .bg(const Color(0xFF10B981)).size(48).radius(12),
      ]
    ),
  ]
))''',
    ),
    PlaygroundSnippet(
      id: 'toggle',
      name: 'Toggle State',
      category: 'Reactive',
      icon: '🔄',
      description: 'Signal-driven UI toggle',
      code: '''final isActive = flux(false);

Fx(() => Fx.col(
  gap: 20,
  items: CrossAxisAlignment.center,
  children: [
    // Animated indicator
    Fx.box()
      .size(80)
      .radius(40)
      .bg(isActive.value ? const Color(0xFF10B981) : const Color(0xFF374151))
      .shadow.lg,
    Fx.text(isActive.value ? 'ACTIVE' : 'INACTIVE')
      .fontSize(16).bold()
      .color(isActive.value ? 0xFF10B981 : 0xFF9CA3AF),
    Fx.button(
      isActive.value ? 'Turn Off' : 'Turn On',
      onTap: () => isActive.value = !isActive.value
    )
    .bg(isActive.value ? const Color(0xFFF43F5E) : const Color(0xFF6366F1))
    .px(28).py(14).radius(12),
  ]
))''',
    ),
  ],
);

// ---------------------------------------------------------------------------
// STABILITY DEMOS
// ---------------------------------------------------------------------------

const _stability = PlaygroundCategory(
  id: 'stability',
  name: 'Stability',
  icon: '🛡️',
  snippets: [
    PlaygroundSnippet(
      id: 'crash_recovery',
      name: 'Crash Recovery',
      category: 'Stability',
      icon: '🚑',
      description: 'See the Stability Kernel intercept a crash',
      code: '''// This intentionally causes a widget error
// Watch the Stability Console intercept it!
Fx.col(
  gap: 16,
  children: [
    Fx.text('Stability Demo').fontSize(20).bold(),
    Fx.text('The sandbox will catch any crash below.')
      .fontSize(13).color(0xFF9CA3AF),
    // This box is fine
    Fx.box()
      .size(100).radius(16)
      .bg(const Color(0xFF6366F1)),
    Fx.text('✅ Sandbox protected').fontSize(12).color(0xFF10B981),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'nested_scroll',
      name: 'Nested Scroll',
      category: 'Stability',
      icon: '📜',
      description: 'Scroll inside scroll — stability test',
      code: '''Fx.col(
  gap: 12,
  children: [
    Fx.text('Nested Scroll Stability Test').fontSize(16).bold(),
    Fx.text('Fluxy handles scroll conflicts gracefully.')
      .fontSize(12).color(0xFF9CA3AF),
    // Outer scroll container
    FxScroll(
      child: Fx.col(
        gap: 8,
        children: List.generate(5, (i) =>
          Fx.box(
            child: Fx.text('Scrollable Item \${i + 1}')
              .fontSize(14)
          ).p(16).wFull().radius(12)
           .bg(const Color(0xFF6366F1).withValues(alpha: 0.1 + i * 0.05))
        ),
      ),
    ).h(200).radius(12),
  ]
)''',
    ),
    PlaygroundSnippet(
      id: 'api_retry',
      name: 'API Retry Sim',
      category: 'Stability',
      icon: '🔁',
      description: 'Async guard + retry simulation',
      code: '''final status = flux('idle'); // idle | loading | success | error

Fx(() => Fx.col(
  gap: 20,
  items: CrossAxisAlignment.center,
  children: [
    Fx.text('API Retry Simulation').fontSize(18).bold(),
    // Status indicator
    Fx.box(
      child: Fx.col(
        gap: 8,
        items: CrossAxisAlignment.center,
        children: [
          Icon(
            status.value == 'success' ? Icons.check_circle :
            status.value == 'error'   ? Icons.error_outline :
            status.value == 'loading' ? Icons.hourglass_empty :
            Icons.wifi_tethering,
            color: status.value == 'success' ? const Color(0xFF10B981) :
                   status.value == 'error'   ? const Color(0xFFF43F5E) :
                   const Color(0xFF6366F1),
            size: 40,
          ),
          Fx.text(status.value.toUpperCase())
            .fontSize(12).bold()
            .color(status.value == 'success' ? 0xFF10B981 : 0xFF6366F1),
        ]
      )
    ).size(120).radius(60)
     .bg(const Color(0xFF6366F1).withValues(alpha: 0.08)),
    // Controls
    Fx.row(
      gap: 12,
      children: [
        Fx.button('Fetch', onTap: () {
          status.value = 'loading';
          Future.delayed(const Duration(seconds: 1), () {
            status.value = 'success';
          });
        }).bg(const Color(0xFF6366F1)).px(20).py(12).radius(8),
        Fx.button('Fail', onTap: () {
          status.value = 'error';
        }).bg(const Color(0xFFF43F5E)).px(20).py(12).radius(8),
        Fx.button('Reset', onTap: () {
          status.value = 'idle';
        }).bg(const Color(0xFF6B7280)).px(20).py(12).radius(8),
      ]
    ),
  ]
))''',
    ),
  ],
);

// ---------------------------------------------------------------------------
// SHOWCASE
// ---------------------------------------------------------------------------

const _showcase = PlaygroundCategory(
  id: 'showcase',
  name: 'Showcase',
  icon: '🚀',
  snippets: [
    PlaygroundSnippet(
      id: 'finance_dashboard',
      name: 'Finance Dashboard',
      category: 'Showcase',
      icon: '🏛️',
      description: 'Ultra-complex nested UI showcase',
      code: '''Fx.col(
  gap: 20,
  children: [
    // Header
    Fx.row(
      gap: 12,
      children: [
        Fx.avatar(size: FxAvatarSize.lg, fallback: 'JS').radius(16),
        Fx.col(
          gap: 4,
          children: [
            Fx.text('Welcome back, James').fontSize(18).bold(),
            Fx.text('Account: Active').fontSize(11).color(0xFF10B981),
          ]
        ),
        const Spacer(),
        Fx.box().size(40).radius(12).bg(const Color(0xFF6366F1).withValues(alpha: 0.1)).child(
          const Icon(Icons.notifications_none_rounded, color: Color(0xFF6366F1), size: 18)
        ),
      ]
    ),
    
    // Total Balance Card
    Fx.box(
      child: Fx.col(
        gap: 12,
        children: [
          Fx.text('TOTAL BALANCE').fontSize(10).bold().color(0xFFFFFFFF).withValues(alpha: 0.6),
          Fx.text('\$42,850.12').fontSize(32).bold().color(0xFFFFFFFF),
          Fx.row(
            gap: 8,
            children: [
              Fx.text('+ \$1,240.00 today').fontSize(12).color(0xFF10B981),
              const Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 14),
            ]
          ),
        ]
      )
    ).p(24).wFull().radius(24).bg(const Color(0xFF6366F1)).shadow.xl,
    
    // Quick Actions
    Fx.row(
      gap: 12,
      children: [
        Expanded(child: Fx.box().h(48).radius(12).bg(const Color(0xFF1A1A2E)).child(
          const Center(child: Text('SENT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)))
        )),
        Expanded(child: Fx.box().h(48).radius(12).bg(const Color(0xFF1A1A2E)).child(
          const Center(child: Text('RECEIVE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)))
        )),
        Expanded(child: Fx.box().h(48).radius(12).bg(const Color(0xFF1A1A2E)).child(
          const Center(child: Text('SWAP', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)))
        )),
      ]
    ),
    
    // Transactions
    Fx.col(
      gap: 16,
      children: [
        Fx.row(
          children: [
            Fx.text('Recent Transactions').fontSize(14).bold(),
            const Spacer(),
            Fx.text('View All').fontSize(12).color(0xFF6366F1),
          ]
        ),
        // Item 1
        Fx.row(
          gap: 12,
          children: [
            Fx.box().size(44).radius(12).bg(const Color(0xFF10B981).withValues(alpha: 0.1)).child(
              const Icon(Icons.shopping_bag_outlined, color: Color(0xFF10B981), size: 18)
            ),
            Fx.col(
              gap: 2,
              children: [
                Fx.text('Apple Store').fontSize(13).bold(),
                Fx.text('Electronics - 2m ago').fontSize(10).color(0xFF9CA3AF),
              ]
            ),
            const Spacer(),
            Fx.text('- \$999.00').fontSize(13).bold().color(0xFFF43F5E),
          ]
        ),
        // Item 2
        Fx.row(
          gap: 12,
          children: [
            Fx.box().size(44).radius(12).bg(const Color(0xFF6366F1).withValues(alpha: 0.1)).child(
              const Icon(Icons.payment_rounded, color: Color(0xFF6366F1), size: 18)
            ),
            Fx.col(
              gap: 2,
              children: [
                Fx.text('Salary Deposit').fontSize(13).bold(),
                Fx.text('Incoming - 4h ago').fontSize(10).color(0xFF9CA3AF),
              ]
            ),
            const Spacer(),
            Fx.text('+ \$4,500.00').fontSize(13).bold().color(0xFF10B981),
          ]
        ),
      ]
    ),
  ]
)''',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Legacy compatibility with old FluxySnippets
// ---------------------------------------------------------------------------

class FluxySnippets {
  static const String buttons = '''Fx.col(
  gap: 16,
  children: [
    Fx.button('Primary Action', onTap: () {})
      .bg(const Color(0xFF6366F1))
      .px(32).py(14).radius(12).shadowMd(),
    Fx.button('Secondary', onTap: () {})
      .applyStyle(FxStyle(
        border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        borderRadius: BorderRadius.circular(12),
      )),
  ]
)''';

  static const String badges = '''Fx.row(
  gap: 20,
  children: [
    Fx.badge(
      label: 'NEW',
      color: const Color(0xFF10B981),
      child: Fx.box().size(64).radius(16).bg(const Color(0xFF10B981).withValues(alpha: 0.1)),
    ),
    Fx.badge(
      label: '99+',
      color: const Color(0xFF6366F1),
      child: Fx.avatar(size: FxAvatarSize.md, fallback: 'A').radius(24),
    ),
  ]
)''';

  static const String avatars = '''Fx.row(
  gap: 16,
  children: [
    Fx.avatar(size: FxAvatarSize.sm, fallback: 'S').radius(999),
    Fx.avatar(size: FxAvatarSize.md, fallback: 'M').radius(999),
    Fx.avatar(size: FxAvatarSize.lg, fallback: 'L').radius(999).shadow.lg,
  ]
)''';

  static const String cards = '''Fx.box(
  child: Fx.col(
    gap: 12,
    children: [
      Fx.text('Premium Card').fontSize(18).bold(),
      Fx.text('Built with Fluxy DSL').fontSize(13).color(0xFF9CA3AF),
      Fx.button('Action', onTap: () {}).bg(const Color(0xFF6366F1)).px(20).py(10).radius(8),
    ]
  )
).p(24).radius(20).bg(const Color(0xFF1A1A2E)).shadow.xl''';

  static const String layouts_dashboard = '''Fx.row(
  gap: 12,
  children: [
    Fx.box().w(60).bg(const Color(0xFF0F0F1A)).radius(12),
    Expanded(
      child: Fx.col(
        gap: 12,
        children: [
          Fx.box().h(50).radius(12).bg(const Color(0xFF1A1A2E)),
          Expanded(child: Fx.box().wFull().radius(12).bg(const Color(0xFF6366F1).withValues(alpha: 0.1))),
        ]
      )
    ),
  ]
)''';
}
