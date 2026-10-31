import 'package:flutter/material.dart';

/// Tokens de diseño de SALUX (fuente: docs/DESIGN_TOKENS.json).
class SaluxRadius {
  const SaluxRadius._();
  static const double chip = 19;
  static const double input = 18;
  static const double card = 22;
  static const double tile = 24;
  static const double button = 28;
  static const double sheetTop = 30;
  static const double icon = 15;
}

class SaluxGradients {
  const SaluxGradients._();
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7360F2), Color(0xFF4B35C9)],
  );
  static const LinearGradient orange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB24F), Color(0xFFF0732A)],
  );
  static const LinearGradient violet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA394FF), Color(0xFF5B45D6)],
  );
  static const LinearGradient blue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7CC2FF), Color(0xFF2F6FD0)],
  );
  static const LinearGradient mint = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF59DDAE), Color(0xFF1A9670)],
  );
  static const LinearGradient pink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9BB8), Color(0xFFD8386C)],
  );
  static const LinearGradient amber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFCB66), Color(0xFFF0832A)],
  );
}

/// Tono de color para mosaicos y píldoras.
enum Tone { violet, blue, mint, pink, orange }

extension ToneGradient on Tone {
  LinearGradient get gradient => switch (this) {
        Tone.violet => SaluxGradients.violet,
        Tone.blue => SaluxGradients.blue,
        Tone.mint => SaluxGradients.mint,
        Tone.pink => SaluxGradients.pink,
        Tone.orange => SaluxGradients.amber,
      };
}

/// Paleta semántica; se accede con `context.colors`.
@immutable
class SaluxColors extends ThemeExtension<SaluxColors> {
  const SaluxColors({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.primary,
    required this.line,
    required this.soft,
    required this.ok,
    required this.okBg,
    required this.error,
    required this.errorBg,
    required this.warn,
    required this.warnBg,
    required this.tones,
    required this.shadow,
  });

  final Color bg;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color primary;
  final Color line;
  final Color soft;
  final Color ok;
  final Color okBg;
  final Color error;
  final Color errorBg;
  final Color warn;
  final Color warnBg;

  /// Pares (fondo, texto) por tono.
  final Map<Tone, (Color, Color)> tones;
  final Color shadow;

  static const light = SaluxColors(
    bg: Color(0xFFF4F2FF),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF16134A),
    muted: Color(0xFF5E5B86),
    primary: Color(0xFF5B45D6),
    line: Color(0xFFE6E2F8),
    soft: Color(0xFFEEEAFE),
    ok: Color(0xFF1B7D58),
    okBg: Color(0xFFDDF4EA),
    error: Color(0xFFC7364A),
    errorBg: Color(0xFFFDE3E6),
    warn: Color(0xFFB5611A),
    warnBg: Color(0xFFFFEBD3),
    shadow: Color(0x1A4632A0),
    tones: {
      Tone.violet: (Color(0xFFE8E3FD), Color(0xFF4A37C4)),
      Tone.blue: (Color(0xFFDCEBFC), Color(0xFF2A66AE)),
      Tone.mint: (Color(0xFFD6F3E7), Color(0xFF17704F)),
      Tone.pink: (Color(0xFFFCE0E8), Color(0xFFB52D58)),
      Tone.orange: (Color(0xFFFFEBD3), Color(0xFFA85A14)),
    },
  );

  static const dark = SaluxColors(
    bg: Color(0xFF0C0B18),
    surface: Color(0xFF171530),
    ink: Color(0xFFF3F1FF),
    muted: Color(0xFFABA8D3),
    primary: Color(0xFF9486FF),
    line: Color(0xFF2A2851),
    soft: Color(0xFF242148),
    ok: Color(0xFF5ED6A5),
    okBg: Color(0xFF133A2D),
    error: Color(0xFFFF8A9A),
    errorBg: Color(0xFF47202A),
    warn: Color(0xFFFFC283),
    warnBg: Color(0xFF46301A),
    shadow: Color(0x6B000000),
    tones: {
      Tone.violet: (Color(0xFF2A2457), Color(0xFFC4BAFF)),
      Tone.blue: (Color(0xFF172B47), Color(0xFF8CC3FF)),
      Tone.mint: (Color(0xFF123A2E), Color(0xFF7FE0B8)),
      Tone.pink: (Color(0xFF43182B), Color(0xFFFF9CB8)),
      Tone.orange: (Color(0xFF46301A), Color(0xFFFFC283)),
    },
  );

  Color toneBg(Tone t) => tones[t]!.$1;
  Color toneFg(Tone t) => tones[t]!.$2;

  List<BoxShadow> get cardShadow =>
      [BoxShadow(color: shadow, blurRadius: 28, offset: const Offset(0, 10))];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Color(0x575B45D6), blurRadius: 22, offset: Offset(0, 10)),
  ];

  @override
  SaluxColors copyWith() => this;

  @override
  SaluxColors lerp(ThemeExtension<SaluxColors>? other, double t) =>
      t < 0.5 ? this : (other as SaluxColors? ?? this);
}

extension SaluxThemeContext on BuildContext {
  SaluxColors get colors => Theme.of(this).extension<SaluxColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
