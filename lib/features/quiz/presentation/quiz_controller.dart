import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/presentation/app_controller.dart';
import '../data/question_repository.dart';
import '../domain/question.dart';

/// Configuración elegida en `/quiz-setup`.
class QuizConfig {
  const QuizConfig({
    this.mode = QuizMode.practice,
    this.count = 10,
    this.minutes = 0,
    this.examKey,
    this.examName = 'Banco de ejemplo',
    this.topic,
  });

  final QuizMode mode;
  final int count;

  /// 0 = sin límite.
  final int minutes;
  final String? examKey;
  final String examName;
  final String? topic;

  QuizConfig copyWith({
    QuizMode? mode,
    int? count,
    int? minutes,
    String? examKey,
    String? examName,
    String? topic,
  }) =>
      QuizConfig(
        mode: mode ?? this.mode,
        count: count ?? this.count,
        minutes: minutes ?? this.minutes,
        examKey: examKey ?? this.examKey,
        examName: examName ?? this.examName,
        topic: topic ?? this.topic,
      );
}

class QuizConfigController extends Notifier<QuizConfig> {
  @override
  QuizConfig build() => const QuizConfig();

  void set(QuizConfig c) => state = c;
  void patch(QuizConfig Function(QuizConfig c) f) => state = f(state);
}

final quizConfigProvider =
    NotifierProvider<QuizConfigController, QuizConfig>(QuizConfigController.new);

/// Estado de un intento en curso.
class QuizState {
  const QuizState({
    required this.config,
    required this.questions,
    required this.answers,
    this.marked = const {},
    this.index = 0,
    this.elapsed = 0,
    this.paused = false,
    this.notice,
  });

  final QuizConfig config;
  final List<Question> questions;

  /// Opción elegida por pregunta (-1 = ninguna).
  final List<int> answers;
  final Set<int> marked;
  final int index;
  final int elapsed;
  final bool paused;

  /// Mensaje informativo al iniciar (p. ej. sin errores previos).
  final String? notice;

  Question get current => questions[index];
  int get answer => answers[index];
  bool get answered => answer >= 0;
  bool get isLast => index == questions.length - 1;
  bool get isPractice => config.mode != QuizMode.timed;
  int get limitSeconds => config.minutes * 60;
  int get remaining => limitSeconds - elapsed;

  QuizState copyWith({
    List<int>? answers,
    Set<int>? marked,
    int? index,
    int? elapsed,
    bool? paused,
  }) =>
      QuizState(
        config: config,
        questions: questions,
        answers: answers ?? this.answers,
        marked: marked ?? this.marked,
        index: index ?? this.index,
        elapsed: elapsed ?? this.elapsed,
        paused: paused ?? this.paused,
        notice: notice,
      );
}

class QuizController extends Notifier<QuizState?> {
  Timer? _timer;
  QuizResult? lastResult;

  @override
  QuizState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  Future<void> start(QuizConfig config) async {
    _timer?.cancel();
    final repo = ref.read(questionRepositoryProvider);
    var questions = <Question>[];
    String? notice;

    if (config.mode == QuizMode.review) {
      final failed = <String>{};
      for (final r in ref.read(appProvider).history) {
        for (var i = 0; i < r.questionIds.length; i++) {
          if (r.answers[i] >= 0) {
            final q = (await repo.byIds([r.questionIds[i]])).firstOrNull;
            if (q != null && q.correctIndex != r.answers[i]) failed.add(q.id);
          }
        }
      }
      questions = (await repo.byIds(failed.toList())).take(config.count).toList();
      if (questions.isEmpty) {
        questions = await repo.pick(count: config.count);
        notice = 'Aún no tienes errores que repasar. Practicamos con preguntas al azar.';
      }
    } else {
      questions = await repo.pick(
        examKey: config.examKey,
        count: config.count,
        topic: config.topic,
      );
    }

    state = QuizState(
      config: config,
      questions: questions,
      answers: List.filled(questions.length, -1),
      notice: notice,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s == null || s.paused) return;
      state = s.copyWith(elapsed: s.elapsed + 1);
      if (s.config.mode == QuizMode.timed &&
          s.limitSeconds > 0 &&
          s.elapsed + 1 >= s.limitSeconds) {
        finish();
      }
    });
  }

  void answer(int option) {
    final s = state;
    if (s == null) return;
    // En práctica la respuesta queda bloqueada tras elegir.
    if (s.isPractice && s.answered) return;
    final a = [...s.answers]..[s.index] = option;
    state = s.copyWith(answers: a);
  }

  void next() {
    final s = state;
    if (s == null || s.isLast) return;
    state = s.copyWith(index: s.index + 1);
  }

  void goTo(int i) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(index: i);
  }

  void toggleMark() {
    final s = state;
    if (s == null) return;
    final m = {...s.marked};
    if (!m.remove(s.index)) m.add(s.index);
    state = s.copyWith(marked: m);
  }

  void setPaused({required bool paused}) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(paused: paused);
  }

  /// Corrige, guarda el resultado y suma actividad (racha).
  QuizResult? finish() {
    final s = state;
    if (s == null) return null;
    _timer?.cancel();
    final result = scoreAttempt(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      at: DateTime.now(),
      examName: s.config.examName,
      mode: s.config.mode,
      questions: s.questions,
      answers: s.answers,
      seconds: s.elapsed,
    );
    lastResult = result;
    ref.read(appProvider.notifier)
      ..saveResult(result)
      ..registerAnswers(s.answers.where((a) => a >= 0).length);
    state = null;
    return result;
  }

  /// Salir sin corregir (el avance no se guarda en el MVP).
  void abandon() {
    _timer?.cancel();
    state = null;
  }
}

final quizProvider = NotifierProvider<QuizController, QuizState?>(QuizController.new);
