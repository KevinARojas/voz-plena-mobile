import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'exercise_detail_screen.dart';

class ExercisesMenuScreen extends StatelessWidget {
  const ExercisesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      {
        'title': 'Ejercicio de Volumen',
        'subtitle': 'Controla la fuerza de tu voz',
        'icon': Icons.volume_up_rounded,
        'color': AppColors.primary,
        'route': '/volume',
      },
      {
        'title': 'Ejercicio de Tono',
        'subtitle': 'Mejora tu entonación al hablar',
        'icon': Icons.graphic_eq_rounded,
        'color': AppColors.secondary,
        'route': '/tone',
      },
      {
        'title': 'Ejercicio de Respiración',
        'subtitle': 'Aprende a respirar mejor',
        'icon': Icons.air_rounded,
        'color': AppColors.accent,
        'route': '/breathing',
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ejercicios de Voz'),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, i) {
                final ex = exercises[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(
                          title: ex['title'] as String,
                          description: _getDescription(ex['title'] as String),
                          imagePath:
                              'assets/images/${_getImageName(ex['title'] as String)}',
                          route: ex['route'] as String,
                          color: ex['color'] as Color,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (ex['color'] as Color).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: (ex['color'] as Color).withOpacity(
                            0.15,
                          ),
                          radius: 36,
                          child: Icon(
                            ex['icon'] as IconData,
                            color: ex['color'] as Color,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex['title'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ex['subtitle'] as String,
                                style: TextStyle(
                                  color: AppColors.textDark.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String _getDescription(String title) {
  switch (title) {
    case 'Ejercicio de Volumen':
      return 'Habla con voz fuerte y constante. Practica mantener tu volumen estable mientras pronuncias frases o palabras.';
    case 'Ejercicio de Tono':
      return 'Emite sonidos largos y trata de mantener la misma nota sin variaciones. Esto ayuda a mejorar tu control tonal.';
    case 'Ejercicio de Respiración':
      return 'Inhala profundamente por la nariz y exhala lentamente. Este ejercicio te ayuda a mejorar tu control respiratorio.';
    default:
      return 'Ejercicio terapéutico para mejorar tus habilidades vocales.';
  }
}

String _getImageName(String title) {
  if (title.contains('Volumen')) return 'volume.png';
  if (title.contains('Tono')) return 'tone.png';
  if (title.contains('Respiración')) return 'breathing.png';
  return 'default.png';
}
