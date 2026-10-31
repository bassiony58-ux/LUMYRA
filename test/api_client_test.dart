import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumyra/core/network/api_client.dart';
import 'package:lumyra/core/network/api_exceptions.dart';

void main() {
  group('ApiClient Tests', () {
    test('attaches Authorization Bearer token when provided', () async {
      String? capturedHeader;

      final mockClient = MockClient((request) async {
        capturedHeader = request.headers['Authorization'];
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://test.local/api/v1',
        tokenProvider: () => 'valid-mock-token-123',
      );

      final result = await apiClient.get('/test-endpoint');

      expect(capturedHeader, 'Bearer valid-mock-token-123');
      expect(result, isA<Map>());
      expect(result['status'], 'ok');
    });

    test('throws UnauthorizedException and triggers session expired callback on 401', () async {
      bool sessionExpiredTriggered = false;

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Invalid or expired Firebase ID token.'}),
          401,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://test.local/api/v1',
        tokenProvider: () => 'expired-token',
        onSessionExpired: () {
          sessionExpiredTriggered = true;
        },
      );

      await expectLater(
        apiClient.get('/protected-endpoint'),
        throwsA(isA<UnauthorizedException>()),
      );

      expect(sessionExpiredTriggered, isTrue);
    });

    test('throws ForbiddenException on 403', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Access denied: You do not have an active clinical care assignment.'}),
          403,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://test.local/api/v1',
      );

      await expectLater(
        apiClient.get('/patients/other-patient-id'),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('throws NotFoundException on 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Medical center not found'}),
          404,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://test.local/api/v1',
      );

      await expectLater(
        apiClient.get('/medical-centers/nonexistent-id'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
