import 'package:example/core/packages/packages.dart';

class RequestResult {
  final int? statusCode;
  final int latencyMs;
  final bool isSuccess;
  final String message;

  const RequestResult({
    required this.statusCode,
    required this.latencyMs,
    required this.isSuccess,
    required this.message,
  });
}

class HomeProvider extends ChangeNotifier {
  final Map<String, bool> _loadingMap = {};
  final Map<String, RequestResult> _resultMap = {};
  String? _inspectorUrl;
  bool _isInspectorRunning = false;
  NetworkSimulation _currentSimulation = NetworkSimulation.normal;

  Map<String, bool> get loadingMap => _loadingMap;
  Map<String, RequestResult> get resultMap => _resultMap;
  String? get inspectorUrl => _inspectorUrl;
  bool get isInspectorRunning => _isInspectorRunning;
  NetworkSimulation get currentSimulation => _currentSimulation;
  int get logsCount => DioLogger.instance.logs.logsNotifier.value.length;

  bool isLoading(String key) => _loadingMap[key] ?? false;
  RequestResult? getResult(String key) => _resultMap[key];

  void init() {
    _currentSimulation = NetworkSimulator.instance.simulationNotifier.value;
    _isInspectorRunning = WebInspectorServer.instance.isRunningNotifier.value;
    _inspectorUrl = WebInspectorServer.instance.serverUrl;

    NetworkSimulator.instance.simulationNotifier.addListener(_onSimulationChanged);
    WebInspectorServer.instance.isRunningNotifier.addListener(_onInspectorChanged);
    DioLogger.instance.logs.logsNotifier.addListener(_onLogsChanged);

    _detectLocalIp();
  }

  void _onLogsChanged() {
    notifyListeners();
  }

  void _onSimulationChanged() {
    _currentSimulation = NetworkSimulator.instance.simulationNotifier.value;
    notifyListeners();
  }

  void _onInspectorChanged() {
    _isInspectorRunning = WebInspectorServer.instance.isRunningNotifier.value;
    _inspectorUrl = WebInspectorServer.instance.serverUrl;
    notifyListeners();
  }

  Future<void> _detectLocalIp() async {
    await WebInspectorServer.getLocalIpAddress();
    notifyListeners();
  }

  @override
  void dispose() {
    NetworkSimulator.instance.simulationNotifier.removeListener(_onSimulationChanged);
    WebInspectorServer.instance.isRunningNotifier.removeListener(_onInspectorChanged);
    DioLogger.instance.logs.logsNotifier.removeListener(_onLogsChanged);
    super.dispose();
  }

  void clearLogs() {
    DioLogger.instance.logs.clearLogs();
    notifyListeners();
  }

  void toggleTheme(BuildContext context) {
    FloatingLoggerTheme.toggleTheme(context);
    notifyListeners();
  }

