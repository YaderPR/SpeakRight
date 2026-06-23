# SpeakRight - Stack Tecnológico

Para cumplir con el requerimiento de coste cero y el uso exclusivo de tecnologías open-source o con licencias gratuitas permisivas, y que además cuenten con soporte activo de la comunidad, el stack tecnológico seleccionado e implementado es el siguiente:

## 1. Framework Principal
*   **Flutter (Dart):** Código abierto (licencia BSD de 3 cláusulas), mantenido por Google y con una de las comunidades más dinámicas en el desarrollo móvil multiplataforma.

## 2. Reconocimiento de Voz Local (STT - On-Device)
La arquitectura de Speech-to-Text se ejecuta íntegramente de forma local sin requerir servicios en la nube.

*   **Motor de Inferencia Seleccionado:** **Sherpa-ONNX** (basado en el motor de ejecución multiplataforma **ONNX Runtime**).
*   **Licencia:** Apache 2.0 / MIT (Completamente gratuito y de código abierto).
*   **Integración en Flutter (In-Process vía Dart FFI):** 
    Para evitar que el sistema operativo móvil detenga un daemon/proceso en segundo plano por políticas de ahorro de recursos, compilamos `sherpa-onnx` como bibliotecas nativas de C/C++ y nos comunicamos directamente a través de **Dart FFI (Foreign Function Interface)**. Esto proporciona un rendimiento nativo de C++ directamente en el hilo de ejecución de la app.

### Enfoque Híbrido (Streaming vs Offline)
El motor STT soporta dos flujos de trabajo intercambiables, los cuales la aplicación gestiona de manera dinámica en base al modelo activo seleccionado por el usuario:
1.  **Modelos en Tiempo Real (Online / Streaming):**
    *   **Modelo de Referencia:** **Zipformer Streaming (English)** (~120MB).
    *   **Funcionamiento:** Captura audio del micrófono y lo envía en trozos (chunks) en tiempo real al `OnlineRecognizer` a través de un `OnlineStream`. Permite obtener la transcripción de forma inmediata mientras el usuario habla, con un delay inferior a **500-700ms**.
2.  **Modelos de Alta Precisión (Offline / Lote):**
    *   **Modelos de Referencia:** **Moonshine Tiny** (~35MB), **SenseVoice Small** (~120MB) o **Whisper Tiny** (~75MB).
    *   **Funcionamiento:** Graba el fragmento completo en un búfer en memoria y, al detener la grabación, procesa el búfer en su totalidad mediante el `OfflineRecognizer`. Logra la máxima precisión disponible en dispositivos de hardware limitado (2-3 GB RAM).

## 3. Conversión de Texto a IPA (Alfabeto Fonético Internacional)
*   **Base de Datos Local SQLite:** Un archivo pre-sembrado indexado en los assets del proyecto (`assets/database/ipa_dictionary.db`) que almacena la transcripción fonética IPA de **más de 125,000 palabras únicas** (derivado de CMUdict-IPA).
*   **Optimización de Consultas por Lote:** El repositorio realiza búsquedas en bloque utilizando sentencias SQL `IN` sobre los tokens de la frase, reduciendo las llamadas a base de datos de $N$ queries a un único viaje de base de datos.
*   **Manejo de Puntuación:** Filtra caracteres no fonéticos pero mantiene la integridad de contracciones (e.g. `don't`) y palabras compuestas (e.g. `on-device`).

## 4. Comparación de Textos (Algoritmo de Precisión)
*   **Alineación de Secuencias (Needleman-Wunsch / Levenshtein):** Implementación en Dart de algoritmos de alineación para comparar la transcripción obtenida por el STT contra el texto original. Esto nos permitirá calcular el porcentaje exacto de acierto e indicar visualmente cuáles palabras fueron pronunciadas correctamente, cuáles fallaron y cuáles fueron omitidas.

## 5. Base de Datos Local y Almacenamiento (Persistencia)
*   **SQLite (`sqflite`):** Usada para albergar el diccionario de pronunciación de IPA. El archivo de base de datos de solo lectura se copia dinámicamente desde los activos (assets) de solo lectura al directorio de documentos escribibles del dispositivo en el primer inicio de la app.
*   **Isar o Hive:** Base de datos NoSQL rápida para almacenar el progreso del usuario, estadísticas diarias, configuraciones del sistema y textos de práctica.

## 6. Arquitectura y Gestión de Estado
*   **Patrón Arquitectónico:** Clean Architecture + MVVM (Model-View-ViewModel).
*   **Gestión de Estado:** **Riverpod** (`flutter_riverpod`), que proporciona un sistema de inyección de estado seguro, testeable y reactivo en Flutter.
*   **Inyección de Dependencias:** **GetIt** como service locator para el registro de los repositorios y casos de uso del dominio.
