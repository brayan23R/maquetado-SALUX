import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import 'salux_icon.dart';

export 'salux_icon.dart';

/// Botón principal (píldora de 56 dp) o secundario.
class SaluxButton extends StatelessWidget {
  const SaluxButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.secondary = false,
    this.icon,
    this.danger = false,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool danger;
  final String? icon;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    final fg = secondary ? (danger ? c.error : c.primary) : Colors.white;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : .45,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: secondary ? null : (gradient ?? SaluxGradients.primary),
              color: secondary ? c.surface : null,
              borderRadius: BorderRadius.circular(SaluxRadius.button),
              border: secondary
                  ? Border.all(color: danger ? c.error : c.primary, width: 1.5)
                  : null,
              boxShadow: secondary || !enabled ? null : SaluxColors.buttonShadow,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(SaluxRadius.button),
              onTap: onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      SaluxIcon(icon!, size: 20, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta con borde y sombra del tema.
class SaluxCard extends StatelessWidget {
  const SaluxCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.border,
    this.gradient,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final Color? border;
  final Gradient? gradient;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(SaluxRadius.card);
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.surface) : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: border ?? c.line),
        boxShadow: c.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    return card;
  }
}

/// Mosaico de icono con degradado por tono.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.tone = Tone.violet, this.size = 46});

  final String icon;
  final Tone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: tone.gradient,
        borderRadius: BorderRadius.circular(SaluxRadius.icon),
      ),
      child: Center(child: SaluxIcon(icon, size: size * .5, color: Colors.white)),
    );
  }
}

/// Píldora de texto con tono.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.tone = Tone.violet, this.icon});

  final String text;
  final Tone tone;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.toneBg(tone),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SaluxIcon(icon!, size: 14, color: c.toneFg(tone)),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: c.toneFg(tone),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón circular de icono (44 dp visibles, 48 dp táctiles).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.dot = false,
    this.color,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool dot;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
                border: Border.all(color: c.line),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SaluxIcon(icon, size: 20, color: color ?? c.ink),
                  if (dot)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: c.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Estructura estándar de pantalla: cabecera con atrás/título/acciones + cuerpo.
class SaluxPage extends StatelessWidget {
  const SaluxPage({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
    this.showBack = true,
    this.onBack,
    this.bottom,
    this.bottomPadding = 32,
    this.padding = 20,
    this.leading,
  });

  final String title;
  final List<Widget> children;
  final List<Widget> actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? bottom;
  final double bottomPadding;
  final double padding;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: bottom == null,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding - 4, 8, padding - 4, 4),
              child: Row(
                children: [
                  if (leading != null)
                    leading!
                  else if (showBack)
                    RoundIconButton(
                      icon: 'back',
                      label: 'Volver',
                      onTap: onBack ?? () => safePop(context),
                    )
                  else
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -.2,
                      ),
                    ),
                  ),
                  if (actions.isEmpty)
                    const SizedBox(width: 48)
                  else
                    Row(mainAxisSize: MainAxisSize.min, children: actions),
                ],
              ),
            ),
            Expanded(
              child: FadeIn(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(padding, 8, padding, bottomPadding),
                  children: children,
                ),
              ),
            ),
            if (bottom != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, 8, padding, 14),
                  child: bottom,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vuelve atrás o, si no hay pila, va al inicio.
void safePop(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}

/// Animación de entrada de 320 ms (fade + 10 px).
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      builder: (_, v, w) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: w),
      ),
      child: child,
    );
  }
}

/// Campo de texto estándar.
class SaluxInput extends StatelessWidget {
  const SaluxInput({
    super.key,
    this.controller,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.keyboard,
    this.onChanged,
    this.trailing,
    this.maxLength,
    this.center = false,
    this.autofocus = false,
    this.onSubmitted,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String hint;
  final String? icon;
  final bool obscure;
  final TextInputType? keyboard;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;
  final int? maxLength;
  final bool center;
  final bool autofocus;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    OutlineInputBorder border(Color col, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(SaluxRadius.input),
          borderSide: BorderSide(color: col, width: w),
        );
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      maxLines: obscure ? 1 : maxLines,
      autofocus: autofocus,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: center ? 22 : 15,
        letterSpacing: center ? 6 : 0,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: TextStyle(color: c.muted, letterSpacing: 0, fontSize: 15),
        filled: true,
        fillColor: c.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.all(14),
                child: SaluxIcon(icon!, size: 20, color: c.muted),
              ),
        suffixIcon: trailing,
        enabledBorder: border(c.line),
        focusedBorder: border(c.primary, 2),
      ),
    );
  }
}

