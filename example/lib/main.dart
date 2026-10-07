import 'package:example/core/packages/packages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect local IP address asynchronously for Web Inspector
  WebInspectorServer.getLocalIpAddress();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: FloatingLoggerTheme.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Flutter Floating Logger',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3B82F6),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            fontFamily: 'Inter',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3B82F6),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF181825),
            fontFamily: 'Inter',
          ),
          initialRoute: HomePage.routeName,
          onGenerateRoute: RouteGenerator.generateRoute,
        );
      },
    );
  }
}
