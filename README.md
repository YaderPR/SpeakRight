# SpeakRight

SpeakRight is a 100% local, privacy-first mobile application designed to help users practice and improve their English pronunciation. It functions completely offline without requiring any cloud APIs or internet connection, making pronunciation training cost-free and accessible on low-end devices (2-3GB RAM).

---

## Key Features Implemented

### 1. Local SQLite IPA Dictionary
*   **Offline Dictionary Database**: Pre-bundled SQLite dictionary containing over **125,000+ unique words** mapped to their International Phonetic Alphabet (IPA) representations.
*   **Batch Queries Optimization**: Fetches phonetic transcriptions for entire sentences in a single query transaction using SQL `IN` operators, minimizing roundtrip overhead.
*   **Contraction & Compound Handling**: Intelligently cleans leading and trailing punctuation (e.g. commas, periods) while preserving internal apostrophes (e.g., `don't`) and hyphens (e.g., `on-device`).
*   **Build-time Compilation**: Pre-seeded database generated from CMUdict-IPA using a Python pipeline script.

### 2. Hybrid On-Device STT (Speech-to-Text) Engine
*   **Dart FFI Bindings**: Uses `sherpa_onnx` with ONNX Runtime compiled libraries, running speech-to-text fully in-process to avoid termination by the OS low-memory killer.
*   **Hybrid Recognition Engine**: Supports two interchangeable speech recognition workflows, switching dynamically depending on the selected model:
    1.  **Online / Streaming (Real-time)**: Streams microphone audio chunk-by-chunk to an `OnlineRecognizer` (using Zipformer Streaming). Provides live transcriptions with **sub-500ms** latency.
    2.  **Offline / Batch (High-precision)**: Buffers raw recorded audio in memory and decodes the entire phrase at once using `OfflineRecognizer` (supporting Moonshine Tiny, SenseVoice Small, and Whisper Tiny models).
*   **Audio Pipeline Integration**: Captures raw mono 16kHz PCM audio buffers via the `record` package and converts them to normalized `Float32List` samples (`[-1.0, 1.0]`) on the fly.
*   **Native Memory Safety**: Properly frees allocated FFI native pointers and streams (`.free()`) to prevent native memory leaks during sessions.

---

## Tech Stack

*   **Framework**: Flutter (Dart)
*   **Speech Recognition**: `sherpa_onnx` (FFI native wrapper for ONNX Runtime)
*   **Local Database**: SQLite (`sqflite`) for the IPA lookup tables
*   **Audio Recording**: `record` package (PCM 16-bit streaming)
*   **State Management**: Riverpod (`flutter_riverpod`)
*   **Dependency Injection**: GetIt (`get_it`)

---

## Project Structure

The project strictly adheres to **Clean Architecture** patterns, divided into independent feature layers:

```
lib/
├── core/
│   ├── di/                 # Dependency injection registration (injection_container.dart)
│   ├── errors/             # Failure domain definitions (failures.dart)
│   └── usecases/           # Abstract usecase pattern contracts
├── data/
│   ├── datasources/        # Local SQLite data source wrappers
│   └── repositories/       # Concrete SQLite IPA and Sherpa-ONNX STT repositories
├── domain/
│   ├── entities/           # Core domain models (STTModelPackage, IPAWord, etc.)
│   ├── repositories/       # Abstract repository interfaces
│   └── usecases/           # Pronunciation evaluation and STT management usecases
└── presentation/
    ├── practice/           # Practice session screens, providers, and state
    └── settings/           # Model downloading and active language configuration settings
```

---

## Getting Started

### Prerequisites
*   Flutter SDK (v3.12.0 or newer)
*   Python 3.x (only if compiling or regenering the SQLite dictionary asset)

### 1. Generating the SQLite IPA Dictionary
The dictionary SQLite file is pre-generated, but if you want to rebuild it:
1.  Navigate to the `scripts/` directory:
2.  Install dependencies and run the script:
    ```bash
    python scripts/generate_ipa_db.py
    ```
    This script downloads CMUdict-IPA, parses the mappings, filters duplicates, and compiles a SQLite database into `assets/database/ipa_dictionary.db`.

### 2. Fetching Dependencies
Install the package dependencies (including `sherpa_onnx` and `record`):
```bash
flutter pub get
```

### 3. Running Tests
Run the automated test suite to verify the SQLite IPA repository and DI dependencies are correctly configured:
```bash
flutter test
```

### 4. Running the Application
Launch the app on your connected device or emulator:
```bash
flutter run
```
*(Note: To test Speech-to-Text, you must download at least one model package from the Settings screen inside the app).*
