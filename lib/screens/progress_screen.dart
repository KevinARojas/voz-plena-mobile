import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import '../services/progress_service.dart';
import '../models/progress_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressService _progressService = ProgressService();
  ProgressModel? _progress;

  bool _highContrast = false;
  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadProgress();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highContrast = prefs.getBool('highContrast') ?? false;
      _textScale = prefs.getDouble('textScale') ?? 1.0;
    });
  }

  Future<void> _loadProgress() async {
    final data = await _progressService.loadProgress();
    setState(() => _progress = data);
  }

  /// 🧠 Genera feedback basado en desempeño promedio
  String _generateAdvice(ProgressModel data) {
    final avg = (data.volumeScore + data.toneScore + data.breathingScore) / 3;
    if (avg >= 0.8) return "Excelente desempeño 🎉 ¡Sigue así!";
    if (avg >= 0.6) return "Vas muy bien 💪, sigue practicando tu respiración.";
    if (avg >= 0.4)
      return "Buen inicio 👏, trata de mantener un ritmo constante.";
    return "Necesitas mejorar 💬. Intenta practicar más seguido y con calma.";
  }

  @override
  Widget build(BuildContext context) {
    final contrastText = _highContrast ? Colors.black : Colors.white;
    final secondaryText = _highContrast
        ? Colors.black87
        : Colors.white.withOpacity(0.8);

    if (_progress == null) {
      return Scaffold(
        backgroundColor: _highContrast ? Colors.white : AppColors.primary,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final items = [
      ('Volumen', _progress!.volumeScore),
      ('Tono', _progress!.toneScore),
      ('Respiración', _progress!.breathingScore),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Progreso",
          style: TextStyle(
            color: contrastText,
            fontSize: 22 * _textScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _highContrast
                ? [Colors.white, Colors.white]
                : [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadProgress,
            color: AppColors.accent,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 10),
                Text(
                  "¡Sigue practicando! 💪\nTu avance mejora cada día.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20 * _textScale,
                    fontWeight: FontWeight.w600,
                    color: contrastText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),

                // 📊 Tarjetas de progreso reales
                ...items.map(
                  (e) => _MetricCard(
                    label: e.$1,
                    value: e.$2,
                    textScale: _textScale,
                  ),
                ),

                const SizedBox(height: 24),

                // 💡 Consejo dinámico según desempeño
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: AppColors.accent,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "💡 Consejo del día:\n${_generateAdvice(_progress!)}",
                          style: TextStyle(
                            fontSize: 16 * _textScale,
                            color: AppColors.textDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Última actualización: ${_progress!.lastUpdated.toLocal().toString().split('.').first}",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14 * _textScale,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Versión 1.0.0",
                    style: TextStyle(
                      color: secondaryText.withOpacity(0.7),
                      fontSize: 14 * _textScale,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _progressService.resetProgress();
          await _loadProgress();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Progreso reiniciado"),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        label: const Text("Reiniciar"),
        icon: const Icon(Icons.refresh),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.textScale,
  });

  final String label;
  final double value;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final color = value > 0.65
        ? AppColors.green
        : value > 0.4
        ? AppColors.accent
        : AppColors.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 20 * textScale,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 16,
              color: color,
              backgroundColor: color.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(value * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16 * textScale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
