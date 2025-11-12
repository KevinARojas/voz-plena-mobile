import 'dart:async';
import 'dart:math';
import 'package:flutter_sound/flutter_sound.dart';

/// Handles microphone input for multiple voice training modes.
class MicInputService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  StreamSubscription? _subscription;

  /// Initializes the recorder safely.
  Future<void> init() async {
    if (_isInitialized) return;
    await _recorder.openRecorder();
    _isInitialized = true;
  }

  /// Starts listening to the microphone and emits processed values depending on mode.
  ///
  /// Modes:
  /// - "volume": normalized amplitude (0–1)
  /// - "tone": estimated frequency in Hz
  /// - "breathing": smoothed breathing level (0–1)
  Future<void> startListening(
    void Function(double value) onData, {
    String mode = "volume",
  }) async {
    if (!_isInitialized) await init();

    // Simulated mic input (replace with real FFT plugin for production)
    _subscription = Stream.periodic(const Duration(milliseconds: 100), (i) {
      final amp = Random().nextDouble();

      switch (mode) {
        case "volume":
          return amp;
        case "tone":
          // Simulated frequency between 100–400Hz with oscillation
          return 100 + (sin(i / 5) * 150 + 200);
        case "breathing":
          // Smooth amplitude oscillation to simulate inhale/exhale
          return 0.5 + sin(i / 10) * 0.3;
        default:
          return amp;
      }
    }).listen((val) => onData(val.toDouble()));
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stopListening();
    await _recorder.closeRecorder();
  }
}
