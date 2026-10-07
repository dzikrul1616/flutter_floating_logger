import 'package:example/core/packages/packages.dart';

class GuideSnippetItem {
  final String title;
  final String category;
  final String description;
  final String code;
  final String tip;

  const GuideSnippetItem({
    required this.title,
    required this.category,
    required this.description,
    required this.code,
    required this.tip,
  });
}

class GuideProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;

  int get selectedTabIndex => _selectedTabIndex;

  final List<GuideSnippetItem> snippets = const [
    GuideSnippetItem(
      title: '1. Basic Setup',
      category: 'Setup',
      description: 'Wrap your app MaterialApp or target screen with FloatingLoggerControl to enable the draggable floating debug widget.',
      code: '''import 'package:floating_logger/floating_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FloatingLoggerControl(
        child: const HomeScreen(),
      ),
    );
  }
}''',
      tip: 'The floating button automatically magnetically snaps to the nearest screen edge when dragged.',
    ),
    GuideSnippetItem(
      title: '2. DioLogger (No-Config)',
      category: 'Network',
      description: 'Use the built-in DioLogger singleton for out-of-the-box automatic request, response, error, and cURL logging.',
      code: '''import 'package:floating_logger/floating_logger.dart';

// GET request
final response = await DioLogger.instance.get(
  'https://api.example.com/users',
  queryParameters: {'role': 'developer'},
);

// POST request with JSON
final postRes = await DioLogger.instance.post(
  'https://api.example.com/items',
  data: {'title': 'New Item', 'price': 99},
);''',
      tip: 'DioLogger singleton handles connection timeouts and SSL certificates gracefully for local development.',
    ),
    GuideSnippetItem(
      title: '3. Custom Dio Interceptor',
      category: 'Dio',
      description: 'If you have an existing custom Dio client, simply add FloatingLoggerInterceptor to its interceptors list.',
      code: '''import 'package:dio/dio.dart';
import 'package:floating_logger/floating_logger.dart';

final dio = Dio(
  BaseOptions(baseUrl: 'https://api.example.com'),
);

// Add the interceptor directly
dio.interceptors.add(FloatingLoggerInterceptor());

// Or add custom interceptors to DioLogger
DioLogger.instance.addInterceptor(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer token123';
      handler.next(options);
    },
  ),
);''',
      tip: 'FloatingLoggerInterceptor captures cURL commands including multipart FormData and GraphQL bodies.',
    ),
    GuideSnippetItem(
      title: '4. Web Inspector (Desktop)',
      category: 'Desktop',
      description: 'Stream live app logs to any desktop or laptop browser on your local network over HTTP & WebSocket.',
      code: '''import 'package:floating_logger/floating_logger.dart';

// Start server on port 21616
await WebInspectorServer.instance.start();

// Get local URL (e.g. http://192.168.1.50:21616)
final url = WebInspectorServer.instance.serverUrl;
print('Open browser at: \$url');

// Stop server when no longer needed
await WebInspectorServer.instance.stop();''',
      tip: 'Zero extra dependencies! Uses standard dart:io HttpServer and WebSocketTransformer.',
    ),
    GuideSnippetItem(
      title: '5. Network Simulator',
      category: 'Testing',
      description: 'Simulate bad network conditions like Slow 3G, Offline mode, Socket refusal, Server 500, and Timeouts.',
      code: '''import 'package:floating_logger/floating_logger.dart';

// Normal speed
NetworkSimulator.instance.setSimulation(NetworkSimulation.normal);

// 2000ms Slow 3G latency
NetworkSimulator.instance.setSimulation(NetworkSimulation.slow3g);

// Offline error (Airplane mode)
NetworkSimulator.instance.setSimulation(NetworkSimulation.offline);

// HTTP 500 Internal Server Error
NetworkSimulator.instance.setSimulation(NetworkSimulation.serverError);''',
      tip: 'When simulation is active, an orange indicator badge appears automatically on the floating button.',
    ),
    GuideSnippetItem(
      title: '6. Binary Preview (Image & PDF)',
      category: 'Binary',
      description: 'Preview image responses directly inside the logger and view PDF metadata by passing responseType: ResponseType.bytes.',
      code: '''import 'package:floating_logger/floating_logger.dart';

// Fetch Image with binary bytes
final imageRes = await DioLogger.instance.get(
  'https://picsum.photos/id/237/400/300',
  options: Options(responseType: ResponseType.bytes),
);

// Fetch PDF document with binary bytes
final pdfRes = await DioLogger.instance.get(
  'https://example.com/invoice.pdf',
  options: Options(responseType: ResponseType.bytes),
);''',
      tip: 'Inside Floating Logger, tap any image log to open a high-res zoomable preview dialog!',
    ),
    GuideSnippetItem(
      title: '7. Theme & Custom Style',
      category: 'Style',
      description: 'Completely customize the floating button appearance, color, size, and toggle Dark/Light theme mode.',
      code: '''import 'package:flutter/material.dart';
import 'package:floating_logger/floating_logger.dart';

// Toggle Dark / Light theme
FloatingLoggerTheme.toggleTheme(context);

// Custom Floating Button Style
FloatingLoggerControl(
  style: FloatingLoggerStyle(
    backgroundColor: Colors.deepPurple,
    size: const Size(54, 54),
    tooltip: 'API Debugger',
    icon: const Icon(Icons.bug_report, color: Colors.white, size: 24),
  ),
  child: const HomeScreen(),
);''',
      tip: 'FloatingLoggerTheme provides complete theme isolation so your app theme is never affected.',
    ),
  ];

  GuideSnippetItem get currentSnippet => snippets[_selectedTabIndex];

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void copyCurrentSnippet(BuildContext context) {
    Clipboard.setData(ClipboardData(text: currentSnippet.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "${currentSnippet.title}" code to clipboard!'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
