import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/mic_input_service.dart';
import '../../services/ai_service.dart';
import '../../services/progress_service.dart';
import '../../services/session_logger.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  final MicInputService _microfono = MicInputService();
  final ProgressService _progreso = ProgressService();

  bool _grabando = false;
  bool _micListo = false;
  double _nivelRespiracion = 0.0;
  double _suavizado = 0.0;
  double _puntaje = 0.0;
  final List<double> _historial = [];

  @override
  void initState() {
    super.initState();
    AIService.init();

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

  Future<void> _alternar() async {
    setState(() => _grabando = !_grabando);

    if (_grabando) {
      _puntaje = 0.0;
      _historial.clear();

      await _microfono.startListening((amp) {
        _suavizado = (_suavizado * 0.9) + (amp * 0.1);

        setState(() {
          _nivelRespiracion = _suavizado;
          _historial.add(_suavizado);
          if (_historial.length > 100) _historial.removeAt(0);
        });
      }, modo: "respiracion");
    } else {
      await _microfono.stopListening();

      try {
        final resultadoIA = await AIService.analyzeVoice();
        final respiracionScore = resultadoIA.length > 2 ? resultadoIA[2] : 0.0;
        _puntaje = respiracionScore;

        await _progreso.updateMetric('breathing', respiracionScore);
        await SessionLogger.logSession(tipo: 'breathing', valores: _historial);

        final retro = AIService.generateFeedback(resultadoIA);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$retro\nRespiración: ${(respiracionScore * 100).toStringAsFixed(1)}%',
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

  Color _colorPorRespiracion() {
    if (_nivelRespiracion > 0.75) return AppColors.green;
    if (_nivelRespiracion > 0.4) return AppColors.accent;
    return AppColors.red;
  }

  @override
  void dispose() {
    _microfono.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _grabando ? _colorPorRespiracion() : AppColors.accent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Ejercicio: Respiración"),
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
                  "Inhala y exhala suavemente.\nMantén el círculo verde con respiración constante.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 30),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 200 + (_nivelRespiracion * 120),
                  width: 200 + (_nivelRespiracion * 120),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.25 + _nivelRespiracion * 0.6),
                    border: Border.all(color: color, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: color,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text((_nivelRespiracion * 100).toStringAsFixed(0)),
                  ),
                ),

                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CustomPaint(
                      painter: _BarrasResp(values: _historial),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  _grabando
                      ? "Analizando respiración..."
                      : _puntaje > 0
                      ? "Puntaje: ${(100 * _puntaje).toStringAsFixed(0)}%"
                      : _micListo
                      ? "Presiona comenzar para iniciar"
                      : "Inicializando micrófono...",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _micListo ? _alternar : null,
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

class _BarrasResp extends CustomPainter {
  final List<double> values;
  _BarrasResp({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final ancho = size.width / (values.length * 1.5);
    final centroY = size.height / 2;

    for (var i = 0; i < values.length; i++) {
      final x = (i * ancho * 1.5) + ancho / 2;
      final h = values[i] * (size.height * 0.8);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, centroY), width: ancho, height: h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarrasResp oldDelegate) =>
      oldDelegate.values != values;
}
