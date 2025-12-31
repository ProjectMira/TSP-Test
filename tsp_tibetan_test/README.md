# TSP Tibetan Test

A Flutter application for practicing past papers with bilingual support (English and Tibetan).

## Features

-   **Past Papers**: Browse and select past papers by year.
-   **Bilingual Support**: Toggle between English and Tibetan for questions and options.
-   **Timed Tests**: Practice with a timer to simulate exam conditions.
-   **Section Selection**: Start from the beginning or jump to specific sections.
-   **Scoring**: Get immediate feedback on your performance.

## Getting Started

### Prerequisites

-   Flutter SDK installed.
-   An editor (VS Code, Android Studio, etc.).

### Installation

1.  Clone the repository or download the source code.
2.  Navigate to the project directory:
    ```bash
    cd tsp_tibetan_test
    ```
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the app:
    ```bash
    flutter run
    ```

### Running on Emulators

To run the app on an emulator, follow these steps:

1.  **List available emulators:**
    ```bash
    flutter emulators
    ```

2.  **Launch an emulator:**
    -   **iOS Simulator:**
        ```bash
        flutter emulators --launch apple_ios_simulator
        ```
    -   **Android Emulator:**
        ```bash
        flutter emulators --launch Medium_Phone_API_36.0
        ```
        *(Note: Replace `Medium_Phone_API_36.0` with your specific emulator ID if different)*

3.  **Run the app:**
    Once the emulator is running, execute:
    ```bash
    flutter run
    ```
    If multiple devices are connected, specify the device ID:
    ```bash
    flutter run -d <device_id>
    ```

## Data

The app loads paper data from `assets/data/papers.json`. You can modify this file to add more papers, sections, and questions.

## Testing

Run the tests using:

```bash
flutter test
```
