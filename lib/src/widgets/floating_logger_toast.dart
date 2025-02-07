import 'package:floating_logger/floating_logger.dart';

/// LoggerToast class provides methods for displaying custom toast messages
/// with animations. It includes functionality for showing success and error
/// toasts with configurable message duration, position, color, and icon.
///
/// The class uses a slide-in animation to display the toast from either the
/// top or bottom of the screen, and it removes the toast automatically after
/// the specified duration. This class relies on OverlayEntry and AnimationController
/// to handle the visual representation and animation of the toast.
class LoggerToast {
  // List to keep track of active toasts to prevent overlapping
  static final List<OverlayEntry> _activeToasts = [];

  // Method to show a success toast with a green color and a check icon
  static void successToast(
    BuildContext context,
    String message, {
    Duration duration =
        const Duration(seconds: 2), // Default duration is 2 seconds
    ToastPosition position = ToastPosition.top, // Default position is top
  }) {
    _showToast(context, message, position, Colors.green, Icons.check, duration);
  }

  // Method to show an error toast with a red color and an error icon
  static void errorToast(
    BuildContext context,
    String message, {
    Duration duration =
        const Duration(seconds: 2), // Default duration is 2 seconds
    ToastPosition position = ToastPosition.center, // Default position is center
  }) {
    _showToast(context, message, position, Colors.red, Icons.error, duration);
  }

  // Private method that handles displaying the toast
  static void _showToast(
    BuildContext context,
    String message,
    ToastPosition position,
    Color color,
    IconData icon,
    Duration duration,
  ) {
    final overlay = Overlay.of(context); // Get the overlay of the context
    final overlayEntry = _createOverlayEntry(
      // Create a new overlay entry
      context,
      message,
      position,
      color,
      icon,
      duration,
    );

    // Insert the overlay entry into the overlay
    overlay.insert(overlayEntry);
    _activeToasts.add(overlayEntry); // Add the overlay entry to active toasts
  }

  // Create an OverlayEntry for the toast with animation
  static OverlayEntry _createOverlayEntry(
    BuildContext context,
    String message,
    ToastPosition position,
    Color color,
    IconData icon,
    Duration duration,
  ) {
    Overlay.of(context);
    final animationController = AnimationController(
      duration: Duration(milliseconds: 300), // Duration of the animation
      vsync: Navigator.of(context), // Sync with the navigator
    );

    // Animation to slide the toast in from the top
    final animation = Tween<Offset>(
      begin: Offset(0, -1), // Start position (off-screen)
      end: Offset.zero, // End position (on-screen)
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack, // Ease-in animation curve
    ));

    // Overlay entry with the toast's widget and animation
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            alignment: _getAlignment(
                position), // Position the toast based on the alignment
            children: [
              // Slide transition for the toast animation
              SlideTransition(
                position: animation,
                child: Material(
                  color: Colors.transparent, // Make the background transparent
                  child: IntrinsicWidth(
                    // Adjust the width based on content
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 30), // Padding from the top
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: color, // Set the background color
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: Offset(0, 4), // Shadow offset
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Adjust width based on content
                          children: [
                            Icon(icon, color: Colors.white), // Icon
                            SizedBox(width: 8), // Space between icon and text
                            Flexible(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: Colors.white, // Set text color
                                  fontSize: 16, // Set font size
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Start the animation
    animationController.forward();

    // Remove the toast after the specified duration
    Future.delayed(duration, () async {
      await animationController.reverse(); // Reverse the animation
      overlayEntry.remove(); // Remove the toast from the overlay
      _activeToasts.remove(overlayEntry); // Remove from active toasts list
      animationController.dispose(); // Dispose of the animation controller
    });

    return overlayEntry;
  }

  // Method to get the alignment of the toast based on the position
  static Alignment _getAlignment(ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
        return Alignment.topCenter; // Align the toast at the top center
      case ToastPosition.bottom:
        return Alignment.bottomCenter; // Align the toast at the bottom center
      default:
        return Alignment.center; // Default is to center the toast
    }
  }
}

// Enum to define the positions of the toast
enum ToastPosition { top, center, bottom }
