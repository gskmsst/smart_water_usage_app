# 💧 Smart Water Usage & Hydration Tracker

A modern, privacy-focused, cross-platform Flutter application designed to track personal hydration and household water consumption. Built with **Material 3**, **offline-first local SQLite**, and a frictionless **Guest-First** architecture.

---

## ✨ Features

- **🚀 Instant Guest Mode by Default**
  - No forced login or registration screens on launch.
  - New users jump straight into tracking their water intake within seconds.

- **🔐 Seamless Account Sync & Migration**
  - Sign in or create an account at any time from the **Account** tab.
  - Any water logs recorded while in Guest Mode are automatically transferred to your new account—no data is lost!

- **💾 Offline-First Local SQLite Database**
  - Powered by embedded SQLite (`sqflite`), completely eliminating external server dependencies (migrated from MySQL).
  - Works offline with zero latency, ensuring complete user data privacy.
  - Cross-platform support: Native SQLite on Android & iOS, FFI on Desktop (Linux/macOS/Windows), and WebAssembly (`sqlite3.wasm`) on Web.

- **📱 Mobile-First Responsive Design**
  - Modern Material 3 UI with a clean Teal & Ocean Blue color palette.
  - Smooth bottom navigation bar with 4 core views:
    1. **Tracker**: Circular progress ring, current intake vs. target, quick-add chips (+250 mL, +500 mL, +750 mL, +1000 mL), activity picker, and recent entries.
    2. **Analytics**: 7-day consumption bar charts powered by `fl_chart`, daily trends, peak intake, and progress benchmarks.
    3. **History**: Comprehensive list of all past logs grouped by date with activity icons and deletion support.
    4. **Account**: Guest/User status, custom daily target configuration, and data management.

- **📊 Categorized Water Usage**
  - Track diverse activities: Drinking 💧, Shower 🚿, Cooking 🍳, Gardening 🌱, Cleaning 🧹, Laundry 🧺, and Custom activities.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Dart 3.x)
- **Design System**: Material Design 3
- **Database**:
  - [sqflite](https://pub.dev/packages/sqflite) (Mobile)
  - [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) (Desktop)
  - [sqflite_common_ffi_web](https://pub.dev/packages/sqflite_common_ffi_web) (Web / Wasm)
- **Charts & Visualization**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Icons**: Cupertino Icons & Material Symbols

### Project Structure

```
smart_water_usage_app/
├── lib/
│   ├── main.dart             # Main entry point, UI navigation, Tracker, History & Account tabs
│   ├── analytics_screen.dart # 7-Day interactive bar charts, stats breakdown, and trends
│   └── db_helper.dart        # Database abstraction layer (SQLite schema, CRUD, guest transfer)
├── test/
│   └── widget_test.dart      # Smoke and UI widget tests
├── web/                      # Web platform scaffolding (includes sqlite3.wasm & sqflite_sw.js)
├── android/                  # Native Android configuration
├── linux/                    # Native Linux desktop runner
├── pubspec.yaml              # App configuration & package dependencies
└── README.md                 # Project documentation
```

---

## 🗄️ Database Schema

The local SQLite database (`water_tracker.db`) consists of three tables:

### 1. `users`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Unique user identifier |
| `username` | `TEXT UNIQUE` | Username (or `guest_user` for guest mode) |
| `password` | `TEXT` | User password |
| `is_guest` | `INTEGER` | `1` for Guest account, `0` for Registered |
| `created_at` | `TEXT` | Account creation timestamp (ISO 8601) |

### 2. `logs`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Log entry ID |
| `user_id` | `INTEGER` | Foreign key referencing `users(id)` |
| `amount` | `REAL` | Water volume recorded in mL |
| `activity` | `TEXT` | Category (Drinking, Shower, Cooking, etc.) |
| `timestamp` | `TEXT` | Time of entry (ISO 8601) |

### 3. `settings`
| Column | Type | Description |
| :--- | :--- | :--- |
| `user_id` | `INTEGER PRIMARY KEY` | Foreign key referencing `users(id)` |
| `daily_target` | `REAL` | User's daily water goal in mL (default: `2500.0`) |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.13.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- A target device:
  - **Mobile**: Android Studio / Xcode / connected Android or iOS device
  - **Desktop**: Linux (clang, cmake, gtk3), macOS, or Windows
  - **Web**: Google Chrome, Firefox, or any modern browser

### 1. Installation

Clone the repository and install the dependencies:

```bash
git clone https://github.com/your-username/smart_water_usage_app.git
cd smart_water_usage_app
flutter pub get
```

### 2. Running on Mobile (Android / iOS)

Connect your physical phone or launch an emulator, then execute:

```bash
flutter run
```

To build a standalone Android APK:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 3. Running on Desktop (Linux / macOS / Windows)

```bash
# On Linux
flutter run -d linux

# On macOS
flutter run -d macos

# On Windows
flutter run -d windows
```

### 4. Running on Web

To support SQLite in the browser, ensure the WebAssembly binaries are in place:

```bash
# Set up SQLite WebAssembly binaries (generates sqlite3.wasm and sqflite_sw.js in web/)
dart run sqflite_common_ffi_web:setup

# Run directly in Chrome
flutter run -d chrome
```

Or build a production web bundle:
```bash
flutter build web --release
# Serve build/web using any HTTP server:
python3 -m http.server 8080 --directory build/web
```

---

## 🧪 Testing & Code Quality

Run widget and integration tests:
```bash
flutter test
```

Perform static analysis to verify code health:
```bash
flutter analyze
```

---

## 💡 Key Architectural Highlights

- **Automatic Guest Data Transfer**: When a user decides to register or log in after tracking water as a guest, `DBHelper.transferGuestLogs(registeredUserId)` seamlessly reassigns all existing guest logs and target settings to the newly authenticated user profile.
- **Keyboard-Safe Bottom Sheets**: Water entry and authentication modal sheets dynamically adapt using `EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)` to ensure forms remain fully visible when virtual keyboards appear on mobile devices.
- **Dynamic Daily Progress**: The circular intake indicator recalculates in real-time based on the user's custom daily target, showing percentage, remaining balance, and celebratory cues upon reaching the goal.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
