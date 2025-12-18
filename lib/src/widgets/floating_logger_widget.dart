import 'widgets.dart';
import 'package:floating_logger/floating_logger.dart';
import 'package:floating_logger/src/network/network.dart';

/// A widget that provides a floating logger control button.
/// This button allows debugging API logs and can be dragged around the screen.
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

  @override
  State<FloatingLoggerControl> createState() => _FloatingLoggerControlState();
}

class _FloatingLoggerControlState extends State<FloatingLoggerControl> {
  /// Stores the visibility state of the floating button.
  bool? isShow = true;

  /// Stores the current position of the floating button.
  Offset position = const Offset(10, 100);

  /// Retrieves the stored visibility preference.
  Future<void> _getShowPreference() async {
    try {
      bool data = true; // Default value if getPreference is null
      if (widget.getPreference != null) {
        // Add 5 second timeout to prevent hanging
        data = await widget.getPreference!().timeout(
          const Duration(seconds: 5),
          onTimeout: () => true,
        );
      }
      if (mounted) {
        setState(() {
          isShow = data;
          DioLogger.shouldLogNotifier.value = data;
        });
      }
    } catch (e) {
      // Fallback to default value on error
      if (mounted) {
        setState(() {
          isShow = true;
          DioLogger.shouldLogNotifier.value = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Configure max log size
    DioLogger.instance.logs.maxLogSize = widget.maxLogSize;
    _getShowPreference();
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showWidget = widget.isShow?.value ?? isShow!;
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          widget.child,
          if (showWidget)
            Positioned(
              left: position.dx.clamp(0, constraints.maxWidth - 56),
              top: position.dy.clamp(0, constraints.maxHeight - 56),
              child: Draggable(
                feedback: _buildFloatingActionButton(widget.style),
                childWhenDragging: const SizedBox.shrink(),
                onDragEnd: (details) {
                  setState(() {
                    double newX = details.offset.dx -
                        (MediaQuery.of(context).size.width -
                                constraints.maxWidth) /
                            2;
                    double newY = details.offset.dy -
                        (MediaQuery.of(context).size.height -
                                constraints.maxHeight) /
                            2;

                    position = Offset(
                      newX.clamp(0, constraints.maxWidth - 56),
                      newY.clamp(0, constraints.maxHeight - 56),
                    );
                  });
                },
                child: _buildFloatingActionButton(widget.style),
              ),
            ),
        ],
      );
    });
  }

  /// Builds the floating action button for opening the debug panel.
  Widget _buildFloatingActionButton(
    FloatingLoggerStyle? style,
  ) {
    return SizedBox(
      width: style?.size == null ? 50 : style!.size?.width,
      height: style?.size == null ? 50 : style!.size?.height,
      child: FloatingActionButton(
        heroTag: "floating_logger",
        tooltip: style?.tooltip == null ? "Debug API" : style!.tooltip,
        backgroundColor: style?.backgroundColor == null
            ? const Color.fromARGB(255, 77, 159, 226)
            : style!.backgroundColor,
        onPressed: _showDebugPanel,
        child: style?.icon == null
            ? const Icon(
                Icons.code_rounded,
                color: Colors.white,
              )
            : style!.icon,
      ),
    );
  }

  /// Opens the debug panel in a bottom sheet.
  void _showDebugPanel() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
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
