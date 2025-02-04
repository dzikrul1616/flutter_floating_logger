import 'package:floating_logger/src/network/network.dart';
import 'package:flutter_test/flutter_test.dart';

void networkModel() {
  group('Network Model', () {
    // Test: Model creation from JSON
    test('LogRepositoryModel should be created from JSON', () {
      // Example JSON input
      final json = {
        "type": "GET",
        "response": "200 OK",
        "queryparameter": "id=1",
        "header": "Content-Type: application/json",
        "data": '{"name": "John"}',
        "response_data": '{"id": 1, "name": "John"}',
        "message": "Request successful",
        "curl": "curl -X GET https://example.com"
      };

      // Create LogRepositoryModel from JSON
      final log = LogRepositoryModel.fromJson(json);

      // Verify that the values are assigned correctly
      expect(log.type, "GET");
      expect(log.response, "200 OK");
      expect(log.queryparameter, "id=1");
      expect(log.header, "Content-Type: application/json");
      expect(log.data, '{"name": "John"}');
      expect(log.responseData, '{"id": 1, "name": "John"}');
      expect(log.message, "Request successful");
      expect(log.curl, "curl -X GET https://example.com");
    });

    // Test: Model to JSON conversion
    test('LogRepositoryModel should convert to JSON correctly', () {
      // Create LogRepositoryModel instance
      final log = LogRepositoryModel(
        type: "POST",
        response: "404 Not Found",
        queryparameter: "id=2",
        header: "Content-Type: application/json",
        data: '{"name": "Doe"}',
        responseData: '{"error": "Not found"}',
        message: "Request failed",
        curl: "curl -X POST https://example.com",
      );

      // Convert to JSON
      final json = log.toJson();

      // Verify the converted JSON values
      expect(json["type"], "POST");
      expect(json["response"], "404 Not Found");
      expect(json["queryparameter"], "id=2");
      expect(json["header"], "Content-Type: application/json");
      expect(json["data"], '{"name": "Doe"}');
      expect(json["response_data"], '{"error": "Not found"}');
      expect(json["message"], "Request failed");
      expect(json["curl"], "curl -X POST https://example.com");
    });

    // Test: Equality check
    test('LogRepositoryModel should be equal based on properties', () {
      // Create two instances with the same data
      final log1 = LogRepositoryModel(
        type: "GET",
        response: "200 OK",
        queryparameter: "id=1",
        header: "Content-Type: application/json",
        data: '{"name": "John"}',
        responseData: '{"id": 1, "name": "John"}',
        message: "Request successful",
        curl: "curl -X GET https://example.com",
      );
      final log2 = LogRepositoryModel(
        type: "GET",
        response: "200 OK",
        queryparameter: "id=1",
        header: "Content-Type: application/json",
        data: '{"name": "John"}',
        responseData: '{"id": 1, "name": "John"}',
        message: "Request successful",
        curl: "curl -X GET https://example.com",
      );

      // Verify that they are equal
      expect(log1, equals(log2));

      // Create an instance with different data
      final log3 = LogRepositoryModel(
        type: "POST",
        response: "404 Not Found",
        queryparameter: "id=2",
        header: "Content-Type: application/json",
        data: '{"name": "Doe"}',
        responseData: '{"error": "Not found"}',
        message: "Request failed",
        curl: "curl -X POST https://example.com",
      );

      // Verify that it is not equal to the previous logs
      expect(log1, isNot(equals(log3)));
    });

    // Test: toString method
    test('LogRepositoryModel should format toString correctly', () {
      // Create LogRepositoryModel instance
      final log = LogRepositoryModel(
        type: "REQUEST",
        method: "GET",
        response: "200 OK",
        queryparameter: "id=1",
        header: "Content-Type: application/json",
        data: '{"name": "John"}',
        responseData: '{"id": 1, "name": "John"}',
        message: "Request successful",
        curl: "curl -X GET https://example.com",
      );

      // Verify the toString method output
      expect(log.toString(),
          "REQUEST, GET, 200 OK, Content-Type: application/json, id=1, {\"name\": \"John\"}, {\"id\": 1, \"name\": \"John\"}, null, Request successful, curl -X GET https://example.com");
    });
  });
}
