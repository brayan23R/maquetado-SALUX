import 'package:flutter/material.dart';

import '../../quiz/domain/question.dart';

class Note {
  const Note({required this.id, required this.text, required this.tag, required this.at});

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'] as String,
        text: j['text'] as String,
        tag: j['tag'] as String,
        at: DateTime.parse(j['at'] as String),
      );

  final String id;
  final String text;
  final String tag;
  final DateTime at;

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'tag': tag, 'at': at.toIso8601String()};
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Racha: días consecutivos con meta cumplida. Un día "congelado" cuenta como cumplido.
/// Si hoy aún no cumple la meta, la racha sigue viva desde ayer.
int computeStreak({
  required Map<String, int> answered,
  required int goal,
  required Set<String> frozen,
  required DateTime today,
}) {
  bool met(DateTime d) =>
      (answered[dayKey(d)] ?? 0) >= goal || frozen.contains(dayKey(d));
  var cursor = DateTime(today.year, today.month, today.day);
  if (!met(cursor)) cursor = cursor.subtract(const Duration(days: 1));
  var n = 0;
  while (met(cursor)) {
    n++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return n;
}

/// Estado persistente de la aplicación (modo mock).
class AppState {
  const AppState({
    this.loggedIn = false,
    this.name = 'Estudiante',
    this.email = '',
    this.career = 'Medicina',
    this.goalExam = 'ENAM',
    this.examDate,
    this.dailyGoal = 10,
    this.reminder = '20:00',
    this.mfaEnabled = false,
    this.biometric = false,
    this.trialEndsAt,
    this.premiumUntil,
    this.planKey,
    this.payMethod,
    this.themeMode = ThemeMode.system,
    this.language = 'es',
    this.remindersOn = true,
    this.streakRiskOn = true,
    this.newSimsOn = true,
    this.offersOn = false,
    this.sounds = true,
    this.vibration = true,
    this.wifiOnly = true,
    this.answeredByDay = const {},
    this.frozenDays = const {},
    this.freezers = 1,
    this.bestStreak = 0,
    this.favorites = const {},
    this.notes = const [],
    this.downloads = const {},
    this.history = const [],
    this.notificationsRead = false,
    this.studyDone = const {},
    this.studyHours = 2,
    this.xp = 0,
    this.university = '',
    this.studyYear = 5,
    this.savedDocs = const {},
    this.inviteCode = 'SALUX-4K7Q',
  });

  factory AppState.fromJson(Map<String, dynamic> j) {
    DateTime? d(String k) => j[k] == null ? null : DateTime.parse(j[k] as String);
    return AppState(
      loggedIn: j['loggedIn'] as bool? ?? false,
      name: j['name'] as String? ?? 'Estudiante',
      email: j['email'] as String? ?? '',
      career: j['career'] as String? ?? 'Medicina',
      goalExam: j['goalExam'] as String? ?? 'ENAM',
      examDate: d('examDate'),
      dailyGoal: j['dailyGoal'] as int? ?? 10,
      reminder: j['reminder'] as String? ?? '20:00',
      mfaEnabled: j['mfaEnabled'] as bool? ?? false,
      biometric: j['biometric'] as bool? ?? false,
      trialEndsAt: d('trialEndsAt'),
      premiumUntil: d('premiumUntil'),
      planKey: j['planKey'] as String?,
      payMethod: j['payMethod'] as String?,
      themeMode: ThemeMode.values.byName(j['themeMode'] as String? ?? 'system'),
      language: j['language'] as String? ?? 'es',
      remindersOn: j['remindersOn'] as bool? ?? true,
      streakRiskOn: j['streakRiskOn'] as bool? ?? true,
      newSimsOn: j['newSimsOn'] as bool? ?? true,
      offersOn: j['offersOn'] as bool? ?? false,
      sounds: j['sounds'] as bool? ?? true,
      vibration: j['vibration'] as bool? ?? true,
      wifiOnly: j['wifiOnly'] as bool? ?? true,
      answeredByDay: {
        for (final e in ((j['answeredByDay'] as Map<String, dynamic>?) ?? {}).entries)
          e.key: e.value as int,
      },
      frozenDays: ((j['frozenDays'] as List<dynamic>?) ?? []).cast<String>().toSet(),
      freezers: j['freezers'] as int? ?? 1,
      bestStreak: j['bestStreak'] as int? ?? 0,
      favorites: ((j['favorites'] as List<dynamic>?) ?? []).cast<String>().toSet(),
      notes: [
        for (final n in (j['notes'] as List<dynamic>? ?? []))
          Note.fromJson(n as Map<String, dynamic>),
      ],
      downloads: ((j['downloads'] as List<dynamic>?) ?? []).cast<String>().toSet(),
      history: [
        for (final r in (j['history'] as List<dynamic>? ?? []))
          QuizResult.fromJson(r as Map<String, dynamic>),
      ],
      notificationsRead: j['notificationsRead'] as bool? ?? false,
      studyDone: ((j['studyDone'] as List<dynamic>?) ?? []).cast<int>().toSet(),
      studyHours: j['studyHours'] as int? ?? 2,
      xp: j['xp'] as int? ?? 0,
      university: j['university'] as String? ?? '',
      studyYear: j['studyYear'] as int? ?? 5,
      savedDocs: ((j['savedDocs'] as List<dynamic>?) ?? []).cast<String>().toSet(),
      inviteCode: j['inviteCode'] as String? ?? 'SALUX-4K7Q',
    );
  }

  final bool loggedIn;
  final String name;
  final String email;
  final String career;
  final String goalExam;
  final DateTime? examDate;
  final int dailyGoal;
  final String reminder;
  final bool mfaEnabled;
  final bool biometric;
  final DateTime? trialEndsAt;
  final DateTime? premiumUntil;
  final String? planKey;
  final String? payMethod;
  final ThemeMode themeMode;
  final String language;
  final bool remindersOn;
  final bool streakRiskOn;
  final bool newSimsOn;
  final bool offersOn;
  final bool sounds;
  final bool vibration;
  final bool wifiOnly;
  final Map<String, int> answeredByDay;
  final Set<String> frozenDays;
  final int freezers;
  final int bestStreak;
  final Set<String> favorites;
  final List<Note> notes;
  final Set<String> downloads;
  final List<QuizResult> history;
  final bool notificationsRead;
  final Set<int> studyDone;
  final int studyHours;
  final int xp;
  final String university;
  final int studyYear;
  final Set<String> savedDocs;
  final String inviteCode;

  bool get isPremium =>
      premiumUntil != null && premiumUntil!.isAfter(DateTime.now());

  bool get isTrial =>
      !isPremium && trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now());

  /// Acceso completo: suscripción activa o prueba vigente.
  bool get hasAccess => isPremium || isTrial;

  /// Prueba iniciada y ya vencida.
  bool get trialExpired =>
      !isPremium && trialEndsAt != null && !trialEndsAt!.isAfter(DateTime.now());

  int get trialDaysLeft {
    if (trialEndsAt == null) return 0;
    final h = trialEndsAt!.difference(DateTime.now()).inHours;
    return h <= 0 ? 0 : (h / 24).ceil();
  }

  int get streak => computeStreak(
        answered: answeredByDay,
        goal: dailyGoal,
        frozen: frozenDays,
        today: DateTime.now(),
      );

  int get answeredToday => answeredByDay[dayKey(DateTime.now())] ?? 0;

  bool get goalMetToday => answeredToday >= dailyGoal;

  int get level => 1 + xp ~/ 500;

  Map<String, dynamic> toJson() => {
        'loggedIn': loggedIn,
        'name': name,
        'email': email,
        'career': career,
        'goalExam': goalExam,
        'examDate': examDate?.toIso8601String(),
        'dailyGoal': dailyGoal,
        'reminder': reminder,
        'mfaEnabled': mfaEnabled,
        'biometric': biometric,
        'trialEndsAt': trialEndsAt?.toIso8601String(),
        'premiumUntil': premiumUntil?.toIso8601String(),
        'planKey': planKey,
        'payMethod': payMethod,
        'themeMode': themeMode.name,
        'language': language,
        'remindersOn': remindersOn,
        'streakRiskOn': streakRiskOn,
        'newSimsOn': newSimsOn,
        'offersOn': offersOn,
        'sounds': sounds,
        'vibration': vibration,
        'wifiOnly': wifiOnly,
        'answeredByDay': answeredByDay,
        'frozenDays': frozenDays.toList(),
        'freezers': freezers,
        'bestStreak': bestStreak,
        'favorites': favorites.toList(),
        'notes': [for (final n in notes) n.toJson()],
        'downloads': downloads.toList(),
        'history': [for (final r in history) r.toJson()],
        'notificationsRead': notificationsRead,
        'studyDone': studyDone.toList(),
        'studyHours': studyHours,
        'xp': xp,
        'university': university,
        'studyYear': studyYear,
        'savedDocs': savedDocs.toList(),
        'inviteCode': inviteCode,
      };

  AppState copyWith({
    bool? loggedIn,
    String? name,
    String? email,
    String? career,
    String? goalExam,
    DateTime? examDate,
    int? dailyGoal,
    String? reminder,
    bool? mfaEnabled,
    bool? biometric,
    DateTime? trialEndsAt,
    DateTime? premiumUntil,
    bool clearPremium = false,
    String? planKey,
    String? payMethod,
    ThemeMode? themeMode,
    String? language,
    bool? remindersOn,
    bool? streakRiskOn,
    bool? newSimsOn,
    bool? offersOn,
    bool? sounds,
    bool? vibration,
    bool? wifiOnly,
    Map<String, int>? answeredByDay,
    Set<String>? frozenDays,
    int? freezers,
    int? bestStreak,
    Set<String>? favorites,
    List<Note>? notes,
    Set<String>? downloads,
    List<QuizResult>? history,
    bool? notificationsRead,
    Set<int>? studyDone,
    int? studyHours,
    int? xp,
    String? university,
    int? studyYear,
    Set<String>? savedDocs,
  }) =>
      AppState(
        loggedIn: loggedIn ?? this.loggedIn,
        name: name ?? this.name,
        email: email ?? this.email,
        career: career ?? this.career,
        goalExam: goalExam ?? this.goalExam,
        examDate: examDate ?? this.examDate,
        dailyGoal: dailyGoal ?? this.dailyGoal,
        reminder: reminder ?? this.reminder,
        mfaEnabled: mfaEnabled ?? this.mfaEnabled,
        biometric: biometric ?? this.biometric,
        trialEndsAt: trialEndsAt ?? this.trialEndsAt,
        premiumUntil: clearPremium ? null : (premiumUntil ?? this.premiumUntil),
        planKey: clearPremium ? null : (planKey ?? this.planKey),
        payMethod: clearPremium ? null : (payMethod ?? this.payMethod),
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        remindersOn: remindersOn ?? this.remindersOn,
        streakRiskOn: streakRiskOn ?? this.streakRiskOn,
        newSimsOn: newSimsOn ?? this.newSimsOn,
        offersOn: offersOn ?? this.offersOn,
        sounds: sounds ?? this.sounds,
        vibration: vibration ?? this.vibration,
        wifiOnly: wifiOnly ?? this.wifiOnly,
        answeredByDay: answeredByDay ?? this.answeredByDay,
        frozenDays: frozenDays ?? this.frozenDays,
        freezers: freezers ?? this.freezers,
        bestStreak: bestStreak ?? this.bestStreak,
        favorites: favorites ?? this.favorites,
        notes: notes ?? this.notes,
        downloads: downloads ?? this.downloads,
        history: history ?? this.history,
        notificationsRead: notificationsRead ?? this.notificationsRead,
        studyDone: studyDone ?? this.studyDone,
        studyHours: studyHours ?? this.studyHours,
        xp: xp ?? this.xp,
        university: university ?? this.university,
        studyYear: studyYear ?? this.studyYear,
        savedDocs: savedDocs ?? this.savedDocs,
        inviteCode: inviteCode,
      );
}
