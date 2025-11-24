import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../utils/colors.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _haptics = true;
  bool _highContrast = false;
  double _textScale = 1.0;

  String? userName;
  bool loadingUser = true;

  final List<Map<String, dynamic>> _buttons = [
    {
      'title': 'Ejercicios',
      'icon': Icons.record_voice_over,
      'color': AppColors.primary,
      'route': '/exercises',
    },
    {
      'title': 'Progreso',
      'icon': Icons.show_chart,
      'color': AppColors.green,
      'route': '/progress',
    },
    {
      'title': 'Cuentos',
      'icon': Icons.menu_book_rounded,
      'color': AppColors.secondary,
      'route': '/stories',
    },
    {
      'title': 'Configuración',
      'icon': Icons.settings_rounded,
      'color': AppColors.red,
      'route': '/settings',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _loadPreferences();
    _loadUserData();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _haptics = prefs.getBool('haptics') ?? true;
      _highContrast = prefs.getBool('highContrast') ?? false;
      _textScale = prefs.getDouble('textScale') ?? 1.0;
    });
  }

  Future<void> _loadUserData() async {
    try {
      final authUser = FirebaseAuth.instance.currentUser;

      if (authUser == null) {
        setState(() {
          userName = "Invitado";
          loadingUser = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();

      setState(() {
        userName = snap.data()?['firstName'] ?? 'Usuario';
        loadingUser = false;
      });
    } catch (e) {
      setState(() {
        userName = "Usuario";
        loadingUser = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate(String route) {
    if (_haptics) HapticFeedback.lightImpact();
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final contrastColor = _highContrast ? Colors.black : Colors.white;
    final secondaryTextColor = _highContrast ? Colors.black87 : Colors.white70;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Voz Plena",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22 * _textScale,
            color: contrastColor,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: BreathingBackgroundPainter(
              animation: _controller,
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    loadingUser ? "Cargando..." : "¡Hola, $userName!",
                    style: TextStyle(
                      fontSize: 28 * _textScale,
                      fontWeight: FontWeight.bold,
                      color: contrastColor,
                    ),
                  ),

                  Text(
                    "Elige una actividad para comenzar",
                    style: TextStyle(
                      fontSize: 16 * _textScale,
                      color: secondaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                      itemCount: _buttons.length,
                      itemBuilder: (context, i) {
                        final item = _buttons[i];
                        return _HomeCard(
                          title: item['title'],
                          icon: item['icon'],
                          color: item['color'],
                          textScale: _textScale,
                          highContrast: _highContrast,
                          onTap: () => _navigate(item['route']),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.85),
                        foregroundColor: AppColors.red,
                        minimumSize: const Size(200, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: AppColors.red.withOpacity(0.4),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Cerrar sesión",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double textScale;
  final bool highContrast;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.textScale,
    required this.highContrast,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: highContrast ? Colors.white : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 38),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18 * textScale,
                  fontWeight: FontWeight.bold,
                  color: highContrast ? Colors.black : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BreathingBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  BreathingBackgroundPainter({required this.animation, required this.colors})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final t = (animation.value * 2 * 3.1416);
    final waveHeight = 30 + 20 * (1 + sin(t)) / 2;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final path = Path();
    path.moveTo(0, size.height * 0.85);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height * 0.85 +
          sin((x / size.width * 3.1416 * 2) + t) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.8, size.width, 200));

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant BreathingBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
