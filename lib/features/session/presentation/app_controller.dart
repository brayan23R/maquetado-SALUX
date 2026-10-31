import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../quiz/domain/question.dart';
import '../domain/app_state.dart';

/// Se sobrescribe en `main` con la instancia ya cargada.
final prefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());

final appProvider = NotifierProvider<AppController, AppState>(AppController.new);

const _key = 'salux.state.v1';

/// Planes de ejemplo (editables desde el panel admin cuando haya backend).
const plans = <String, ({String name, int months, int price, String badge})>{
  'monthly': (name: 'Mensual', months: 1, price: 29, badge: ''),
  'quarterly': (name: 'Trimestral', months: 3, price: 69, badge: '-21 %'),
  'yearly': (name: 'Anual', months: 12, price: 199, badge: '-43 %'),
};

class AppController extends Notifier<AppState> {
  SharedPreferences get _prefs => ref.read(prefsProvider);

  @override
  AppState build() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const AppState();
    try {
      return AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const AppState();
    }
  }

  void _set(AppState s) {
    state = s;
    _prefs.setString(_key, jsonEncode(s.toJson()));
  }

  void update(AppState Function(AppState s) f) => _set(f(state));

  // ------------------------------------------------------------- Cuenta

  /// Inicio de sesión simulado (modo mock): acepta cualquier correo válido.
  void signIn({required String email, String? name}) {
    final s = state;
    _set(s.copyWith(
      loggedIn: true,
      email: email,
      name: name ?? (s.email == email && s.name != 'Estudiante' ? s.name : _nameFrom(email)),
      trialEndsAt: s.trialEndsAt ?? DateTime.now().add(const Duration(days: 3)),
    ));
  }

  /// Registro: la prueba gratis de 3 días empieza aquí (en backend lo decide el servidor).
  void register({required String name, required String email}) {
    _set(state.copyWith(
      loggedIn: true,
      name: name,
      email: email,
      trialEndsAt: DateTime.now().add(const Duration(days: 3)),
    ));
  }

  void signOut() => _set(state.copyWith(loggedIn: false));

  void deleteAccount() {
    _prefs.remove(_key);
    state = const AppState();
  }

  String _nameFrom(String email) {
    final base = email.split('@').first;
    if (base.isEmpty) return 'Estudiante';
    return base[0].toUpperCase() + base.substring(1);
  }

  // ------------------------------------------------------ Favoritos / notas

  void toggleFavorite(String questionId) {
    final f = {...state.favorites};
    if (!f.remove(questionId)) f.add(questionId);
    _set(state.copyWith(favorites: f));
  }

  void addNote(String text, String tag) {
    final n = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      tag: tag,
      at: DateTime.now(),
    );
    _set(state.copyWith(notes: [n, ...state.notes]));
  }

  void deleteNote(String id) =>
      _set(state.copyWith(notes: state.notes.where((n) => n.id != id).toList()));

  void toggleDownload(String id) {
    final d = {...state.downloads};
    if (!d.remove(id)) d.add(id);
    _set(state.copyWith(downloads: d));
  }

  void toggleSavedDoc(String id) {
    final d = {...state.savedDocs};
    if (!d.remove(id)) d.add(id);
    _set(state.copyWith(savedDocs: d));
  }

  // --------------------------------------------------------- Actividad

  /// Registra respuestas del día y actualiza racha y XP.
  void registerAnswers(int count) {
    if (count <= 0) return;
    final k = dayKey(DateTime.now());
    final map = {...state.answeredByDay};
    map[k] = (map[k] ?? 0) + count;
    final next = state.copyWith(answeredByDay: map, xp: state.xp + count * 5);
    final cur = next.streak;
    _set(next.copyWith(bestStreak: cur > next.bestStreak ? cur : next.bestStreak));
  }

  void saveResult(QuizResult r) {
    final h = [r, ...state.history];
    _set(state.copyWith(history: h.take(40).toList(), xp: state.xp + r.correct * 10));
  }

  /// Usa el congelador sobre ayer si no se cumplió la meta.
  bool useFreezer() {
    if (state.freezers <= 0) return false;
    final y = dayKey(DateTime.now().subtract(const Duration(days: 1)));
    _set(state.copyWith(freezers: state.freezers - 1, frozenDays: {...state.frozenDays, y}));
    return true;
  }

  // ----------------------------------------------------------- Ajustes

  void setTheme(ThemeMode m) => _set(state.copyWith(themeMode: m));

  // ------------------------------------------------------------- Pagos

  /// Pago confirmado (en backend lo hace el webhook y llega por Realtime).
  void activatePremium({required String planKey, required String method}) {
    final plan = plans[planKey]!;
    final from = state.isPremium ? state.premiumUntil! : DateTime.now();
    _set(state.copyWith(
      premiumUntil: DateTime(from.year, from.month + plan.months, from.day),
      planKey: planKey,
      payMethod: method,
    ));
  }

  void cancelSubscription() => _set(state.copyWith(clearPremium: true));

  /// Ayuda de demostración: vence la prueba gratis para ver el paywall.
  void expireTrial() => _set(state.copyWith(
        trialEndsAt: DateTime.now().subtract(const Duration(minutes: 1)),
        clearPremium: true,
      ));

  void restartTrial() => _set(
        state.copyWith(trialEndsAt: DateTime.now().add(const Duration(days: 3))),
      );
}
