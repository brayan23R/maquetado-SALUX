import 'package:intl/intl.dart';

String mmss(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}

String percent(double v) => '${(v * 100).round()} %';

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Buenos días';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

String longDate(DateTime d) => DateFormat("d 'de' MMMM 'de' y", 'es').format(d);

String monthYear(DateTime d) {
  final s = DateFormat('MMMM y', 'es').format(d);
  return s[0].toUpperCase() + s.substring(1);
}

/// Etiqueta de grupo del historial.
String groupLabel(DateTime at, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final d = DateTime(at.year, at.month, at.day);
  final diff = today.difference(d).inDays;
  if (diff <= 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  if (diff < 7) return 'Esta semana';
  return 'Antes';
}

/// Evalúa la fortaleza de una contraseña: 0 débil, 1 media, 2 fuerte.
int passwordStrength(String p) {
  var score = 0;
  if (p.length >= 8) score++;
  if (RegExp('[A-Z]').hasMatch(p) && RegExp('[a-z]').hasMatch(p)) score++;
  if (RegExp('[0-9]').hasMatch(p)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
  if (score <= 1) return 0;
  if (score <= 3) return 1;
  return 2;
}

bool isValidEmail(String e) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(e.trim());
