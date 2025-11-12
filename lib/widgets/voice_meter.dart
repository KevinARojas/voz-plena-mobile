import 'package:flutter/material.dart';

class VoiceMeter extends StatelessWidget {
  const VoiceMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
        ),
      ),
      child: const Center(
        child: Icon(Icons.graphic_eq, color: Colors.white, size: 80),
      ),
    );
  }
}
