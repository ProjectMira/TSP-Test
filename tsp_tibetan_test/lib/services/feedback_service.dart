import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _correctPlayer.setSource(AssetSource('sounds/correct.wav'));
    await _incorrectPlayer.setSource(AssetSource('sounds/incorrect.wav'));
    await _correctPlayer.setVolume(0.7);
    await _incorrectPlayer.setVolume(0.7);
    _initialized = true;
  }

  Future<void> playCorrect() async {
    await _correctPlayer.stop();
    await _correctPlayer.play(AssetSource('sounds/correct.wav'));
    HapticFeedback.mediumImpact();
  }

  Future<void> playIncorrect() async {
    await _incorrectPlayer.stop();
    await _incorrectPlayer.play(AssetSource('sounds/incorrect.wav'));
    HapticFeedback.heavyImpact();
  }

  void dispose() {
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _initialized = false;
  }
}
