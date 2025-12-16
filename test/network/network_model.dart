import 'package:floating_logger/src/network/network.dart';
import 'package:flutter_test/flutter_test.dart';

void networkModel() {
  group('Network Model', () {
    test('LogRepositoryModel should be created from JSON', () {
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

      final log = LogRepositoryModel.fromJson(json);

      expect(log.type, "GET");
      expect(log.response, "200 OK");
      expect(log.queryparameter, "id=1");
      expect(log.header, "Content-Type: application/json");
      expect(log.data, '{"name": "John"}');
      expect(log.responseData, '{"id": 1, "name": "John"}');
      expect(log.message, "Request successful");
      expect(log.curl, "curl -X GET https://example.com");
    });

    test('LogRepositoryModel should convert to JSON correctly', () {
      final log = LogRepositoryModel(
        type: "POST",
        response: "404 Not Found",
        queryparameter: "id=2",
        header: "Content-Type: application/json",
        data: '{"name": "Doe"}',
        responseData: '{"error": "Not found"}',
        message: "Request failed",
        curl: "curl -X POST https://example.com",
        responseTime: 100,
      );

      final json = log.toJson();

      expect(json["type"], "POST");
      expect(json["response"], "404 Not Found");
      expect(json["queryparameter"], "id=2");
      expect(json["header"], "Content-Type: application/json");
      expect(json["data"], '{"name": "Doe"}');
      expect(json["response_data"], '{"error": "Not found"}');
      expect(json["message"], "Request failed");
      expect(json["curl"], "curl -X POST https://example.com");
      expect(json["response_time"], 100);
    });

    test('LogRepositoryModel should be equal based on properties', () {
      final log1 = LogRepositoryModel(
        type: "GET",
        response: "200 OK",
        queryparameter: "id=1",
        header: "Content-Type: application/json",
        data: '{"name": "John"}',
        responseData: '{"id": 1, "name": "John"}',
        message: "Request successful",
        curl: "curl -X GET https://example.com",
        responseTime: 200,
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
        responseTime: 200,
      );

      expect(log1, equals(log2));

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

      expect(log1, isNot(equals(log3)));
    });

    test('LogRepositoryModel should format toString correctly', () {
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
        responseTime: 150,
      );

      expect(log.toString(),
          "REQUEST, GET, 200 OK, Content-Type: application/json, id=1, {\"name\": \"John\"}, {\"id\": 1, \"name\": \"John\"}, null, 150, Request successful, curl -X GET https://example.com");
    });
  });

  group('LogRepository', () {
    test('addLog should limit logs to 30 and keep newest', () {
      final repository = LogRepository();

      for (int i = 0; i < 35; i++) {
        repository.addLog(LogRepositoryModel(
          path: '/api/$i',
          message: 'Log $i',
        ));
      }

      expect(repository.logsNotifier.value.length, 30);
      expect(repository.logsNotifier.value.first.message, 'Log 34');
      expect(repository.logsNotifier.value.last.message, 'Log 5');
    });

    test('addLog should respect custom maxLogSize', () {
      final repository = LogRepository(maxLogSize: 10);

      for (int i = 0; i < 15; i++) {
        repository.addLog(LogRepositoryModel(
          path: '/api/$i',
          message: 'Log $i',
        ));
      }

      expect(repository.logsNotifier.value.length, 10);
      expect(repository.logsNotifier.value.first.message, 'Log 14');
      expect(repository.logsNotifier.value.last.message, 'Log 5');
    });
  });
}
