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
  });

  /// The main child widget (usually the app content).
  final Widget child;

  /// Controls whether the floating button is shown or hidden.
  final ValueNotifier<bool>? isShow;

  /// Determines if the visibility preference should be retrieved.
  final Future<bool> Function()? getPreference;

  /// Custom widget builder for log items.
  final Widget Function(
    int index,
    List<LogRepositoryModel> data,
  )? widgetItemBuilder;

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
    bool data = true; // Default value if getPreference is null
    if (widget.getPreference != null) {
      data = await widget.getPreference!();
    }
    setState(() {
      isShow = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getShowPreference();
  }

  @override
  Widget build(BuildContext context) {
    bool showWidget = widget.isShow?.value ?? isShow!;
    return Stack(
      children: [
        widget.child,
        if (showWidget)
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              feedback: _buildFloatingActionButton(),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) {
                setState(() {
                  position = details.offset;
                });
              },
              child: _buildFloatingActionButton(),
            ),
          ),
      ],
    );
  }

  /// Builds the floating action button for opening the debug panel.
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      tooltip: "Debug API",
      backgroundColor: const Color.fromARGB(255, 77, 159, 226),
      onPressed: _showDebugPanel,
      child: const Icon(
        Icons.code_rounded,
        color: Colors.white,
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
        );
      },
    );
  }
}
