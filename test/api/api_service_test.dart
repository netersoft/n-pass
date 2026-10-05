import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_starter/core/services/api/config.dart';
import 'package:flutter_starter/core/services/api/response.dart';
import 'package:flutter_starter/core/services/api/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_utils.dart';

void main() {
  setUpAll(() async {
    registerFallbackValue(RequestType.get);
    await dotenv.load();
  });

  group('ApiClient', () {
    test(
      'uses injected client and token provider without mutating base headers',
      () async {
        late Map<String, String> capturedHeaders;

        final apiClient = ApiClient(
          tokenProvider: () => 'test-token',
          client: MockClient((request) async {
            capturedHeaders = request.headers;

            return http.Response(
              '{"message":"OK","data":{"id":1}}',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );

        final response = await apiClient.makeRequest(
          path: 'https://example.test/items',
          useApiUrl: false,
        );

        expect(response.isSuccess, isTrue);
        expect(response.data, {
          'message': 'OK',
          'data': {'id': 1},
        });
        expect(capturedHeaders['Authorization'], 'Bearer test-token');
        expect(ApiConfig.requestHeaders.containsKey('Authorization'), isFalse);
      },
    );

    test('sends a PATCH request with a JSON-encoded body', () async {
      late String capturedMethod;
      late String capturedBody;

      final apiClient = ApiClient(
        client: MockClient((request) async {
          capturedMethod = request.method;
          capturedBody = request.body;

          return http.Response(
            '{"message":"OK"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final response = await apiClient.makeRequest(
        path: 'https://example.test/profile',
        type: RequestType.patch,
        data: {'name': 'John Doe'},
        useApiUrl: false,
      );

      expect(response.isSuccess, isTrue);
      expect(capturedMethod, 'PATCH');
      expect(capturedBody, '{"name":"John Doe"}');
    });

    test(
      'uploadAvatar sends a multipart POST with an avatar file field through the injected client',
      () async {
        late http.BaseRequest capturedRequest;
        late String capturedBody;

        final apiClient = ApiClient(
          tokenProvider: () => 'test-token',
          client: MockClient((request) async {
            capturedRequest = request;
            capturedBody = request.body;

            return http.Response(
              '{"id":1,"avatar":"https://example.test/avatars/1.jpg"}',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );

        final avatarFile = File('${Directory.systemTemp.path}/avatar_upload_test.jpg');
        await avatarFile.writeAsBytes([1, 2, 3]);
        addTearDown(avatarFile.delete);

        final response = await apiClient.uploadAvatar(avatarFile);

        expect(response.isSuccess, isTrue);
        expect(capturedRequest.method, 'POST');
        expect(capturedRequest.url.toString(), '${ApiConfig.url}/profile/avatar');
        expect(capturedRequest.headers['Authorization'], 'Bearer test-token');
        expect(capturedBody, contains('name="avatar"'));
        expect(capturedBody, contains('avatar_upload_test.jpg'));
      },
    );
  });

  group('ApiService facade', () {
    late MockApiClient mockApiClient;

    setUp(() async {
      mockApiClient = MockApiClient();
      await setupTestLocator(apiClient: mockApiClient);
    });

    tearDown(teardownTestLocator);

    test('makeRequest delegates to the ApiClient registered in DI', () async {
      final expected = ApiResponse(statusCode: 200, message: 'ok');
      when(
        () => mockApiClient.makeRequest(
          type: any(named: 'type'),
          path: any(named: 'path'),
          data: any(named: 'data'),
          useApiUrl: any(named: 'useApiUrl'),
        ),
      ).thenAnswer((_) async => expected);

      final response = await ApiService.makeRequest(path: '/ping');

      expect(response, same(expected));
      verify(() => mockApiClient.makeRequest(path: '/ping')).called(1);
    });

    test('displayFormErrors delegates to the ApiClient registered in DI', () {
      when(() => mockApiClient.displayFormErrors(any())).thenReturn(null);

      final errors = {
        'email': ['already used'],
      };
      ApiService.displayFormErrors(errors);

      verify(() => mockApiClient.displayFormErrors(errors)).called(1);
    });
  });
}
