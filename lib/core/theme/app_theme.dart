import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Construye el tema claro u oscuro a partir de los tokens.
class AppTheme {
  const AppTheme._();

  /// Las pruebas lo desactivan para no descargar fuentes de la red.
  static bool useGoogleFonts = true;

  static ThemeData light() => _build(SaluxColors.light, Brightness.light);
  static ThemeData dark() => _build(SaluxColors.dark, Brightness.dark);

  static ThemeData _build(SaluxColors c, Brightness b) {
    final base = ThemeData(brightness: b, useMaterial3: true);
    final raw = useGoogleFonts
        ? GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        : base.textTheme;
    final text = raw.apply(bodyColor: c.ink, displayColor: c.ink);
    return base.copyWith(
      scaffoldBackgroundColor: c.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B45D6),
        brightness: b,
      ).copyWith(
        primary: c.primary,
        surface: c.surface,
        error: c.error,
      ),
      textTheme: text,
      extensions: [c],
      dividerColor: c.line,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
