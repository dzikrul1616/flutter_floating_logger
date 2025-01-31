library;

/// Change color debug console from default to styling text, you can using [AnsiColor].
/// for example ansi color provide inside string with [AnsiColor.green] and last text [AnsiColor.reset] for bring
/// back default color debug console.
///
/// Example :
///   ```dart
///     SetFailure.failureCommand('${AnsiColor.green}module${AnsiColor.reset}');
///   ```
///
/// Ansi for formating text can use [AnsiColor.reset],[AnsiColor.bold], [AnsiColor.underscore].
///
/// Example :
///   ```dart
///     SetFailure.failureCommand('${AnsiColor.bold}${AnsiColor.green}module
///       ${AnsiColor.reset}'
///     );
///   ```
///
/// give bg ahead for background color. [AnsiColor.bGblack], [AnsiColor.bGgreen].
///
/// Example :
///   ```dart
///     SetFailure.failureCommand('${AnsiColor.bold}${AnsiColor.bGblack}module
///       ${AnsiColor.reset}'
///     );
///   ```
///
class AnsiColor {
  // FORMAT
  /// `Reset` color, format, and background color to default color
  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';
  static const underscore = "\x1B[4m";

  // COLOR TEXT
  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const blue = '\x1B[34m';
  static const cyan = '\x1B[36m';
  static const magenta = "\x1B[35m";
  static const white = "\x1bB37m";

  // BACKGORUND COLOR TEXT
  static const bGblack = "\x1B[40m";
  static const bGred = "\x1B[41m";
  static const bGgreen = "\x1B[42m";
  static const bGyellow = "\x1B[43m";
  static const bGblue = "\x1B[44m";
  static const bGmagenta = "\x1B[45m";
  static const bGcyan = "\x1B[46m";
  static const bGwhite = "\x1B[47m";
}
