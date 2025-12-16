// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:floating_logger/src/utils/utils_simulation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkSimulator', () {
    setUp(() {
      NetworkSimulator.instance.setSimulation(NetworkSimulation.normal);
    });

    test('should update simulation notifier', () {
      NetworkSimulator.instance.setSimulation(NetworkSimulation.slow3g);
      expect(NetworkSimulator.instance.simulationNotifier.value,
          NetworkSimulation.slow3g);
    });

    test('should delay request for Slow 3G', () {
      fakeAsync((async) {
        NetworkSimulator.instance.setSimulation(NetworkSimulation.slow3g);
        final options = RequestOptions(path: '/test');

        bool completed = false;
        NetworkSimulator.instance
            .simulate(options)
            .then((_) => completed = true);

        async.elapse(const Duration(seconds: 1));
        expect(completed, isFalse); // Should strictly wait 2 seconds

        async.elapse(const Duration(seconds: 1, milliseconds: 100));
        expect(completed, isTrue);
      });
    });

    test('should throw DioException for Offline', () async {
      NetworkSimulator.instance.setSimulation(NetworkSimulation.offline);
      final options = RequestOptions(path: '/test');

      expect(
        () => NetworkSimulator.instance.simulate(options),
        throwsA(isA<DioException>()),
      );
    });

    test('should throw DioException with SocketException for Socket Error',
        () async {
      NetworkSimulator.instance.setSimulation(NetworkSimulation.socketError);
      final options = RequestOptions(path: '/test');

      try {
        await NetworkSimulator.instance.simulate(options);
        fail('Should trigger exception');
      } on DioException catch (e) {
        expect(e.error, isA<SocketException>());
      }
    });

    test('should throw DioException with 500 response for Server Error',
        () async {
      NetworkSimulator.instance.setSimulation(NetworkSimulation.serverError);
      final options = RequestOptions(path: '/test');

      try {
        await NetworkSimulator.instance.simulate(options);
        fail('Should trigger exception');
      } on DioException catch (e) {
        expect(e.type, DioExceptionType.badResponse);
        expect(e.response?.statusCode, 500);
      }
    });

    test('should throw DioException for Timeout after delay', () {
      fakeAsync((async) {
        NetworkSimulator.instance.setSimulation(NetworkSimulation.timeout);
        final options = RequestOptions(path: '/test');

        bool completed = false;
        DioException? caughtException;

        NetworkSimulator.instance.simulate(options).catchError((e) {
          caughtException = e as DioException;
          completed = true;
        });

        // Should wait 2 seconds before throwing
        async.elapse(const Duration(seconds: 1));
        expect(completed, isFalse);

        async.elapse(const Duration(seconds: 1, milliseconds: 100));
        expect(completed, isTrue);
        expect(caughtException, isNotNull);
        expect(caughtException!.type, DioExceptionType.connectionTimeout);
        expect(caughtException!.message, 'Connection Timeout (Simulated)');
      });
    });
  });
}
