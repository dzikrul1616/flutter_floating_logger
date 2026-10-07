import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/utils_theme.dart';

class FloatinLoggerJsonViewer extends StatefulWidget {
  final dynamic jsonObj;
  final bool initialExpanded;
  final String searchQuery;

  const FloatinLoggerJsonViewer(
    this.jsonObj, {
    super.key,
    this.initialExpanded = true,
    this.searchQuery = "",
  });

  @override
  State<FloatinLoggerJsonViewer> createState() =>
      _FloatinLoggerJsonViewerState();
}

class _FloatinLoggerJsonViewerState extends State<FloatinLoggerJsonViewer> {
  @override
  Widget build(BuildContext context) {
    final colors = FloatingLoggerTheme.of(context);
    return _buildJsonWidget(widget.jsonObj, colors);
  }

  Widget _buildJsonWidget(dynamic content, FloatingLoggerColors colors) {
    if (content is Map) {
      if (content.isEmpty) {
        return Text(
          '{}',
          style: TextStyle(
            color: colors.jsonBraces,
            fontSize: 12,
            fontFamily: 'Inter',
            package: 'floating_logger',
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '{',
            style: TextStyle(
              color: colors.jsonBraces,
              fontSize: 12,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: _buildJsonChildren(content, colors),
          ),
          Text(
            '},',
            style: TextStyle(
              color: colors.jsonBraces,
              fontSize: 12,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
        ],
      );
    } else if (content is List) {
      if (content.isEmpty) {
        return Text(
          '[],',
          style: TextStyle(
            color: colors.jsonBraces,
            fontSize: 12,
            fontFamily: 'Inter',
            package: 'floating_logger',
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[',
            style: TextStyle(
              color: colors.jsonBraces,
              fontSize: 12,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: _buildJsonChildren(content, colors),
          ),
          Text(
            '],',
            style: TextStyle(
              color: colors.jsonBraces,
              fontSize: 12,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
        ],
      );
    } else {
      return _buildPrimitive(content, colors);
    }
  }

  Widget _buildJsonChildren(dynamic content, FloatingLoggerColors colors) {
    if (content is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.entries.map((entry) {
          final isComplex = entry.value is Map || entry.value is List;

          if (isComplex) {
            final isEmpty = (entry.value is Map && entry.value.isEmpty) ||
                (entry.value is List && entry.value.isEmpty);
            if (isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      _buildHighlightSpan(
                        '"${entry.key}": ',
                        TextStyle(
                          color: colors.jsonKey,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                      TextSpan(
                        text: entry.value is List ? '[],' : '{},',
                        style: TextStyle(
                          color: colors.jsonBraces,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final openBrace = entry.value is List ? '[' : '{';
            final closeBrace = entry.value is List ? '],' : '},';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      _buildHighlightSpan(
                        '"${entry.key}": ',
                        TextStyle(
                          color: colors.jsonKey,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                      TextSpan(
                        text: openBrace,
                        style: TextStyle(
                          color: colors.jsonBraces,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: _buildJsonChildren(entry.value, colors),
                ),
                Text(
                  closeBrace,
                  style: TextStyle(
                    color: colors.jsonBraces,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    package: 'floating_logger',
                  ),
                ),
              ],
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    _buildHighlightSpan(
                      '"${entry.key}": ',
                      TextStyle(
                        color: colors.jsonKey,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        package: 'floating_logger',
                      ),
                    ),
                    _buildPrimitiveSpan(entry.value, colors),
                  ],
                ),
              ),
            );
          }
        }).toList(),
      );
    } else if (content is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.asMap().entries.map((entry) {
          return _CollapsibleJsonItem(
            index: entry.key,
            content: entry.value,
            isLast: entry.key == content.length - 1,
            searchQuery: widget.searchQuery,
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPrimitive(dynamic content, FloatingLoggerColors colors) {
    return Text.rich(_buildPrimitiveSpan(content, colors));
  }

  Color _getPrimitiveColor(dynamic content, FloatingLoggerColors colors) {
    if (content == null) return colors.jsonNull;
    if (content is String) return colors.jsonString;
    if (content is num) return colors.jsonNumber;
    if (content is bool) return colors.jsonBool;
    return colors.textPrimary;
  }

  TextSpan _buildPrimitiveSpan(dynamic content, FloatingLoggerColors colors) {
    String text = content is String ? '"$content",' : '$content,';
    final contentColor = _getPrimitiveColor(content, colors);

    return _buildHighlightSpan(
      text,
      TextStyle(
        color: contentColor,
        fontSize: 12,
        fontFamily: 'Inter',
      ),
    );
  }

  TextSpan _buildHighlightSpan(String text, TextStyle baseStyle) {
    if (widget.searchQuery.trim().isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final query = widget.searchQuery.trim().toLowerCase();
    final lowerText = text.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    int index = lowerText.indexOf(query);

    if (index == -1) {
      return TextSpan(text: text, style: baseStyle);
    }

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: baseStyle.copyWith(
          color: Colors.white,
          backgroundColor: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
      index = lowerText.indexOf(query, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}

class _CollapsibleJsonItem extends StatefulWidget {
  final int index;
  final dynamic content;
  final bool isLast;
  final String searchQuery;

  const _CollapsibleJsonItem({
    required this.index,
    required this.content,
    required this.isLast,
    this.searchQuery = "",
  });

  @override
  State<_CollapsibleJsonItem> createState() => _CollapsibleJsonItemState();
}

class _CollapsibleJsonItemState extends State<_CollapsibleJsonItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.searchQuery.isNotEmpty
        ? _containsSearch(widget.searchQuery)
        : true;
  }

  @override
  void didUpdateWidget(_CollapsibleJsonItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery.isNotEmpty) {
      if (_containsSearch(widget.searchQuery)) {
        _isExpanded = true;
      }
    }
  }

  bool _containsSearch(String query) {
    final q = query.toLowerCase();
    try {
      final contentStr = jsonEncode(widget.content).toLowerCase();
      return contentStr.contains(q);
    } catch (_) {
      return widget.content.toString().toLowerCase().contains(q);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FloatingLoggerTheme.of(context);

    if (widget.content is! Map && widget.content is! List) {
      String text = widget.content is String
          ? '"${widget.content}",'
          : '${widget.content},';
      final contentColor = widget.content is String
          ? colors.jsonString
          : widget.content is num
              ? colors.jsonNumber
              : widget.content is bool
                  ? colors.jsonBool
                  : colors.textPrimary;

      if (widget.searchQuery.isEmpty) {
        return Text(
          text,
          style: TextStyle(
            color: contentColor,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        );
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
            style: TextStyle(
              color: contentColor,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ));
        }
        spans.add(TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            color: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ));
        start = index + query.length;
        index = lowerText.indexOf(query, start);
      }

      if (start < text.length) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: contentColor,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ));
      }

      return Text.rich(TextSpan(children: spans));
    }

    return AnimatedCrossFade(
      firstChild: InkWell(
        onTap: () => setState(() => _isExpanded = true),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '> {${widget.index}},',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
      secondChild: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = false),
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: FloatinLoggerJsonViewer(
              widget.content,
              initialExpanded: true,
              searchQuery: widget.searchQuery,
            ),
          ),
        ],
      ),
      crossFadeState:
          _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      sizeCurve: Curves.easeInOut,
    );
  }
}
