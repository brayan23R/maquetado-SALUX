import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../session/presentation/app_controller.dart';
import '../data/question_repository.dart';
import '../domain/question.dart';
import 'quiz_controller.dart';

/// Prepara el intento y abre `/quiz`.
Future<void> launchQuiz(BuildContext context, WidgetRef ref, QuizConfig config) async {
  final app = ref.read(appProvider);
  var cfg = config;
  if (!app.hasAccess) {
    // Plan gratis: 5 preguntas por día (el servidor lo validará en modo supabase).
    final left = 5 - app.answeredToday;
    if (left <= 0) {
      showToast(context, 'Llegaste al límite gratis de hoy');
      context.push('/paywall');
      return;
    }
    if (cfg.count > left) cfg = cfg.copyWith(count: left);
  }
  await ref.read(quizProvider.notifier).start(cfg);
  if (context.mounted) context.push('/quiz');
}

// =============================================================== /quiz-setup

class QuizSetupScreen extends ConsumerWidget {
  const QuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(quizConfigProvider);
    final ctl = ref.read(quizConfigProvider.notifier);
    final c = context.colors;

    Widget modeCard(QuizMode m, String title, String sub, String icon, Tone tone) {
      final sel = cfg.mode == m;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SaluxCard(
          border: sel ? c.primary : null,
          onTap: () => ctl.patch((x) => x.copyWith(
                mode: m,
                minutes: m == QuizMode.timed ? 15 : 0,
              )),
          child: Row(
            children: [
              IconTile(icon, tone: tone, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(sub, style: TextStyle(color: c.muted, fontSize: 12)),
                  ],
                ),
              ),
              Icon(
                sel ? Icons.radio_button_checked : Icons.radio_button_off,
                color: sel ? c.primary : c.muted,
              ),
            ],
          ),
        ),
      );
    }

    return SaluxPage(
      title: 'Crea tu simulacro',
      bottom: SaluxButton(
        'Comenzar',
        onPressed: () => launchQuiz(context, ref, cfg),
      ),
      children: [
        Text('Examen: ${cfg.examName}', style: TextStyle(color: c.muted)),
        const SectionTitle('Modo'),
        modeCard(QuizMode.practice, 'Práctica', 'Feedback inmediato en cada pregunta', 'bulb', Tone.violet),
        modeCard(QuizMode.timed, 'Simulacro con tiempo', 'Sin feedback hasta el final', 'clock', Tone.orange),
        modeCard(QuizMode.review, 'Repaso de errores', 'Preguntas que fallaste antes', 'refresh', Tone.pink),
        const SectionTitle('Cantidad de preguntas'),
        Row(
          children: [
            for (final n in [5, 10]) ...[
              SaluxChip('$n preguntas',
                  selected: cfg.count == n,
                  onTap: () => ctl.patch((x) => x.copyWith(count: n))),
              const SizedBox(width: 10),
            ],
          ],
        ),
        if (cfg.mode == QuizMode.timed) ...[
          const SectionTitle('Tiempo'),
          Row(
            children: [
              SaluxChip('Sin límite',
                  selected: cfg.minutes == 0,
                  onTap: () => ctl.patch((x) => x.copyWith(minutes: 0))),
              const SizedBox(width: 10),
              SaluxChip('15 min',
                  selected: cfg.minutes == 15,
                  onTap: () => ctl.patch((x) => x.copyWith(minutes: 15))),
            ],
          ),
        ],
        const SizedBox(height: 18),
        SaluxCard(
          color: c.soft,
          child: Row(
            children: [
              SaluxIcon('info', size: 20, color: c.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Usas un banco de ejemplo para el MVP. El contenido final será validado por profesionales.',
                  style: TextStyle(color: c.muted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================== /quiz

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  /// Evita el redireccionamiento de seguridad cuando la salida es intencional.
  bool _leaving = false;

  Future<void> _exit() async {
    final leave = await showSaluxSheet<bool>(
      context,
      builder: (ctx) => Column(
        children: [
          const Mascot(MascotMood.think, size: 100),
          const SizedBox(height: 8),
          const Text('¿Salir del simulacro?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 18),
          SaluxButton('Salir y guardar', onPressed: () => Navigator.pop(ctx, true)),
          const SizedBox(height: 10),
          SaluxButton('Seguir', secondary: true, onPressed: () => Navigator.pop(ctx, false)),
        ],
      ),
    );
    if (leave ?? false) {
      _leaving = true;
      ref.read(quizProvider.notifier).abandon();
      if (mounted) {
        context.go('/simulations');
        showToast(context, 'Simulacro guardado');
      }
    }
  }

  Future<void> _pause() async {
    final ctl = ref.read(quizProvider.notifier)..setPaused(paused: true);
    final exit = await showSaluxSheet<bool>(
      context,
      builder: (ctx) => Column(
        children: [
          const Mascot(MascotMood.sleep, size: 110),
          const Text('Simulacro en pausa',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 18),
          SaluxButton('Continuar', onPressed: () => Navigator.pop(ctx, false)),
          const SizedBox(height: 10),
          SaluxButton('Salir y guardar', secondary: true, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    ctl.setPaused(paused: false);
    if (exit ?? false) {
      _leaving = true;
      ctl.abandon();
      if (mounted) {
        context.go('/simulations');
        showToast(context, 'Simulacro guardado');
      }
    }
  }

  void _finish() {
    _leaving = true;
    final r = ref.read(quizProvider.notifier).finish();
    if (r != null && mounted) context.pushReplacement('/result?id=${r.id}');
  }

  Future<void> _navigator(QuizState s) async {
    await showSaluxSheet<void>(
      context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final st = ref.watch(quizProvider) ?? s;
          final c = ctx.colors;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Navegador',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < st.questions.length; i++)
                    Semantics(
                      button: true,
                      label: 'Pregunta ${i + 1}',
                      child: InkWell(
                        onTap: () {
                          ref.read(quizProvider.notifier).goTo(i);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == st.index
                                ? c.primary
                                : st.marked.contains(i)
                                    ? c.warnBg
                                    : st.answers[i] >= 0
                                        ? c.okBg
                                        : c.soft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: i == st.index ? Colors.white : c.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SaluxButton(
                st.isPractice ? 'Finalizar práctica' : 'Finalizar simulacro',
                onPressed: () {
                  Navigator.pop(ctx);
                  _finish();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _report() async {
    var reason = 0;
    final reasons = ['Respuesta incorrecta', 'Enunciado confuso', 'Error de ortografía', 'Otro'];
    await showSaluxSheet<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reportar pregunta',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < reasons.length; i++)
                  SaluxChip(reasons[i], selected: reason == i, onTap: () => set(() => reason = i)),
              ],
            ),
            const SizedBox(height: 14),
            const SaluxInput(hint: 'Comentario (opcional)', maxLines: 3),
            const SizedBox(height: 16),
            SaluxButton('Enviar', onPressed: () {
              Navigator.pop(ctx);
              showToast(context, 'Gracias, revisaremos la pregunta');
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(quizProvider);
    final app = ref.watch(appProvider);
    final c = context.colors;
    if (s == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_leaving && ref.read(quizProvider) == null) context.go('/simulations');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final q = s.current;
    final fav = app.favorites.contains(q.id);
    final timeText = s.config.mode == QuizMode.timed && s.limitSeconds > 0
        ? mmss(s.remaining)
        : s.config.mode == QuizMode.timed
            ? mmss(s.elapsed)
            : 'Libre';

    Color optBg(int i) {
      if (s.isPractice && s.answered) {
        if (i == q.correctIndex) return c.okBg;
        if (i == s.answer) return c.errorBg;
      } else if (s.answer == i) {
        return c.soft;
      }
      return c.surface;
    }

    Color optBorder(int i) {
      if (s.isPractice && s.answered) {
        if (i == q.correctIndex) return c.ok;
        if (i == s.answer) return c.error;
      } else if (s.answer == i) {
        return c.primary;
      }
      return c.line;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    RoundIconButton(icon: 'close', label: 'Salir', onTap: _exit),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Pregunta ${s.index + 1} de ${s.questions.length}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          SaluxBar((s.index + 1) / s.questions.length),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _pause,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48, minWidth: 70),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SaluxIcon('clock', size: 16, color: c.primary),
                            const SizedBox(width: 4),
                            Text(timeText,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, color: c.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    if (s.notice != null && s.index == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SaluxCard(
                          color: c.warnBg,
                          child: Text(s.notice!, style: TextStyle(color: c.warn)),
                        ),
                      ),
                    SaluxCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Pill(q.topic, tone: Tone.violet),
                              const SizedBox(width: 8),
                              Pill('${app.streak} días', tone: Tone.orange, icon: 'flame'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(q.text,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < q.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Semantics(
                          button: true,
                          label: 'Opción ${q.options[i].label}: ${q.options[i].text}',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(SaluxRadius.card),
                            onTap: () => ref.read(quizProvider.notifier).answer(i),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 56),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: optBg(i),
                                borderRadius: BorderRadius.circular(SaluxRadius.card),
                                border: Border.all(color: optBorder(i), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: c.soft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(q.options[i].label,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800, color: c.primary)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(q.options[i].text,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (s.isPractice && s.answered)
                      SaluxCard(
                        color: s.answer == q.correctIndex ? c.okBg : c.errorBg,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Mascot(
                              s.answer == q.correctIndex ? MascotMood.cheer : MascotMood.sad,
                              size: 64,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.answer == q.correctIndex ? '¡Correcto!' : 'Incorrecto',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(q.explanation),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RoundIconButton(
                          icon: 'heart',
                          label: fav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                          color: fav ? c.error : null,
                          onTap: () => ref.read(appProvider.notifier).toggleFavorite(q.id),
                        ),
                        RoundIconButton(
                          icon: 'flag',
                          label: 'Marcar para revisar',
                          color: s.marked.contains(s.index) ? c.warn : null,
                          onTap: () => ref.read(quizProvider.notifier).toggleMark(),
                        ),
                        RoundIconButton(
                          icon: 'note',
                          label: 'Crear nota',
                          onTap: () {
                            ref.read(appProvider.notifier).addNote(
                                  'Repasar: ${q.text}',
                                  q.topic,
                                );
                            showToast(context, 'Nota guardada');
                          },
                        ),
                        RoundIconButton(
                          icon: 'grid',
                          label: 'Navegador de preguntas',
                          onTap: () => _navigator(s),
                        ),
                        RoundIconButton(icon: 'help', label: 'Reportar pregunta', onTap: _report),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: SaluxButton(
                  s.isLast ? 'Finalizar' : 'Siguiente',
                  onPressed: !s.answered
                      ? null
                      : s.isLast
                          ? _finish
                          : () => ref.read(quizProvider.notifier).next(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================== /result

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final r = app.history.where((x) => x.id == id).firstOrNull ??
        ref.read(quizProvider.notifier).lastResult ??
        app.history.firstOrNull;
    if (r == null) {
      return SaluxPage(
        title: 'Resultado',
        children: [
          EmptyState(
            mood: MascotMood.sleep,
            title: 'Aún no hay resultados',
            subtitle: 'Completa un simulacro para ver tu resultado.',
            action: () => context.go('/quiz-setup'),
            actionLabel: 'Crear simulacro',
          ),
        ],
      );
    }
    final high = r.score >= .7;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (high && !MediaQuery.of(context).disableAnimations)
              const Positioned.fill(child: IgnorePointer(child: _Confetti())),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      RoundIconButton(icon: 'close', label: 'Cerrar', onTap: () => context.go('/home')),
                      const Spacer(),
                      RoundIconButton(
                        icon: 'share',
                        label: 'Compartir resultado',
                        onTap: () => showToast(context, 'Resultado copiado para compartir'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      Center(
                        child: Mascot(high ? MascotMood.cheer : MascotMood.sad, size: 120),
                      ),
                      Text(
                        high ? '¡Excelente trabajo!' : 'Sigue practicando',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ProgressRing(
                          value: r.score,
                          size: 150,
                          stroke: 14,
                          color: high ? c.ok : c.warn,
                          child: Text(percent(r.score),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 30)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _Stat('Correctas', '${r.correct}', c.okBg, c.ok),
                          const SizedBox(width: 10),
                          _Stat('Incorrectas', '${r.wrong + r.unanswered}', c.errorBg, c.error),
                          const SizedBox(width: 10),
                          _Stat('Tiempo', mmss(r.seconds), c.soft, c.primary),
                        ],
                      ),
                      const SectionTitle('Por tema'),
                      for (final e in r.byTopic.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SaluxCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(e.key,
                                          style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                    Text('${e.value[0]}/${e.value[1]}',
                                        style: TextStyle(color: c.muted)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SaluxBar(e.value[1] == 0 ? 0 : e.value[0] / e.value[1]),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      SaluxCard(
                        color: c.warnBg,
                        child: Row(
                          children: [
                            SaluxIcon('flame', size: 24, color: c.warn),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                app.goalMetToday
                                    ? '¡Meta diaria cumplida! Racha: ${app.streak} días.'
                                    : 'Llevas ${app.answeredToday} de ${app.dailyGoal} preguntas hoy.',
                                style: TextStyle(color: c.warn, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: SaluxButton('Repetir',
                            secondary: true, onPressed: () => context.go('/quiz-setup')),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SaluxButton('Revisar', onPressed: () => context.push('/review?id=${r.id}')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.bg, this.fg);

  final String label;
  final String value;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: fg)),
              Text(label, style: TextStyle(color: fg, fontSize: 12)),
            ],
          ),
        ),
      );
}

class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
  final _rnd = math.Random(7);
  late final List<(double, double, double, Color)> _p = [
    for (var i = 0; i < 40; i++)
      (
        _rnd.nextDouble(),
        _rnd.nextDouble() * .4,
        .6 + _rnd.nextDouble() * .8,
        [
          const Color(0xFF7360F2),
          const Color(0xFFFFB24F),
          const Color(0xFF59DDAE),
          const Color(0xFFFF9BB8),
        ][i % 4],
      ),
  ];

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctl,
        builder: (_, _) => CustomPaint(painter: _ConfettiPainter(_p, _ctl.value)),
      );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.p, this.t);

  final List<(double, double, double, Color)> p;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, delay, speed, color) in p) {
      final prog = ((t - delay) * speed).clamp(0.0, 1.0);
      if (prog <= 0 || prog >= 1) continue;
      canvas
        ..save()
        ..translate(x * size.width + math.sin(prog * 8) * 14, prog * size.height)
        ..rotate(prog * 10)
        ..drawRect(
          const Rect.fromLTWH(0, 0, 8, 12),
          Paint()..color = color.withValues(alpha: 1 - prog * .6),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

// ================================================================== /review

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final r = app.history.where((x) => x.id == id).firstOrNull ?? app.history.firstOrNull;
    final all = ref.watch(allQuestionsProvider);
    if (r == null) {
      return SaluxPage(title: 'Revisión', children: const [
        EmptyState(mood: MascotMood.sleep, title: 'Nada para revisar'),
      ]);
    }
    return SaluxPage(
      title: 'Revisión',
      bottom: SaluxButton('Volver al inicio', onPressed: () => context.go('/home')),
      children: all.when(
        loading: () => [const Skeleton(height: 160), const Skeleton(height: 160)],
        error: (e, _) => [
          EmptyState(
            mood: MascotMood.sad,
            title: 'No se pudo cargar',
            action: () => ref.invalidate(allQuestionsProvider),
          ),
        ],
        data: (qs) {
          final byId = {for (final q in qs) q.id: q};
          return [
            for (var i = 0; i < r.questionIds.length; i++)
              if (byId[r.questionIds[i]] case final q?)
                _ReviewCard(
                  index: i,
                  q: q,
                  chosen: r.answers[i],
                  fav: app.favorites.contains(q.id),
                  onFav: () => ref.read(appProvider.notifier).toggleFavorite(q.id),
                  colors: c,
                ),
          ];
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.index,
    required this.q,
    required this.chosen,
    required this.fav,
    required this.onFav,
    required this.colors,
  });

  final int index;
  final Question q;
  final int chosen;
  final bool fav;
  final VoidCallback onFav;
  final SaluxColors colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final ok = chosen == q.correctIndex;
    final label = chosen < 0 ? 'Sin responder' : (ok ? 'Correcta' : 'Incorrecta');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SaluxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(label, tone: ok ? Tone.mint : (chosen < 0 ? Tone.orange : Tone.pink)),
                const Spacer(),
                RoundIconButton(
                  icon: 'heart',
                  label: 'Favorito',
                  color: fav ? c.error : null,
                  onTap: onFav,
                ),
              ],
            ),
            Text('${index + 1}. ${q.text}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(
              'Tu respuesta: ${chosen < 0 ? '—' : q.options[chosen].text}',
              style: TextStyle(color: ok ? c.ok : c.error, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('Respuesta correcta: ${q.options[q.correctIndex].text}',
                style: TextStyle(color: c.ok, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(q.explanation, style: TextStyle(color: c.muted)),
          ],
        ),
      ),
    );
  }
}
