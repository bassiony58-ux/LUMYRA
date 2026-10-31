import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  final String? Function()? _tokenProvider;
  final VoidCallback? _onSessionExpired;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    String? Function()? tokenProvider,
    VoidCallback? onSessionExpired,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _tokenProvider = tokenProvider,
        _onSessionExpired = onSessionExpired;

  String get baseUrl => _baseUrl;

  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return _sendRequest(() => _client.get(uri, headers: _buildHeaders(extraHeaders: headers)));
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    return _sendRequest(() => _client.post(
          uri,
          headers: _buildHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    return _sendRequest(() => _client.patch(
          uri,
          headers: _buildHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    return _sendRequest(() => _client.delete(uri, headers: _buildHeaders(extraHeaders: headers)));
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required List<int> fileBytes,
    required String fileName,
    String fileField = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      final reqHeaders = _buildHeaders(extraHeaders: headers);
      reqHeaders.remove('Content-Type');
      request.headers.addAll(reqHeaders);

      final multipartFile = http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 25),
      );
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Could not connect to Lumyra backend server (${e.message}).',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Request timed out. Please check your connection and try again.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected network communication error: $e');
    }
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final urlString = '$_baseUrl/$cleanEndpoint';
    final uri = Uri.parse(urlString);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<dynamic> _sendRequest(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn().timeout(
        const Duration(seconds: AppConfig.requestTimeoutSeconds),
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Could not connect to Lumyra backend server (${e.message}).',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Request timed out. Please check your connection and try again.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected network communication error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decodedBody;
    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }
    } catch (_) {
      decodedBody = response.body;
    }

    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    String message = 'HTTP $statusCode error occurred';
    if (decodedBody is Map && decodedBody['message'] != null) {
      final rawMsg = decodedBody['message'];
      message = rawMsg is List ? rawMsg.join(', ') : rawMsg.toString();
    }

    if (statusCode == 401) {
      _onSessionExpired?.call();
      throw UnauthorizedException(message: message, details: decodedBody);
    } else if (statusCode == 403) {
      throw ForbiddenException(message: message, details: decodedBody);
    } else if (statusCode == 404) {
      throw NotFoundException(message: message, details: decodedBody);
    } else {
      throw ApiException(
        message: message,
        statusCode: statusCode,
        details: decodedBody,
      );
    }
  }
}
