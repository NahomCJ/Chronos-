import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<void> playWebAudio(Uint8List bytes) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'audio/mpeg'),
  );
  final url = web.URL.createObjectURL(blob);
  final audio = web.HTMLAudioElement();
  audio.src = url;
  audio.play();
  // Revoke the blob URL after playback to free memory
  audio.onEnded.listen((_) => web.URL.revokeObjectURL(url));
}
