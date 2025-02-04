import 'package:floating_logger/floating_logger.dart';

class FloatingLoggerStyle {
  const FloatingLoggerStyle({
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.size,
  });

  final Widget? icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Size? size;
}
