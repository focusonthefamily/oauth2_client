import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/src/storage.dart';
import 'package:oauth2_client/src/secure_storage.dart';
import 'package:oauth2_client/src/token_storage.dart';
import 'package:oauth2_client/src/volatile_storage.dart';

class SecureStorageMock extends Mock implements SecureStorage {}

void main() {

  group('Token Storage.', () {

    test('Read non existent token', () async {

      final Storage secStorage = SecureStorageMock();
      final TokenStorage storage = TokenStorage('my_token_url', storage: secStorage);

      Map<String, Map> tokens = {
        'scope1': {
          'access_token': '1234567890',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'refresh_token': '0987654321',
          'scope': ['scope1'],
        }
      };

      when(secStorage.read('my_token_url')).thenAnswer((_) async => jsonEncode(tokens));

      AccessTokenResponse tknResp = await storage.getToken(['scope2']);

      expect(tknResp, null);
    });

    test('Read existent token', () async {

      final Storage secStorage = SecureStorageMock();
      final TokenStorage storage = TokenStorage('my_token_url', storage: secStorage);

      Map<String, Map> tokens = {
        'scope1': {
          'access_token': '1234567890',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'refresh_token': '0987654321',
          'scope': ['scope1'],
          'http_status_code': 200
        }
      };

      when(secStorage.read('my_token_url')).thenAnswer((_) async => jsonEncode(tokens));

      AccessTokenResponse tknResp = await storage.getToken(['scope1']);

      expect(tknResp.isValid(), true);
    });

    test('Insert token', () async {

      final Storage secStorage = SecureStorageMock();
      final TokenStorage storage = TokenStorage('my_token_url', storage: secStorage);

      Map<String, dynamic> scope1Map = {
        'access_token': '1234567890',
        'token_type': 'Bearer',
        'refresh_token': '0987654321',
        'scope': ['scope1'],
        'expires_in': 3600,
        'http_status_code': 200
      };

      Map<String, dynamic> scope2Map = {
        'access_token': '1234567890',
        'token_type': 'Bearer',
        'refresh_token': '0987654321',
        'scope': ['scope2'],
        'expires_in': 3600,
        'http_status_code': 200
      };

      Map<String, Map> tokens = await storage.insertToken(AccessTokenResponse.fromMap(scope1Map));

      expect(tokens, contains('scope1'));
      expect(tokens.containsKey('scope2'), false);

      when(secStorage.read('my_token_url')).thenAnswer((_) async => jsonEncode({
        'scope1': scope1Map
      }));

      tokens = await storage.insertToken(AccessTokenResponse.fromMap(scope2Map));

      expect(tokens, contains('scope2'));

    });

    test('Add token', () async {

      final Storage secStorage = SecureStorageMock();
      final TokenStorage storage = TokenStorage('my_token_url', storage: secStorage);

      Map<String, dynamic> scope1Map = {
        'access_token': '1234567890',
        'token_type': 'Bearer',
        'refresh_token': '0987654321',
        'scope': ['scope1'],
        'expires_in': 3600,
        'http_status_code': 200
      };

      await storage.addToken(AccessTokenResponse.fromMap(scope1Map));

    });

  });
}