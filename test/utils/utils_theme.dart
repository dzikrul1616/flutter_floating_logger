import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_logger/src/utils/utils_theme.dart';

void utilsThemeTest() {
  group('Utils Theme Tests', () {
    test('FloatingLoggerColors light and dark have valid colors', () {
      expect(FloatingLoggerColors.light.background, isA<Color>());
      expect(FloatingLoggerColors.dark.background, isA<Color>());
      expect(FloatingLoggerColors.light.textPrimary, isA<Color>());
      expect(FloatingLoggerColors.dark.textPrimary, isA<Color>());
      expect(FloatingLoggerColors.light.jsonKey, isA<Color>());
      expect(FloatingLoggerColors.dark.jsonKey, isA<Color>());
    });

    test('FloatingLoggerTheme toggleTheme works properly', () {
      FloatingLoggerTheme.setThemeMode(ThemeMode.light);
      expect(FloatingLoggerTheme.themeModeNotifier.value, ThemeMode.light);

      FloatingLoggerTheme.toggleTheme();
      expect(FloatingLoggerTheme.themeModeNotifier.value, ThemeMode.dark);

      FloatingLoggerTheme.toggleTheme();
      expect(FloatingLoggerTheme.themeModeNotifier.value, ThemeMode.light);

      FloatingLoggerTheme.setThemeMode(ThemeMode.system);
      FloatingLoggerTheme.toggleTheme();
      expect(FloatingLoggerTheme.themeModeNotifier.value, ThemeMode.dark);
    });

    testWidgets('FloatingLoggerTheme of context returns correct colors and isolated ThemeData',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Builder(builder: (context) {
            FloatingLoggerTheme.setThemeMode(ThemeMode.light);
            final colorsLight = FloatingLoggerTheme.of(context);
            expect(colorsLight.cardBackground, FloatingLoggerColors.light.cardBackground);
            expect(FloatingLoggerTheme.isDarkMode(context), isFalse);

            final themeData = FloatingLoggerTheme.getIsolatedTheme(context);
            expect(themeData.brightness, Brightness.light);

            FloatingLoggerTheme.setThemeMode(ThemeMode.dark);
            final colorsDark = FloatingLoggerTheme.of(context);
            expect(colorsDark.cardBackground, FloatingLoggerColors.dark.cardBackground);
            expect(FloatingLoggerTheme.isDarkMode(context), isTrue);

            final darkThemeData = FloatingLoggerTheme.getIsolatedTheme(context);
            expect(darkThemeData.brightness, Brightness.dark);

            // Test system mode with context
            FloatingLoggerTheme.setThemeMode(ThemeMode.system);
            FloatingLoggerTheme.toggleTheme(context);
            // Since platformBrightness is light in MaterialApp by default, toggling sets dark
            expect(FloatingLoggerTheme.themeModeNotifier.value, ThemeMode.dark);

            return const SizedBox.shrink();
          }),
        ),
      );
    });

    testWidgets('FloatingLoggerTheme toggleTheme with dark system brightness sets light mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: Builder(builder: (context) {
            FloatingLoggerTheme.setThemeMode(ThemeMode.system);
            expect(FloatingLoggerTheme.isDarkMode(context), isTrue);
            FloatingLoggerTheme.toggleTheme(context);
            expect(FloatingLoggerTheme.themeModeNotifier.value, ThemeMode.light);
            return const SizedBox.shrink();
          }),
        ),
      );
    });
  });
}
