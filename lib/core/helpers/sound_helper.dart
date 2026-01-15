import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCorrect() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/correct.mp3'));
  }

  static Future<void> playWrong() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/wrong.mp3'));
  }

  static Future<void> playSuccess() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/success.mp3'));
  }
}
