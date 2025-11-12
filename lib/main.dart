import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/exercises/volume_screen.dart' as volume;
import 'screens/exercises/tone_screen.dart';
import 'screens/exercises/breathing_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/session_result_screen.dart';
import 'screens/therapist_mode_screen.dart';
import 'screens/exercises/exercises_menu_screen.dart';

void main() => runApp(const VozPlenaApp());

class VozPlenaApp extends StatelessWidget {
  const VozPlenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voz Plena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/exercises': (_) => const ExercisesMenuScreen(),
        '/volume': (_) => const volume.VolumeScreen(),
        '/tone': (_) => const ToneScreen(),
        '/breathing': (_) => const BreathingScreen(),
        '/progress': (_) => const ProgressScreen(),
        '/stories': (_) => const StoriesScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/result': (_) => const SessionResultScreen(
          type: 'Volumen',
          score: 0.8,
          feedback: '¡Excelente control de voz!',
        ),
        '/therapist': (_) => const TherapistModeScreen(),
        // '/nlp': (_) => const NLPAnalysisScreen(),
      },
    );
  }
}
