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
  late ValueNotifier<bool> isExpand;
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _empty = SizedBox.shrink();

  @override
  void initState() {
    final bool shouldExpand = widget.initialExpanded ||
        (widget.isActive && widget.searchQuery.isNotEmpty);
    isExpand = ValueNotifier(shouldExpand);
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (isExpand.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FloatingLoggerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive ||
        widget.searchQuery != oldWidget.searchQuery) {
      if (widget.isActive && widget.searchQuery.isNotEmpty) {
        if (!isExpand.value) {
          isExpand.value = true;
          _controller.value = 1.0;
        }
      } else if (!widget.isActive && oldWidget.isActive && widget.searchQuery.isNotEmpty) {
        if (isExpand.value) {
          isExpand.value = false;
          _controller.value = 0.0;
        }
      }
    }
  }

  @override
  void dispose() {
    isExpand.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child!;
    }

    final colors = FloatingLoggerTheme.of(context);

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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.isActive
                    ? Colors.orange.withOpacity(0.15)
                    : Colors.transparent,
              ),
              child: _buildLogContainer(context, value, colors),
            ),
          ),
        );
      },
    );
  }

  /// Copies the cURL command to clipboard and shows a toast message.
  void copyCurlToClipboard(BuildContext context) {
    if (widget.data.curl == null || widget.data.curl!.isEmpty) {
      LoggerToast.errorToast(
        context,
        "Failed to copy, no cURL data available",
      );
    } else {
      Clipboard.setData(ClipboardData(text: widget.data.curl!)).then((_) {
        if (!mounted) return;
        LoggerToast.successToast(
          // ignore: use_build_context_synchronously
          context,
          "cURL copied to clipboard",
        );
      });
    }
  }

  /// Copies response data to clipboard.
  void copyResponseToClipboard(BuildContext context) {
    final response = widget.data.responseData ?? widget.data.data;
    if (response == null || response.isEmpty) {
      LoggerToast.errorToast(
        context,
        "No response data available to copy",
      );
    } else {
      Clipboard.setData(ClipboardData(text: response)).then((_) {
        if (!mounted) return;
        LoggerToast.successToast(
          // ignore: use_build_context_synchronously
          context,
          "Response data copied",
        );
      });
    }
  }

  /// Builds the log container with styling and expandable details.
  Widget _buildLogContainer(
      BuildContext context, bool isExpanded, FloatingLoggerColors colors) {
    return Container(
      decoration: _boxDecoration(colors),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIndex(colors),
            const SizedBox(width: 6.0),
            _buildLogDetails(isExpanded, colors),
          ],
        ),
      ),
    );
  }

  /// Returns the BoxDecoration for styling the log container.
  BoxDecoration _boxDecoration(FloatingLoggerColors colors) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        width: widget.isActive ? 2.5 : 1.0,
        color: widget.isActive
            ? Colors.orange
            : colors.border,
      ),
      borderRadius: BorderRadius.circular(12),
      color: colors.cardBackground,
    );
  }

  /// Builds the log index number.
  Widget _buildIndex(FloatingLoggerColors colors) {
    return SizedBox(
      width: 24,
      child: _highlightSubText(
        '${widget.index + 1}.',
        TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
          package: 'floating_logger',
        ),
      ),
    );
  }

  /// Builds the log details including type, path, and status.
  Widget _buildLogDetails(bool isExpanded, FloatingLoggerColors colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogHeader(isExpanded, colors),
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
                  child: _buildExpandedDetails(colors),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the log header with type, status, and path.
  Widget _buildLogHeader(bool isExpanded, FloatingLoggerColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogType(colors),
        const SizedBox(height: 6.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _highlightSubText(
                widget.data.path ?? "",
                TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: colors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the log type with response status indicator.
  Widget _buildLogType(FloatingLoggerColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.data.method != null) _buildMethod(),
              if (widget.data.type != null) _buildRequest(),
              if (widget.data.isSimulation)
                _labelStatus(
                  const Color(0xFF9333EA),
                  "SIMULATION",
                ),
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
      '${widget.data.response ?? ""} $statusText'.trim(),
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

  /// Builds the Request indicator based on the log response.
  Widget _buildRequest() {
    Color statusColor = _getRequestColor();
    return _labelStatus(
      statusColor,
      widget.data.type!,
    );
  }

  Widget _labelStatus(
    Color statusColor,
    String statusText,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 3,
        ),
        child: Text(
          statusText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 11,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  /// Builds expanded details when the log is expanded.
  Widget _buildExpandedDetails(FloatingLoggerColors colors) {
    var param = widget.data.queryparameter;
    var message = widget.data.message;
    var header = widget.data.header;
    var curl = widget.data.curl;
    var responseTime = widget.data.responseTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Divider(
          thickness: 1,
          color: colors.divider,
        ),
        responseTime == null
            ? _empty
            : _codeFieldCopy(
                'Response Time',
                "$responseTime ms",
                colors,
              ),
        _isDataEmpty(message)
            ? _empty
            : _codeFieldCopy(
                'Message',
                message!,
                colors,
              ),
        _isDataEmpty(param)
            ? _empty
            : _CollapsibleCodeField(
                title: 'Param',
                data: param!,
                searchQuery: widget.searchQuery,
              ),
        widget.data.isBinaryResponse && widget.data.binaryData != null
            ? _buildBinaryPreview(colors)
            : _isDataEmpty(widget.data.type == "REQUEST"
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

  /// Builds binary preview widget (image or PDF indicator)
  Widget _buildBinaryPreview(FloatingLoggerColors colors) {
    final contentType = widget.data.contentType?.toLowerCase() ?? '';
    final binaryData = widget.data.binaryData;

    if (binaryData == null) return _empty;

    if (contentType.startsWith('image/')) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: GestureDetector(
          onTap: () => _showImageDialog(context, binaryData),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colors.codeBackground,
              border: Border.all(color: colors.border),
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
                        'Image Preview',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colors.textPrimary,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                      const Icon(Icons.zoom_in, size: 18, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      binaryData,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              package: 'floating_logger',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${(binaryData.length / 1024).toStringAsFixed(2)} KB',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      package: 'floating_logger',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (contentType.contains('application/pdf')) {
      String fileName = 'PDF Document';
      if (widget.data.path != null && widget.data.path!.isNotEmpty) {
        try {
          final uri = Uri.parse(widget.data.path!);
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            final lastSegment = pathSegments.last;
            if (lastSegment.toLowerCase().endsWith('.pdf')) {
              fileName = lastSegment;
            }
          }
        } catch (_) {}
      }

      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colors.codeBackground,
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Size: ${(binaryData.length / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _empty;
  }

  void _showImageDialog(BuildContext context, Uint8List binaryData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.memory(
                binaryData,
                fit: BoxFit.contain,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeFieldCopy(
    String title,
    String data,
    FloatingLoggerColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colors.codeBackground,
          border: Border.all(color: colors.border),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
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
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: _highlightSubText(
                  data,
                  TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                  ),
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
  Color _getStatusColor() {
    switch (widget.data.type) {
      case 'RESPONSE':
        return const Color(0xFF16A34A);
      case 'ERROR':
        return const Color(0xFFDC2626);
      case 'REQUEST':
        return const Color(0xFFEAB308);
      default:
        return LoggerNetworkSettings.isSucces(widget.data)
            ? const Color(0xFF16A34A)
            : LoggerNetworkSettings.isError(widget.data)
                ? const Color(0xFFDC2626)
                : const Color(0xFFEAB308);
    }
  }

  /// Determines the color of the Request indicator.
  Color _getRequestColor() {
    switch (widget.data.type) {
      case 'RESPONSE':
        return Colors.blue[600]!;
      case 'ERROR':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getMethodColor() {
    switch (widget.data.method) {
      case 'GET':
        return const Color(0xFF16A34A);
      case 'POST':
        return const Color(0xFFEAB308);
      case 'PUT':
        return Colors.blue;
      case 'PATCH':
        return Colors.purpleAccent;
      case 'OPTIONS':
        return Colors.purple;
      case 'HEAD':
        return Colors.teal;
      default:
        return Colors.red;
    }
  }

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
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.searchQuery.isNotEmpty
        ? widget.data.toLowerCase().contains(widget.searchQuery.toLowerCase())
        : true;
  }

  @override
  void didUpdateWidget(_CollapsibleCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery.isNotEmpty) {
      if (widget.data.toLowerCase().contains(widget.searchQuery.toLowerCase())) {
        _isExpanded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FloatingLoggerTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colors.codeBackground,
            border: Border.all(color: colors.border),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colors.textPrimary,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
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
                            color: colors.textSecondary,
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
                          child: Icon(
                            Icons.copy,
                            size: 15,
                            color: colors.textSecondary,
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
                          child: _buildContent(colors),
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

  Widget _buildContent(FloatingLoggerColors colors) {
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: _highlightSubText(
        widget.data,
        TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: colors.textPrimary,
          fontFamily: 'Inter',
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
}
