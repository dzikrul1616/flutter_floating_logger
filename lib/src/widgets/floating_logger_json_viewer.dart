import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return _buildJsonWidget(widget.jsonObj);
  }

  Widget _buildJsonWidget(dynamic content) {
    if (content is Map) {
      if (content.isEmpty) return const Text('{}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('{'),
          Padding(
            padding: const EdgeInsets.only(left: 10.0), // Reduced spacing
            child: _buildJsonChildren(content),
          ),
          const Text('},'),
        ],
      );
    } else if (content is List) {
      if (content.isEmpty) return const Text('[],');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('['),
          Padding(
            padding: const EdgeInsets.only(left: 10.0), // Reduced spacing
            child: _buildJsonChildren(content),
          ),
          const Text('],'),
        ],
      );
    } else {
      return _buildPrimitive(content);
    }
  }

  Widget _buildJsonChildren(dynamic content) {
    if (content is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.entries.map((entry) {
          final isComplex = entry.value is Map || entry.value is List;

          if (isComplex) {
            final isEmpty = (entry.value is Map && entry.value.isEmpty) ||
                (entry.value is List && entry.value.isEmpty);
            if (isEmpty) {
              return Text(
                  '"${entry.key}": ${entry.value is List ? '[]' : '{}'},',
                  style: GoogleFonts.inter(
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ));
            }

            final openBrace = entry.value is List ? '[' : '{';
            final closeBrace = entry.value is List ? '],' : '},';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${entry.key}": $openBrace',
                  style: GoogleFonts.inter(
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0), // Reduced spacing
                  child: _buildJsonChildren(entry.value),
                ),
                Text(
                  closeBrace,
                  style: GoogleFonts.inter(
                    color: Colors.black, // Default color for braces
                    fontSize: 12,
                  ),
                ),
              ],
            );
          } else {
            // Primitive value using RichText for perfect flow
            return Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '"${entry.key}": ',
                      style: GoogleFonts.inter(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    _buildPrimitiveSpan(entry.value),
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

  Widget _buildPrimitive(dynamic content) {
    return Text.rich(_buildPrimitiveSpan(content));
  }

  TextSpan _buildPrimitiveSpan(dynamic content) {
    String text = content is String ? '"$content",' : '$content,';
    if (widget.searchQuery.isEmpty) {
      return TextSpan(
        text: text,
        style: GoogleFonts.inter(
          color: content is String ? Colors.green : Colors.blue,
          fontSize: 12,
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
          style: GoogleFonts.inter(
            color: content is String ? Colors.green : Colors.blue,
            fontSize: 12,
          ),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: GoogleFonts.inter(
          color: Colors.white,
          backgroundColor: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
      index = lowerText.indexOf(query, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: GoogleFonts.inter(
          color: content is String ? Colors.green : Colors.blue,
          fontSize: 12,
        ),
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
    final contentStr = jsonEncode(widget.content).toLowerCase();
    return contentStr.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content is! Map && widget.content is! List) {
      String text = widget.content is String
          ? '"${widget.content}",'
          : '${widget.content},';

      if (widget.searchQuery.isEmpty) {
        return Text(
          text,
          style: GoogleFonts.inter(
            color: widget.content is String ? Colors.green : Colors.blue,
            fontSize: 12,
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
            style: GoogleFonts.inter(
              color: widget.content is String ? Colors.green : Colors.blue,
              fontSize: 12,
            ),
          ));
        }
        spans.add(TextSpan(
          text: text.substring(index, index + query.length),
          style: GoogleFonts.inter(
            color: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ));
        start = index + query.length;
        index = lowerText.indexOf(query, start);
      }

      if (start < text.length) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: GoogleFonts.inter(
            color: widget.content is String ? Colors.green : Colors.blue,
            fontSize: 12,
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
            style: GoogleFonts.inter(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
      secondChild: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = false),
            child: const Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Colors.grey,
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
