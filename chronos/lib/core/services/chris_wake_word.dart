class ChrisWakeCommand {
  final bool triggered;
  final String command;

  const ChrisWakeCommand._({
    required this.triggered,
    required this.command,
  });

  const ChrisWakeCommand.missed() : this._(triggered: false, command: '');

  const ChrisWakeCommand.detected([String command = ''])
      : this._(triggered: true, command: command);
}

class ChrisWakeWord {
  static final _wakePhrase = RegExp(
    r'\b(?:hey|hi)[\s,.;:!?-]+(?:chris|kris)\b',
    caseSensitive: false,
  );
  static final _leadingCommandNoise = RegExp(r'^[\s,.;:!?-]+');

  static ChrisWakeCommand parse(String transcript) {
    final match = _wakePhrase.firstMatch(transcript);
    if (match == null) return const ChrisWakeCommand.missed();

    final command = transcript
        .substring(match.end)
        .replaceFirst(_leadingCommandNoise, '')
        .trim();
    return ChrisWakeCommand.detected(command);
  }
}
