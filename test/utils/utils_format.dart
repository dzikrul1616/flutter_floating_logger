import 'package:floating_logger/src/utils/utils.dart';
import '../test.dart';

void utilsFormat() {
  group('Utils Format', () {
    // Test for generateCurlCommand method
    test('generateCurlCommand should generate a valid curl command', () {
      // Create a mock RequestOptions object
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com/api/v1/resource',
        headers: {'Content-Type': 'application/json'},
        data: '{"name": "John", "age": 30}',
      );

      // Generate the curl command
      final curlCommand = FormatLogger.generateCurlCommand(options);

      // Verify the generated curl command
      expect(curlCommand,
          'curl -X POST -H "Content-Type: application/json" -d \'{"name": "John", "age": 30}\' "https://example.com/api/v1/resource"');
    });

    // Test for parseJson method
    test('parseJson should format Map into pretty JSON', () {
      // Sample Map to format
      final map = {'name': 'John', 'age': 30};

      // Parse the map to JSON
      final formattedJson = FormatLogger.parseJson(map);

      // Verify the formatted JSON
      expect(formattedJson, '{\n  "name": "John",\n  "age": 30\n}');
    });

    test('parseJson should format List into pretty JSON', () {
      // Sample List to format
      final list = ['apple', 'banana', 'cherry'];

      // Parse the list to JSON
      final formattedJson = FormatLogger.parseJson(list);

      // Verify the formatted JSON
      expect(formattedJson, '[\n  "apple",\n  "banana",\n  "cherry"\n]');
    });

    test('parseJson should parse JSON string and format correctly', () {
      // Sample JSON string to parse
      final jsonString = '{"name": "John", "age": 30}';

      // Parse the JSON string and format it
      final formattedJson = FormatLogger.parseJson(jsonString);

      // Verify the formatted JSON
      expect(formattedJson, '{\n  "name": "John",\n  "age": 30\n}');
    });

    test('parseJson should return string representation for non-Map, non-List',
        () {
      // Sample non-Map and non-List object
      final nonJsonObject = 12345;

      // Parse the object
      final result = FormatLogger.parseJson(nonJsonObject);

      // Verify the string representation
      expect(result, '12345');
    });

    test('parseJson should return string for invalid JSON', () {
      // Invalid JSON string
      final invalidJsonString =
          '{"name": "John", "age": 30'; // Missing closing bracket

      // Parse the invalid JSON string
      final result = FormatLogger.parseJson(invalidJsonString);

      // Verify that it returns the string representation
      expect(result, invalidJsonString);
    });
  });
}
