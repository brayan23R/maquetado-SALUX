import 'package:flutter_test/flutter_test.dart';
import 'package:saluxprototipo/core/utils/format.dart';
import 'package:saluxprototipo/features/quiz/domain/question.dart';
import 'package:saluxprototipo/features/session/domain/app_state.dart';

Question _q(String id, String topic, int correct) => Question(
      id: id,
      exam: 'ENAM',
      topic: topic,
      text: 'Pregunta $id',
      explanation: '',
      options: [
        for (var i = 0; i < 4; i++)
          QuestionOption(label: 'ABCD'[i], text: 'op$i', isCorrect: i == correct),
      ],
    );

void main() {
  group('scoreAttempt', () {
    final qs = [_q('1', 'Cirugía', 1), _q('2', 'Cirugía', 0), _q('3', 'Pediatría', 2)];

    test('cuenta correctas, incorrectas y sin responder', () {
      final r = scoreAttempt(
        id: 'a',
        at: DateTime(2026),
        examName: 'ENAM',
        mode: QuizMode.timed,
        questions: qs,
        answers: [1, 3, -1],
        seconds: 60,
      );
      expect(r.correct, 1);
      expect(r.wrong, 1);
      expect(r.unanswered, 1);
      expect(r.score, closeTo(1 / 3, 1e-9));
      expect(r.byTopic['Cirugía'], [1, 2]);
      expect(r.byTopic['Pediatría'], [0, 1]);
    });

    test('serializa y deserializa sin perder datos', () {
      final r = scoreAttempt(
        id: 'b',
        at: DateTime(2026, 5, 4),
        examName: 'ENAM',
        mode: QuizMode.practice,
        questions: qs,
        answers: [1, 0, 2],
        seconds: 10,
      );
      final back = QuizResult.fromJson(r.toJson());
      expect(back.correct, 3);
      expect(back.answers, [1, 0, 2]);
    });
  });

  group('computeStreak', () {
    final today = DateTime(2026, 10, 30);
    String d(int daysAgo) => dayKey(today.subtract(Duration(days: daysAgo)));

    test('sin actividad la racha es 0', () {
      expect(computeStreak(answered: {}, goal: 10, frozen: {}, today: today), 0);
    });

    test('suma días consecutivos que cumplen la meta', () {
      final answered = {d(0): 10, d(1): 12, d(2): 10};
      expect(computeStreak(answered: answered, goal: 10, frozen: {}, today: today), 3);
    });

    test('si hoy aún no cumple, la racha sigue viva desde ayer', () {
      final answered = {d(0): 3, d(1): 10, d(2): 10};
      expect(computeStreak(answered: answered, goal: 10, frozen: {}, today: today), 2);
    });

    test('un hueco rompe la racha y el congelador la repara', () {
      final answered = {d(0): 10, d(2): 10};
      expect(computeStreak(answered: answered, goal: 10, frozen: {}, today: today), 1);
      expect(computeStreak(answered: answered, goal: 10, frozen: {d(1)}, today: today), 3);
    });
  });

  group('acceso por prueba gratis', () {
    test('prueba vigente da acceso', () {
      final s = AppState(trialEndsAt: DateTime.now().add(const Duration(days: 2)));
      expect(s.hasAccess, isTrue);
      expect(s.isTrial, isTrue);
    });

    test('prueba vencida sin suscripción bloquea', () {
      final s = AppState(trialEndsAt: DateTime.now().subtract(const Duration(days: 1)));
      expect(s.hasAccess, isFalse);
      expect(s.trialExpired, isTrue);
    });

    test('suscripción activa da acceso aunque la prueba haya vencido', () {
      final s = AppState(
        trialEndsAt: DateTime.now().subtract(const Duration(days: 5)),
        premiumUntil: DateTime.now().add(const Duration(days: 30)),
      );
      expect(s.hasAccess, isTrue);
    });
  });

  group('validaciones', () {
    test('fortaleza de contraseña', () {
      expect(passwordStrength('abc'), 0);
      expect(passwordStrength('Abcdefg1'), 1);
      expect(passwordStrength('Abcdefg1!'), 2);
    });

    test('correo', () {
      expect(isValidEmail('a@b.co'), isTrue);
      expect(isValidEmail('a@b'), isFalse);
      expect(isValidEmail(' '), isFalse);
    });
  });
}
