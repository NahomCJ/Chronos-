import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class TtsService {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  // Set this when the user provides their ElevenLabs key
  static String? elevenLabsApiKey;
  static const String _voiceId = 'pNInz6obpgDQGcFmaJgB'; // Adam voice

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.95);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    if (elevenLabsApiKey != null && elevenLabsApiKey!.isNotEmpty) {
      await _speakElevenLabs(text);
    } else {
      await _speakFallback(text);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
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

  Future<void> _speakElevenLabs(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$_voiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': elevenLabsApiKey!,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_turbo_v2',
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
        }),
      );
      if (response.statusCode == 200) {
        // ElevenLabs audio playback requires audioplayers package
        // Until that's added, fall back to system TTS
        await _speakFallback(text);
      } else {
        await _speakFallback(text);
      }
    } catch (_) {
      await _speakFallback(text);
    }
  }
}
