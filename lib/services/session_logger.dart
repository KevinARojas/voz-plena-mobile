import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class SessionLogger {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/voice_sessions.csv');

    // Si el archivo no existe, creamos encabezados
    if (!(await file.exists())) {
      await file.writeAsString(
        'fecha,tipo_ejercicio,valor_promedio,valores_raw\n',
        mode: FileMode.write,
      );
    }

    return file;
  }

  /// Registra una nueva sesión de ejercicio con sus valores
  static Future<void> logSession({
    required String tipo,
    required List<double> valores,
  }) async {
    try {
      final file = await _getFile();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final avg = valores.isEmpty
          ? 0.0
          : valores.reduce((a, b) => a + b) / valores.length;

      final rawData = valores.map((v) => v.toStringAsFixed(3)).join('|');

      await file.writeAsString(
        '$now,$tipo,${avg.toStringAsFixed(3)},$rawData\n',
        mode: FileMode.append,
      );
      print('✅ Sesión registrada en CSV: $tipo ($avg)');
    } catch (e) {
      print('⚠️ Error al guardar sesión: $e');
    }
  }

  /// Lee todas las sesiones guardadas
  static Future<String> readLog() async {
    final file = await _getFile();
    return file.readAsString();
  }

  /// Limpia el historial si deseas reiniciar el progreso
  static Future<void> clearLog() async {
    final file = await _getFile();
    await file.writeAsString(
      'fecha,tipo_ejercicio,valor_promedio,valores_raw\n',
    );
  }
}
