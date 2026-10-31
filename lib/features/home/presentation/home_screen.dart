import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../quiz/data/question_repository.dart';
import '../../quiz/domain/question.dart';
import '../../quiz/presentation/quiz_controller.dart';
import '../../quiz/presentation/quiz_screens.dart';
import '../../session/domain/app_state.dart';
import '../../session/presentation/app_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final last = app.history.firstOrNull;
    final daysToExam = app.examDate?.difference(DateTime.now()).inDays;
    final week = _weekDays();

    void practice({QuizMode mode = QuizMode.practice, int count = 10}) {
      ref.read(quizConfigProvider.notifier).set(QuizConfig(
            mode: mode,
            count: count,
            examKey: moduleByName(app.goalExam).seedKey,
            examName: app.goalExam,
          ));
      launchQuiz(context, ref, ref.read(quizConfigProvider));
    }

    return FadeIn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Ir a mi perfil',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.go('/profile'),
                  child: ClipOval(
                    child: Image.asset('assets/images/salux_avatar.png',
                        width: 48, height: 48, fit: BoxFit.cover, cacheWidth: 144),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting(), style: TextStyle(color: c.muted, fontSize: 12)),
                    Text(app.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.go('/streak'),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Pill('${app.streak}', tone: Tone.orange, icon: 'flame'),
                ),
              ),
              RoundIconButton(
                icon: 'bell',
                label: 'Notificaciones',
                dot: !app.notificationsRead,
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
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
                child: Row(
                  children: [
                    SaluxIcon('search', size: 20, color: c.muted),
                    const SizedBox(width: 10),
                    Text('Busca exámenes, temas…', style: TextStyle(color: c.muted)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (app.isTrial)
            _Banner(
              text: 'Prueba gratis: te quedan ${app.trialDaysLeft} ${app.trialDaysLeft == 1 ? 'día' : 'días'}',
              action: 'Ver planes',
              tone: Tone.mint,
              icon: 'gift',
              onTap: () => context.push('/plans'),
            )
          else if (app.trialExpired)
            _Banner(
              text: 'Tu prueba gratis terminó',
              action: 'Elegir plan',
              tone: Tone.orange,
              icon: 'clock',
              onTap: () => context.push('/paywall'),
            ),
          SaluxCard(
            gradient: SaluxGradients.primary,
            border: Colors.transparent,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Aprende, practica y avanza',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.15)),
                      const SizedBox(height: 6),
                      const Text('Todo lo que necesitas para tu examen.',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 14),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => context.go('/modules'),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            alignment: Alignment.center,
                            child: Text('Explorar',
                                style: TextStyle(color: c.primary, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const MascotSticker(height: 130),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SaluxCard(
            child: Column(
              children: [
                Row(
                  children: [
                    ProgressRing(
                      value: app.dailyGoal == 0 ? 0 : app.answeredToday / app.dailyGoal,
                      child: Text('${app.answeredToday}/${app.dailyGoal}',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Meta diaria', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(
                            app.goalMetToday
                                ? '¡Cumplida! Sigue así.'
                                : 'Faltan ${app.dailyGoal - app.answeredToday} preguntas',
                            style: TextStyle(color: c.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final d in week)
                      Column(
                        children: [
                          Text(d.$1, style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: (app.answeredByDay[dayKey(d.$2)] ?? 0) >= app.dailyGoal ? c.warnBg : c.soft,
                              shape: BoxShape.circle,
                              border: d.$3 ? Border.all(color: c.primary, width: 2) : null,
                            ),
                            child: Center(
                              child: SaluxIcon('flame', size: 16,
                                  color: (app.answeredByDay[dayKey(d.$2)] ?? 0) >= app.dailyGoal ? c.warn : c.muted),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                SaluxButton('Seguir practicando', onPressed: practice),
              ],
            ),
          ),
          const SectionTitle('Accesos rápidos'),
          Row(
            children: [
              _Quick('Simulacro', 'target', Tone.violet, () {
                ref.read(quizConfigProvider.notifier).set(QuizConfig(
                      mode: QuizMode.timed,
                      minutes: 15,
                      examKey: moduleByName(app.goalExam).seedKey,
                      examName: app.goalExam,
                    ));
                context.push('/quiz-setup');
              }),
              _Quick('Repaso', 'refresh', Tone.pink, () => practice(mode: QuizMode.review)),
              _Quick('Favoritos', 'heart', Tone.orange, () => context.push('/favorites')),
              _Quick('Documentos', 'book', Tone.blue, () => context.push('/docs')),
            ],
          ),
          const SectionTitle('Continúa donde lo dejaste'),
          SaluxCard(
            onTap: () => context.push('/exam/${moduleByName(app.goalExam).id}'),
            child: Row(
              children: [
                IconTile(moduleByName(app.goalExam).icon, tone: moduleByName(app.goalExam).tone),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(last == null ? app.goalExam : '${last.examName} · último simulacro',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(last == null ? 'Empieza tu primer simulacro' : 'Puntaje ${percent(last.score)}',
                          style: TextStyle(color: c.muted)),
                    ],
                  ),
                ),
                SaluxIcon('chev', size: 18, color: c.muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SaluxCard(
            onTap: () => context.push('/study-plan'),
            child: Row(
              children: [
                IconTile('calendar', tone: Tone.mint, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        daysToExam == null ? 'Define la fecha de tu examen' : '${daysToExam < 0 ? 0 : daysToExam} días',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      Text(daysToExam == null ? 'Crea tu plan de estudio' : 'para tu examen ${app.goalExam}',
                          style: TextStyle(color: c.muted)),
                    ],
                  ),
                ),
                SaluxIcon('chev', size: 18, color: c.muted),
              ],
            ),
          ),
          const SectionTitle('Cursos principales'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              for (final m in modules.take(4))
                SaluxCard(
                  onTap: () => context.push('/exam/${m.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTile(m.icon, tone: m.tone, size: 40),
                      const Spacer(),
                      Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
            ],
          ),
          const SectionTitle('Pregunta del día'),
          _QuestionOfDay(onTap: () {
            ref.read(quizConfigProvider.notifier).set(
                  const QuizConfig(count: 1, examName: 'Pregunta del día'),
                );
            launchQuiz(context, ref, ref.read(quizConfigProvider));
          }),
          const SizedBox(height: 12),
          SaluxCard(
            color: c.soft,
            child: Row(
              children: [
                const Mascot(MascotMood.think, size: 64),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Tip: estudiar 20 minutos diarios rinde más que una maratón de fin de semana.',
                      style: TextStyle(color: c.ink)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lunes a domingo de la semana actual: (inicial, fecha, ¿es hoy?).
  List<(String, DateTime, bool)> _weekDays() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    const names = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return [
      for (var i = 0; i < 7; i++)
        (names[i], monday.add(Duration(days: i)), monday.add(Duration(days: i)).day == now.day),
    ];
  }
}

ModuleItem moduleByName(String name) => modules.firstWhere(
      (m) => m.name.toLowerCase() == name.toLowerCase(),
      orElse: () => modules.first,
    );

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.action, required this.tone, required this.icon, required this.onTap});

  final String text;
  final String action;
  final Tone tone;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SaluxCard(
        color: c.toneBg(tone),
        border: Colors.transparent,
        onTap: onTap,
        child: Row(
          children: [
            SaluxIcon(icon, size: 22, color: c.toneFg(tone)),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(color: c.toneFg(tone), fontWeight: FontWeight.w700))),
            Text(action, style: TextStyle(color: c.toneFg(tone), fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick(this.label, this.icon, this.tone, this.onTap);

  final String label;
  final String icon;
  final Tone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Semantics(
          button: true,
          label: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  IconTile(icon, tone: tone, size: 54),
                  const SizedBox(height: 6),
                  Text(label, maxLines: 1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      );
}

class _QuestionOfDay extends ConsumerWidget {
  const _QuestionOfDay({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qs = ref.watch(allQuestionsProvider);
    final c = context.colors;
    return qs.when(
      loading: () => const Skeleton(height: 90),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final q = list[DateTime.now().difference(DateTime(2026)).inDays.abs() % list.length];
        return SaluxCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Pill(q.topic, tone: Tone.pink),
              const SizedBox(height: 8),
              Text(q.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Responder ahora →', style: TextStyle(color: c.primary, fontWeight: FontWeight.w800)),
            ],
          ),
        );
      },
    );
  }
}
