import 'widgets.dart';
import '../utils/utils.dart';
import 'package:flutter/services.dart';
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

  static const _empty = SizedBox.shrink();

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
            onLongPress: () => copyCurlToClipboard(context),
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
  void copyCurlToClipboard(BuildContext context) {
    if (widget.data.curl!.isEmpty) {
      LoggerToast.errorToast(
        "Failed to copy, no data available",
        context: context,
      );
    } else {
      Clipboard.setData(ClipboardData(text: widget.data.curl!)).then((_) {
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
          color: Color.fromARGB(34, 0, 0, 0),
          blurRadius: 4,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(
        width: 2.0,
        color: _getStatusColor(
          isBorder: true,
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
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
            child: isExpanded ? _empty : _buildExpandedDetails(),
          ),
        ],
      ),
    );
  }

  /// Builds the log header with type, status, and path.
  Widget _buildLogHeader(bool isExpanded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogType(),
              const SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.data.path ?? "",
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.arrow_drop_down_sharp
                        : Icons.arrow_drop_up_sharp,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the log type with response status indicator.
  Widget _buildLogType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            widget.data.method == null ? _empty : _buildMethod(),
            widget.data.type == null ? _empty : _buildRequest(),
          ],
        ),
        widget.data.type == "REQUEST" ? _empty : _buildStatusIndicator(),
      ],
    );
  }

  /// Builds the status indicator based on the log response.
  Widget _buildStatusIndicator() {
    Color statusColor = _getStatusColor();
    String statusText = _getStatusText();

    return _labelStatus(
      statusColor,
      '${widget.data.response} $statusText',
    );
  }

  /// Builds the Method indicator based on the log response.
  Widget _buildMethod() {
    Color statusColor = _getMethodColor();

    return _labelStatus(
      statusColor,
      widget.data.method!,
    );
  }

  /// Builds the Method indicator based on the log response.
  Widget _buildRequest() {
    Color statusColor = _getRequestColor();

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: _labelStatus(
        statusColor,
        widget.data.type!,
      ),
    );
  }

  Widget _labelStatus(
    Color statusColor,
    String statusText,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Text(
          statusText,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Builds expanded details when the log is expanded.
  Widget _buildExpandedDetails() {
    var param = widget.data.queryparameter;
    var message = widget.data.message;
    var header = widget.data.header;
    var curl = widget.data.curl;
    return Column(
      children: [
        Divider(
          thickness: 2,
          color: _getStatusColor(
            isBorder: true,
          ),
        ),
        message == null || message.isEmpty
            ? _empty
            : _codeFieldCopy(
                'Message',
                message,
              ),
        param == null
            ? _empty
            : _codeFieldCopy(
                'Param',
                param,
              ),
        widget.data.data == "null"
            ? _empty
            : _codeFieldCopy(
                'Data',
                widget.data.type == "REQUEST"
                    ? ((widget.data.data ?? ""))
                    : (widget.data.responseData ?? "")),
        header == null
            ? _empty
            : _codeFieldCopy(
                'Header',
                header,
              ),
        curl == null ? _empty : _codeFieldCopy('cURL', curl),
      ],
    );
  }

  Widget _codeFieldCopy(
    String title,
    String data,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: data)).then((_) {
                        LoggerToast.successToast(
                          "Successfully copied $title",
                          // ignore: use_build_context_synchronously
                          context: context,
                        );
                      });
                    },
                    child: Icon(
                      Icons.copy,
                      size: 15,
                    ),
                  ),
                ],
              ),
              Text(
                data,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Determines the color of the status indicator.
  Color _getStatusColor({
    bool isBorder = false,
  }) {
    switch (widget.data.type) {
      case 'RESPONSE':
        return Colors.green;
      case 'ERROR':
        return Colors.red;
      case 'REQUEST':
        return isBorder ? Color(0xffECECEC) : Color(0xffFFB700);
      default:
        return LoggerNetworkSettings.isSucces(widget.data)
            ? Colors.green
            : LoggerNetworkSettings.isError(widget.data)
                ? Colors.red
                : Color(0xffFFB700);
    }
  }

  /// Determines the color of the Request indicator.
  Color _getRequestColor() {
    switch (widget.data.type) {
      case 'RESPONSE':
        return Colors.blue[400]!;
      case 'ERROR':
        return Colors.red[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  /// Determines the color of the Request indicator.

  Color _getMethodColor() {
    switch (widget.data.method) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Color(0xffFFB700);
      case 'PUT':
        return Colors.blue;
      case 'PATCH':
        return Colors.purpleAccent;
      case 'OPTIONS':
        return Colors.purple;
      case 'HEAD':
        return Colors.greenAccent;
      default:
        return Colors.red;
    }
  }

  /// Determines the text of the status indicator.
  String _getStatusText() {
    if (widget.data.type == 'RESPONSE' ||
        LoggerNetworkSettings.isSucces(widget.data)) {
      return "SUCCESS";
    } else if (widget.data.type == 'ERROR' ||
        LoggerNetworkSettings.isError(widget.data)) {
      return "ERROR";
    } else {
      return "UNKNOWN";
    }
  }
}
