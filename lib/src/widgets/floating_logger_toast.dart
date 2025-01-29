import 'package:floating_logger/floating_logger.dart';

class LoggerToast {
  final BuildContext context;

  LoggerToast.of(this.context); // Constructor to initialize with context

  // Static method to show a success toast with custom parameters
  static void successToast(
    String message, {
    required BuildContext context, // Required context for showing the toast
    animation =
        StyledToastAnimation.slideFromTop, // Default animation: slide from top
    reverseAnimation =
        StyledToastAnimation.fade, // Default reverse animation: fade
    Duration animDuration =
        const Duration(milliseconds: 200), // Animation duration
    StyledToastPosition position =
        StyledToastPosition.top, // Position of the toast on the screen
    Duration duration =
        const Duration(seconds: 2), // How long the toast will be visible
  }) async {
    showToastWidget(
      Container(
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width *
              0.1, // Margin on the left and right (10% of screen width)
        ),
        padding: const EdgeInsets.all(10), // Padding inside the toast
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(10), // Rounded corners for the toast
          color: Colors.green, // Green color for success message
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Ensure the row takes up minimal space
          children: [
            const Icon(
              Icons.check_circle_outline_rounded, // Success icon (check circle)
              color: Colors.white, // White color for the icon
            ),
            const SizedBox(
              width: 8, // Space between icon and text
            ),
            Flexible(
              child: Text(
                message, // The success message to be displayed
                style: GoogleFonts.roboto(
                  fontSize: 12, // Font size of the message
                  fontWeight: FontWeight.w600, // Bold font weight for emphasis
                  color: Colors.white, // White color for the message text
                ),
              ),
            ),
          ],
        ),
      ),
      context: context, // The context to show the toast
      duration: duration, // The duration for which the toast will be visible
      position: position, // Position of the toast on the screen
      animation: animation, // Animation type for the toast
      animDuration: animDuration, // Animation duration
      reverseAnimation:
          reverseAnimation, // Reverse animation after the toast disappears
    );
  }

  // Static method to show an error toast with custom parameters
  static void errorToast(
    String message, {
    required BuildContext context, // Required context for showing the toast
    animation = StyledToastAnimation.fade, // Default animation: fade
    reverseAnimation =
        StyledToastAnimation.fade, // Default reverse animation: fade
    Duration animDuration =
        const Duration(milliseconds: 200), // Animation duration
    StyledToastPosition position =
        StyledToastPosition.top, // Position of the toast on the screen
    Duration duration =
        const Duration(seconds: 2), // How long the toast will be visible
  }) async {
    // Clean up the error message by removing specific patterns
    String cleanedMessage = message
        .replaceAll('Exception:', '') // Remove 'Exception:' text
        .replaceAll(
            'Expetion: Exception:', '') // Remove redundant 'Expetion' text
        .trim(); // Trim any leading/trailing whitespace

    showToastWidget(
      Container(
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width *
              0.1, // Margin on the left and right (10% of screen width)
        ),
        padding: const EdgeInsets.all(10), // Padding inside the toast
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(10), // Rounded corners for the toast
          color: Colors.red, // Red color for error message
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Ensure the row takes up minimal space
          children: [
            const Icon(
              Icons.cancel_outlined, // Error icon (cancel)
              color: Colors.white, // White color for the icon
            ),
            const SizedBox(
              width: 8, // Space between icon and text
            ),
            Flexible(
              child: Text(
                cleanedMessage, // The cleaned error message to be displayed
                style: GoogleFonts.roboto(
                  fontSize: 12, // Font size of the message
                  fontWeight: FontWeight.w600, // Bold font weight for emphasis
                  color: Colors.white, // White color for the message text
                ),
              ),
            ),
          ],
        ),
      ),
      context: context, // The context to show the toast
      duration: duration, // The duration for which the toast will be visible
      position: position, // Position of the toast on the screen
      animation: animation, // Animation type for the toast
      animDuration: animDuration, // Animation duration
      reverseAnimation:
          reverseAnimation, // Reverse animation after the toast disappears
    );
  }

  // Instance methods for showing success/error toasts using the current context
  // These methods are shorthand for calling the static methods with the context already set
  void $howSuccessToast(String message) =>
      successToast(message, context: context);
  void $howErrorToast(String message) => errorToast(message, context: context);
}
