import 'package:floating_logger/src/widgets/widgets.dart';

import '../test.dart';

void widgetFloatingLoggerToastTest() {
  group('FloatingLoggerToast Widget Test', () {
    testWidgets('Displays success toast', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => LoggerToast.successToast(
                  'Success message',
                  context: context,
                ),
                child: Text('Show Toast'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Displays error toast', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => LoggerToast.errorToast(
                  'Error occurred',
                  context: context,
                ),
                child: Text('Show Error Toast'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('LoggerToast.of should initialize with the provided context',
        (WidgetTester tester) async {
      BuildContext? testContext;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      );

      final loggerToast = LoggerToast.of(testContext!);

      expect(loggerToast.context, equals(testContext));
    });

    testWidgets('\$howSuccessToast should display toast',
        (WidgetTester tester) async {
      BuildContext? testContext;
      const message = 'Success message';

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return StyledToast(
              locale: Locale('en', 'EN'),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      );

      final loggerToast = LoggerToast.of(testContext!);
      loggerToast.$howSuccessToast(message);
 
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
 
      expect(find.byType(StyledToast), findsOneWidget);
    });

    testWidgets('\$howErrorToast should display toast',
        (WidgetTester tester) async {
      BuildContext? testContext;
      const message = 'Error message';

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return StyledToast(
              locale: Locale('en', 'EN'),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      );

      final loggerToast = LoggerToast.of(testContext!);
      loggerToast.$howErrorToast(message);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(StyledToast), findsOneWidget);
    });
  });
}
