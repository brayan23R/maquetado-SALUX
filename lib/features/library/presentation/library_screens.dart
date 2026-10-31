import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../session/presentation/app_controller.dart';

// ====================================================================== /docs

class DocsScreen extends ConsumerStatefulWidget {
  const DocsScreen({super.key});

  @override
  ConsumerState<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends ConsumerState<DocsScreen> {
  String _filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final list = docs.where((d) => _filter == 'Todos' || d.kind == _filter).toList();
    return SaluxPage(
      title: 'Biblioteca',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final f in docFilters)
              Padding(padding: const EdgeInsets.only(right: 8), child: SaluxChip(f, selected: _filter == f, onTap: () => setState(() => _filter = f))),
          ]),
        ),
        const SizedBox(height: 14),
        for (final d in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              onTap: () => context.push('/doc/${d.id}'),
              child: Row(children: [
                IconTile('file', tone: d.kind == 'PDF' ? Tone.pink : d.kind == 'Guías' ? Tone.violet : Tone.mint, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${d.kind} · ${d.size}', style: TextStyle(color: c.muted, fontSize: 12)),
                  ]),
                ),
                RoundIconButton(
                  icon: app.downloads.contains(d.id) ? 'check' : 'download',
                  label: 'Descargar ${d.title}',
                  onTap: () {
                    ref.read(appProvider.notifier).toggleDownload(d.id);
                    showToast(context, app.downloads.contains(d.id) ? 'Descarga eliminada' : 'Descarga simulada');
                  },
                ),
              ]),
            ),
          ),
      ],
    );
  }
}

// ================================================================= /doc/:id

class DocReaderScreen extends ConsumerStatefulWidget {
  const DocReaderScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DocReaderScreen> createState() => _DocReaderScreenState();
}

class _DocReaderScreenState extends ConsumerState<DocReaderScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final d = docs.firstWhere((x) => x.id == widget.id, orElse: () => docs.first);
    final app = ref.watch(appProvider);
    final c = context.colors;
    final saved = app.savedDocs.contains(d.id);
    return SaluxPage(
      title: d.title,
      actions: [
        RoundIconButton(icon: 'bookmark', label: 'Guardar', color: saved ? c.primary : null, onTap: () {
          ref.read(appProvider.notifier).toggleSavedDoc(d.id);
          showToast(context, saved ? 'Quitado de guardados' : 'Documento guardado');
        }),
      ],
      bottom: Row(children: [
        RoundIconButton(icon: 'back', label: 'Página anterior', onTap: _page > 1 ? () => setState(() => _page--) : null),
        Expanded(child: Text('Página $_page de ${d.pages}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))),
        Transform.rotate(
          angle: 3.14159,
          child: RoundIconButton(icon: 'back', label: 'Página siguiente', onTap: _page < d.pages ? () => setState(() => _page++) : null),
        ),
      ]),
      children: [
        SaluxCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              'Contenido de ejemplo de la página $_page. Aquí se mostrará el documento real cuando el backend entregue los archivos desde Storage.\n\n'
              'Puntos clave:\n• Concepto 1\n• Concepto 2\n• Concepto 3',
              style: const TextStyle(height: 1.6),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: SaluxButton('Nota', secondary: true, icon: 'note', onPressed: () {
            ref.read(appProvider.notifier).addNote('${d.title} · pág. $_page', 'Documentos');
            showToast(context, 'Nota guardada');
          })),
          const SizedBox(width: 10),
          Expanded(child: SaluxButton('Descargar', secondary: true, icon: 'download', onPressed: () {
            ref.read(appProvider.notifier).toggleDownload(d.id);
            showToast(context, 'Descarga simulada');
          })),
        ]),
      ],
    );
  }
}

