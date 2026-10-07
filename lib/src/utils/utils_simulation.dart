import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Enum representing different network simulation modes.
enum NetworkSimulation {
  normal,
  slow3g,
  offline,
  socketError,
  serverError,
  timeout;

  String get label {
    switch (this) {
      case NetworkSimulation.normal:
        return 'Normal';
      case NetworkSimulation.slow3g:
        return 'Slow 3G';
      case NetworkSimulation.offline:
        return 'Offline';
      case NetworkSimulation.socketError:
        return 'Socket Error';
      case NetworkSimulation.serverError:
        return 'Server Error';
      case NetworkSimulation.timeout:
        return 'Timeout';
    }
  }
}

/// Class to handle network simulation (throttling and errors).
class NetworkSimulator {
  static final NetworkSimulator _instance = NetworkSimulator._internal();

  static NetworkSimulator get instance => _instance;

  NetworkSimulator._internal();

  /// Notifier for the current network simulation setting.
  final ValueNotifier<NetworkSimulation> simulationNotifier =
      ValueNotifier(NetworkSimulation.normal);

  /// Sets the network simulation mode.
  void setSimulation(NetworkSimulation simulation) {
    simulationNotifier.value = simulation;
  }

  /// Simulates the network condition based on the current setting.
  /// This should be called in the `onRequest` interceptor.
  Future<void> simulate(RequestOptions options) async {
    final simulation = simulationNotifier.value;
    switch (simulation) {
      case NetworkSimulation.normal:
        return;
      case NetworkSimulation.slow3g:
        // Simulate ~2 seconds delay
        await Future.delayed(const Duration(seconds: 2));
        break;
      case NetworkSimulation.offline:
        // Real-world offline exception: no server response, only connection error
        throw DioException(
          requestOptions: options,
          error: 'No Internet Connection (Simulated)',
          type: DioExceptionType.connectionError,
          message:
              'The connection errored: No Internet Connection (Simulated Offline Mode)',
        );
      case NetworkSimulation.socketError:
        // Real-world socket exception: no server response, OS connection refused
        throw DioException(
          requestOptions: options,
          error: const SocketException(
              'OS Error: Connection refused, errno = 111 (Simulated Socket Error)'),
          type: DioExceptionType.connectionError,
          message:
              'Failed host lookup / Connection refused (Simulated Socket Error)',
        );
      case NetworkSimulation.serverError:
        // Server 500 actually responds from the server with 500 status code and error body
        throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 500,
            statusMessage: 'Internal Server Error',
            data: {'error': 'Internal Server Error (Simulated)'},
          ),
          type: DioExceptionType.badResponse,
          message: 'Internal Server Error (Simulated 500)',
        );
      case NetworkSimulation.timeout:
        // Real-world timeout: no server response, connection timed out after delay
        await Future.delayed(const Duration(seconds: 2));
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          message:
              'Connection Timeout: The request took longer than 2000ms (Simulated)',
          error: 'Connection timed out (Simulated)',
        );
    }
  }
}
