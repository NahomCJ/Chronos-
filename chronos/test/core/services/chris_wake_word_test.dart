import 'package:flutter_test/flutter_test.dart';
import 'package:chronos_bank/core/services/chris_wake_word.dart';

void main() {
  group('ChrisWakeWord', () {
    test('detects hey Chris without a command', () {
      final wake = ChrisWakeWord.parse('hey Chris');

      expect(wake.triggered, isTrue);
      expect(wake.command, isEmpty);
    });

    test('captures a command spoken after the wake phrase', () {
      final wake = ChrisWakeWord.parse('Hey Chris, show my crypto dashboard');

      expect(wake.triggered, isTrue);
      expect(wake.command, 'show my crypto dashboard');
    });

    test('captures commands when punctuation separates hey and Chris', () {
      final wake = ChrisWakeWord.parse('hey, Chris what is my balance');

      expect(wake.triggered, isTrue);
      expect(wake.command, 'what is my balance');
    });

    test('supports a common Chris recognition variant', () {
      final wake = ChrisWakeWord.parse('hi Kris buy bitcoin');

      expect(wake.triggered, isTrue);
      expect(wake.command, 'buy bitcoin');
    });

    test('does not trigger on similar names', () {
      final wake = ChrisWakeWord.parse('hey Christine open the app');

      expect(wake.triggered, isFalse);
      expect(wake.command, isEmpty);
    });
  });
}
