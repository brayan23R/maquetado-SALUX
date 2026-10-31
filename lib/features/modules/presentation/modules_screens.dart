import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../quiz/domain/question.dart';
import '../../quiz/presentation/quiz_controller.dart';
import '../../session/presentation/app_controller.dart';

// =================================================================== /search

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctl = TextEditingController();
  String _q = '';

  static const _recent = ['ENAM', 'Pediatría', 'Emergencias', 'Cardiología'];

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final q = _q.trim().toLowerCase();
    final results = q.isEmpty
        ? <ModuleItem>[]
        : modules.where((m) => '${m.name} ${m.subtitle}'.toLowerCase().contains(q)).toList();
    return SaluxPage(
      title: 'Buscar',
      onBack: () => context.go('/home'),
      children: [
        SaluxInput(
          controller: _ctl,
          hint: 'Busca exámenes, temas…',
          icon: 'search',
          autofocus: true,
          onChanged: (v) => setState(() => _q = v),
        ),
        const SizedBox(height: 14),
        if (q.isEmpty) ...[
          const SectionTitle('Búsquedas recientes'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in _recent)
                SaluxChip(r, selected: false, onTap: () {
                  _ctl.text = r;
                  setState(() => _q = r);
                }),
            ],
          ),
        ] else if (results.isEmpty)
          const EmptyState(
            mood: MascotMood.sad,
            title: 'Sin resultados',
            subtitle: 'Prueba con otra palabra.',
          )
        else
          for (final m in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SaluxCard(
                onTap: () => context.push('/exam/${m.id}'),
                child: Row(
                  children: [
                    IconTile(m.icon, tone: m.tone, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(m.subtitle, style: TextStyle(color: c.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

// ================================================================== /modules

class ModulesScreen extends ConsumerStatefulWidget {
  const ModulesScreen({super.key});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends ConsumerState<ModulesScreen> {
  String _area = 'Todos';
  bool _onlyFree = false;
  bool _onlyDownloaded = false;
  String _sort = 'Relevancia';

  Future<void> _filters() async {
    await showSaluxSheet<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const FieldLabel('Orden'),
            Wrap(
              spacing: 8,
              children: [
                for (final s in ['Relevancia', 'Nombre'])
                  SaluxChip(s, selected: _sort == s, onTap: () {
                    set(() => _sort = s);
                    setState(() {});
                  }),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(child: Text('Solo gratis')),
                SaluxSwitch(value: _onlyFree, label: 'Solo gratis', onChanged: (v) {
                  set(() => _onlyFree = v);
                  setState(() {});
                }),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text('Solo descargados')),
                SaluxSwitch(value: _onlyDownloaded, label: 'Solo descargados', onChanged: (v) {
                  set(() => _onlyDownloaded = v);
                  setState(() {});
                }),
              ],
            ),
            const SizedBox(height: 14),
            SaluxButton('Aplicar', onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    var list = modules.where((m) => _area == 'Todos' || m.area == _area).toList();
    if (_onlyDownloaded) list = list.where((m) => app.downloads.contains(m.id)).toList();
    if (_onlyFree) list = list.where((m) => m.area == 'Exámenes').toList();
    if (_sort == 'Nombre') list.sort((a, b) => a.name.compareTo(b.name));
    return FadeIn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Módulos',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              ),
              RoundIconButton(icon: 'bell', label: 'Notificaciones', dot: !app.notificationsRead,
                  onTap: () => context.push('/notifications')),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Buscar',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SaluxRadius.input),
                    onTap: () => context.go('/search'),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(SaluxRadius.input),
                        border: Border.all(color: c.line, width: 1.5),
                      ),
                      child: Row(children: [
                        SaluxIcon('search', size: 20, color: c.muted),
                        const SizedBox(width: 10),
                        Text('Buscar', style: TextStyle(color: c.muted)),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RoundIconButton(icon: 'sliders', label: 'Filtros', onTap: _filters),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final a in moduleAreas)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SaluxChip(a, selected: _area == a, onTap: () => setState(() => _area = a)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SaluxCard(
            gradient: SaluxGradients.primary,
            border: Colors.transparent,
            onTap: () => context.push('/exam/ENAM'),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ENAM 2026',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Prepárate con simulacros y teoría',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SaluxIcon('chev', size: 22, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            const EmptyState(mood: MascotMood.sleep, title: 'No hay módulos con esos filtros')
          else
            for (final m in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SaluxCard(
                  onTap: () => context.push('/exam/${m.id}'),
                  child: Row(
                    children: [
                      IconTile(m.icon, tone: m.tone, size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text(m.subtitle, style: TextStyle(color: c.muted, fontSize: 12)),
                            const SizedBox(height: 6),
                            const Pill('10 preguntas de ejemplo', tone: Tone.violet),
                          ],
                        ),
                      ),
                      if (!app.hasAccess) SaluxIcon('lock', size: 20, color: c.muted)
                      else SaluxIcon('chev', size: 18, color: c.muted),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ============================================================== /exam/:id

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  int _tab = 0;

  static const _tabs = ['Contenido', 'Simulacros', 'Casos', 'Recursos'];

  void _setup(ModuleItem m, QuizMode mode) {
    ref.read(quizConfigProvider.notifier).set(QuizConfig(
          mode: mode,
          minutes: mode == QuizMode.timed ? 15 : 0,
          examKey: m.seedKey,
          examName: m.name,
        ));
    context.push('/quiz-setup');
  }

  @override
  Widget build(BuildContext context) {
    final m = moduleById(widget.id);
    final app = ref.watch(appProvider);
    final c = context.colors;
    final done = app.history.where((r) => r.examName == m.name).length;
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  Container(
                    height: 230,
                    decoration: const BoxDecoration(gradient: SaluxGradients.primary),
                    alignment: Alignment.bottomRight,
                    child: Image.asset('assets/images/salux_enam_header.png',
                        height: 190, cacheHeight: 380),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          RoundIconButton(icon: 'back', label: 'Volver', onTap: () => safePop(context)),
                          const Spacer(),
                          RoundIconButton(icon: 'download', label: 'Descargas', onTap: () => context.push('/downloads')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                    Text(m.subtitle, style: TextStyle(color: c.muted)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Metric('${done * 10} %'.replaceAll('0 %', '0 %'), 'Avance'),
                        const SizedBox(width: 10),
                        _Metric(app.examDate == null ? '—' : '${app.examDate!.difference(DateTime.now()).inDays} días', 'Para el examen'),
                        const SizedBox(width: 10),
                        const _Metric('10', 'Preguntas'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SaluxBar((done * .1).clamp(0, 1)),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < _tabs.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SaluxChip(_tabs[i], selected: _tab == i, onTap: () => setState(() => _tab = i)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_tab == 0)
                      for (final t in topics)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SaluxCard(
                            onTap: () => context.push('/topic/${t.id}'),
                            child: Row(
                              children: [
                                IconTile('book', tone: Tone.violet, size: 40),
                                const SizedBox(width: 12),
                                Expanded(child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                                Text('${t.questions}', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 6),
                                SaluxIcon('chev', size: 16, color: c.muted),
                              ],
                            ),
                          ),
                        )
                    else if (_tab == 1)
                      for (final n in [1, 2, 3])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SaluxCard(
                            onTap: () => _setup(m, QuizMode.timed),
                            child: Row(
                              children: [
                                IconTile('clock', tone: Tone.orange, size: 40),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Simulacro $n', style: const TextStyle(fontWeight: FontWeight.w700))),
                                SaluxIcon('chev', size: 16, color: c.muted),
                              ],
                            ),
                          ),
                        )
                    else if (_tab == 2)
                      for (final n in [1, 2])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SaluxCard(
                            onTap: () => _setup(m, QuizMode.practice),
                            child: Row(
                              children: [
                                IconTile('steth', tone: Tone.pink, size: 40),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Caso clínico $n', style: const TextStyle(fontWeight: FontWeight.w700))),
                                SaluxIcon('chev', size: 16, color: c.muted),
                              ],
                            ),
                          ),
                        )
                    else ...[
                      for (final d in docs.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SaluxCard(
                            child: Row(
                              children: [
                                IconTile('file', tone: Tone.blue, size: 40),
                                const SizedBox(width: 12),
                                Expanded(child: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                                RoundIconButton(icon: 'download', label: 'Descargar ${d.title}',
                                    onTap: () => showToast(context, 'Descarga simulada: ${d.title}')),
                              ],
                            ),
                          ),
                        ),
                      SaluxButton('Ver biblioteca', secondary: true, onPressed: () => context.push('/docs')),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 14,
            child: SafeArea(
              child: SaluxButton('Iniciar simulacro', onPressed: () => _setup(m, QuizMode.timed)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: c.soft, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.primary)),
            Text(label, style: TextStyle(color: c.muted, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ============================================================= /topic/:id

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = topicById(id);
    final app = ref.watch(appProvider);
    final c = context.colors;
    final key = 'topic-${t.id}';
    final fav = app.downloads.contains('fav-$key');
    return SaluxPage(
      title: t.name,
      actions: [
        RoundIconButton(
          icon: 'heart',
          label: 'Tema favorito',
          color: fav ? c.error : null,
          onTap: () {
            ref.read(appProvider.notifier).toggleDownload('fav-$key');
            showToast(context, fav ? 'Quitado de favoritos' : 'Tema guardado en favoritos');
          },
        ),
      ],
      bottom: SaluxButton('Practicar', onPressed: () {
        ref.read(quizConfigProvider.notifier).set(QuizConfig(
              examKey: 'ENAM',
              examName: t.name,
            ));
        context.push('/quiz-setup');
      }),
      children: [
        SaluxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tu avance', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const SaluxBar(.0),
              const SizedBox(height: 6),
              Text('0 % completado', style: TextStyle(color: c.muted, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            _Metric('12', 'Lecturas'),
            SizedBox(width: 10),
            _Metric('8', 'Casos'),
            SizedBox(width: 10),
            _Metric('40', 'Tarjetas'),
          ],
        ),
        const SizedBox(height: 14),
        SaluxButton(
          app.downloads.contains(key) ? 'Descargado ✓' : 'Descargar tema',
          secondary: true,
          icon: 'download',
          onPressed: () {
            ref.read(appProvider.notifier).toggleDownload(key);
            showToast(context, 'Descarga simulada');
          },
        ),
      ],
    );
  }
}
