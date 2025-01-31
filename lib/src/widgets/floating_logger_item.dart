import 'widgets.dart';
import '../utils/utils.dart';
import 'package:floating_logger/src/network/network_model.dart';

/// A widget representing a single log item inside the floating logger.
class FloatingLoggerItem extends StatefulWidget {
  /// Constructor for FloatingLoggerItem.
  const FloatingLoggerItem({
    super.key,
    required this.data,
    required this.index,
    this.child,
  });

  /// The log data to display.
  final LogRepositoryModel data;

  /// The index of the log in the list.
  final int index;

  /// An optional child widget to override default UI.
  final Widget? child;

  @override
  State<FloatingLoggerItem> createState() => _FloatingLoggerItemState();
}

class _FloatingLoggerItemState extends State<FloatingLoggerItem>
    with TickerProviderStateMixin {
  late AnimationController _expandAnimationController;

  // ValueNotifier to track expansion state of log item
  ValueNotifier<bool> isExpand = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _expandAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _expandAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If a child widget is provided, use it instead of default UI
    if (widget.child != null) {
      return widget.child!;
    }

    return ValueListenableBuilder(
        valueListenable: isExpand,
        builder: (context, value, child) {
          return GestureDetector(
            onLongPress: () => _copyCurlToClipboard(context),
            onTap: () {
              isExpand.value = !value;
              if (value) {
                _expandAnimationController.reverse(); // Collapse
              } else {
                _expandAnimationController.forward(); // Expand
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: _buildLogContainer(context, value),
            ),
          );
        });
  }

  /// Copies the cURL command to clipboard and shows a toast message.
  void _copyCurlToClipboard(BuildContext context) {
    if (widget.data.curl!.isEmpty) {
      LoggerToast.errorToast(
        "Failed to copy, no data available",
        context: context,
      );
    } else {
      FlutterClipboard.copy(widget.data.curl!).then((value) {
        LoggerToast.successToast(
          "Successfully copied cURL data",
          // ignore: use_build_context_synchronously
          context: context,
        );
      });
    }
  }

  /// Builds the log container with styling and expandable details.
  Widget _buildLogContainer(BuildContext context, bool isExpanded) {
    return Container(
      decoration: _boxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIndex(),
            const SizedBox(width: 5.0),
            _buildLogDetails(isExpanded),
          ],
        ),
      ),
    );
  }

  /// Returns the BoxDecoration for styling the log container.
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      boxShadow: const <BoxShadow>[
        BoxShadow(
            color: Color(0xffeaeaea), blurRadius: 4, offset: Offset(0, 4)),
        BoxShadow(
            color: Color(0xffeaeaea), blurRadius: 4, offset: Offset(-4, 0)),
      ],
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey[300],
    );
  }

  /// Builds the log index number.
  Widget _buildIndex() {
    return SizedBox(
      width: 20,
      child: Text(
        '${widget.index + 1}. ',
        style: GoogleFonts.inter(),
      ),
    );
  }

  /// Builds the log details including type, path, and status.
  Widget _buildLogDetails(bool isExpanded) {
    return Expanded(
      child: Column(
        children: [
          _buildLogHeader(isExpanded),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                isExpanded ? const SizedBox.shrink() : _buildExpandedDetails(),
          ),
        ],
      ),
    );
  }

  /// Builds the log header with type, status, and path.
  Widget _buildLogHeader(bool isExpanded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogType(),
              const SizedBox(height: 5.0),
              Text(
                widget.data.path!,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Icon(
          isExpanded ? Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp,
          color: Colors.grey[700],
        ),
      ],
    );
  }

  /// Builds the log type with response status indicator.
  Widget _buildLogType() {
    return Row(
      children: [
        Text('[${widget.data.type}]',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        Text(
          widget.data.response!.isEmpty ? '' : '[${widget.data.response}]',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        widget.data.type == "Request"
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _buildStatusIndicator(),
              ),
      ],
    );
  }

  /// Builds the status indicator based on the log response.
  Widget _buildStatusIndicator() {
    Color statusColor = _getStatusColor();
    String statusText = _getStatusText();

    return Container(
      decoration: BoxDecoration(
          color: statusColor, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          statusText,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  /// Determines the color of the status indicator.
  Color _getStatusColor() {
    if (widget.data.type == 'Response' ||
        LoggerNetworkSettings.isSucces(widget.data)) {
      return Colors.green;
    } else if (widget.data.type == 'Error' ||
        LoggerNetworkSettings.isError(widget.data)) {
      return Colors.red;
    } else {
      return Colors.yellow;
    }
  }

  /// Determines the text of the status indicator.
  String _getStatusText() {
    if (widget.data.type == 'Response' ||
        LoggerNetworkSettings.isSucces(widget.data)) {
      return "Success";
    } else if (widget.data.type == 'Error' ||
        LoggerNetworkSettings.isError(widget.data)) {
      return "Error";
    } else {
      return "Unknown";
    }
  }

  /// Builds expanded details when the log is expanded.
  Widget _buildExpandedDetails() {
    return Column(
      children: [
        const Divider(thickness: 1, color: Colors.white),
        widget.data.type == "Request"
            ? const SizedBox.shrink()
            : FloatingLoggerRowText(
                title: 'Message', data: widget.data.message ?? ""),
        FloatingLoggerRowText(
          title: 'Param',
          data: widget.data.queryparameter ?? "",
        ),
        widget.data.data == "null"
            ? const SizedBox.shrink()
            : FloatingLoggerRowText(
                title: 'Data',
                data: widget.data.type == "Request"
                    ? ((widget.data.data ?? ""))
                    : (widget.data.responseData ?? ""),
              ),
        FloatingLoggerRowText(
          title: 'Header',
          data: widget.data.header ?? "",
        ),
        FloatingLoggerRowText(
          title: 'cURL',
          data: widget.data.curl ?? "",
        ),
      ],
    );
  }
}
