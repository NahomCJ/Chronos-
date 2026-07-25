import 'package:chronos_bank/core/network/api_client.dart';
import 'package:chronos_bank/features/auth/data/services/token_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late TokenStorageService tokenStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tokenStorage = TokenStorageService(await SharedPreferences.getInstance());
  });

  test(
    'postBytesWithBase returns audio bytes and normalized content type',
    () async {
      final client = ApiClient(
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://voice.example/api/synthesize',
          );
          expect(request.headers['content-type'], 'application/json');
          expect(request.body, '{"text":"Hello from Chris"}');
          return http.Response.bytes(
            [0x49, 0x44, 0x33],
            200,
            headers: {'content-type': 'audio/mpeg; charset=binary'},
          );
        }),
        tokenStorage: tokenStorage,
      );

      final audio = await client.postBytesWithBase(
        'https://voice.example',
        '/api/synthesize',
        {'text': 'Hello from Chris'},
      );

      expect(audio.bytes, [0x49, 0x44, 0x33]);
      expect(audio.contentType, 'audio/mpeg');
    },
  );

  test('postBytesWithBase keeps a missing content type nullable', () async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response.bytes([0x01], 200)),
      tokenStorage: tokenStorage,
    );

    final audio = await client.postBytesWithBase(
      'https://voice.example',
      '/api/synthesize',
      {'text': 'Hello'},
    );

    expect(audio.bytes, [0x01]);
    expect(audio.contentType, isNull);
  });

  test('postBytesWithBase surfaces API errors', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          '{"error":"Voice unavailable"}',
          502,
          headers: {'content-type': 'application/json'},
        ),
      ),
      tokenStorage: tokenStorage,
    );

    expect(
      () => client.postBytesWithBase(
        'https://voice.example',
        '/api/synthesize',
        {'text': 'Hello'},
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Voice unavailable'),
        ),
      ),
    );
  });
}
