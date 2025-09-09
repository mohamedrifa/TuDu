import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class EffectService {
  EffectService._privateConstructor();
  static final EffectService _instance = EffectService._privateConstructor();
  factory EffectService() => _instance;

  final AudioPlayer player = AudioPlayer();

  Future<void> play(String path) async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(DeviceFileSource(path));
  }

  Future<void> playAsset(String assetPath) async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource(assetPath));
  }

  Future<void> startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 1000], // vibrate, pause, vibrate, pause
          repeat: 0, // repeat indefinitely from index 0
      );
    }
  }

  Future<void> stopEffect() async {
    await player.stop();
    await Vibration.cancel();
  }
}
