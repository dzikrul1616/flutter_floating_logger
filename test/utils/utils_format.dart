import 'package:floating_logger/src/utils/utils.dart';
import '../test.dart';

void utilsFormat() {
  group('Utils Format', () {
    test(
        'generateCurlCommand should generate a valid curl command for REST API',
        () {
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com/api/v1/resource',
        headers: {'Content-Type': 'application/json'},
        data: {"name": "John", "age": 30},
      );
      final curlCommand = FormatLogger.generateCurlCommand(options);

      expect(curlCommand,
          'curl -X POST -H "Content-Type: application/json" "https://example.com/api/v1/resource" -d \'{"name":"John","age":30}\'');
    });

    test('generateCurlCommand should generate a valid curl command for GraphQL',
        () {
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com/graphql',
        headers: {'Content-Type': 'application/json'},
        data: {"query": "query { user(id: 1) { name email } }"},
      );
      final curlCommand = FormatLogger.generateCurlCommand(options);

      expect(curlCommand,
          'curl -X POST -H "Content-Type: application/json" "https://example.com/graphql" -d \'{"query":"query { user(id: 1) { name email } }"}\'');
    });

    test('generateCurlCommand should handle non-Map data correctly', () {
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com/api/v1/resource',
        headers: {'Content-Type': 'text/plain'},
        data:
            'Raw text data', // Ini bukan Map, jadi langsung diproses sebagai string
      );
      final curlCommand = FormatLogger.generateCurlCommand(options);

      expect(curlCommand,
          'curl -X POST -H "Content-Type: text/plain" "https://example.com/api/v1/resource" -d \'Raw text data\'');
    });

    test('parseJson should format Map into pretty JSON', () {
      final map = {'name': 'John', 'age': 30};

      final formattedJson = FormatLogger.parseJson(map);

      expect(formattedJson, '{\n  "name": "John",\n  "age": 30\n}');
    });

    test('parseJson should format List into pretty JSON', () {
      final list = ['apple', 'banana', 'cherry'];

      final formattedJson = FormatLogger.parseJson(list);

      expect(formattedJson, '[\n  "apple",\n  "banana",\n  "cherry"\n]');
    });

    test('parseJson should parse JSON string and format correctly', () {
      final jsonString = '{"name": "John", "age": 30}';

      final formattedJson = FormatLogger.parseJson(jsonString);

      expect(formattedJson, '{\n  "name": "John",\n  "age": 30\n}');
    });

    test('parseJson should return string representation for non-Map, non-List',
        () {
      final nonJsonObject = 12345;

      final result = FormatLogger.parseJson(nonJsonObject);

      expect(result, '12345');
    });

    test('parseJson should return string for invalid JSON', () {
      final invalidJsonString = '{"name": "John", "age": 30';

      final result = FormatLogger.parseJson(invalidJsonString);

      expect(result, invalidJsonString);
    });
    test('generateCurlCommand should handle FormData correctly', () {
      final formData = FormData.fromMap({
        'name': 'John',
        'age': 30,
        'file': MultipartFile.fromString('file content', filename: 'test.txt'),
      });

      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com/upload',
        data: formData,
      );

      final curlCommand = FormatLogger.generateCurlCommand(options);

      expect(curlCommand, contains('-F "name=John"'));
      expect(curlCommand, contains('-F "age=30"'));
      expect(curlCommand, contains('-F "file=@test.txt"'));
      expect(curlCommand, contains('curl -X POST'));
      expect(curlCommand, contains('"https://example.com/upload"'));
    });
  });
}
