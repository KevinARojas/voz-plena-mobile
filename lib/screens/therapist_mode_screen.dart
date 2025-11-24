import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TherapistModeScreen extends StatelessWidget {
  const TherapistModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = [
      {'name': 'Kevin R.', 'type': 'Volumen', 'date': '13 Oct', 'score': 0.85},
      {'name': 'Ana M.', 'type': 'Tono', 'date': '12 Oct', 'score': 0.65},
      {
        'name': 'Luis C.',
        'type': 'Respiración',
        'date': '11 Oct',
        'score': 0.40,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Modo Terapeuta"), centerTitle: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (_, i) {
          final s = sessions[i];
          final score = s['score'] as double;
          final color = score > 0.7
              ? AppColors.green
              : score > 0.5
              ? AppColors.primary
              : AppColors.red;
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                "${s['name']} - ${s['type']}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              subtitle: Text("Fecha: ${s['date']}"),
              trailing: Text(
                "${((s['score']! as double) * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ver detalle de ${s['name']}')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Exportando datos...')));
        },
        label: const Text(
          'Exportar CSV',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.download, color: Colors.white),
      ),
    );
  }
}
