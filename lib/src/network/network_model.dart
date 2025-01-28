import 'package:floating_logger/floating_logger.dart'
    show ValueNotifier, Equatable;

class LogRepository {
  final ValueNotifier<List<LogRepositoryModel>> _logsNotifier =
      ValueNotifier<List<LogRepositoryModel>>([]);

  void addLog(LogRepositoryModel log) {
    _logsNotifier.value = [log, ..._logsNotifier.value];
  }

  ValueNotifier<List<LogRepositoryModel>> get logsNotifier => _logsNotifier;

  void clearLogs() {
    _logsNotifier.value = [];
  }
}

class LogRepositoryModel extends Equatable {
  const LogRepositoryModel({
    this.type,
    this.response,
    this.queryparameter,
    this.data,
    this.responseData,
    this.path,
    this.message,
    this.curl,
  });

  final String? type;
  final String? response;
  final String? queryparameter;
  final String? data;
  final String? responseData;
  final String? path;
  final String? message;
  final String? curl;

  factory LogRepositoryModel.fromJson(Map<String, dynamic> json) {
    return LogRepositoryModel(
      type: json["type"] ?? "-",
      response: json["response"] ?? "-",
      queryparameter: json["queryparameter"] ?? "-",
      data: json["data"] ?? "-",
      responseData: json["response_data"] ?? "-",
      message: json["message"] ?? "-",
      curl: json["curl"] ?? "-",
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "response": response,
        "queryparameter": queryparameter,
        "data": data,
        "response_data": responseData,
        "path": path,
        "message": message,
        "curl": curl,
      };

  @override
  String toString() {
    return "$type, $response, $queryparameter, $data, $responseData, $path, $message, $curl";
  }

  @override
  List<Object?> get props => [
        type,
        response,
        queryparameter,
        data,
        responseData,
        path,
        message,
        curl,
      ];
}
