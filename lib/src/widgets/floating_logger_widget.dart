import 'widgets.dart';
import 'package:floating_logger/floating_logger.dart';

/// A widget that provides a floating logger control button.
/// This button allows debugging API logs, can be dragged around,
/// and automatically snaps to the nearest screen edge (Magnetic Snapping).
class FloatingLoggerControl extends StatefulWidget {
  const FloatingLoggerControl({
    super.key,
    required this.child,
    this.isShow,
    this.getPreference,
    this.widgetItemBuilder,
    this.style,
    this.maxLogSize = 30,
    this.isSimulationActive = true,
    this.showConsoleLog = true,
  });

  /// The main child widget (usually the app content).
  final Widget child;

  /// Controls whether the floating button is shown or hidden.
  final ValueNotifier<bool>? isShow;

  /// Determines if the visibility preference should be retrieved.
  final Future<bool> Function()? getPreference;

  /// Styling of widget float.
  final FloatingLoggerStyle? style;

  /// Custom widget builder for log items.
  final Widget Function(
    int index,
    List<LogRepositoryModel> data,
  )? widgetItemBuilder;

  /// Maximum number of logs to store (default: 30).
  final int maxLogSize;

  /// Controls whether the network simulation control is shown (default: true).
  final bool isSimulationActive;

  /// Controls whether console/terminal logs are outputted (default: true).
  final bool showConsoleLog;

  @override
  State<FloatingLoggerControl> createState() => _FloatingLoggerControlState();
}

class _FloatingLoggerControlState extends State<FloatingLoggerControl> {
  /// Stores the visibility state of the floating button.
  late bool isShow;

  /// Stores the current position of the floating button.
  Offset position = const Offset(12, 120);

  /// Tracks if currently dragging to disable animation during drag.
  bool isDragging = false;

  /// Retrieves the stored visibility preference.
  Future<void> _getShowPreference() async {
    try {
      final data = await widget.getPreference!().timeout(
        const Duration(seconds: 5),
        onTimeout: () => DioLogger.shouldLogNotifier.value,
      );
      if (mounted) {
        setState(() {
          isShow = data;
          DioLogger.shouldLogNotifier.value = data;
        });
      }
    } catch (_) {
      // Retain current visibility on failure
    }
  }

  @override
  void initState() {
    super.initState();
    isShow = widget.isShow?.value ?? DioLogger.shouldLogNotifier.value;
    DioLogger.instance.logs.maxLogSize = widget.maxLogSize;
    DioLogger.showConsoleLogNotifier.value = widget.showConsoleLog;
    DioLogger.shouldLogNotifier.addListener(_onVisibilityChanged);
    if (widget.isShow != null && widget.isShow != DioLogger.shouldLogNotifier) {
      widget.isShow!.addListener(_onVisibilityChanged);
    }
    if (widget.getPreference != null) {
      _getShowPreference();
    }
  }

  void _onVisibilityChanged() {
    if (mounted) {
      setState(() {
        isShow = widget.isShow?.value ?? DioLogger.shouldLogNotifier.value;
      });
    }
  }

  @override
  void didUpdateWidget(covariant FloatingLoggerControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showConsoleLog != widget.showConsoleLog) {
      DioLogger.showConsoleLogNotifier.value = widget.showConsoleLog;
    }
    if (oldWidget.maxLogSize != widget.maxLogSize) {
      DioLogger.instance.logs.maxLogSize = widget.maxLogSize;
    }
    if (oldWidget.isShow != widget.isShow) {
      if (oldWidget.isShow != null &&
          oldWidget.isShow != DioLogger.shouldLogNotifier) {
        oldWidget.isShow!.removeListener(_onVisibilityChanged);
      }
      if (widget.isShow != null &&
          widget.isShow != DioLogger.shouldLogNotifier) {
        widget.isShow!.addListener(_onVisibilityChanged);
      }
      isShow = widget.isShow?.value ?? DioLogger.shouldLogNotifier.value;
    }
    if (oldWidget.style != widget.style ||
        oldWidget.widgetItemBuilder != widget.widgetItemBuilder) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    DioLogger.shouldLogNotifier.removeListener(_onVisibilityChanged);
    if (widget.isShow != null && widget.isShow != DioLogger.shouldLogNotifier) {
      widget.isShow!.removeListener(_onVisibilityChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showWidget =
        (widget.isShow?.value ?? isShow) && DioLogger.shouldLogNotifier.value;
    final btnWidth = widget.style?.size?.width ?? 50.0;
    final btnHeight = widget.style?.size?.height ?? 50.0;

    return LayoutBuilder(builder: (context, constraints) {
      final safePadding = MediaQuery.of(context).padding;
      final minX = 12.0;
      final maxX = (constraints.maxWidth - btnWidth - 12.0).clamp(minX, double.infinity);
      final minY = (safePadding.top + 10.0).clamp(0.0, constraints.maxHeight);
      final maxY = (constraints.maxHeight - btnHeight - safePadding.bottom - 10.0).clamp(minY, double.infinity);

      return Stack(
        children: [
          // RepaintBoundary isolates the app tree from floating button animations
          RepaintBoundary(child: widget.child),
          if (showWidget)
            AnimatedPositioned(
              duration: isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: position.dx.clamp(minX, maxX),
              top: position.dy.clamp(minY, maxY),
              child: Draggable(
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildFloatingActionButton(widget.style, isDraggingFeedback: true),
                ),
                childWhenDragging: const SizedBox.shrink(),
                onDragStarted: () {
                  setState(() {
                    isDragging = true;
                  });
                },
                onDragEnd: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;
                  double rawX = details.offset.dx -
                      (screenWidth - constraints.maxWidth) / 2;
                  double rawY = details.offset.dy -
                      (screenHeight - constraints.maxHeight) / 2;

                  // Smooth magnetic snap to closest left or right edge
                  final middleX = (minX + maxX) / 2;
                  final targetX = rawX < middleX ? minX : maxX;
                  final targetY = rawY.clamp(minY, maxY);

                  setState(() {
                    isDragging = false;
                    position = Offset(targetX, targetY);
                  });
                },
                child: _buildFloatingActionButton(widget.style),
              ),
            ),
        ],
      );
    });
  }

  /// Builds the modern floating action button for opening the debug panel.
  Widget _buildFloatingActionButton(
    FloatingLoggerStyle? style, {
    bool isDraggingFeedback = false,
  }) {
    final width = style?.size?.width ?? 50.0;
    final height = style?.size?.height ?? 50.0;
    final bgColor =
        style?.backgroundColor ?? const Color.fromARGB(255, 77, 159, 226);

    return SizedBox(
      width: width,
      height: height,
      child: ValueListenableBuilder<NetworkSimulation>(
        valueListenable: NetworkSimulator.instance.simulationNotifier,
        builder: (context, simulation, _) {
          final isSimulationActive = simulation != NetworkSimulation.normal;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                heroTag: "floating_logger",
                tooltip: style?.tooltip ?? "Debug API",
                backgroundColor: bgColor,
                elevation: isDraggingFeedback ? 8 : 4,
                highlightElevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: isDraggingFeedback ? null : _showDebugPanel,
                child: style?.icon ??
                    const Icon(
                      Icons.code_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
              ),
              // Indicator badge for active network simulation
              if (isSimulationActive)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Opens the debug panel in a bottom sheet with transparent barrier.
  void _showDebugPanel() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return FloatingLoggerModalBottomWidget(
          widgetItemBuilder: widget.widgetItemBuilder,
          isSimulationActive: widget.isSimulationActive,
        );
      },
    );
  }
}
