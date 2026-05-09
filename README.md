# foood

A Flutter application designed to simplify grocery shopping, meal planning, and recipe management.

## Features

- **Meal Planning**: Plan your weekly meals with ease.
- **Recipe Management**: Store and organize your favorite recipes, including ingredients and instructions.
- **Shopping Lists**: Automatically generate or manually create shopping lists to keep your pantry stocked.
- **Spin Wheel**: Use the interactive fortune wheel to help decide what to eat when you're feeling indecisive.
- **Persistent Storage**: All your data is saved locally using SQLite for offline access.

## Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/) (Material Design)
- **State Management**: [Riverpod](https://riverpod.dev/) (AsyncNotifier, StateProvider)
- **Database**: [Drift](https://drift.simonbinder.eu/) (formerly Moor) for reactive SQLite persistence.
- **Code Generation**: [build_runner](https://pub.dev/packages/build_runner) with `json_serializable` and `drift_dev`.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- Android Studio / VS Code with Flutter extensions

### Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/alejandroarroyo/foood.git
    cd foood
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate code**:
    Since the project uses `drift` and `json_serializable`, you need to run the build runner to generate necessary code:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app**:
    ```bash
    flutter run
    ```

### Installation
- run `flutter build apk --split-per-abi`
- run `flutter devices`
- run `flutter install --device-id <id-from-above-command> --use-application-binary="build/app/outputs/flutter-apk/<your-arch-file>"`

## Project Structure

- `lib/data/`: Database definition and Drift configurations.
- `lib/models/`: Data models and JSON serialization logic.
- `lib/notifiers/`: Business logic and state management using Riverpod.
- `lib/pages/`: Main application screens and views.
- `lib/repositories/`: Data access layer abstracting the database.
- `lib/providers/`: Riverpod provider definitions.
- `lib/partials/`: Reusable widgets and UI components.


The project follows a repository pattern to separate data concerns from the UI. UI state is managed via Riverpod notifiers, ensuring a reactive and testable codebase.

When modifying database schemas or models, remember to run the `build_runner` command to update the generated files.