// ================================================================== /ranking

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final me = RankEntry(app.name, app.xp);
    final all = [...rankingSample, me]..sort((a, b) => b.points.compareTo(a.points));
    final top = all.take(3).toList();
    return SaluxPage(
      title: 'Ranking',
      children: [
        Row(children: [
          for (final t in ['Semana', 'Mes', 'General'].indexed) ...[
            SaluxChip(t.$2, selected: _tab == t.$1, onTap: () => setState(() => _tab = t.$1)),
            const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 10),
        Text('Datos de ejemplo para la demostración.', style: TextStyle(color: c.muted, fontSize: 12)),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final i in [1, 0, 2])
            Expanded(
              child: Column(children: [
                SaluxIcon('crown', size: 22, color: i == 0 ? c.warn : c.muted),
                const SizedBox(height: 4),
                CircleAvatar(radius: i == 0 ? 34 : 28, backgroundColor: c.soft, child: Text(top[i].name[0], style: TextStyle(fontWeight: FontWeight.w800, color: c.primary, fontSize: 20))),
                const SizedBox(height: 6),
                Text(top[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('${top[i].points} pts', style: TextStyle(color: c.muted, fontSize: 12)),
                Container(
                  height: i == 0 ? 70 : i == 1 ? 50 : 36,
                  margin: const EdgeInsets.only(top: 6, left: 4, right: 4),
                  decoration: BoxDecoration(gradient: SaluxGradients.primary, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                ),
              ]),
            ),
        ]),
        const SizedBox(height: 16),
        for (final e in all.indexed.skip(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SaluxCard(
              color: e.$2 == me ? c.soft : null,
              border: e.$2 == me ? c.primary : null,
              child: Row(children: [
                SizedBox(width: 28, child: Text('${e.$1 + 1}', style: const TextStyle(fontWeight: FontWeight.w800))),
                Expanded(child: Text(e.$2 == me ? '${e.$2.name} (tú)' : e.$2.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                Text('${e.$2.points} pts', style: TextStyle(color: c.muted)),
              ]),
            ),
          ),
      ],
    );
  }
}

// =================================================================== /invite

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    return SaluxPage(
      title: 'Invitar amigos',
      children: [
        SaluxCard(
          gradient: SaluxGradients.primary,
          border: Colors.transparent,
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Mascot(MascotMood.love, size: 130),
            const SizedBox(height: 8),
            const Text('Estudiar juntos es mejor', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const Text('Comparte tu código con tus compañeros.', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          ]),
        ),
        const SizedBox(height: 16),
        SaluxCard(
          child: Row(children: [
            Expanded(child: Text(app.inviteCode, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 2))),
            RoundIconButton(icon: 'copy', label: 'Copiar código', onTap: () async {
              await Clipboard.setData(ClipboardData(text: app.inviteCode));
              if (context.mounted) showToast(context, 'Código copiado');
            }),
          ]),
        ),
        const SizedBox(height: 12),
        SaluxButton('Compartir', icon: 'share', onPressed: () => showToast(context, 'Compartir disponible en el dispositivo')),
        const SizedBox(height: 16),
        SaluxCard(color: c.soft, child: const Row(children: [
          SaluxIcon('users', size: 22),
          SizedBox(width: 10),
          Expanded(child: Text('Amigos unidos: 0', style: TextStyle(fontWeight: FontWeight.w700))),
        ])),
      ],
    );
  }
}

// ============================================================== /study-plan

class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  static const _plan = <(String, String, String)>[
    ('Lunes', 'Medicina Interna', 'Resolver 20 preguntas'),
    ('Martes', 'Cirugía General', 'Leer resumen + 10 preguntas'),
    ('Miércoles', 'Pediatría', 'Practicar casos clínicos'),
    ('Jueves', 'Salud Pública', 'Simulacro corto'),
    ('Viernes', 'Emergencias', 'Repaso de errores'),
    ('Sábado', 'Ciencias Básicas', 'Tarjetas de memoria'),
    ('Domingo', 'Simulacro general', 'Simulacro con tiempo'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final ctl = ref.read(appProvider.notifier);
    final c = context.colors;
    return SaluxPage(
      title: 'Plan de estudio',
      children: [
        SaluxCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.examDate == null ? 'Aún no defines la fecha del examen' : 'Examen: ${longDate(app.examDate!)}', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SaluxBar(app.studyDone.length / 7),
            const SizedBox(height: 6),
            Text('${app.studyDone.length} de 7 días completados', style: TextStyle(color: c.muted, fontSize: 12)),
          ]),
        ),
        const FieldLabel('Horas de estudio por día'),
        Row(children: [
          for (final h in [1, 2, 3, 4]) ...[
            SaluxChip('$h h', selected: app.studyHours == h, onTap: () => ctl.update((s) => s.copyWith(studyHours: h))),
            const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 14),
        for (final e in _plan.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SaluxCard(
              onTap: () {
                final d = {...app.studyDone};
                if (!d.remove(e.$1)) d.add(e.$1);
                ctl.update((s) => s.copyWith(studyDone: d));
              },
              child: Row(children: [
                Icon(app.studyDone.contains(e.$1) ? Icons.check_circle : Icons.radio_button_unchecked, color: app.studyDone.contains(e.$1) ? c.ok : c.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${e.$2.$1} · ${e.$2.$2}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${e.$2.$3} (${app.studyHours} h)', style: TextStyle(color: c.muted, fontSize: 12)),
                  ]),
                ),
              ]),
            ),
          ),
      ],
    );
  }
}
