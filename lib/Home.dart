// ignore_for_file: file_names
import 'package:flutter/material.dart';

/// Widget estático (StatelessWidget) para la cabecera visual de la aplicación,
/// implementado con la estructura pedagógica enseñada por el profesor.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  // Paleta de colores Hatsune Miku
  static const Color mikuTeal = Color(0xFF39C5BB);      // Celeste/Turquesa icónico
  static const Color mikuPink = Color(0xFFE12885);      // Rosa / Magenta de acento
  static const Color mikuLightBg = Color(0xFFE8F8F7);   // Fondo menta suave para modo día
  static const Color mikuDarkBg = Color(0xFF1E202B);    // Fondo oscuro para modo noche

  @override
  Widget build(BuildContext context) {
    final bool esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 16),

        // 1. TÍTULO EN MAYÚSCULAS Y NEGRITA
        const Center(
          child: Text(
            'MI PRIMERA APLICACIÓN',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mikuTeal,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. CIRCLE AVATAR (Radio 100 con la imagen de assets/img/persona.avif)
        Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: mikuTeal, width: 3),
              boxShadow: [
                BoxShadow(
                  color: mikuTeal.withValues(alpha: esModoOscuro ? 0.45 : 0.25),
                  blurRadius: esModoOscuro ? 20 : 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 100,
              backgroundColor: esModoOscuro ? mikuDarkBg : mikuLightBg,
              backgroundImage: const AssetImage('assets/img/hombre.avif'),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 3. ROW CON TEXTOS "COMPUTER" Y "SETIEMBRE 2026"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'COMPUTER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mikuTeal,
              ),
            ),
            Text(
              ' SETIEMBRE 2026',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: esModoOscuro ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
