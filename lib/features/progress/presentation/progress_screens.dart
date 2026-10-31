import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../home/presentation/home_screen.dart';
import '../../quiz/domain/question.dart';
import '../../quiz/presentation/quiz_controller.dart';
import '../../quiz/presentation/quiz_screens.dart';
import '../../session/domain/app_state.dart';
import '../../session/presentation/app_controller.dart';

// ============================================================= /simulations

class SimulationsScreen extends ConsumerWidget {
  const SimulationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;

    void setup(QuizMode mode) {
      ref.read(quizConfigProvider.notifier).set(QuizConfig(
            mode: mode,
            minutes: mode == QuizMode.timed ? 15 : 0,
            examKey: moduleByName(app.goalExam).seedKey,
            examName: app.goalExam,
          ));
      if (mode == QuizMode.review) {
        launchQuiz(context, ref, ref.read(quizConfigProvider));
      } else {
        context.push('/quiz-setup');
      }
    }

    Widget mode(String title, String sub, String icon, Tone tone, QuizMode m) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SaluxCard(
            onTap: () => setup(m),
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
                SaluxIcon('chev', size: 16, color: c.muted),
              ],
            ),
          ),
        );

    return FadeIn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Simulacros',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              ),
              RoundIconButton(icon: 'history', label: 'Historial', onTap: () => context.push('/history')),
            ],
          ),
          const SizedBox(height: 8),
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
                      const Text('Crea tu simulacro',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Elige modo, cantidad y tiempo.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 14),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setup(QuizMode.practice),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            alignment: Alignment.center,
                            child: Text('Nuevo simulacro',
                                style: TextStyle(color: c.primary, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Mascot(MascotMood.cheer, size: 100),
              ],
            ),
          ),
          const SectionTitle('Modos'),
          mode('Práctica', 'Feedback inmediato', 'bulb', Tone.violet, QuizMode.practice),
          mode('Simulacro con tiempo', 'Como el examen real', 'clock', Tone.orange, QuizMode.timed),
          mode('Repaso de errores', 'Refuerza lo que fallaste', 'refresh', Tone.pink, QuizMode.review),
          const SectionTitle('Recientes'),
          if (app.history.isEmpty)
            const EmptyState(
              mood: MascotMood.sleep,
              title: 'Aún no hay simulacros',
              subtitle: 'Tus resultados aparecerán aquí.',
            )
          else
            for (final r in app.history.take(5)) _ResultRow(r),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.r);

  final QuizResult r;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final good = r.score >= .7;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SaluxCard(
        onTap: () => context.push('/result?id=${r.id}'),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: good ? c.okBg : c.warnBg, borderRadius: BorderRadius.circular(16)),
              child: Text(percent(r.score),
                  style: TextStyle(fontWeight: FontWeight.w800, color: good ? c.ok : c.warn)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.examName, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${r.correct}/${r.total} correctas · ${mmss(r.seconds)}',
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            SaluxIcon('chev', size: 16, color: c.muted),
          ],
        ),
      ),
    );
  }
}

// ================================================================== /history

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final groups = <String, List<QuizResult>>{};
    for (final r in app.history) {
      groups.putIfAbsent(groupLabel(r.at), () => []).add(r);
    }
    return SaluxPage(
      title: 'Historial',
      children: [
        if (app.history.isEmpty)
          const EmptyState(mood: MascotMood.sleep, title: 'Sin historial', subtitle: 'Aún no completaste simulacros.')
        else
          for (final e in groups.entries) ...[
            SectionTitle(e.key),
            for (final r in e.value) _ResultRow(r),
          ],
      ],
    );
  }
}

