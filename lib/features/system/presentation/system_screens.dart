import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../catalog/data/mock_catalog.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SaluxPage(
      title: 'Ayuda',
      children: [
        for (final f in faqs.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              onTap: () => setState(() => _open = _open == f.$1 ? null : f.$1),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(f.$2.$1, style: const TextStyle(fontWeight: FontWeight.w800))),
                  Icon(_open == f.$1 ? Icons.expand_less : Icons.expand_more, color: c.muted),
                ]),
                if (_open == f.$1) ...[
                  const SizedBox(height: 8),
                  Text(f.$2.$2, style: TextStyle(color: c.muted, height: 1.4)),
                ],
              ]),
            ),
          ),
        const SizedBox(height: 8),
        SaluxButton('Contactar soporte', icon: 'mail', onPressed: () => showToast(context, 'soporte@salux.app (demo)')),
      ],
    );
  }
}

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Spacer(),
            const Mascot(MascotMood.sad, size: 170),
            const SizedBox(height: 8),
            SaluxIcon('wifioff', size: 32, color: context.colors.muted),
            const SizedBox(height: 8),
            const Text('Sin conexión', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            Text('Puedes seguir con lo que descargaste.', style: TextStyle(color: context.colors.muted)),
            const Spacer(),
            SaluxButton('Ir a descargas', onPressed: () => context.push('/downloads')),
            const SizedBox(height: 10),
            SaluxButton('Reintentar', secondary: true, onPressed: () => context.go('/home')),
          ]),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Spacer(),
            const Mascot(MascotMood.sad, size: 170),
            const SizedBox(height: 8),
            const Text('Algo salió mal', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            Text(message ?? 'Inténtalo de nuevo en unos segundos.', textAlign: TextAlign.center, style: TextStyle(color: context.colors.muted)),
            const Spacer(),
            SaluxButton('Reintentar', onPressed: () => context.go('/home')),
            const SizedBox(height: 10),
            SaluxButton('Hablar con soporte', secondary: true, onPressed: () => context.push('/help')),
          ]),
        ),
      ),
    );
  }
}
