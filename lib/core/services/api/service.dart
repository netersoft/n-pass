import 'dart:convert';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../../helpers/logging/log_helper.dart';
import '../../helpers/router/navigation_helper.dart';
import '../../routes/app_route.dart';
import '../di/locator.dart';
import '../hive/keys.dart';
import 'config.dart';
import 'response.dart';

/// Holds the actual HTTP client/state and does the request work. Registered
/// as a DI singleton (see AppModule) instead of living behind static fields,
/// so it can be constructed directly with a fake client/token provider in
/// tests instead of going through a configure()/resetConfiguration() escape
/// hatch.
class ApiClient {
  ApiClient({http.Client? client, this.tokenProvider}) : _client = client ?? http.Client();

  final http.Client _client;
  final String? Function()? tokenProvider;

  Map<String, String> _finalRequestHeaders() {
    var headers = {...ApiConfig.requestHeaders};
    var token = tokenProvider?.call() ?? _getStoredAuthToken();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  String? _getStoredAuthToken() {
    try {
      if (!Hive.isBoxOpen(HiveKeys.auth)) return null;

      return Hive.box(HiveKeys.auth).get(
        HiveKeys.authToken,
        defaultValue: null,
      );
    } catch (e) {
      LogHelper.e(e);
      return null;
    }
  }

  Future<ApiResponse> makeRequest({
    RequestType type = RequestType.get,
    String path = '',
    dynamic data,
    bool useApiUrl = true,
  }) async {
    var uri = Uri.parse(useApiUrl ? ApiConfig.url + path : path);
    http.Response? response;
    String? message;

    var requestHeaders = _finalRequestHeaders();

    try {
      switch (type) {
        case RequestType.get:
          response = await _client.get(uri, headers: requestHeaders).timeout(ApiConfig.requestTimeout);
        case RequestType.put:
          response = await _client
              .put(
                uri,
                headers: requestHeaders,
                body: jsonEncode(data),
              )
              .timeout(ApiConfig.requestTimeout);
        case RequestType.patch:
          response = await _client
              .patch(
                uri,
                headers: requestHeaders,
                body: jsonEncode(data),
              )
              .timeout(ApiConfig.requestTimeout);
        case RequestType.post:
          response = await _client
              .post(
                uri,
                headers: requestHeaders,
                body: jsonEncode(data),
              )
              .timeout(ApiConfig.requestTimeout);
        case RequestType.delete:
          response = await _client
              .delete(
                uri,
                headers: requestHeaders,
                body: jsonEncode(data),
              )
              .timeout(ApiConfig.requestTimeout);
      }
    } catch (e) {
      message = '$e';
      LogHelper.e(e);
    }

    return handleResponse(response, message: message, useApiUrl: useApiUrl);
  }

  Future<ApiResponse> addItem(String path, dynamic data) => makeRequest(type: RequestType.post, path: path, data: data);

  Future<ApiResponse> deleteItem(String path, String id) => makeRequest(type: RequestType.delete, path: '$path/$id');

  Future<ApiResponse> updateItem(String path, String id, dynamic data) => makeRequest(type: RequestType.put, path: '$path/$id', data: data);

  Future<ApiResponse> getAllItems(String path) => makeRequest(path: path);

  Future<ApiResponse> getItem(String path, String id) => makeRequest(path: '$path/$id');

  Future<ApiResponse> uploadFile(
    File file,
    String folder, {
    String path = '/file/upload',
  }) async {
    final formData = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.url}$path'),
    )..headers.addAll(_finalRequestHeaders());
    formData.fields['folder'] = folder;
    formData.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await file.readAsBytes(),
        filename: file.path.split('/').last,
      ),
    );
    http.Response? response;
    String? message;

    try {
      response = await http.Response.fromStream(
        await formData.send().timeout(ApiConfig.requestTimeout),
      );
    } catch (e) {
      message = '$e';
      LogHelper.e(e);
    }

    return handleResponse(response, message: message);
  }

  Future<ApiResponse> uploadAvatar(
    File avatar, {
    String path = '/profile/avatar',
  }) async {
    final formData = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.url}$path'),
    )..headers.addAll(_finalRequestHeaders());
    formData.files.add(
      http.MultipartFile.fromBytes(
        'avatar',
        await avatar.readAsBytes(),
        filename: avatar.path.split('/').last,
      ),
    );
    http.Response? response;
    String? message;

    try {
      response = await http.Response.fromStream(
        await _client.send(formData).timeout(ApiConfig.requestTimeout),
      );
    } catch (e) {
      message = '$e';
      LogHelper.e(e);
    }

    return handleResponse(response, message: message);
  }

  ApiResponse handleResponse(
    http.Response? response, {
    String? message,
    bool useApiUrl = true,
  }) {
    if (response == null) {
      return ApiResponse(
        statusCode: 0,
        message: message ?? 'No response',
      );
    }

    dynamic decodedBody;

    try {
      decodedBody = jsonDecode(response.body);
    } catch (e) {
      decodedBody = {};
      LogHelper.e(response.body, usePrettier: false);
    }

    if (response.statusCode == 401) {
      if (Hive.isBoxOpen(HiveKeys.auth)) {
        Hive.box(HiveKeys.auth).clear();
      }

      if (locator.isRegistered<NavigationHelper>()) {
        locator<NavigationHelper>().pushReplacement(const RedirectionRoute().location);
      }
    }

    int? retryAfterSeconds;
    if (response.statusCode == 429) {
      retryAfterSeconds = int.tryParse(response.headers['retry-after'] ?? '');
    }

    return ApiResponse(
      statusCode: response.statusCode,
      message: message ?? (decodedBody is Map ? decodedBody['message'] : null),
      errors: decodedBody is Map ? decodedBody['errors'] : null,
      retryAfterSeconds: retryAfterSeconds,
      data: decodedBody,
    );
  }

  void displayFormErrors(Map<String, dynamic> errors) {
    if (errors.isNotEmpty) {
      errors.forEach((key, value) {
        if (value is List) {
          for (final error in value) {
            if (error is String) {
              EasyLoading.showError(error);
            }
          }
        }
      });
    }
  }
}

