import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool showPassword2 = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final first = firstCtrl.text.trim();
    final last = lastCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final pass2 = pass2Ctrl.text.trim();

    if ([first, last, email, phone, pass, pass2].contains("")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    if (pass != pass2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService().register(
        firstName: first,
        lastName: last,
        email: email,
        password: pass,
      );

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cuenta creada con éxito. Ahora inicia sesión."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  Widget breathingBackground(BuildContext context, Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * pi;
        final wave = 0.5 + 0.5 * sin(t);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8 + wave * 0.2),
                AppColors.secondary.withOpacity(0.8 + wave * 0.2),
                AppColors.accent.withOpacity(0.8 + wave * 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
    );
  }

  Widget input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primary,
                ),
                onPressed: toggle,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: breathingBackground(
        context,
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Crear cuenta",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      input(
                        label: "Nombre",
                        controller: firstCtrl,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),

                      input(
                        label: "Apellido",
                        controller: lastCtrl,
                        icon: Icons.badge_rounded,
                      ),
                      const SizedBox(height: 15),

                      input(
                        label: "Correo electrónico",
                        controller: emailCtrl,
                        icon: Icons.email_rounded,
                      ),
                      const SizedBox(height: 15),

                      input(
                        label: "Teléfono",
                        controller: phoneCtrl,
                        icon: Icons.phone_rounded,
                      ),
                      const SizedBox(height: 15),

                      input(
                        label: "Contraseña",
                        controller: passCtrl,
                        icon: Icons.lock_rounded,
                        obscure: !showPassword,
                        toggle: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                      const SizedBox(height: 15),

                      input(
                        label: "Confirmar contraseña",
                        controller: pass2Ctrl,
                        icon: Icons.lock_outline_rounded,
                        obscure: !showPassword2,
                        toggle: () =>
                            setState(() => showPassword2 = !showPassword2),
                      ),

                      const SizedBox(height: 25),

                      ElevatedButton(
                        onPressed: loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Crear cuenta",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "¿Ya tienes cuenta? Iniciar sesión",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
