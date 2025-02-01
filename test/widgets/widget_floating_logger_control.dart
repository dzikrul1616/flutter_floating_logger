import 'package:floating_logger/src/widgets/widgets.dart';
import '../test.dart';

void widgetFloatingLoggerControlTest() {
  group('FloatingLoggerControl Widget Test', () {
    testWidgets('Should show floating button when isShow is true',
        (WidgetTester tester) async {
      final isShow = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: FloatingLoggerControl(
            isShow: isShow,
            child: Container(),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Should hide floating button when isShow is false',
        (WidgetTester tester) async {
      final isShow = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: FloatingLoggerControl(
            isShow: isShow,
            child: Container(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Should open debug panel when button is clicked',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FloatingLoggerControl(
            child: Container(),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingLoggerModalBottomWidget), findsOneWidget);
    });

    testWidgets('FloatingLoggerControl updates position on drag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerControl(
              isShow: ValueNotifier(true),
              child: Container(),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);

      final initialPosition =
          tester.getTopLeft(find.byType(FloatingActionButton));

      final dragOffset = Offset(100, 100);
      await tester.drag(find.byType(FloatingActionButton), dragOffset);
      await tester.pumpAndSettle();

      final newPosition = tester.getTopLeft(find.byType(FloatingActionButton));

      expect(newPosition, isNot(equals(initialPosition)));

      final screenSize = tester.getSize(find.byType(Scaffold));
      expect(newPosition.dx, greaterThanOrEqualTo(0));
      expect(newPosition.dy, greaterThanOrEqualTo(0));
      expect(newPosition.dx, lessThanOrEqualTo(screenSize.width - 56));
      expect(newPosition.dy, lessThanOrEqualTo(screenSize.height - 56));
    });
    testWidgets('FloatingLoggerControl should retrieve preference correctly',
        (WidgetTester tester) async {
      Future<bool> mockGetPreference() async => true;

      await tester.pumpWidget(
        MaterialApp(
          home: FloatingLoggerControl(
            getPreference: mockGetPreference,
            child: Container(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingLoggerControl), findsOneWidget);
    });
  });
}
