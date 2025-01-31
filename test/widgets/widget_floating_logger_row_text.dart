import 'package:floating_logger/src/widgets/widgets.dart';
import '../test.dart';

void widgetFloatingLoggerRowTextTest() {
  group('FloatingLoggerRowtext Widget Test', () {
    testWidgets('Should display title and data correctly',
        (WidgetTester tester) async {
      // Arrange
      const String title = 'Status';
      const String data = 'Success';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerRowText(
              title: title,
              data: data,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(':'), findsOneWidget);
      expect(find.text(data), findsOneWidget);
    });
  });
}
