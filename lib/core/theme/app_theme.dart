import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Accent color — фиолетовый
  static const accent = Color(0xFF7C6AF7);
  static const accentLight = Color(0xFFA594FF);
  static const green = Color(0xFF34D399);
  static const red = Color(0xFFF87171);
  static const amber = Color(0xFFFBBF24);

  static ThemeData dark() {
    const bg = Color(0xFF0A0A0F);
    const surface = Color(0xFF111118);
    const surface2 = Color(0xFF18181F);
    const textPrimary = Color(0xFFF0F0F5);
    const textSecondary = Color(0x73F0F0F5);
    const border = Color(0x12FFFFFF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.syneTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      extensions: const [
        AppColors(
          bg: bg,
          surface: surface,
          surface2: surface2,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          border: border,
        ),
      ],
    );
  }

  static ThemeData light() {
    const bg = Color(0xFFF5F4F0);
    const surface = Color(0xFFFFFFFF);
    const surface2 = Color(0xFFF0EFF8);
    const textPrimary = Color(0xFF12111A);
    const textSecondary = Color(0x7312111A);
    const border = Color(0x14000000);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF5B4DE0),
        secondary: accent,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.syneTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
        ),
      ),
      extensions: const [
        AppColors(
          bg: bg,
          surface: surface,
          surface2: surface2,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          border: border,
        ),
      ],
    );
  }
}

/// Расширение темы — достаём через context.appColors
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  AppColors copyWith({
    Color? bg, Color? surface, Color? surface2,
    Color? textPrimary, Color? textSecondary, Color? border,
  }) => AppColors(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    surface2: surface2 ?? this.surface2,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    border: border ?? this.border,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension ThemeX on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
