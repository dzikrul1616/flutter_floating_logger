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
  });
}