  Future<void> fetchGraphQL(BuildContext context) async {
    const key = 'graphql';
    _loadingMap[key] = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final response = await DioLogger.instance.post(
        'https://countries.trevorblades.com/',
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
        data: {
          "query": """
          query GetCountry(\$code: ID!) {
            country(code: \$code) {
              name
              capital
              currency
              emoji
            }
          }
        """,
          "variables": {"code": "ID"}
        },
      );
      stopwatch.stop();

      _resultMap[key] = RequestResult(
        statusCode: response.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: true,
        message: 'GraphQL query succeeded (200 OK)',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('GraphQL Query executed! Tap floating button to view.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: e.response?.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: CustomError.mapDioErrorToMessage(e),
      );
    } catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: null,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: e.toString(),
      );
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestGet(BuildContext context) async {
    const key = 'rest_get';
    _loadingMap[key] = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final response = await DioLogger.instance.get(
        'https://api.genderize.io',
        queryParameters: {"name": "alex"},
        options: Options(headers: {
          "Accept": "application/json",
        }),
      );
      stopwatch.stop();

      _resultMap[key] = RequestResult(
        statusCode: response.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: true,
        message: 'REST GET succeeded: ${response.data}',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('REST GET response received! Check Floating Logger.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: e.response?.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: CustomError.mapDioErrorToMessage(e),
      );
    } catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: null,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: e.toString(),
      );
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> fetchImagePreview(BuildContext context) async {
    const key = 'image_preview';
    _loadingMap[key] = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final response = await DioLogger.instance.get(
        'https://picsum.photos/id/237/400/300',
        options: Options(
          responseType: ResponseType.bytes, // Key for binary image preview!
        ),
      );
      stopwatch.stop();

      _resultMap[key] = RequestResult(
        statusCode: response.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: true,
        message: 'Binary Image fetched! Open logger to see Image Preview.',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF2563EB),
            content: Text('Binary Image loaded! Open Floating Logger to see Image preview.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: e.response?.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: CustomError.mapDioErrorToMessage(e),
      );
    } catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: null,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: e.toString(),
      );
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> fetchPdfPreview(BuildContext context) async {
    const key = 'pdf_preview';
    _loadingMap[key] = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final response = await DioLogger.instance.get(
        'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf',
        options: Options(
          responseType: ResponseType.bytes, // Key for PDF binary response!
        ),
      );
      stopwatch.stop();

      _resultMap[key] = RequestResult(
        statusCode: response.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: true,
        message: 'Binary PDF fetched! Open logger to see PDF badge & details.',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFDC2626),
            content: Text('PDF fetched! Open Floating Logger to view PDF badge preview.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: e.response?.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: CustomError.mapDioErrorToMessage(e),
      );
    } catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: null,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: e.toString(),
      );
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> fetchFormData(BuildContext context) async {
    const key = 'form_data';
    _loadingMap[key] = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final dio = Dio();
      dio.interceptors.add(FloatingLoggerInterceptor());

      final formData = FormData.fromMap({
        "username": "developer_pro",
        "role": "Flutter Lead",
        "timestamp": DateTime.now().toIso8601String(),
        "tags": ["debug", "floating_logger", "v2.1.2"],
      });

      final response = await dio.post(
        'https://httpbin.org/post',
        data: formData,
      );
      stopwatch.stop();

      _resultMap[key] = RequestResult(
        statusCode: response.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: true,
        message: 'FormData Multipart sent successfully!',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFEAB308),
            content: Text('FormData POST sent! Check cURL formatting in logger.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: e.response?.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: CustomError.mapDioErrorToMessage(e),
      );
    } catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: null,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: e.toString(),
      );
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> fetchWithCustomInterceptor(BuildContext context) async {
    const key = 'interceptor';
    _loadingMap[key] = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['X-Custom-Logger-Client'] = 'FloatingLogger-Example/2.1.2';
            options.headers['X-Request-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
            handler.next(options);
          },
        ),
      );
      dio.interceptors.add(FloatingLoggerInterceptor());

      final response = await dio.get('https://dummyjson.com/quotes/random');
      stopwatch.stop();

      _resultMap[key] = RequestResult(
        statusCode: response.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: true,
        message: 'Custom Interceptor chain executed!',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF8B5CF6),
            content: Text('Interceptor chained successfully! Check custom headers in logger.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: e.response?.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: CustomError.mapDioErrorToMessage(e),
      );
    } catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: null,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: e.toString(),
      );
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> fetchError500(BuildContext context) async {
    const key = 'error_500';
    _loadingMap[key] = true;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      await DioLogger.instance.get('https://httpstat.us/500');
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: 500,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: 'Simulated 500 Error received',
      );
    } on DioException catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: e.response?.statusCode ?? 500,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: CustomError.mapDioErrorToMessage(e),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFEF4444),
            content: Text('500 Error captured in Floating Logger! Check ERROR tab.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      stopwatch.stop();
      _resultMap[key] = RequestResult(
        statusCode: 500,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        message: e.toString(),
      );
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }
}
