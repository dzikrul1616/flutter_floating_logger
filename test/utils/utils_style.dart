import '../test.dart';

void utilsStyle() {
  group('Utils Style', () {
    test('should create instance with default values', () {
      const style = FloatingLoggerStyle();

      expect(style.icon, isNull);
      expect(style.tooltip, isNull);
      expect(style.backgroundColor, isNull);
      expect(style.size, isNull);
    });

    test('should create instance with provided values', () {
      const style = FloatingLoggerStyle(
        icon: Icon(Icons.bug_report),
        tooltip: 'Logger',
        backgroundColor: Colors.blue,
        size: Size(50, 50),
      );

      expect(style.icon, isA<Icon>());
      expect(style.tooltip, 'Logger');
      expect(style.backgroundColor, Colors.blue);
      expect(style.size, const Size(50, 50));
    });
  });
}
