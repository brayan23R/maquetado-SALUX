import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saluxprototipo/features/quiz/domain/question.dart';

void main() {
  test('el seed se parsea y cada pregunta tiene exactamente una correcta', () {
    final json = jsonDecode(File('seed/questions.seed.json').readAsStringSync())
        as Map<String, dynamic>;
    final list = json['questions'] as List<dynamic>;
    final qs = [
      for (var i = 0; i < list.length; i++)
        Question.fromJson(list[i] as Map<String, dynamic>, i),
    ];
    expect(qs.length, 40);
    for (final q in qs) {
      expect(q.options.where((o) => o.isCorrect).length, 1, reason: q.id);
      expect(q.options.length, 4, reason: q.id);
    }
    expect(qs.map((q) => q.id).toSet().length, qs.length, reason: 'ids únicos');
  });
}
