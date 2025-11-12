import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/mic_input_service.dart';
import '../../services/ai_service.dart';
import '../../services/progress_service.dart';
import '../../services/session_logger.dart';

class ToneScreen extends StatefulWidget {
  const ToneScreen({super.key});

  @override
  State<ToneScreen> createState() => _ToneScreenState();
}

class _ToneScreenState extends State<ToneScreen> {
  final MicInputService _microfono = MicInputService();
  final ProgressService _progreso = ProgressService();

  bool _grabando = false;
  bool _micListo = false;

  double _frecuencia = 0.0;
  double _frecuenciaSuavizada = 0.0;
  double _puntajeTono = 0.0;

  final List<double> _historial = [];

  @override
  void initState() {
    super.initState();
    AIService.init();

    // ✅ Initialize microphone before enabling button
    Future.microtask(() async {
      try {
        await Future.delayed(const Duration(milliseconds: 800));
        await _microfono.init();
        setState(() => _micListo = true);
        print('🎤 Micrófono listo para usar');
      } catch (e) {
        print('❌ Error al inicializar el micrófono: $e');
      }
    });
  }

  Future<void> _alternarGrabacion() async {
    setState(() => _grabando = !_grabando);

    if (_grabando) {
      _historial.clear();
      await _microfono.startListening((freq) {
        final f = freq.clamp(60.0, 800.0);
        _frecuenciaSuavizada = (_frecuenciaSuavizada * 0.8) + (f * 0.2);

        setState(() {
          _frecuencia = _frecuenciaSuavizada;
          _historial.add(f);
          if (_historial.length > 60) _historial.removeAt(0);
        });
      }, modo: "tono");
    } else {
      await _microfono.stopListening();

      try {
        final resultadoIA = await AIService.analyzeVoice();
        final tonoScore = resultadoIA.length > 1 ? resultadoIA[1] : 0.0;
        _puntajeTono = tonoScore;

        await _progreso.updateMetric('tone', tonoScore);
        await SessionLogger.logSession(tipo: 'tone', valores: _historial);

        final retro = AIService.generateFeedback(resultadoIA);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$retro\nTono: ${(tonoScore * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error durante el análisis: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 🎵 Convert frequency (Hz) to note (ex: 440Hz → A4)
  String _notaDesdeFrecuencia(double freq) {
    if (freq <= 0) return "-";
    const notas = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    const base = 440.0; // A4
    final semitonos = 12 * (log(freq / base) / ln2);
    final indice = (semitonos.round() + 9) % 12;
    final octava = 4 + ((semitonos.round() + 9) ~/ 12);
    return "${notas[indice]}$octava";
  }

  /// 🎨 Color dinámico según estabilidad del tono
  Color _colorPorTono() {
    if (_frecuencia > 500) return AppColors.green; // tono agudo y estable
    if (_frecuencia > 250) return AppColors.accent; // tono medio
    if (_frecuencia > 60) return AppColors.red; // tono bajo
    return Colors.grey; // sin voz detectada
  }

  @override
  void dispose() {
    _microfono.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _grabando ? _colorPorTono() : AppColors.accent;
    final nota = _notaDesdeFrecuencia(_frecuencia);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Ejercicio: Tono"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Mantén un tono estable.\nHabla hasta mantener el círculo en verde.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 30),

                // 🔵 Animated Circle showing frequency + color feedback
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(color: color, width: 10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${_frecuencia.toStringAsFixed(1)} Hz"),
                        const SizedBox(height: 4),
                        Text(nota, style: const TextStyle(fontSize: 34)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CustomPaint(
                      painter: _BarrasTono(values: _historial),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  _grabando
                      ? "Analizando tono..."
                      : _puntajeTono > 0
                      ? "Puntaje: ${(100 * _puntajeTono).toStringAsFixed(0)}%"
                      : _micListo
                      ? "Presiona comenzar para iniciar"
                      : "Inicializando micrófono...",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _micListo ? _alternarGrabacion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_micListo
                        ? Colors.grey
                        : _grabando
                        ? AppColors.red
                        : AppColors.primary,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    _grabando ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                  label: Text(
                    !_micListo
                        ? "Cargando..."
                        : _grabando
                        ? "Detener"
                        : "Comenzar",
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎚 Custom tone visualization bars
class _BarrasTono extends CustomPainter {
  final List<double> values;
  _BarrasTono({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    final ancho = size.width / (values.length * 1.5);
    final centroY = size.height / 2;
    for (var i = 0; i < values.length; i++) {
      final x = (i * ancho * 1.5) + ancho / 2;
      final h = (values[i] / 800.0) * (size.height * 0.8);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, centroY), width: ancho, height: h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarrasTono oldDelegate) =>
      oldDelegate.values != values;
}
