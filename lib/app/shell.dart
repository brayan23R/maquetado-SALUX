import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';

/// Contenedor con la barra inferior flotante de 5 pestañas.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <(String, String, String, List<String>)>[
    ('Inicio', 'home', '/home', ['/home', '/search']),
    ('Módulos', 'book', '/modules', ['/modules', '/exam', '/topic']),
    ('Simulacros', 'target', '/simulations', ['/simulations']),
    ('Progreso', 'chart', '/progress', ['/progress', '/streak', '/achievements']),
    ('Perfil', 'user', '/profile', ['/profile']),
  ];

  int _index(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (_tabs[i].$4.any(location.startsWith)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final location = GoRouterState.of(context).uri.path;
    final index = _index(location);
    return Scaffold(
      extendBody: true,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          height: 68,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: c.line),
            boxShadow: [BoxShadow(color: c.shadow, blurRadius: 34, offset: const Offset(0, 14))],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: _tabs[i].$1,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.go(_tabs[i].$3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 46,
                            height: 30,
                            decoration: BoxDecoration(
                              color: i == index ? c.soft : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: SaluxIcon(
                                _tabs[i].$2,
                                size: 22,
                                color: i == index ? c.primary : c.muted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tabs[i].$1,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: i == index ? c.primary : c.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
