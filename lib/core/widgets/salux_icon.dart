import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icono de trazo cargado por nombre desde `assets/icons`.
class SaluxIcon extends StatelessWidget {
  const SaluxIcon(this.name, {super.key, this.size = 22, this.color, this.label});

  final String name;
  final double size;
  final Color? color;

  /// Etiqueta de accesibilidad; si es nula el icono es decorativo.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
      semanticsLabel: label,
      excludeFromSemantics: label == null,
    );
  }
}

/// Estados de la mascota de apoyo.
enum MascotMood { happy, cheer, sad, sleep, love, think }

class Mascot extends StatelessWidget {
  const Mascot(this.mood, {super.key, this.size = 120});

  final MascotMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/mascot/mascota_${mood.name}.svg',
      height: size,
      excludeFromSemantics: true,
    );
  }
}

/// Personaje oficial (PNG transparente).
class MascotSticker extends StatelessWidget {
  const MascotSticker({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/salux_mascota_sticker.png',
      height: height,
      cacheHeight: (height * 2).round(),
      semanticLabel: 'Mascota de SALUX',
    );
  }
}
