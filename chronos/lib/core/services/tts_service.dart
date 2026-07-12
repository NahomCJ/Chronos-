import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

// Web-only import — compiled away on mobile
import 'tts_web_player.dart' if (dart.library.io) 'tts_web_player_stub.dart';

class TtsService {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _initialized = false;

  static const String _elevenLabsApiKey = String.fromEnvironment('ELEVEN_API_KEY');
  static const String _voiceId = 'pNInz6obpgDQGcFmaJgB'; // Adam voice
  static const String _backendBase = 'http://chronos.us-east-1.elasticbeanstalk.com';

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.95);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String text, {String? authToken}) async {
    if (text.isEmpty) return;
    if (kIsWeb) {
      await _speakWeb(text, authToken: authToken);
    } else {
      await _speakElevenLabs(text);
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _tts.stop();
  }

  // ── Web: call backend /api/ai/voice/synthesize → play blob URL ──────────────
  Future<void> _speakWeb(String text, {String? authToken}) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendBase/api/ai/voice/synthesize'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'text': text.length > 500 ? text.substring(0, 497) + '...' : text}),
      );
      if (response.statusCode == 200) {
        await playWebAudio(response.bodyBytes);
      } else {
        debugPrint('Backend synthesize error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Web TTS error: $e');
    }
  }

  // ── Mobile: call ElevenLabs directly → play bytes ──────────────────────────
  Future<void> _speakElevenLabs(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$_voiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _elevenLabsApiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_turbo_v2',
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
        }),
      );
      if (response.statusCode == 200) {
        final Uint8List audioBytes = response.bodyBytes;
        await _audioPlayer.stop();
        await _audioPlayer.play(BytesSource(audioBytes));
      } else {
        debugPrint('ElevenLabs error ${response.statusCode}: ${response.body}');
        await _speakFallback(text);
      }
    } catch (e) {
      debugPrint('ElevenLabs TTS error: $e');
      await _speakFallback(text);
    }
  }

  Future<void> _speakFallback(String text) async {
    try {
      await _ensureInit();
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS fallback error: $e');
    }
  }
}
