# AI Tutor

AI Tutor is an Android learning assistant that uses an on-device large language model to help students study from their own notes and documents. Users can chat with the tutor, ask questions about PDFs or images, generate quizzes and flashcards, review previous results, and organize study material into reusable "Gems".

**Team:** BitByBit (Team 12)

## Features

### AI-assisted learning

- General chat with an on-device LLM.
- PDF-grounded questions using extracted document text.
- Image questions using OCR text recognition.
- Follow-up questions with short-term conversation memory.
- Context reset when the user changes or clears a document/image.

### Quizzes and adaptive practice

- Generate multiple-choice quizzes from PDF content.
- Choose quiz difficulty and question count.
- Submit answers and receive a score with question-level results.
- Store quiz history per user and open detailed past results.
- Identify weak topics from recent quizzes and include them in future quiz prompts.

### Flashcards and study material

- Generate flashcards from PDF content or create flashcard sets manually.
- Browse saved sets and study cards in a dedicated study mode.
- Export flashcard sets to PDF.

### Organization and account flow

- Login and registration screens for separate local user profiles.
- Home dashboard with counts for chat sessions, analyzed documents, and saved Gems.
- Create a Gem with a name, description, PDF, and/or image.
- Start a chat or generate a quiz directly from a Gem.
- Browse, reopen, and delete saved chat sessions.
- Logout without removing the user-specific learning data stored locally.

## How It Works

The app is organized around a small set of Android activities and local managers:

1. `MainActivity` checks the local login state and routes the user to login or home.
2. `HomeActivity` provides the main dashboard and launches chat, document, quiz, flashcard, and Gem workflows.
3. `Conversation` accepts a normal prompt, PDF, or image. PDFBox extracts PDF text, while Google ML Kit extracts text from images.
4. The extracted context, recent conversation, and current question are combined into a prompt.
5. `GenieWrapper` starts and communicates with the persistent `genie-app` process, which runs the model locally using the Genie runtime and Qualcomm hardware acceleration when available.
6. `QuizActivity` and `FlashcardPdfGeneratorActivity` send structured generation prompts to the same model and parse the returned content into app data models.
7. `ChatSessionManager` serializes chat sessions with Gson. User accounts, Gems, quiz results, and counters are stored in Android `SharedPreferences`.

### Conversation context

The chat keeps the latest three user-assistant exchanges in memory. A prompt can contain document context, recent conversation, and the current question while staying within the model's 1024-token context window. History is cleared when the active document or image context changes.

### Quiz personalization

After each quiz, incorrectly answered questions are analyzed to extract weak topics. The most recent five quizzes are considered, and topics from quizzes below 80% are added to the next quiz-generation prompt. This makes later quizzes focus on areas that need more practice without requiring a server-side recommendation system.

### Local-first data model

The current implementation is local-first. Chat sessions are stored as JSON through Gson, while lightweight account state, quiz history, Gems, and progress counters use `SharedPreferences`. No MongoDB client or remote synchronization layer is currently implemented; the MongoDB guide is retained as project documentation space for future work.

## Technology Stack

| Area | Technology |
| --- | --- |
| Platform | Android 12+ devices (minimum API 31) |
| Language | Java |
| UI | Android Views, XML layouts, AndroidX AppCompat, Material Components, ConstraintLayout, RecyclerView |
| Build | Gradle, Android Gradle Plugin, Android Studio |
| AI runtime | Qualcomm Genie SDK / QAIRT, with Qualcomm NPU acceleration where supported |
| Model format | Genie configuration and QNN context binaries |
| PDF processing | Apache PDFBox Android `2.0.27.0` |
| OCR | Google ML Kit Text Recognition `16.0.0` |
| Serialization | Gson `2.10.1` |
| Persistence | Android `SharedPreferences` |
| Native/runtime assets | Genie executable, model binaries, JSON configuration, and Android JNI libraries |

## Project Structure

```text
AI-Tutor/
├── Code/
│   └── ai-hub-apps-main-Kartik/
│       ├── apps/android/ChatApp/       # Main Android application
│       │   ├── src/main/java/          # Activities, adapters, model and utility classes
│       │   ├── src/main/res/            # XML layouts, menus, strings and themes
│       │   ├── src/main/assets/         # Genie configuration and model assets
│       │   └── build.gradle             # Android dependencies and build configuration
│       └── apps/android/                # Android project and supporting documentation
├── Demos/                               # Demo videos, images, or links
├── Presentation/                        # Final presentation files
└── Report/                              # Project report material
```

## Requirements

- Android Studio 2024.3.1 or newer.
- Linux, macOS, or Windows host machine.
- Android device with API 31 or newer.
- A compatible Snapdragon device or Qualcomm Device Cloud (QDC) session for tested NPU acceleration.
- Git LFS, if model binaries are tracked through Git LFS.
- A Genie model bundle containing the model binaries, `genie_config.json`, tokenizer, and the required Genie executable.

The original Qualcomm setup documentation is available at [Code/ai-hub-apps-main-Kartik/apps/android/ChatApp/README.md](Code/ai-hub-apps-main-Kartik/apps/android/ChatApp/README.md). It describes how to export or download model assets and prepare a QDC device.

## Build and Run

1. Clone the repository with Git LFS enabled.
2. Open the `Code/ai-hub-apps-main-Kartik/apps/android` directory in Android Studio. Open the parent `android` directory, not the `ChatApp` module directly.
3. Place the Genie model bundle on the target device at:

	```text
	/data/local/tmp/genie_bundle
	```

4. Ensure the bundle contains the model binaries and configuration expected by `GenieWrapper`.
5. Connect an Android device or start a compatible emulator/device session.
6. Sync Gradle and build the `ChatApp` target.
7. Install and run the generated APK from `apps/android/ChatApp/build/outputs/apk/`.

The Gradle file currently uses a placeholder QAIRT path because model execution is started through the device-side Genie process. For a standard QAIRT/native build, configure the local SDK path and native build settings described in the app README.

## Important Limitations

- Model execution depends on a compatible Genie bundle and device runtime.
- The bundled model has a 1024-token context window, so PDF and conversation text are truncated to leave room for the generated answer.
- Chat context is intentionally limited to recent exchanges and is reset when the source document changes.
- Authentication and learning data are stored locally; there is no production backend, account synchronization, or MongoDB integration yet.
- NPU acceleration is device-dependent. The app can run without NPU acceleration on unsupported Snapdragon configurations, but performance may be lower.
- The original sample app reports compatibility limitations on some consumer Android 14 devices. Qualcomm Device Cloud is recommended for reliable testing.

## Supporting Documentation

- [Android app setup and model deployment](Code/ai-hub-apps-main-Kartik/apps/android/ChatApp/README.md)
- [Conversation history implementation](Code/ai-hub-apps-main-Kartik/apps/android/CONVERSATION_HISTORY_FEATURE.md)
- [Quiz personalization implementation](Code/ai-hub-apps-main-Kartik/apps/android/QUIZ_PERSONALIZATION_IMPLEMENTATION.md)
- [Android quickstart](Code/ai-hub-apps-main-Kartik/QUICKSTART.md)

## License

The Android application is based on Qualcomm AI Hub Apps and is released under the [BSD-3-Clause license](Code/ai-hub-apps-main-Kartik/LICENSE). Model files and the Qualcomm QAIRT/Genie SDK are distributed under their own licenses; consult the license included with each dependency before redistribution.
 