/// Etiqueta de campo.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: context.colors.muted,
          ),
        ),
      );
}

/// Chip seleccionable.
class SaluxChip extends StatelessWidget {
  const SaluxChip(this.label, {super.key, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(SaluxRadius.chip),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? SaluxGradients.primary : null,
            color: selected ? null : c.surface,
            borderRadius: BorderRadius.circular(SaluxRadius.chip),
            border: selected ? null : Border.all(color: c.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : c.ink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Interruptor con semántica de switch.
class SaluxSwitch extends StatelessWidget {
  const SaluxSwitch({super.key, required this.value, required this.onChanged, this.label});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      toggled: value,
      label: label,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: c.primary,
        inactiveTrackColor: c.line,
        inactiveThumbColor: Colors.white,
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

/// Anillo de progreso.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 76,
    this.stroke = 8,
    this.child,
    this.color,
  });

  final double value;
  final double size;
  final double stroke;
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value.clamp(0, 1), stroke, c.soft, color ?? c.primary),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.track, this.color);

  final double value;
  final double stroke;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawArc(rect, 0, math.pi * 2, false, p..color = track)
      ..drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, p..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Barra de progreso lineal.
class SaluxBar extends StatelessWidget {
  const SaluxBar(this.value, {super.key, this.height = 8, this.gradient});

  final double value;
  final double height;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: c.soft,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: gradient ?? SaluxGradients.primary),
          ),
        ),
      ),
    );
  }
}

/// Estado vacío / error con mascota.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.mood,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
  });

  final MascotMood mood;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Mascot(mood, size: 130),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.muted),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 18),
            SaluxButton(actionLabel ?? 'Reintentar', onPressed: action),
          ],
        ],
      ),
    );
  }
}

/// Bloque de carga (skeleton).
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height = 80, this.radius = 22});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.colors.soft,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Título de sección.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing, this.onTrailing});

  final String text;
  final String? trailing;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            if (trailing != null)
              InkWell(
                onTap: onTrailing,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    trailing!,
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Fila de menú/ajustes.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.tone = Tone.violet,
    this.trailing,
    this.danger = false,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Tone tone;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: danger ? c.errorBg : c.toneBg(tone),
                  borderRadius: BorderRadius.circular(SaluxRadius.icon - 3),
                ),
                child: Center(
                  child: SaluxIcon(
                    icon,
                    size: 20,
                    color: danger ? c.error : c.toneFg(tone),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: danger ? c.error : c.ink,
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(color: c.muted, fontSize: 12)),
                  ],
                ),
              ),
              trailing ??
                  (onTap == null
                      ? const SizedBox.shrink()
                      : SaluxIcon('chev', size: 18, color: c.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grupo de filas dentro de una tarjeta con separadores.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(Divider(height: 1, color: c.line));
      }
    }
    return SaluxCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(children: items),
    );
  }
}

// ---------------------------------------------------------------- Avisos

OverlayEntry? _toast;
Timer? _toastTimer;

/// Aviso breve de 2,2 s sobre la barra inferior.
void showToast(BuildContext context, String message) {
  _toastTimer?.cancel();
  _toast?.remove();
  final overlay = Overlay.of(context, rootOverlay: true);
  final c = context.colors;
  _toast = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 20,
      right: 20,
      bottom: 96 + MediaQuery.of(ctx).padding.bottom,
      child: IgnorePointer(
        child: Semantics(
          liveRegion: true,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: c.ink,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.bg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(_toast!);
  _toastTimer = Timer(const Duration(milliseconds: 2200), () {
    _toast?.remove();
    _toast = null;
  });
}

// ----------------------------------------------------------------- Hojas

/// Hoja inferior con asa y fondo oscurecido.
Future<T?> showSaluxSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final c = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: c.surface,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(SaluxRadius.sheetTop)),
    ),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: c.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            builder(ctx),
          ],
        ),
      ),
    ),
  );
}

/// Hoja de confirmación genérica con mascota.
Future<bool> confirmSheet(
  BuildContext context, {
  required MascotMood mood,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  bool danger = false,
}) async {
  final r = await showSaluxSheet<bool>(
    context,
    builder: (ctx) => Column(
      children: [
        Mascot(mood, size: 110),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: ctx.colors.muted),
        ),
        const SizedBox(height: 20),
        SaluxButton(
          confirmLabel,
          danger: danger,
          secondary: danger,
          onPressed: () => Navigator.pop(ctx, true),
        ),
        const SizedBox(height: 10),
        SaluxButton(
          cancelLabel,
          secondary: true,
          onPressed: () => Navigator.pop(ctx, false),
        ),
      ],
    ),
  );
  return r ?? false;
}
