import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  // key used to store custom audio path in SharedPreferences
  static const String _customAudioKey = 'custom_audio_path';

  // get saved custom audio path for a specific child
  static Future<String?> getCustomAudioPath(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_customAudioKey}_$childId');
  }

  // save custom audio path for a specific child
  static Future<void> saveCustomAudioPath(
      String childId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_customAudioKey}_$childId', path);
  }

  // remove custom audio for a specific child (revert to default)
  static Future<void> clearCustomAudioPath(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_customAudioKey}_$childId');
  }

  Future<void> playWhiteNoise({String? childId}) async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);

      // check for custom audio if childId provided
      if (childId != null && childId.isNotEmpty) {
        final customPath = await getCustomAudioPath(childId);
        if (customPath != null && File(customPath).existsSync()) {
          await _player.play(DeviceFileSource(customPath));
          _isPlaying = true;
          return;
        }
      }

      // fall back to default white noise asset
      await _player.play(AssetSource('audio/white_noise.mp3'));
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _player.dispose();
  }
}