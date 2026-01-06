import 'dart:async';
import 'dart:convert';
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
    this.searchQuery = "",
    this.isActive = false,
    this.child,
    this.initialExpanded = false,
  });

  /// The log data to display.
  final LogRepositoryModel data;

  /// The index of the log in the list.
  final int index;

  /// The search query for highlighting.
  final String searchQuery;

  /// Whether this item is the currently active search match.
  final bool isActive;

  /// An optional child widget to override default UI.
  final Widget? child;

  /// Whether the item should be initially expanded.
  final bool initialExpanded;

  @override
  State<FloatingLoggerItem> createState() => _FloatingLoggerItemState();
}

class _FloatingLoggerItemState extends State<FloatingLoggerItem>
    with SingleTickerProviderStateMixin {
  // ValueNotifier to track expansion state of log item
  late ValueNotifier<bool> isExpand;
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _expansionTimer;

  static const _empty = SizedBox.shrink();

  @override
  void initState() {
    isExpand = ValueNotifier(widget.initialExpanded);
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (isExpand.value) {
      _controller.value = 1.0;
    }

    // Handle initial active state (e.g., when scrolled into view)
    if (widget.isActive && widget.searchQuery.isNotEmpty) {
      _expansionTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted && widget.isActive) {
          isExpand.value = true;
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(FloatingLoggerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Synchronize expansion with active search match
    if (widget.isActive != oldWidget.isActive ||
        widget.searchQuery != oldWidget.searchQuery) {
      if (widget.isActive && widget.searchQuery.isNotEmpty) {
        if (!isExpand.value) {
          // Delay expansion to allow previous item to collapse and scroll to finish
          _expansionTimer?.cancel();
          _expansionTimer = Timer(const Duration(milliseconds: 300), () {
            if (mounted && widget.isActive) {
              isExpand.value = true;
              _controller.forward();
            }
          });
        }
      } else {
        // If it was active but no longer is, or search cleared, collapse it
        _expansionTimer?.cancel();
        if (isExpand.value) {
          isExpand.value = false;
          _controller.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _expansionTimer?.cancel();
    isExpand.dispose();
    _controller.dispose();
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
              if (isExpand.value) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.isActive
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: _buildLogContainer(context, value),
              ),
            ),
          );
        });
  }

  /// Copies the cURL command to clipboard and shows a toast message.
  void copyCurlToClipboard(BuildContext context) {
    if (widget.data.curl!.isEmpty) {
      LoggerToast.errorToast(
        context,
        "Failed to copy, no data available",
      );
    } else {
      Clipboard.setData(ClipboardData(text: widget.data.curl!)).then((_) {
        if (!mounted) return;
        LoggerToast.successToast(
          // ignore: use_build_context_synchronously
          context,
          "Successfully copied cURL data",
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
        width: widget.isActive ? 3.0 : 2.0,
        color: widget.isActive
            ? Colors.orange
            : _getStatusColor(
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
      child: _highlightSubText(
        '${widget.index + 1}. ',
        GoogleFonts.inter(),
      ),
    );
  }

  /// Builds the log details including type, path, and status.
  Widget _buildLogDetails(bool isExpanded) {
    return Expanded(
      child: Column(
        children: [
          _buildLogHeader(isExpanded),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              if (_animation.isDismissed && !isExpand.value) {
                return const SizedBox.shrink();
              }
              return FadeTransition(
                opacity: _animation,
                child: SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: -1.0,
                  child: _buildExpandedDetails(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the log header with type, status, and path.
  Widget _buildLogHeader(bool isExpanded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogType(),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _highlightSubText(
                widget.data.path ?? "",
                GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
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
    );
  }

  /// Builds the log type with response status indicator.
  Widget _buildLogType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              if (widget.data.method != null) _buildMethod(),
              if (widget.data.type != null) _buildRequest(),
            ],
          ),
        ),
        if (widget.data.type != "REQUEST") _buildStatusIndicator(),
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            statusText,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 12,
            ),
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
    var responseTime = widget.data.responseTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          thickness: 2,
          color: _getStatusColor(
            isBorder: true,
          ),
        ),
        responseTime == null
            ? _empty
            : _codeFieldCopy(
                'Response Time',
                "$responseTime ms",
              ),
        _isDataEmpty(message)
            ? _empty
            : _codeFieldCopy(
                'Message',
                message!,
              ),
        _isDataEmpty(param)
            ? _empty
            : _CollapsibleCodeField(
                title: 'Param',
                data: param!,
                searchQuery: widget.searchQuery,
              ),
        _isDataEmpty(widget.data.type == "REQUEST"
                ? widget.data.data
                : widget.data.responseData)
            ? _empty
            : _CollapsibleCodeField(
                title: 'Data',
                data: widget.data.type == "REQUEST"
                    ? ((widget.data.data ?? ""))
                    : (widget.data.responseData ?? ""),
                searchQuery: widget.searchQuery,
              ),
        _isDataEmpty(header)
            ? _empty
            : _CollapsibleCodeField(
                title: 'Header',
                data: header!,
                searchQuery: widget.searchQuery,
              ),
        _isDataEmpty(curl)
            ? _empty
            : _CollapsibleCodeField(
                title: 'cURL',
                data: curl!,
                searchQuery: widget.searchQuery,
              ),
      ],
    );
  }

  bool _isDataEmpty(String? data) {
    if (data == null || data.isEmpty || data == "null") return true;
    final trimmed = data.trim();
    if (trimmed == "{}" || trimmed == "[]") return true;
    return false;
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
                        if (!mounted) return;
                        LoggerToast.successToast(
                          context,
                          "Successfully copied $title",
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
              _highlightSubText(
                data,
                GoogleFonts.inter(
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

  Widget _highlightSubText(String text, TextStyle style) {
    if (widget.searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final query = widget.searchQuery.toLowerCase();
    final lowerText = text.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    int index = lowerText.indexOf(query);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: Colors.orange,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
      index = lowerText.indexOf(query, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
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

class _CollapsibleCodeField extends StatefulWidget {
  final String title;
  final String data;
  final String searchQuery;

  const _CollapsibleCodeField({
    required this.title,
    required this.data,
    this.searchQuery = "",
  });

  @override
  State<_CollapsibleCodeField> createState() => _CollapsibleCodeFieldState();
}

class _CollapsibleCodeFieldState extends State<_CollapsibleCodeField> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GestureDetector(
        onTap: () {
          // Do nothing to absorb the tap and prevent the main Log Item from toggling.
        },
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
                    Flexible(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Icon(
                            _isExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.data))
                                .then((_) {
                              if (!mounted) return;
                              LoggerToast.successToast(
                                // ignore: use_build_context_synchronously
                                context,
                                "Successfully copied ${widget.title}",
                              );
                            });
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildContent(),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    try {
      if (widget.data.trim().startsWith('{') ||
          widget.data.trim().startsWith('[')) {
        final dynamic jsonObj = jsonDecode(widget.data);
        return FloatinLoggerJsonViewer(
          jsonObj,
          searchQuery: widget.searchQuery,
        );
      }
    } catch (_) {}
    // Fallback to text if not JSON or parsing fails
    return _highlightSubText(
      widget.data,
      GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    );
  }

  Widget _highlightSubText(String text, TextStyle style) {
    if (widget.searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final query = widget.searchQuery.toLowerCase();
    final lowerText = text.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    int index = lowerText.indexOf(query);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: Colors.orange,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
      index = lowerText.indexOf(query, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
    );
  }
}
