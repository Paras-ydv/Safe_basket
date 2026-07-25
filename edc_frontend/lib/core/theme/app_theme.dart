import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'risk_colors.dart';

/// Central app theme — a strict dark, cyber-laboratory interface.
///
/// Palette (Color Mapping Protocol):
/// - Primary accent  `#00E5FF` — active scanning, primary focus triggers
/// - Surface base    `#121921` — info blocks, scan metric plates
/// - Obsidian dark   `#090C11` — absolute app background (scaffold)
///
/// Typography combines three Google Fonts:
/// - Space Grotesk   — headings & core UI actions
/// - Plus Jakarta Sans — body content & explanations
/// - JetBrains Mono  — data readouts & lab metrics (labels)
///
/// Risk color tokens are attached as a [RiskColors] theme extension so screens
/// resolve them via `context.riskColors` rather than hardcoding.
abstract final class AppTheme {
  static const _primaryAccent = Color(0xFF00E5FF);
  static const _surfaceBase = Color(0xFF121921);
  static const _obsidian = Color(0xFF090C11);

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryAccent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _primaryAccent,
      surface: _surfaceBase,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: _obsidian,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      extensions: const [RiskColors.dark],
    );
  }

  /// Applies the three-font hierarchy on top of a base [TextTheme].
  static TextTheme _textTheme(TextTheme base) {
    return TextTheme(
      // Headings & core UI — Space Grotesk (edgy, technical).
      displayLarge: GoogleFonts.spaceGrotesk(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w500,
      ),
      // Body & explanations — Plus Jakarta Sans (geometric readability).
      bodyLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.bodyLarge,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        textStyle: base.bodySmall,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
      // Data readouts & lab metrics — JetBrains Mono (engineering precision).
      labelMedium: GoogleFonts.jetBrainsMono(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