/// Thin static facade kept for the existing call sites (queries, mutations,
/// providers) across the app -- it just forwards to the DI-registered
/// [ApiClient] singleton, so none of them need to change.
abstract class ApiService {
  static ApiClient get _client => locator<ApiClient>();

  static Future<ApiResponse> makeRequest({
    RequestType type = RequestType.get,
    String path = '',
    dynamic data,
    bool useApiUrl = true,
  }) => _client.makeRequest(type: type, path: path, data: data, useApiUrl: useApiUrl);

  static Future<ApiResponse> addItem(String path, dynamic data) => _client.addItem(path, data);

  static Future<ApiResponse> deleteItem(String path, String id) => _client.deleteItem(path, id);

  static Future<ApiResponse> updateItem(String path, String id, dynamic data) => _client.updateItem(path, id, data);

  static Future<ApiResponse> getAllItems(String path) => _client.getAllItems(path);

  static Future<ApiResponse> getItem(String path, String id) => _client.getItem(path, id);

  static Future<ApiResponse> uploadFile(
    File file,
    String folder, {
    String path = '/file/upload',
  }) => _client.uploadFile(file, folder, path: path);

  static Future<ApiResponse> uploadAvatar(
    File avatar, {
    String path = '/profile/avatar',
  }) => _client.uploadAvatar(avatar, path: path);

  static ApiResponse handleResponse(
    http.Response? response, {
    String? message,
    bool useApiUrl = true,
  }) => _client.handleResponse(response, message: message, useApiUrl: useApiUrl);

  static void displayFormErrors(Map<String, dynamic> errors) => _client.displayFormErrors(errors);
}

enum RequestType { post, put, patch, get, delete }
