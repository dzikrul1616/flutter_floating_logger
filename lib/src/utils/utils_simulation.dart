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
        // Simulate connection error
        throw DioException(
          requestOptions: options,
          error: 'Simulated Offline Mode',
          type: DioExceptionType.connectionError,
          message: 'No Internet Connection (Simulated)',
        );
      case NetworkSimulation.socketError:
        throw DioException(
          requestOptions: options,
          error: const SocketException('Simulated Socket Exception'),
          type: DioExceptionType.connectionError,
          message: 'Socket Exception (Simulated)',
        );
      case NetworkSimulation.serverError:
        throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 500,
            statusMessage: 'Internal Server Error (Simulated)',
            data: {'error': 'Simulated Internal Server Error'},
          ),
          type: DioExceptionType.badResponse,
          message: 'Internal Server Error (Simulated)',
        );
      case NetworkSimulation.timeout:
        // Simulate timeout delay before throwing? Or just throw immediately?
        // Real timeout waits. I should wait a bit then throw?
        // User asked for "timeout". Usually implies a wait.
        await Future.delayed(const Duration(seconds: 2));
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          message: 'Connection Timeout (Simulated)',
          error: 'Simulated Timeout',
        );
    }
  }
}
