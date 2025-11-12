import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _haptics = true;
  double _textScale = 1.0;
  bool _highContrast = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// 🔹 Cargar preferencias guardadas
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _haptics = prefs.getBool('haptics') ?? true;
      _textScale = prefs.getDouble('textScale') ?? 1.0;
      _highContrast = prefs.getBool('highContrast') ?? false;
    });
  }

  /// 🔹 Guardar preferencias
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics', _haptics);
    await prefs.setDouble('textScale', _textScale);
    await prefs.setBool('highContrast', _highContrast);

    if (_haptics) HapticFeedback.mediumImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias guardadas correctamente'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  /// 🔹 Restablecer valores por defecto
  Future<void> _resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias restablecidas'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
    setState(() {
      _haptics = true;
      _textScale = 1.0;
      _highContrast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Configuración'),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Preferencias de usuario",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔘 Vibración y feedback
                    _buildSwitchTile(
                      title: "Vibración y feedback háptico",
                      value: _haptics,
                      icon: Icons.vibration,
                      onChanged: (v) => setState(() => _haptics = v),
                    ),

                    const Divider(height: 24, thickness: 1.2),

                    // 🔠 Tamaño de texto
                    _buildSliderTile(
                      title: "Tamaño del texto",
                      icon: Icons.text_fields,
                      value: _textScale,
                      onChanged: (v) => setState(() => _textScale = v),
                      min: .8,
                      max: 1.6,
                    ),

                    const Divider(height: 24, thickness: 1.2),

                    // 🎨 Alto contraste
                    _buildSwitchTile(
                      title: "Alto contraste",
                      value: _highContrast,
                      icon: Icons.contrast,
                      onChanged: (v) => setState(() => _highContrast = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 💾 Guardar cambios
              ElevatedButton.icon(
                onPressed: _savePreferences,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Guardar cambios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
              ),

              const SizedBox(height: 16),

              // 🔄 Restablecer
              TextButton.icon(
                onPressed: _resetPreferences,
                icon: const Icon(Icons.restore, color: Colors.white70),
                label: const Text(
                  "Restablecer valores predeterminados",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Voz Plena © 2025",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔘 Switch personalizado
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // 🔠 Slider personalizado
  Widget _buildSliderTile({
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 26),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              "${(value * 100).round()}%",
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbColor: AppColors.secondary,
            activeTrackColor: AppColors.secondary,
            inactiveTrackColor: AppColors.secondary.withOpacity(0.3),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: 8,
          ),
        ),
      ],
    );
  }
}
