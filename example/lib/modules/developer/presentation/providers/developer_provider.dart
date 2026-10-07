import 'package:example/core/packages/packages.dart';

class DeveloperProvider extends ChangeNotifier {
  int _currentTab = 0;
  bool _isLoggerVisible = true;
  bool _showConsoleLog = true;
  int _maxLogSize = 30;
  NetworkSimulation _currentSimulation = NetworkSimulation.normal;
  bool _isInspectorRunning = false;
  String? _inspectorUrl;
  String? _localIp;
  ThemeMode _themeMode = ThemeMode.system;
  Color _floatingButtonColor = const Color(0xFF3B82F6);

  int get currentTab => _currentTab;
  bool get isLoggerVisible => _isLoggerVisible;
  bool get showConsoleLog => _showConsoleLog;
  int get maxLogSize => _maxLogSize;
  NetworkSimulation get currentSimulation => _currentSimulation;
  bool get isInspectorRunning => _isInspectorRunning;
  String? get inspectorUrl => _inspectorUrl;
  String? get localIp => _localIp;
  ThemeMode get themeMode => _themeMode;
  Color get floatingButtonColor => _floatingButtonColor;

  void init() {
    _loadSettings();
    _currentSimulation = NetworkSimulator.instance.simulationNotifier.value;
    _isInspectorRunning = WebInspectorServer.instance.isRunningNotifier.value;
    _inspectorUrl = WebInspectorServer.instance.serverUrl;
    _showConsoleLog = DioLogger.showConsoleLogNotifier.value;
    _maxLogSize = DioLogger.instance.logs.maxLogSize;
    _themeMode = FloatingLoggerTheme.themeModeNotifier.value;

    NetworkSimulator.instance.simulationNotifier.addListener(_onSimulationChanged);
    WebInspectorServer.instance.isRunningNotifier.addListener(_onInspectorChanged);
    FloatingLoggerTheme.themeModeNotifier.addListener(_onThemeChanged);

    _detectLocalIp();
  }

  Future<void> _loadSettings() async {
    try {
      _isLoggerVisible = await CustomSharedPreferences.getDebugger();
      DioLogger.shouldLogNotifier.value = _isLoggerVisible;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _detectLocalIp() async {
    _localIp = await WebInspectorServer.getLocalIpAddress();
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

  void _onThemeChanged() {
    _themeMode = FloatingLoggerTheme.themeModeNotifier.value;
    notifyListeners();
  }

  @override
  void dispose() {
    NetworkSimulator.instance.simulationNotifier.removeListener(_onSimulationChanged);
    WebInspectorServer.instance.isRunningNotifier.removeListener(_onInspectorChanged);
    FloatingLoggerTheme.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  Future<void> toggleLoggerVisibility(bool val) async {
    _isLoggerVisible = val;
    DioLogger.shouldLogNotifier.value = val;
    await CustomSharedPreferences.saveDebugger(val);
    notifyListeners();
  }

  void toggleConsoleLog(bool val) {
    _showConsoleLog = val;
    DioLogger.showConsoleLogNotifier.value = val;
    notifyListeners();
  }

  void setMaxLogSize(int size) {
    _maxLogSize = size;
    DioLogger.instance.logs.maxLogSize = size;
    notifyListeners();
  }

  void setSimulation(NetworkSimulation sim) {
    _currentSimulation = sim;
    NetworkSimulator.instance.setSimulation(sim);
    notifyListeners();
  }

  Future<void> toggleWebInspector() async {
    if (_isInspectorRunning) {
      await WebInspectorServer.instance.stop();
    } else {
      await WebInspectorServer.instance.start();
    }
    _isInspectorRunning = WebInspectorServer.instance.isRunningNotifier.value;
    _inspectorUrl = WebInspectorServer.instance.serverUrl;
    notifyListeners();
  }

  void copyInspectorUrl(BuildContext context) {
    if (_inspectorUrl != null) {
      Clipboard.setData(ClipboardData(text: _inspectorUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied: $_inspectorUrl'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    FloatingLoggerTheme.setThemeMode(mode);
    notifyListeners();
  }

  void setFloatingColor(Color color) {
    _floatingButtonColor = color;
    notifyListeners();
  }
}
