import 'package:flutter/material.dart';

/// Palette tokens for Floating Logger UI.
class FloatingLoggerColors {
  final Color background;
  final Color cardBackground;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color divider;
  final Color codeBackground;
  final Color searchBackground;
  final Color handleBar;
  final Color chipBackground;
  final Color chipText;
  final Color navButtonBackground;
  final Color navButtonBorder;

  // JSON Syntax Highlight Tokens
  final Color jsonKey;
  final Color jsonString;
  final Color jsonNumber;
  final Color jsonBool;
  final Color jsonNull;
  final Color jsonBraces;

  const FloatingLoggerColors({
    required this.background,
    required this.cardBackground,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.codeBackground,
    required this.searchBackground,
    required this.handleBar,
    required this.chipBackground,
    required this.chipText,
    required this.navButtonBackground,
    required this.navButtonBorder,
    required this.jsonKey,
    required this.jsonString,
    required this.jsonNumber,
    required this.jsonBool,
    required this.jsonNull,
    required this.jsonBraces,
  });

  /// Light theme color palette
  static const light = FloatingLoggerColors(
    background: Color(0xFFF8F9FA),
    cardBackground: Colors.white,
    surface: Color(0xFFF1F3F5),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    textMuted: Color(0xFF94A3B8),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFE2E8F0),
    codeBackground: Color(0xFFF1F5F9),
    searchBackground: Colors.white,
    handleBar: Color(0xFFCBD5E1),
    chipBackground: Color(0xFFE2E8F0),
    chipText: Color(0xFF475569),
    navButtonBackground: Colors.white,
    navButtonBorder: Color(0xFFF97316),
    jsonKey: Color(0xFF8B5CF6),
    jsonString: Color(0xFF16A34A),
    jsonNumber: Color(0xFF2563EB),
    jsonBool: Color(0xFFEA580C),
    jsonNull: Color(0xFF64748B),
    jsonBraces: Color(0xFF334155),
  );

  /// Dark theme color palette
  static const dark = FloatingLoggerColors(
    background: Color(0xFF181825),
    cardBackground: Color(0xFF242538),
    surface: Color(0xFF1E1E2E),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    border: Color(0xFF374151),
    divider: Color(0xFF334155),
    codeBackground: Color(0xFF13141F),
    searchBackground: Color(0xFF1E1E2E),
    handleBar: Color(0xFF475569),
    chipBackground: Color(0xFF334155),
    chipText: Color(0xFFE2E8F0),
    navButtonBackground: Color(0xFF242538),
    navButtonBorder: Color(0xFFF97316),
    jsonKey: Color(0xFFC084FC),
    jsonString: Color(0xFF4ADE80),
    jsonNumber: Color(0xFF60A5FA),
    jsonBool: Color(0xFFFBBF24),
    jsonNull: Color(0xFF94A3B8),
    jsonBraces: Color(0xFFE2E8F0),
  );
}

/// Theme manager for Floating Logger to guarantee complete theme isolation.
abstract class FloatingLoggerTheme {

  /// Reactive notifier for the active theme mode.
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Toggles between light and dark mode.
  static void toggleTheme([BuildContext? context]) {
    if (themeModeNotifier.value == ThemeMode.dark) {
      themeModeNotifier.value = ThemeMode.light;
    } else if (themeModeNotifier.value == ThemeMode.light) {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      // If system, switch to opposite of current brightness
      if (context != null) {
        final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
        themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
      } else {
        themeModeNotifier.value = ThemeMode.dark;
      }
    }
  }

  /// Sets the theme mode explicitly.
  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  /// Checks if dark mode is currently active.
  static bool isDarkMode(BuildContext context) {
    if (themeModeNotifier.value == ThemeMode.dark) return true;
    if (themeModeNotifier.value == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  /// Retrieves the active colors based on the current context.
  static FloatingLoggerColors of(BuildContext context) {
    final isDark = isDarkMode(context);
    return isDark ? FloatingLoggerColors.dark : FloatingLoggerColors.light;
  }

  /// Generates a completely isolated ThemeData to prevent bleeding from the host app.
  static ThemeData getIsolatedTheme(BuildContext context) {
    final isDark = isDarkMode(context);
    final colors = isDark ? FloatingLoggerColors.dark : FloatingLoggerColors.light;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      dialogBackgroundColor: colors.cardBackground,
      cardColor: colors.cardBackground,
      dividerColor: colors.divider,
      colorScheme: isDark
          ? const ColorScheme.dark().copyWith(
              surface: colors.surface,
              primary: Colors.blue,
              secondary: Colors.orange,
              onSurface: colors.textPrimary,
            )
          : const ColorScheme.light().copyWith(
              surface: colors.surface,
              primary: Colors.blue,
              secondary: Colors.orange,
              onSurface: colors.textPrimary,
            ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.textPrimary, fontFamily: 'Inter'),
        bodyMedium: TextStyle(color: colors.textPrimary, fontFamily: 'Inter'),
        bodySmall: TextStyle(color: colors.textSecondary, fontFamily: 'Inter'),
        titleLarge: TextStyle(color: colors.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: colors.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: colors.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.searchBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: TextStyle(color: colors.textMuted, fontSize: 13, fontFamily: 'Inter'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
    );
  }
}
