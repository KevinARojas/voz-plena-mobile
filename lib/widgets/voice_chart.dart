import 'package:flutter/material.dart';

class VoiceChart extends StatelessWidget {
  final List<double> amplitudes;
  const VoiceChart({super.key, required this.amplitudes});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VoicePainter(amplitudes),
      size: const Size(double.infinity, 200),
    );
  }
}

class _VoicePainter extends CustomPainter {
  final List<double> amplitudes;
  _VoicePainter(this.amplitudes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (amplitudes.length + 1);

    for (int i = 0; i < amplitudes.length; i++) {
      final y = size.height / 2 - (amplitudes[i] * 80);
      if (i == 0) {
        path.moveTo(0, y);
      } else {
        path.lineTo(i * stepX, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_VoicePainter oldDelegate) =>
      oldDelegate.amplitudes != amplitudes;
}
