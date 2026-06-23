# SpeakRight - Stack Tecnológico Propuesto

Para cumplir con el requerimiento de coste cero y el uso exclusivo de tecnologías open-source o con licencias gratuitas permisivas, y que además cuenten con soporte activo de la comunidad, proponemos el siguiente stack tecnológico:

## 1. Framework Principal
*   **Flutter (Dart):** Código abierto (licencia BSD de 3 cláusulas), mantenido por Google y con una de las comunidades más dinámicas en el desarrollo móvil multiplataforma.

## 2. Reconocimiento de Voz Local (STT - On-Device)

Para garantizar un funcionamiento fluido en dispositivos de gama media-baja (procesadores de 2020, 2-3 GB de RAM) y evitar problemas de rendimiento (lag, sobrecalentamiento, o cierres por falta de memoria/OOM), analizamos la viabilidad y alternativas a Whisper:

### Nota sobre Whisper.cpp en hardware limitado
> [!WARNING]
> **No se puede garantizar** una experiencia fluida con `whisper.cpp` en dispositivos de 2-3 GB de RAM y procesadores antiguos. El descodificado autorregresivo de Whisper es computacionalmente muy pesado. Incluso el modelo `tiny` (~75MB) puede tardar varios segundos en transcribir y consumir picos altos de RAM y CPU, lo que degradará la experiencia del usuario (haciendo que no se sienta "sin delay").

Debido a esto, proponemos las siguientes opciones de alta precisión y bajo consumo:

### Opción A: Sherpa-ONNX con modelos de última generación para Edge
Sherpa-ONNX es un framework de reconocimiento de voz local muy activo y optimizado para ejecutarse sobre el motor ONNX Runtime en dispositivos móviles. Nos permite usar modelos ultra-eficientes:
*   **Moonshine (Tiny - 27M params / ~35MB):** Desarrollado específicamente para streaming en dispositivos embebidos y móviles. Es extremadamente rápido (latencia sub-200ms) y consume una fracción de los recursos de Whisper manteniendo una precisión excelente para frases conversacionales.
*   **SenseVoice-Small (Alibaba):** Un modelo no autorregresivo (calcula todo el texto en una sola pasada en lugar de palabra por palabra). Es hasta 15 veces más rápido que Whisper y consume muy pocos recursos, además de ofrecer detección de emociones y eventos de audio (risas, tos, etc.).
*   **Licencia:** Apache 2.0 / MIT (Completamente gratuito y open-source).

### Escalabilidad Dinámica (Aprovechando la Gama Alta)
El uso de Sherpa-ONNX **no limita en absoluto a los dispositivos potentes**. La arquitectura nos permite implementar una descarga dinámica de modelos:
*   **Gama Baja/Media:** La app usará `Moonshine Tiny` por defecto para garantizar fluidez.
*   **Gama Alta:** La app puede detectar el hardware (o permitirle al usuario activar el "Modo Alta Precisión") y descargar automáticamente un modelo mucho más potente y pesado (como Whisper Base/Small o Moonshine Base/Medium), aprovechando toda la CPU/RAM disponible sin modificar el código interno del motor.

### Opción B: Vosk (`vosk_flutter`)
*   **Licencia:** Apache 2.0.
*   **Pros:** Es el campeón indiscutible en consumo de recursos. Puede correr fluidamente incluso en una Raspberry Pi Zero o teléfonos de gama muy baja sin impactar el rendimiento.
*   **Contras:** Su precisión es inferior a la de Moonshine o SenseVoice en oraciones complejas o cuando hay acentos muy marcados.

### Integración en Flutter (¿Daemon o In-Process?)
Para evitar que el sistema operativo (Android/iOS) cierre un proceso de fondo/demonio secundario debido a sus estrictas políticas de gestión de batería y memoria (OOM Killer), la mejor arquitectura es **In-Process a través de Dart FFI (Foreign Function Interface)**:
1. Compilar los motores STT (como `sherpa-onnx` o `vosk`) como bibliotecas nativas de C/C++ (`.so` para Android, `.dylib`/framework para iOS).
2. Comunicar Flutter directamente con estas bibliotecas a través de FFI.
3. Esto elimina el overhead de red/comunicación local (APIs de loopback) y ejecuta el STT a la máxima velocidad permitida por el hardware en el mismo proceso de la app.

## 3. Conversión de Texto a IPA (Alfabeto Fonético Internacional)
Dado que no hay servicios de red gratuitos y confiables que funcionen sin conexión para esto, la mejor opción es:
*   **Base de datos local (CMUdict adaptado a IPA):** Empaquetaremos el diccionario de pronunciación CMU dict (mapeado a símbolos IPA) en una base de datos ligera (SQLite) o archivo indexado en los assets de la app.
*   **Servicio de traducción fonética en Dart:** Un módulo que tokenice el texto de origen y busque la fonética de cada palabra en nuestra base de datos local para mostrarla al instante como "subtítulos".

## 4. Comparación de Textos (Algoritmo de Acierto / Similitud)
*   **Algoritmos de similitud de cadenas:** Uso de métricas como la Distancia de Levenshtein, Coeficiente de Dice o Jaro-Winkler para comparar la transcripción devuelta por el STT contra el texto de referencia.
*   **Librerías propuestas:** `string_similarity` (Dart) o implementaciones custom en Dart de algoritmos de alineación de secuencias (como Needleman-Wunsch, que es ideal para saber exactamente qué palabras fallaron o se omitieron).

## 5. Base de Datos Local (Persistencia)
*   **SQLite (`sqflite` o `drift`):** Ideal para la base de datos de IPA por su capacidad de indexación y búsquedas rápidas.
*   **Isar o Hive:** Bases de datos NoSQL rápidas en Dart para almacenar el progreso del usuario, estadísticas, configuraciones y textos de práctica.

## 6. Arquitectura y Gestión de Estado
*   **Riverpod o BLoC:** Frameworks de gestión de estado líderes en Flutter. Ambos son open-source, maduros y con soporte masivo de la comunidad.
