import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  AudioService._internal() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  bool _isMusicOn = true;

  bool get isMusicOn => _isMusicOn;

  Future<void> _init() async {
    // Set to loop endlessly
    await _player.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBGM() async {
    if (_isMusicOn) {
      if (_player.state == PlayerState.playing) return;
      // audioplayers automatically looks in assets/
      await _player.play(AssetSource('audio/Soundtrack.mp3'));
    }
  }

  Future<void> stopBGM() async {
    await _player.stop();
  }

  Future<void> toggleMusic(bool isOn) async {
    _isMusicOn = isOn;
    if (_isMusicOn) {
      await playBGM();
    } else {
      await stopBGM();
    }
  }

  void dispose() {
    _player.dispose();
  }
}
