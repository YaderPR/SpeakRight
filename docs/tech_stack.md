# SpeakRight - Stack Tecnológico

Para cumplir con el requerimiento de coste cero y el uso exclusivo de tecnologías open-source o con licencias gratuitas permisivas, y que además cuenten con soporte activo de la comunidad, el stack tecnológico seleccionado es el siguiente:

## 1. Framework Principal
*   **Flutter (Dart):** Código abierto (licencia BSD de 3 cláusulas), mantenido por Google y con una de las comunidades más dinámicas en el desarrollo móvil multiplataforma.

## 2. Reconocimiento de Voz Local (STT - On-Device)
La arquitectura de Speech-to-Text se ejecutará íntegramente de forma local sin requerir servicios en la nube.

*   **Motor de Inferencia Seleccionado:** **Sherpa-ONNX** (basado en el motor de ejecución multiplataforma **ONNX Runtime**).
*   **Licencia:** Apache 2.0 / MIT (Completamente gratuito y de código abierto).
*   **Integración en Flutter (In-Process vía Dart FFI):** 
    Para evitar que el sistema operativo móvil (Android/iOS) detenga un daemon/proceso en segundo plano por políticas de ahorro de recursos (OOM Killer), compilamos `sherpa-onnx` como bibliotecas nativas de C/C++ (`.so` / `.dylib`) y nos comunicamos directamente a través de **Dart FFI (Foreign Function Interface)**. Esto proporciona un rendimiento nativo de C++ directamente en el hilo de ejecución de la app.

### Modelos de Voz y Escalabilidad Dinámica
El uso de Sherpa-ONNX permite cargar distintos modelos dinámicamente según el hardware del dispositivo para no degradar la experiencia de usuario:
*   **Gama Baja / Media (Dispositivos con 2-3 GB RAM, CPUs antiguas):** Se utilizará por defecto **Moonshine (Tiny)**. Es un modelo optimizado de 27M de parámetros (~35MB) diseñado específicamente para streaming en dispositivos con recursos limitados. Logra latencias inferiores a **200ms** (tiempo real).
*   **Gama Alta:** Se permitirá la descarga opcional de modelos más complejos como **SenseVoice-Small** (modelo no autorregresivo de Alibaba, ultra rápido, 15x más rápido que Whisper y con capacidad de detectar emociones/eventos de audio) o modelos de **Whisper (Base/Small)** de OpenAI en formato ONNX, maximizando la precisión en dispositivos con hardware potente.

## 3. Conversión de Texto a IPA (Alfabeto Fonético Internacional)
*   **Base de datos local (CMUdict adaptado a IPA):** Empaquetaremos el diccionario de pronunciación CMU dict (mapeado a símbolos IPA) en una base de datos local SQLite o archivo indexado en los assets de la app.
*   **Servicio de traducción fonética en Dart:** Un módulo que procesará el texto de origen palabra por palabra y buscará su transcripción IPA de forma inmediata para mostrarla en pantalla como subtítulo.

## 4. Comparación de Textos (Algoritmo de Precisión)
*   **Alineación de Secuencias (Needleman-Wunsch / Levenshtein):** Implementación en Dart de algoritmos de alineación para comparar la transcripción obtenida por el STT contra el texto original. Esto nos permitirá calcular el porcentaje exacto de acierto e indicar visualmente cuáles palabras fueron pronunciadas correctamente, cuáles fallaron y cuáles fueron omitidas.

## 5. Base de Datos Local (Persistencia)
*   **SQLite (`sqflite` o `drift`):** Ideal para la indexación y búsquedas inmediatas en el diccionario de pronunciación de IPA.
*   **Isar o Hive:** Base de datos NoSQL rápida para almacenar el progreso del usuario, estadísticas diarias, configuraciones del sistema y textos de práctica.

## 6. Arquitectura y Gestión de Estado
*   **Patrón Arquitectónico:** Clean Architecture + MVVM (Model-View-ViewModel).
*   **Gestión de Estado:** **Riverpod** (`flutter_riverpod`), que proporciona un sistema de inyección de estado seguro, testeable y reactivo en Flutter.
*   **Inyección de Dependencias:** **GetIt** como service locator para el registro de los repositorios y casos de uso del dominio.
