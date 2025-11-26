# HealthMate – Personal Health Tracker App 💪🏃‍♀️💧

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite)
![License](https://img.shields.io/badge/License-MIT-green)

A modern, feature-rich Flutter mobile application for tracking daily health activities including steps, calories, and water intake.

[Features](#features) • [Screenshots](#screenshots) • [Installation](#installation) • [Architecture](#architecture) • [Documentation](#documentation)

</div>

---

## 📱 About

HealthMate is a cross-platform mobile application built with Flutter that helps users maintain a healthy lifestyle by tracking their daily health metrics. The app uses SQLite for local data persistence and Provider for state management, following clean architecture principles.

## ✨ Features

- ✅ **Track Daily Activities**: Record steps walked, calories burned, and water intake
- 📊 **Dashboard Summary**: View today's health metrics at a glance
- 📝 **Manage Records**: Full CRUD operations (Create, Read, Update, Delete)
- 🔍 **Search by Date**: Filter health records by specific dates
- 🎨 **Dark Blue Theme**: Modern, professional UI with color-coded metrics
- 💾 **Offline Storage**: All data stored locally using SQLite
- 📱 **Material Design**: Follows Material Design 3 guidelines
- ✏️ **Form Validation**: Input validation with helpful error messages
- 🗑️ **Swipe to Delete**: Easy record deletion with confirmation dialog
- 🔄 **Pull to Refresh**: Refresh records list with a simple gesture

## 🎯 Color-Coded Metrics

- 🟢 **Steps**: Green - Track your daily movement goals
- 🟠 **Calories**: Orange - Monitor calories burned
- 🔵 **Water**: Blue - Stay hydrated with water intake tracking

## 📸 Screenshots

> Dashboard • Records List • Add/Edit Record

## 🏗️ Architecture

The app follows **Clean Architecture** with **feature-based** folder structure:

```
lib/
├── main.dart
├── core/
│   ├── database/
│   │   └── database_helper.dart      # SQLite operations
│   └── theme/
│       └── app_theme.dart            # App theming
└── features/
    └── health_records/
        ├── models/
        │   └── health_record.dart
        ├── providers/
        │   └── health_record_provider.dart
        ├── screens/
        │   ├── dashboard_screen.dart
        │   ├── add_record_screen.dart
        │   └── records_list_screen.dart
        └── widgets/
            ├── summary_card.dart
            └── record_list_item.dart
```

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **SQLite (sqflite)** | Local database storage |
| **Provider** | State management |
| **intl** | Date formatting |
| **Material Design 3** | UI design system |

## 📦 Installation

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- Android Studio / VS Code with Flutter extensions

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd healthmatrecent
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build APK**
   ```bash
   flutter build apk --release
   ```
   APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## 🚀 Usage

1. **Add a Record**: Tap the floating action button on the dashboard
2. **View Records**: Navigate to the "Records" tab
3. **Search Records**: Use the date picker to filter by date
4. **Edit Record**: Tap on any record in the list
5. **Delete Record**: Swipe left on a record and confirm deletion

## 🗄️ Database Schema

**Table**: `health_records`

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Unique identifier |
| date | TEXT | Date in YYYY-MM-DD format |
| steps | INTEGER | Steps walked |
| calories | INTEGER | Calories burned |
| water | INTEGER | Water intake (ml) |

## 🧪 Testing

Run automated tests:
```bash
flutter test
```

**Test Coverage**:
- Model tests (serialization, validation, formatting)
- CRUD operations
- Form validation
- Date filtering

## 📚 Documentation

For detailed technical documentation, see:
- [Technical Documentation](docs/technical_documentation.md) - Complete technical guide
- [Implementation Plan](docs/implementation_plan.md) - Development roadmap
- [API Documentation](docs/api_docs.md) - Code documentation

## 🎨 Theme

**Primary Colors**:
- Dark Blue: `#0D47A1`
- Blue: `#1565C0`
- Accent Blue: `#42A5F5`

**Metric Colors**:
- Steps (Green): `#4CAF50`
- Calories (Orange): `#FF6F00`
- Water (Blue): `#2196F3`

## 👨‍💻 Development

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS (requires Mac for building)
- ⏳ Web (basic support)
- ⏳ Windows/Linux/macOS desktop (experimental)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- sqflite package maintainers
- Provider package for state management

---

<div align="center">

**Built with ❤️ using Flutter**

[Report Bug](issues) • [Request Feature](issues)

</div>
