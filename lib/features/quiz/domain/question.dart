/// Modos de práctica.
enum QuizMode { practice, timed, review }

class QuestionOption {
  const QuestionOption({required this.label, required this.text, required this.isCorrect});

  factory QuestionOption.fromJson(Map<String, dynamic> j) => QuestionOption(
        label: j['label'] as String,
        text: j['text'] as String,
        isCorrect: j['is_correct'] as bool? ?? false,
      );

  final String label;
  final String text;
  final bool isCorrect;
}

class Question {
  const Question({
    required this.id,
    required this.exam,
    required this.topic,
    required this.text,
    required this.options,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> j, int index) => Question(
        id: '${j['exam']}-${j['order'] ?? index}',
        exam: j['exam'] as String,
        topic: j['topic'] as String,
        text: j['text'] as String,
        explanation: j['explanation'] as String? ?? '',
        options: [
          for (final o in (j['options'] as List<dynamic>))
            QuestionOption.fromJson(o as Map<String, dynamic>),
        ],
      );

  final String id;
  final String exam;
  final String topic;
  final String text;
  final String explanation;
  final List<QuestionOption> options;

  int get correctIndex => options.indexWhere((o) => o.isCorrect);
}

/// Resultado de un intento ya corregido.
class QuizResult {
  const QuizResult({
    required this.id,
    required this.at,
    required this.examName,
    required this.mode,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.seconds,
    required this.byTopic,
    required this.questionIds,
    required this.answers,
  });

  factory QuizResult.fromJson(Map<String, dynamic> j) => QuizResult(
        id: j['id'] as String,
        at: DateTime.parse(j['at'] as String),
        examName: j['examName'] as String,
        mode: QuizMode.values.byName(j['mode'] as String),
        total: j['total'] as int,
        correct: j['correct'] as int,
        wrong: j['wrong'] as int,
        unanswered: j['unanswered'] as int,
        seconds: j['seconds'] as int,
        byTopic: {
          for (final e in (j['byTopic'] as Map<String, dynamic>).entries)
            e.key: (e.value as List<dynamic>).map((x) => x as int).toList(),
        },
        questionIds: (j['questionIds'] as List<dynamic>).cast<String>(),
        answers: (j['answers'] as List<dynamic>).map((x) => x as int).toList(),
      );

  final String id;
  final DateTime at;
  final String examName;
  final QuizMode mode;
  final int total;
  final int correct;
  final int wrong;
  final int unanswered;
  final int seconds;

  /// tema -> [correctas, total]
  final Map<String, List<int>> byTopic;
  final List<String> questionIds;

  /// Índice elegido por pregunta (-1 = sin responder).
  final List<int> answers;

  double get score => total == 0 ? 0 : correct / total;

  Map<String, dynamic> toJson() => {
        'id': id,
        'at': at.toIso8601String(),
        'examName': examName,
        'mode': mode.name,
        'total': total,
        'correct': correct,
        'wrong': wrong,
        'unanswered': unanswered,
        'seconds': seconds,
        'byTopic': byTopic,
        'questionIds': questionIds,
        'answers': answers,
      };
}

/// Corrige un intento (lógica pura, probada en test/).
QuizResult scoreAttempt({
  required String id,
  required DateTime at,
  required String examName,
  required QuizMode mode,
  required List<Question> questions,
  required List<int> answers,
  required int seconds,
}) {
  var correct = 0;
  var wrong = 0;
  var blank = 0;
  final topics = <String, List<int>>{};
  for (var i = 0; i < questions.length; i++) {
    final q = questions[i];
    final a = answers[i];
    final t = topics.putIfAbsent(q.topic, () => [0, 0]);
    t[1]++;
    if (a < 0) {
      blank++;
    } else if (a == q.correctIndex) {
      correct++;
      t[0]++;
    } else {
      wrong++;
    }
  }
  return QuizResult(
    id: id,
    at: at,
    examName: examName,
    mode: mode,
    total: questions.length,
    correct: correct,
    wrong: wrong,
    unanswered: blank,
    seconds: seconds,
    byTopic: topics,
    questionIds: [for (final q in questions) q.id],
    answers: answers,
  );
}
