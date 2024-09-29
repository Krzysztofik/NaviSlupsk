import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioState with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancja AudioPlayer
  bool _isMuted = false; // Stan wyciszenia

  bool get isMuted => _isMuted;

  // Funkcja do włączania/wyłączania dźwięku
  void toggleMute() {
    _isMuted = !_isMuted;
    stopSound();
    notifyListeners(); // Powiadomienie słuchaczy o zmianie stanu
  }

  // Funkcja do odtwarzania dźwięku
  Future<void> playSound(String soundFileName) async {
    if (!_isMuted) {
      await _audioPlayer.play(AssetSource('$soundFileName')); // Odtwarzanie dźwięku
    }
  }

  // Funkcja do zatrzymywania dźwięku
  Future<void> stopSound() async {
    await _audioPlayer.stop(); // Zatrzymywanie odtwarzania
  }
}