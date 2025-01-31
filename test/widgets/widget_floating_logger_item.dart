import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/widgets/widgets.dart';
import '../test.dart';

void widgetFloatingLoggerItemTest() {
  group('FloatingLoggerItem Widget Test', () {
    testWidgets('Should display log details correctly',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        path: '/api/test',
        response: '200',
        queryparameter: 'id=123',
        message: 'Success',
        data: '{}',
        responseData: '{"status":"ok"}',
        curl: 'curl -X GET /api/test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
            ),
          ),
        ),
      );

      // Periksa apakah path ditampilkan
      expect(find.text('/api/test'), findsOneWidget);

      // Periksa apakah response status ditampilkan
      expect(find.text('[Response]'), findsOneWidget);
      expect(find.text('[200]'), findsOneWidget);

      // Periksa apakah indikator status Success ada
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('Should toggle expanded details when tapped',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        path: '/api/test',
        response: '200',
        queryparameter: 'id=123',
        message: 'Success',
        data: '{}',
        responseData: '{"status":"ok"}',
        curl: 'curl -X GET /api/test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
            ),
          ),
        ),
      );

      // Periksa apakah data awal tidak ditampilkan (karena expanded)
      expect(find.text('Data'), findsNothing);

      // Klik untuk mengecilkan
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Sekarang data harus terlihat
      expect(find.text('Data'), findsOneWidget);
    });
  });
}
