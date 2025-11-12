import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';

/// 🎙 Servicio de entrada de micrófono usando el paquete moderno `record`
/// Soporta análisis de volumen, tono y respiración en tiempo real.
class MicInputService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isInitialized = false;
  StreamSubscription<Amplitude>? _ampSubscription;
  StreamSubscription<List<int>>? _streamSubscription;

  /// Frecuencia de muestreo (solo relevante para FFT)
  final int _sampleRate = 16000;

  /// 🔧 Inicializa permisos y prepara el grabador
  Future<void> init() async {
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      throw Exception('Permiso de micrófono denegado');
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Permiso de micrófono no concedido al plugin record.');
    }

    _isInitialized = true;
    print('🎤 Micrófono inicializado correctamente');
  }

  /// ▶️ Inicia la escucha en tiempo real (volumen / tono / respiración)
  Future<void> startListening(
    void Function(double valor) onData, {
    String modo = "volumen",
  }) async {
    if (_isRecording) return;
    if (!_isInitialized) {
      throw Exception(
        'MicInputService no inicializado. Llama a init() antes de startListening().',
      );
    }

    _isRecording = true;

    // Configurar stream de audio PCM (para FFT)
    final config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
    );

    final audioStream = await _recorder.startStream(config);

    // 🔹 Para modo volumen: usar stream de amplitud
    if (modo == "volumen" || modo == "respiracion") {
      _ampSubscription = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amp) {
            // dB values are negative: -60 (silence) → 0 (max volume)
            // Convert to positive scale 0.0–1.0 (stronger voice = higher value)
            double db = amp.current;
            double normalized = ((db + 60) / 60).clamp(0.0, 1.0);
            onData(normalized);
          });
    }

    // 🔹 Para modo tono: procesar muestras reales de audio (FFT)
    if (modo == "tono") {
      _streamSubscription = audioStream.listen((data) {
        try {
          final bytes = Int16List.view(Uint8List.fromList(data).buffer);
          final signal = Float64List.fromList(
            bytes.map((x) => x.toDouble()).toList(),
          );

          final freq = _getDominantFrequency(signal, _sampleRate);
          onData(freq);
        } catch (e) {
          print("❌ Error procesando audio (FFT): $e");
        }
      });
    }

    print('🎧 Escuchando micrófono en modo $modo');
  }

  /// ⏹️ Detiene la captura
  Future<void> stopListening() async {
    if (!_isRecording) return;
    await _recorder.stop();
    await _ampSubscription?.cancel();
    await _streamSubscription?.cancel();
    _isRecording = false;
    print('⏹️ Micrófono detenido');
  }

  /// 🎵 Calcula la frecuencia dominante usando FFT
  double _getDominantFrequency(Float64List samples, int sampleRate) {
    final n = samples.length;
    if (n < 512) return 0.0;

    final mean = samples.reduce((a, b) => a + b) / n;
    final centered = Array(samples.map((v) => v - mean).toList());

    final window = Array(
      List.generate(n, (i) => 0.54 - 0.46 * cos(2 * pi * i / (n - 1))),
    );
    final windowed = centered * window;

    final complexSignal = ArrayComplex(
      windowed.map((v) => Complex(real: v, imaginary: 0.0)).toList(),
    );

    final spectrum = fft(complexSignal);
    final magnitudes = spectrum
        .map((c) => sqrt(c.real * c.real + c.imaginary * c.imaginary))
        .toList();

    int maxIndex = 0;
    double maxMag = 0;
    for (int i = 1; i < n ~/ 2; i++) {
      if (magnitudes[i] > maxMag) {
        maxMag = magnitudes[i];
        maxIndex = i;
      }
    }

    final freq = (maxIndex * sampleRate) / n;
    if (freq < 60 || freq > 800) return 0.0;
    return freq;
  }
}
