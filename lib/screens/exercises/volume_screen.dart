import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/mic_input_service.dart';
import '../../services/ai_service.dart';
import '../../services/progress_service.dart';
import '../../services/session_logger.dart';

class VolumeScreen extends StatefulWidget {
  const VolumeScreen({super.key});

  @override
  State<VolumeScreen> createState() => _VolumeScreenState();
}

class _VolumeScreenState extends State<VolumeScreen> {
  bool _grabando = false;
  bool _micListo = false; // ✅ Controla si el micrófono ya está listo
  double _amplitud = 0.0;
  double _puntajeVolumen = 0.0;
  double _amplitudSuavizada = 0.0;
  final List<double> _historial = [];

  final ProgressService _progreso = ProgressService();
  final MicInputService _microfono = MicInputService();

  @override
  void initState() {
    super.initState();
    AIService.init();

    // ✅ Inicializa el micrófono antes de habilitar el botón
    Future.microtask(() async {
      try {
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // pequeña espera
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
      _puntajeVolumen = 0.0;
      _historial.clear();

      await _microfono.startListening((amp) {
        final valor = amp.clamp(0.0, 1.0);
        _amplitudSuavizada = (_amplitudSuavizada * 0.8) + (valor * 0.2);

        setState(() {
          _amplitud = _amplitudSuavizada;
          _historial.add(_amplitudSuavizada);
          if (_historial.length > 60) _historial.removeAt(0);
        });
      }, modo: "volumen");
    } else {
      await _microfono.stopListening();

      try {
        final resultadoIA = await AIService.analyzeVoice();
        final puntaje = resultadoIA.isNotEmpty ? resultadoIA[0] : 0.0;
        _puntajeVolumen = puntaje;

        await _progreso.updateMetric('volume', puntaje);
        await SessionLogger.logSession(tipo: 'volume', valores: _historial);

        final retroalimentacion = AIService.generateFeedback(resultadoIA);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$retroalimentacion\nVolumen: ${(puntaje * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
            ),
          );
          setState(() {});
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

  /// 🎨 Color dinámico en tiempo real según volumen actual
  Color _colorPorNivel() {
    if (_amplitud > 0.75) return AppColors.green; // volumen fuerte
    if (_amplitud > 0.45) return AppColors.accent; // volumen medio
    return AppColors.red; // volumen bajo
  }

  @override
  void dispose() {
    _microfono.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _grabando ? _colorPorNivel() : AppColors.accent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Ejercicio: Volumen"),
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
                  "Habla con voz clara y constante.\nMantén el círculo en color verde.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 30),
                // 🟢 Círculo con animación suave de color
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    child: Text("${(_amplitud * 100).toStringAsFixed(0)}"),
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
                      painter: _Barras(values: _historial),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _grabando
                      ? "Analizando volumen..."
                      : _puntajeVolumen > 0
                      ? "Puntaje: ${(100 * _puntajeVolumen).toStringAsFixed(0)}%"
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

class _Barras extends CustomPainter {
  final List<double> values;
  _Barras({required this.values});

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
  bool shouldRepaint(covariant _Barras oldDelegate) =>
      oldDelegate.values != values;
}
