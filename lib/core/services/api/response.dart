class ApiResponse {
  int statusCode;

  String? message;

  Map<String, dynamic>? errors;

  int? retryAfterSeconds;

  dynamic data;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.errors,
    this.retryAfterSeconds,
    this.data,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  bool get isValidationError => statusCode == 422;

  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => 'ApiResponse{statusCode: $statusCode, message: $message, errors: $errors, data: $data}';
}
