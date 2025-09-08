# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Dose Reminder** is a cross-platform Flutter mobile application for Android and iOS designed to help users manage medication schedules. The app provides medicine management, flexible scheduling, smart notifications, dose history tracking, and personalization features with support for English and Polish languages.

## Quick Start Commands

```bash
# Get dependencies
flutter pub get

# Generate Hive adapters (required after model changes)
flutter packages pub run build_runner build

# Run on connected device/emulator
flutter run

# Run tests
flutter test

# Check for issues
flutter analyze

# Format code
flutter format .
```

## Common Development Commands

### Code Generation
```bash
# Generate Hive adapters after modifying models
flutter packages pub run build_runner build

# Watch for changes and auto-generate (useful during development)
flutter packages pub run build_runner watch

# Clean and rebuild generated files
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Platform-Specific Builds
```bash
# Android APK (debug)
flutter build apk --debug

# Android APK (release)
flutter build apk --release

# iOS (requires Mac and Xcode)
flutter build ios --release

# Windows (if targeting desktop)
flutter build windows
```

### Testing and Quality
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests (if any exist)
flutter test integration_test/

# Analyze code for issues
flutter analyze

# Format all Dart files
flutter format .
```

## Architecture Overview

### Core Architecture Pattern
- **State Management**: Flutter Riverpod with providers for dependency injection and state management
- **Database**: Hive (local NoSQL database) with generated adapters for type-safe serialization
- **Notifications**: flutter_local_notifications for scheduling and handling medication reminders
- **Localization**: Flutter's built-in l10n system supporting English and Polish

### Directory Structure
```
lib/
├── l10n/                           # Generated localization files
├── main.dart                       # App entry point with Hive/service initialization
└── src/
    ├── models/                     # Hive data models with type adapters
    │   ├── medicine.dart           # Medicine entity with scheduling properties
    │   ├── dose.dart              # Individual dose with status tracking
    │   └── *.g.dart               # Generated Hive adapters
    ├── services/                   # Business logic layer
    │   ├── database_service.dart   # Hive CRUD operations
    │   ├── scheduling_service.dart # Dose schedule generation logic
    │   ├── notification_service.dart # Local notification management
    │   └── settings_service.dart   # User preferences persistence
    ├── providers/                  # Riverpod providers for DI and state
    │   └── settings_provider.dart  # Theme and locale state management
    ├── views/                      # Screen-level widgets
    │   ├── splash_screen.dart      # App initialization screen
    │   ├── home_screen.dart        # Main dashboard with medicine list
    │   ├── add_edit_medicine_screen.dart # Medicine creation/editing form
    │   ├── medicine_details_screen.dart  # Full schedule view
    │   └── settings_screen.dart    # User preferences
    └── widgets/                    # Reusable UI components
        └── medicine_card.dart      # Medicine summary display widget
```

### Key Data Flow
1. **Medicine Creation**: Form → SchedulingService (generates doses) → DatabaseService (persists) → NotificationService (schedules reminders)
2. **Notification Handling**: System notification → NotificationService callback → DatabaseService (updates dose status) → UI refresh via Riverpod
3. **State Updates**: Service layer changes → Riverpod providers → UI rebuilds automatically

## Key Workflows

### Adding a New Medicine
1. User fills form in `AddEditMedicineScreen`
2. `Medicine` object created and initially saved to get database key
3. `SchedulingService.generateDoseSchedule()` creates `Dose` objects based on frequency/duration
4. Doses added to medicine's `doseHistory` (HiveList)
5. `NotificationService.scheduleDoseNotifications()` creates local notifications for future doses
6. UI refreshes via Riverpod provider invalidation

### Handling Dose Notifications
1. System displays notification with "Taken" and "Snooze" actions
2. User interaction triggers `NotificationService.onSelectNotification()` or action callback
3. Notification payload parsed to identify `medicineKey` and `scheduledTime`
4. `DatabaseService.updateDoseStatus()` finds and updates specific dose
5. UI automatically reflects changes through Riverpod watchers

### Modifying Models (Requires Code Generation)
1. Edit model files in `lib/src/models/`
2. Run `flutter packages pub run build_runner build` to regenerate adapters
3. Update any affected services or UI components
4. Test thoroughly as database schema changes can affect existing data

## Project Patterns

### Service Layer Pattern
- Services are singletons managed by Riverpod providers
- Each service has a single responsibility (database, scheduling, notifications, settings)
- Services communicate through dependency injection, not direct imports
- All async operations use Future/await pattern

### Hive Database Pattern
- Models extend `HiveObject` for automatic change tracking
- `HiveList<T>` used for one-to-many relationships (Medicine → Doses)
- Type adapters auto-generated with `@HiveType` and `@HiveField` annotations
- Database operations are async and use opened boxes

### Notification Architecture
- Each dose gets a unique notification ID based on medicine key and scheduled time
- Notification payloads contain JSON-serialized medicine key and timestamp
- Action buttons ("Taken", "Snooze") trigger different callback methods
- Snooze creates new notification 30 minutes later rather than rescheduling

### Riverpod State Management
- `Provider` for stateless services and computed values
- `StateNotifierProvider` for mutable state (theme, locale)
- `FutureProvider` for async data loading (medicines list)
- Consumer widgets watch providers and rebuild automatically on state changes

## Important Notes

### Medication Data Sensitivity
- This app handles sensitive health information
- All data is stored locally using Hive (no cloud sync by default)
- Notification handling must be reliable for medication adherence
- Consider data backup/restore implications for device changes

### Time Zone and Scheduling
- Uses `flutter_timezone` package for accurate local time scheduling
- Dose scheduling accounts for mid-day medication starts
- Notification times must be precise for medication effectiveness
- Be careful with daylight saving time transitions

### Platform Considerations
- Notification permissions required on both Android and iOS
- Background processing limitations may affect notification delivery
- Image picker requires camera/gallery permissions
- Consider platform-specific notification behavior differences

### Localization
- ARB files in `lib/l10n/` define translatable strings
- Run `flutter gen-l10n` after modifying ARB files
- Date/time formatting respects user locale settings
- Medical terminology should be reviewed by native speakers

## Troubleshooting

### Code Generation Issues
```bash
# Clean and regenerate all files
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Hive Database Issues
- Database corruption: Delete app data and reinstall
- Schema conflicts: Increment `@HiveType(typeId: X)` for breaking changes
- Box access errors: Ensure boxes are opened in main() before use

### Notification Problems
- Check platform-specific permissions in Android/iOS settings
- Verify notification service initialization in main()
- Test notification scheduling/handling with debug logging
- Consider device-specific battery optimization settings

### Build Issues
```bash
# Clean build cache
flutter clean
flutter pub get

# Platform-specific clean
cd android && ./gradlew clean && cd ..  # Android
cd ios && rm -rf build/ && cd ..       # iOS (Mac only)
```