// ================================================================= /progress

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final totalQ = app.history.fold<int>(0, (a, r) => a + r.total);
    final totalOk = app.history.fold<int>(0, (a, r) => a + r.correct);
    final accuracy = totalQ == 0 ? 0.0 : totalOk / totalQ;

    final topics = <String, List<int>>{};
    for (final r in app.history) {
      r.byTopic.forEach((k, v) {
        final t = topics.putIfAbsent(k, () => [0, 0]);
        t[0] += v[0];
        t[1] += v[1];
      });
    }
    final ranked = topics.entries.toList()
      ..sort((a, b) => (a.value[0] / a.value[1]).compareTo(b.value[0] / b.value[1]));

    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final counts = [
      for (var i = 0; i < 7; i++) app.answeredByDay[dayKey(monday.add(Duration(days: i)))] ?? 0,
    ];
    final maxCount = counts.fold<int>(1, (a, b) => b > a ? b : a);
    const names = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    Widget metric(String v, String l, Tone t) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: c.toneBg(t), borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Text(v, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: c.toneFg(t))),
              Text(l, style: TextStyle(color: c.toneFg(t), fontSize: 11)),
            ]),
          ),
        );

    return FadeIn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Progreso',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.5)),
              ),
              RoundIconButton(icon: 'trophy', label: 'Logros', onTap: () => context.push('/achievements')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              metric('$totalQ', 'Preguntas', Tone.violet),
              const SizedBox(width: 8),
              metric('${app.history.length}', 'Simulacros', Tone.blue),
              const SizedBox(width: 8),
              metric(percent(accuracy), 'Precisión', Tone.mint),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push('/streak'),
                child: SizedBox(
                  width: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: c.toneBg(Tone.orange), borderRadius: BorderRadius.circular(18)),
                    child: Column(children: [
                      Text('${app.streak}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: c.toneFg(Tone.orange))),
                      Text('Racha', style: TextStyle(color: c.toneFg(Tone.orange), fontSize: 11)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          const SectionTitle('Esta semana'),
          SaluxCard(
            child: SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < 7; i++)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${counts[i]}', style: TextStyle(color: c.muted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Container(
                          width: 22,
                          height: 8 + 80 * counts[i] / maxCount,
                          decoration: BoxDecoration(
                            gradient: counts[i] > 0 ? SaluxGradients.primary : null,
                            color: counts[i] > 0 ? null : c.soft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(names[i], style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SectionTitle('Precisión por tema'),
          if (ranked.isEmpty)
            const EmptyState(
              mood: MascotMood.sleep,
              title: 'Sin datos todavía',
              subtitle: 'Completa un simulacro para ver tu precisión por tema.',
            )
          else ...[
            for (final e in ranked.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SaluxCard(
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700))),
                        Text(percent(e.value[0] / e.value[1]), style: TextStyle(color: c.muted)),
                      ]),
                      const SizedBox(height: 8),
                      SaluxBar(e.value[0] / e.value[1]),
                    ],
                  ),
                ),
              ),
            const SectionTitle('Tema por reforzar'),
            SaluxCard(
              color: c.warnBg,
              border: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Text(ranked.first.key,
                        style: TextStyle(color: c.warn, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  SizedBox(
                    width: 120,
                    child: SaluxButton('Repasar', onPressed: () {
                      ref.read(quizConfigProvider.notifier).set(const QuizConfig(mode: QuizMode.review));
                      launchQuiz(context, ref, ref.read(quizConfigProvider));
                    }),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================== /streak

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final c = context.colors;
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final offset = first.weekday - 1;
    final streak = app.streak;
    const milestones = [3, 7, 30, 100];

    return SaluxPage(
      title: 'Racha',
      onBack: () => context.go('/progress'),
      actions: [RoundIconButton(icon: 'trophy', label: 'Logros', onTap: () => context.push('/achievements'))],
      bottom: SaluxButton('Practicar ahora', onPressed: () {
        ref.read(quizConfigProvider.notifier).set(const QuizConfig());
        launchQuiz(context, ref, ref.read(quizConfigProvider));
      }),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: SaluxGradients.orange,
            borderRadius: BorderRadius.circular(SaluxRadius.tile),
          ),
          child: Row(
            children: [
              const SaluxIcon('flame', size: 64, color: Colors.white),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$streak', style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w800, height: 1)),
                  Text(streak == 1 ? 'día de racha' : 'días de racha', style: const TextStyle(color: Colors.white)),
                  Text('Mejor: ${app.bestStreak}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SectionTitle('Calendario'),
        SaluxCard(
          child: Column(
            children: [
              Text(monthYear(now), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final d in ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
                    Center(child: Text(d, style: TextStyle(color: c.muted, fontWeight: FontWeight.w700))),
                  for (var i = 0; i < offset; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= daysInMonth; d++)
                    Builder(builder: (_) {
                      final date = DateTime(now.year, now.month, d);
                      final k = dayKey(date);
                      final met = (app.answeredByDay[k] ?? 0) >= app.dailyGoal || app.frozenDays.contains(k);
                      final today = d == now.day;
                      return Container(
                        margin: const EdgeInsets.all(3),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: met ? SaluxGradients.orange : null,
                          shape: BoxShape.circle,
                          border: today ? Border.all(color: c.primary, width: 2) : null,
                        ),
                        child: Text('$d',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: met ? Colors.white : c.ink,
                            )),
                      );
                    }),
                ],
              ),
            ],
          ),
        ),
        const SectionTitle('Congelador'),
        SaluxCard(
          child: Row(
            children: [
              IconTile('zap', tone: Tone.blue, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${app.freezers} disponible${app.freezers == 1 ? '' : 's'} · protege un día perdido',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: 110,
                child: SaluxButton('Usar', secondary: true, onPressed: app.freezers == 0 ? null : () {
                  ref.read(appProvider.notifier).useFreezer();
                  showToast(context, 'Congelador aplicado a ayer');
                }),
              ),
            ],
          ),
        ),
        const SectionTitle('Hitos'),
        Row(
          children: [
            for (final m in milestones)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: streak >= m ? c.warnBg : c.soft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      SaluxIcon(streak >= m ? 'check' : 'flame', size: 22, color: streak >= m ? c.warn : c.muted),
                      const SizedBox(height: 4),
                      Text('$m días', style: TextStyle(fontWeight: FontWeight.w800, color: streak >= m ? c.warn : c.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SaluxButton('Ver ranking', secondary: true, icon: 'users', onPressed: () => context.push('/ranking')),
      ],
    );
  }
}

// ============================================================= /achievements

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final best = app.bestStreak > app.streak ? app.bestStreak : app.streak;
    final unlocked = <String>{
      if (app.history.isNotEmpty) 'first',
      if (best >= 3) 'streak3',
      if (best >= 7) 'streak7',
      if (app.history.any((r) => r.score >= .9)) 'ace',
      if (app.favorites.length >= 5) 'fav',
      if (best >= 30) 'streak30',
    };
    final c = context.colors;
    return SaluxPage(
      title: 'Logros',
      onBack: () => context.go('/progress'),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .95,
          children: [
            for (final a in achievements)
              Opacity(
                opacity: unlocked.contains(a.id) ? 1 : .45,
                child: SaluxCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTile(unlocked.contains(a.id) ? a.icon : 'lock', tone: a.tone, size: 56),
                      const SizedBox(height: 10),
                      Text(a.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(a.detail, textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
