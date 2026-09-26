import 'package:flutter/material.dart';

/// Semantic colours for SwiftShare. Screens read these through
/// `context.palette` instead of hard-coding hex values, so every surface and
/// every piece of text switches correctly between light and dark mode.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Page background (Scaffold).
  final Color background;

  /// Cards, panels, sheets.
  final Color surface;

  /// Segmented-control track, chips, quiet fills.
  final Color surfaceMuted;

  /// Inset boxes inside a card (code box, input fill).
  final Color surfaceSubtle;

  /// Hairline borders around cards and inputs.
  final Color border;

  /// Borders that need a bit more contrast (outlined buttons).
  final Color borderStrong;

  /// Headings and main text.
  final Color textPrimary;

  /// Body text inside cards.
  final Color textBody;

  /// Supporting text (subtitles, descriptions).
  final Color textSecondary;

  /// Hints, captions, inactive icons.
  final Color textMuted;

  /// Brand colour for text and icons on [surface] (lighter in dark mode so it
  /// stays readable).
  final Color accent;

  /// Tinted fill behind brand icons.
  final Color accentSoft;

  /// Top colour of the soft icon tile gradient.
  final Color accentSoftTop;

  /// Card / panel drop shadow.
  final Color shadow;

  /// Bottom navigation bar background.
  final Color navBar;

  /// "Swift" part of the wordmark.
  final Color wordmark;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceSubtle,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textBody,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.accentSoftTop,
    required this.shadow,
    required this.navBar,
    required this.wordmark,
  });

  static const AppPalette light = AppPalette(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEFF3FA),
    surfaceSubtle: Color(0xFFF8FAFD),
    border: Color(0xFFE5EBF4),
    borderStrong: Color(0xFFDDE5F0),
    textPrimary: Color(0xFF0F172A),
    textBody: Color(0xFF334155),
    textSecondary: Color(0xFF60708C),
    textMuted: Color(0xFF8FA0B8),
    accent: Color(0xFF6366F1),
    accentSoft: Color(0xFFE9ECFF),
    accentSoftTop: Color(0xFFF8FAFF),
    shadow: Color(0x1453617A), // #53617A at 8 %
    navBar: Color(0xFFF8FAFC),
    wordmark: Color(0xFF1E1B4B),
  );

  /// Midnight dark theme: deep navy surfaces with clear, high-contrast text.
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0B1020),
    surface: Color(0xFF131A2E),
    surfaceMuted: Color(0xFF1B2440),
    surfaceSubtle: Color(0xFF0F1628),
    border: Color(0xFF243052),
    borderStrong: Color(0xFF334066),
    textPrimary: Color(0xFFF1F4FB),
    textBody: Color(0xFFD5DBEA),
    textSecondary: Color(0xFFA9B4CC),
    textMuted: Color(0xFF7F8BA8),
    accent: Color(0xFFA5B4FC),
    accentSoft: Color(0xFF232B55),
    accentSoftTop: Color(0xFF1B2242),
    shadow: Color(0x59000000), // black at 35 %
    navBar: Color(0xFF0E1426),
    wordmark: Color(0xFFE0E7FF),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceSubtle,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textBody,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSoft,
    Color? accentSoftTop,
    Color? shadow,
    Color? navBar,
    Color? wordmark,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textBody: textBody ?? this.textBody,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSoftTop: accentSoftTop ?? this.accentSoftTop,
      shadow: shadow ?? this.shadow,
      navBar: navBar ?? this.navBar,
      wordmark: wordmark ?? this.wordmark,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      surfaceSubtle: l(surfaceSubtle, other.surfaceSubtle),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textBody: l(textBody, other.textBody),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      accentSoftTop: l(accentSoftTop, other.accentSoftTop),
      shadow: l(shadow, other.shadow),
      navBar: l(navBar, other.navBar),
      wordmark: l(wordmark, other.wordmark),
    );
  }
}

/// `context.palette.surface`, `context.palette.textPrimary`, ...
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// True in dark mode. Dark mode uses solid fills only (no gradients).
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  static ThemeData get lightTheme => _build(Brightness.light, AppPalette.light);
  static ThemeData get darkTheme => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final bool dark = brightness == Brightness.dark;

    // Seeded scheme for the tonal roles, then pinned to our palette so
    // Material widgets (Card, ListTile, Dialog, TextField...) match the
    // custom screens exactly.
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    ).copyWith(
      primary: dark ? const Color(0xFF818CF8) : primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      error: errorColor,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceMuted,
      surfaceContainerHighest: p.surfaceMuted,
      outline: p.borderStrong,
      outlineVariant: p.border,
      shadow: Colors.black,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Poppins',
    );

    OutlineInputBorder inputBorder(Color c, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[p],
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.border,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1),
      textTheme: base.textTheme.apply(
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
        fontFamily: 'Poppins',
      ),
      iconTheme: IconThemeData(color: p.textSecondary),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: p.border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
        contentTextStyle: TextStyle(
          color: p.textBody,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: p.textPrimary, fontFamily: 'Poppins'),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? p.surfaceMuted : const Color(0xFF1F2937),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : p.surfaceMuted,
        ),
        trackOutlineColor: WidgetStateProperty.all(p.border),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textBody,
          side: BorderSide(color: p.borderStrong),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.accent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder(p.border),
        enabledBorder: inputBorder(p.border),
        focusedBorder: inputBorder(scheme.primary, 2),
        filled: true,
        fillColor: p.surfaceSubtle,
        labelStyle: TextStyle(color: p.textSecondary),
        hintStyle: TextStyle(color: p.textMuted),
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }
}

/// Brand colours that are the same in light and dark mode. For anything that
/// should change with the theme (backgrounds, text, borders) use
/// `context.palette` instead.
class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF06B6D4);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  /// Light-mode page background. Only the splash screen should use this
  /// directly (it matches the native Android splash).
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Poppins',
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: 'Poppins',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: 'Poppins',
  );
}
