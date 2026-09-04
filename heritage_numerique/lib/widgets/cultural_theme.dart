import 'package:flutter/material.dart';

/// Charte graphique et constantes de style pour Héritage Numérique
class CulturalTheme {
  // Couleurs principales
  static const Color primaryOcre = Color(0xFFD69301);       // Ocre vif
  static const Color primaryDarkOcre = Color(0xFFA56C00);   // Ocre foncé / Terre de Sienne
  static const Color primaryOlive = Color(0xFF9F9646);      // Vert Olive
  static const Color primaryBrown = Color(0xFF7B521A);      // Chocolat chaud
  static const Color backgroundLight = Color(0xFFFDFBF7);   // Crème doux
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF2E2E2E);
  static const Color textMuted = Color(0xFF757575);
  static const Color accentGold = Color(0xFFEBC15F);
  static const Color secondaryGold = Color(0xFFEBC15F);
  static const Color borderLight = Color(0xFFEEEEEE);

  // Dégradés
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFA56C00), Color(0xFFD69301)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Styles de bordure
  static BorderRadius defaultBorderRadius = BorderRadius.circular(16);
  static BorderRadius pillBorderRadius = BorderRadius.circular(30);

  // Ombres
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> ocreGlow = [
    BoxShadow(
      color: primaryDarkOcre.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}
