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
  // Static variable to hold the overlay entry for the toast
  static OverlayEntry? _overlayEntry;

  // Static variable to control the animation of the toast
  static late AnimationController _animationController;

  // Static variable to hold the offset animation (used to slide the toast in/out)
  static late Animation<Offset> _offsetAnimation;

  // Initializes the animation controller and the slide transition for the toast
  static void _initializeAnimation(BuildContext context) {
    _animationController = AnimationController(
      // Duration of the animation (300 milliseconds)
      duration: const Duration(milliseconds: 300),
      // Setting the vsync to the Navigator to sync the animation with the screen's frame rate
      vsync: Navigator.of(context),
    );

    // Defining the animation for the toast's position (slides in from above)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start position (above the screen)
      end: Offset.zero, // End position (original position)
    ).animate(CurvedAnimation(
      // Applying a curved animation for the sliding effect
      parent: _animationController,
      curve: Curves.easeOutBack, // Use ease-out-back for smooth animation
    ));
  }

  // Method to show a success toast with a green color and a check icon
  static void successToast(
    BuildContext context,
    String message, {
    // Default duration of 2 seconds for the toast
    Duration duration = const Duration(seconds: 2),
    // Default position is at the top of the screen
    ToastPosition position = ToastPosition.top,
  }) {
    _showToast(context, message, position, Colors.green, Icons.check, duration);
  }

  // Method to show an error toast with a red color and an error icon
  static void errorToast(
    BuildContext context,
    String message, {
    // Default duration of 2 seconds for the toast
    Duration duration = const Duration(seconds: 2),
    // Default position is at the top of the screen
    ToastPosition position = ToastPosition.top,
  }) {
    _showToast(context, message, position, Colors.red, Icons.error, duration);
  }

  // Private method to show the toast with the given parameters
  static void _showToast(
    BuildContext context,
    String message,
    ToastPosition position,
    Color color,
    IconData icon,
    Duration duration,
  ) {
    // Initialize the animation for the new toast
    _initializeAnimation(context);

    // Create the new overlay entry (toast) with the required message, color, and icon
    _overlayEntry =
        _createOverlayEntry(context, message, position, color, icon);
    // Insert the overlay entry into the screen's overlay
    Overlay.of(context).insert(_overlayEntry!);
    // Start the animation to show the toast
    _animationController.forward();

    // Automatically remove the toast after the specified duration
    Future.delayed(duration, () {
      // Reverse the animation (toast slides out)
      _animationController.reverse().then((_) {
        // Remove the overlay entry after animation is complete
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    });
  }

  // Private method to create the overlay entry (the visual representation of the toast)
  static OverlayEntry _createOverlayEntry(
    BuildContext context,
    String message,
    ToastPosition position,
    Color color,
    IconData icon,
  ) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          // Position the toast either at the top or bottom of the screen based on the argument
          top: position == ToastPosition.top ? 50.0 : null,
          bottom: position == ToastPosition.bottom ? 50.0 : null,
          left:
              MediaQuery.of(context).size.width * 0.1, // 10% from the left edge
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: SlideTransition(
            position: _offsetAnimation, // Apply the slide-in animation
            child: Material(
              color: Colors.transparent, // Transparent background for the toast
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20), // Padding inside the toast
                decoration: BoxDecoration(
                  color: color, // Background color (success or error color)
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // Shadow color
                      blurRadius: 10, // Shadow blur radius
                      spreadRadius: 2, // Spread radius of the shadow
                      offset: Offset(0, 4), // Shadow position (below the toast)
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // Make the row as small as possible
                  children: [
                    Icon(icon,
                        color: Colors
                            .white), // Display the appropriate icon (check or error)
                    SizedBox(width: 8), // Space between icon and text
                    Flexible(
                      child: Text(
                        message, // Display the toast message
                        style: TextStyle(
                            color: Colors.white, fontSize: 16), // Text styling
                        textAlign: TextAlign
                            .center, // Center the text inside the toast
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Enum for defining the position of the toast (either top or bottom)
enum ToastPosition { top, bottom }
