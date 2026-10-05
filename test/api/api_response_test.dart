import 'package:flutter_starter/core/services/api/response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse', () {
    test('treats 2xx status codes as success', () {
      final ok = ApiResponse(statusCode: 200, message: 'OK');
      final created = ApiResponse(statusCode: 201, message: 'Created');

      expect(ok.isSuccess, isTrue);
      expect(created.isSuccess, isTrue);
    });

    test('treats non-2xx status codes as failures', () {
      final unauthorized = ApiResponse(statusCode: 401, message: 'Unauthorized');
      final networkFailure = ApiResponse(statusCode: 0, message: 'No response');

      expect(unauthorized.isSuccess, isFalse);
      expect(networkFailure.isSuccess, isFalse);
    });

    test('treats 3xx status codes as failures', () {
      final redirect = ApiResponse(statusCode: 301, message: 'Moved');

      expect(redirect.isSuccess, isFalse);
    });

    test('treats 4xx status codes as failures', () {
      final notFound = ApiResponse(statusCode: 404, message: 'Not found');

      expect(notFound.isSuccess, isFalse);
    });

    test('treats 5xx status codes as failures', () {
      final serverError = ApiResponse(statusCode: 500, message: 'Internal server error');

      expect(serverError.isSuccess, isFalse);
    });

    test('isValidationError is true only for 422', () {
      final validationError = ApiResponse(
        statusCode: 422,
        message: 'The given data was invalid.',
        errors: {
          'email': ['already used'],
        },
      );

      expect(validationError.isValidationError, isTrue);
      expect(ApiResponse(statusCode: 200, message: 'OK').isValidationError, isFalse);
    });

    test('isRateLimited is true only for 429', () {
      final rateLimited = ApiResponse(
        statusCode: 429,
        message: 'Too Many Attempts.',
        retryAfterSeconds: 60,
      );

      expect(rateLimited.isRateLimited, isTrue);
      expect(ApiResponse(statusCode: 200, message: 'OK').isRateLimited, isFalse);
    });
  });
}
