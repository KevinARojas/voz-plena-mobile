import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/progress_service.dart';
import '../services/session_logger.dart';
import '../services/ai_service.dart';

class StoryDetailScreen extends StatefulWidget {
  final String title;
  final String content;
  final String imagePath;
  final String exerciseHint;

  const StoryDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imagePath,
    required this.exerciseHint,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  String _displayedText = "";
  bool _isPlaying = false;
  bool _isCompleted = false;
  Timer? _timer;

  final ProgressService _progressService = ProgressService();

  void _startReading() {
    if (_isPlaying) {
      _stopReading();
      return;
    }

    setState(() {
      _isPlaying = true;
      _displayedText = "";
      _isCompleted = false;
    });

    const duration = Duration(milliseconds: 45);
    int index = 0;

    _timer = Timer.periodic(duration, (timer) {
      if (index < widget.content.length) {
        setState(() => _displayedText += widget.content[index]);
        index++;
      } else {
        timer.cancel();
        _finishStory();
      }
    });
  }

  Future<void> _finishStory() async {
    setState(() {
      _isPlaying = false;
      _isCompleted = true;
    });

    try {
      // AI processing for reading analysis
      final aiResult = await AIService.analyzeVoice();
      final toneScore = aiResult.length > 1 ? aiResult[1] : 0.6;

      // Save progress using the service
      await _progressService.updateMetric('tone', toneScore);

      // Log session for analytics or history
      await SessionLogger.logSession(tipo: 'story', valores: [toneScore]);

      // Generate textual feedback
      final feedback = AIService.generateFeedback(aiResult);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Lectura completada — ${(toneScore * 100).toStringAsFixed(0)}%\n$feedback",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al analizar lectura: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopReading() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              widget.imagePath,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            widget.exerciseHint,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _displayedText.isEmpty
                                  ? "Presiona 'Leer cuento' para comenzar."
                                  : _displayedText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textDark,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          ElevatedButton.icon(
                            onPressed: _startReading,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPlaying
                                  ? AppColors.red
                                  : _isCompleted
                                  ? AppColors.green
                                  : AppColors.primary,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: Icon(
                              _isPlaying
                                  ? Icons.stop
                                  : _isCompleted
                                  ? Icons.check_circle
                                  : Icons.menu_book,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isPlaying
                                  ? "Detener"
                                  : _isCompleted
                                  ? "Completado"
                                  : "Leer cuento",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
