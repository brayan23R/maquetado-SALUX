import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/env.dart';
import '../domain/question.dart';

/// Contrato del banco de preguntas. En modo `supabase` se implementará
/// contra las funciones `get_questions` / `check_answer` del servidor.
abstract class QuestionRepository {
  Future<List<Question>> all();

  /// Preguntas para un examen (clave) o de todos si es nulo.
  Future<List<Question>> pick({String? examKey, required int count, String? topic});

  Future<List<Question>> byIds(List<String> ids);
}

/// Implementación local que lee `seed/questions.seed.json`.
class MockQuestionRepository implements QuestionRepository {
  List<Question>? _cache;

  @override
  Future<List<Question>> all() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('seed/questions.seed.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['questions'] as List<dynamic>;
    _cache = [
      for (var i = 0; i < list.length; i++)
        Question.fromJson(list[i] as Map<String, dynamic>, i),
    ];
    return _cache!;
  }

  @override
  Future<List<Question>> pick({String? examKey, required int count, String? topic}) async {
    var pool = await all();
    if (examKey != null) {
      final filtered = pool.where((q) => q.exam == examKey).toList();
      // Si el módulo no tiene banco propio, se usa el general de ejemplo.
      if (filtered.length >= 3) pool = filtered;
    }
    if (topic != null) {
      final filtered = pool.where((q) => q.topic == topic).toList();
      if (filtered.isNotEmpty) pool = filtered;
    }
    final shuffled = [...pool]..shuffle(Random());
    return shuffled.take(count).toList();
  }

  @override
  Future<List<Question>> byIds(List<String> ids) async {
    final pool = await all();
    return [for (final q in pool) if (ids.contains(q.id)) q];
  }
}

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  // El modo `supabase` aún no está conectado: se usa el mock.
  switch (Env.appMode) {
    case AppMode.mock:
    case AppMode.supabase:
      return MockQuestionRepository();
  }
});

final allQuestionsProvider = FutureProvider<List<Question>>(
  (ref) => ref.watch(questionRepositoryProvider).all(),
);
