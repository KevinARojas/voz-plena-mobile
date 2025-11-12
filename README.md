#  Voz Plena – Entrenamiento de Voz Asistido por IA

<img width="450" height="450" alt="logoo-splash" src="https://github.com/user-attachments/assets/c312fe26-8fce-4845-9068-b48810024ed4" />


**Voz Plena** es una aplicación móvil desarrollada en **Flutter** que ayuda a pacientes con rehabilitación vocal mediante ejercicios interactivos de volumen, tono y respiración, asistidos por **inteligencia artificial (IA)**.  
La app analiza la voz del usuario en tiempo real, proporciona retroalimentación visual y registra su progreso en una base de datos local con proyección hacia un sistema conectado a la nube.

---

##  Características principales

 **Ejercicios activos de voz**
- Detección de **volumen**, **tono** y **control respiratorio** mediante el micrófono.  
- Retroalimentación visual en tiempo real con animaciones dinámicas (colores verde, amarillo, rojo).

 **Entrenamiento guiado con IA**
- Análisis de patrones vocales mediante un modelo TensorFlow Lite (`voice_analyzer.tflite`).  
- Generación automática de puntajes y recomendaciones personalizadas.

 **Progreso del paciente**
- Registro automático de cada sesión.  
- Cálculo de promedios, mejores puntajes y evolución en el tiempo.

 **Módulo de cuentos interactivos**
- Lecturas con efecto de máquina de escribir.  
- Evaluación de tono y ritmo al finalizar cada cuento.

 **Configuración personalizable**
- Modo oscuro/claro, idioma, y parámetros de entrenamiento.  
- Guardado local (por ahora) con futura integración a base de datos remota.

---

##  Arquitectura del sistema

La aplicación está desarrollada bajo el patrón **MVCS (Model – View – Controller – Services)**.

lib/
├── screens/ # Interfaces de usuario (Volumen, Tono, Respiración, Cuentos)
├── services/ # Lógica de negocio (IA, micrófono, progreso, registro)
├── utils/ # Colores, constantes, helpers
└── main.dart # Punto de entrada




**Lenguaje y framework:**  
- Flutter 3.x (Dart)
- TensorFlow Lite para IA local
- SQLite o archivos CSV para persistencia temporal

---

##  Estructura de base de datos (en diseño)

Actualmente la app opera **de forma local**, pero la estructura normalizada prevista para la versión conectada es la siguiente:

| Tabla | Propósito |
|-------|------------|
| **users** | Registro de usuarios y roles (`admin`, `therapist`, `patient`) |
| **patients** | Datos clínicos del paciente y relación con terapeuta |
| **exercises** | Catálogo de ejercicios disponibles |
| **sessions** | Registro de cada práctica realizada |
| **progress** | Avance general por paciente y tipo de ejercicio |
| **ai_analysis** | Resultados del modelo IA por sesión |
| **stories** | Cuentos o lecturas para ejercicios de pronunciación |


---

##  Módulos funcionales actuales

| Módulo | Estado | Descripción |
|--------|---------|-------------|
| Volumen |  Completado | Mide la potencia vocal y proporciona feedback visual |
| Tono |  Completado | Analiza la frecuencia fundamental (Hz) y estabilidad tonal |
| Respiración |  Completado | Evalúa ritmo y control respiratorio |
| Cuentos |  Completado | Lecturas interactivas con IA y registro de avance |
| Configuración |  Parcial | Ajustes de idioma y visualización (efecto al reiniciar) |
| Progreso |  Parcial | Calcula métricas de avance (pendiente de visualización gráfica) |

---

##  Diagrama entidad–relación
<img width="900" height="600" alt="image" src="https://github.com/user-attachments/assets/6695f511-6b79-4396-a5c5-d4a89a273d3f" />

> *La base de datos actual funciona en local (CSV / SQLite), pero la estructura anterior servirá para la conexión remota en la versión final.*

---

##  Tecnologías utilizadas

| Categoría | Herramientas |
|------------|---------------|
| Frontend | Flutter, Dart |
| Backend / IA | TensorFlow Lite |
| Almacenamiento local | CSV, SQLite/Firebase (en progreso) |
| Control de versiones | Git, GitHub |
| Diseño | Figma, Lucidchart (ERD, flujo UI) |

---

---

##  Plan de trabajo (fase final)

| Fase | Actividades | Fecha estimada |
|------|--------------|----------------|
|  Integración BD remota | Conexión con Firebase | 1 semanas |
|  Configuración en tiempo real | Aplicación inmediata de cambios de tema/idioma | 3 días |
|  Login | Registro y acceso de usuarios | 1 semana |
|  Entrega final | Versión estable y apk funcional | Próxima entrega |

---

##  Autores

**Kevin Rojas** – Desarrollador Fullstack y autor del proyecto  
[kevin.rojas18@tectijuana.edu.mx](mailto:kevin.rojas18@tectijuana.edu.mx)
[karg.1999@gmail.com](mailto:karg.1999@gmail.com)

---

## Licencia

© 2025 — Instituto Tecnológico de Tijuana.

---

>  *Proyecto desarrollado como parte del curso de Inteligencia Artificial – Voz Plena: Rehabilitación Vocal con IA.*


