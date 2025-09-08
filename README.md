# Dose Reminder Mobile Application

## 1. Project Purpose

This project is a cross-platform mobile application for Android and iOS designed to help users remember to take their medications. The application focuses on a clean, minimalistic, and user-friendly interface with robust scheduling and notification features.

### Core Features:
- **Medicine Management:** Add medicines by name or by taking a picture.
- **Flexible Scheduling:** Configure doses multiple times a day, every X days, or on specific days of the week.
- **Smart Scheduling:** The app intelligently adjusts the first day's schedule if the user starts their medication mid-day.
- **Customizable Reminders:** Notifications with "Taken" and "Snooze" actions. Grouped notifications for simultaneous doses.
- **Dose History:** Log and view the history of taken doses for each medicine.
- **Schedule Viewing:** See the full schedule for any medicine, with taken doses clearly marked.
- **Main Dashboard:** An at-a-glance view of all active medications, showing doses left and time until the next dose.
- **Personalization:**
    - Light, Dark, or System-based color themes.
    - English and Polish language options.
    - Small, Medium, and Large font sizes.
    - Multiple date and time formats (12/24h, yyyy-mm-dd, etc.).

## 2. Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Flutter Riverpod
- **Database:** Hive
- **Packages:**
    - `flutter_local_notifications`
    - `image_picker`
    - `permission_handler`
    - `intl`
    - `flutter_timezone`
    - `shared_preferences`

## 3. Development Plan

### Phase 1: Project Setup & Foundation (Complete)
- [x] Initialize Flutter Project.
- [x] Establish a clean directory structure.
- [x] Add all necessary dependencies (`riverpod`, `hive`, `image_picker`, etc.).

### Phase 2: Core Models & Business Logic (Complete)
- [x] Define core data models (`Medicine`, `Dose`) with Hive annotations.
- [x] Initialize the Hive database on app startup.
- [x] Create a placeholder `main.dart` to serve as the app's entry point.
- [x] Implement `DatabaseService` for CRUD operations on `Medicine`.
- [x] Implement `SchedulingService` to generate dose schedules based on medicine properties.

### Phase 3: UI - Screens & Widgets (Complete)
- [x] Develop the main dashboard screen (`HomeScreen`) with medicine cards.
- [x] Build the "Add/Edit Medicine" form (`AddEditMedicineScreen`) with all input fields.
- [x] Create the `MedicineCard` widget to display medicine summaries.
- [x] Implement the detailed "Medicine Schedule" view (`MedicineDetailsScreen`).
- [x] Integrate `AddEditMedicineScreen` with `DatabaseService` and `SchedulingService` to save new medicines and their schedules.
- [x] Update `HomeScreen` and `MedicineCard` to display real data from the database, including dose status.

### Phase 4: System Integration & Notifications (Complete)
- [x] Implement `NotificationService` for scheduling local notifications.
- [x] Initialize `NotificationService` on app startup.
- [x] Schedule notifications for all future doses when a medicine is added.
- [x] Implement notification actions ("Taken", "Snooze") and their corresponding logic to update dose status in the database.
- [x] Ensure notification payloads contain necessary data for action handling.

### Phase 5: Final Polish & Localization (Complete)
- [x] Implement `SettingsService` for managing user preferences (theme, language).
- [x] Create the `SettingsScreen` UI with options for theme and language selection.
- [x] Integrate theme switching functionality across the app.
- [x] Implement localization for English and Polish using Flutter's `l10n` system.
- [x] Replace all hardcoded strings in the UI with localized versions.
- [ ] Conduct final testing and debugging. (Ongoing)

## 4. Application Structure and Workflow

### Data Models (`lib/src/models`)
- `Medicine`: Represents a medication with properties like name, frequency, duration, preferred hours, and a list of associated `Dose` objects.
- `Dose`: Represents a single scheduled dose, including its scheduled time, actual taken time, and `DoseStatus` (pending, taken, skipped).

### Services (`lib/src/services`)
- `DatabaseService`: Manages persistence using Hive. Provides methods to add, retrieve, and update `Medicine` objects (which embed `Dose` objects).
- `SchedulingService`: The core logic for generating dose schedules. Takes a `Medicine` object and calculates all future `Dose` times based on frequency, duration, and preferred hours, including smart adjustments for mid-day starts.
- `NotificationService`: Handles local notifications. Initializes the `flutter_local_notifications` plugin, schedules individual dose reminders, and processes user interactions with notification actions (e.g., marking a dose as taken, snoozing).
- `SettingsService`: Manages user preferences (theme, language) using `shared_preferences` for persistent storage.

### State Management (`lib/src/providers`)
- Utilizes Flutter Riverpod for robust and scalable state management.
- `databaseServiceProvider`, `schedulingServiceProvider`, `notificationServiceProvider`, `settingsServiceProvider`: Riverpod `Provider`s that make the respective service instances available throughout the widget tree.
- `medicinesProvider`: A `FutureProvider` that asynchronously fetches and provides the list of all `Medicine` objects from the `DatabaseService` to the `HomeScreen`.
- `themeNotifierProvider`: A `StateNotifierProvider` that manages the app's current `ThemeMode` (system, light, dark) and persists the user's preference via `SettingsService`.
- `localeNotifierProvider`: A `StateNotifierProvider` that manages the app's current `Locale` (language) and persists the user's preference via `SettingsService`.

### User Interface (UI) / Views (`lib/src/views`)
- `HomeScreen`: The main dashboard displaying a list of `MedicineCard` widgets. Allows navigation to `AddEditMedicineScreen` and `SettingsScreen`.
- `AddEditMedicineScreen`: A form for adding new medicines. Collects all necessary details, generates the schedule, saves the `Medicine` object (with embedded `Dose`s) to the database, and schedules notifications.
- `MedicineDetailsScreen`: Displays the full schedule for a selected `Medicine`, showing each `Dose` with its status and scheduled time.
- `SettingsScreen`: Provides options for users to customize app settings like theme and language.

### Core Workflows

#### Adding a New Medicine
1.  User navigates to `AddEditMedicineScreen` from `HomeScreen`.
2.  User fills out the form (medicine name, frequency, duration, start time, preferred hours, optional photo).
3.  On save:
    a.  A `Medicine` object is created from form data.
    b.  The `Medicine` is initially saved to the `DatabaseService` to obtain its unique key.
    c.  The `SchedulingService` generates the full list of `Dose` objects for the `Medicine`.
    d.  These generated `Dose` objects are added to the `Medicine`'s `doseHistory` (a `HiveList`).
    e.  The `Medicine` object is saved again to persist the `doseHistory`.
    f.  The `NotificationService` schedules a local notification for each `Dose` in the future, passing the `medicineKey` and `scheduledTime` in the notification payload.
    g.  The `HomeScreen`'s `medicinesProvider` is invalidated to refresh the list.

#### Dose Reminders and Actions
1.  At the scheduled time, a local notification appears on the user's device.
2.  The notification displays the medicine name and includes action buttons: "Taken" and "Snooze (30 min)".
3.  If the user taps "Taken":
    a.  The `NotificationService`'s callback is triggered.
    b.  The payload is parsed to identify the `medicineKey` and `scheduledTime`.
    c.  The `DatabaseService` is called to update the specific `Dose`'s `status` to `DoseStatus.taken` and record the `takenTime`.
    d.  The UI (e.g., `HomeScreen`, `MedicineDetailsScreen`) automatically updates to reflect the change as Riverpod providers refresh.
4.  If the user taps "Snooze (30 min)":
    a.  The `NotificationService`'s callback is triggered.
    b.  A new notification is scheduled for 30 minutes later with a new unique ID, using the same medicine details.

#### Settings Management
1.  User navigates to `SettingsScreen` from `HomeScreen`.
2.  User selects preferences for theme or language.
3.  The `SettingsService` updates the `shared_preferences` storage.
4.  The respective Riverpod `StateNotifierProvider` (`themeNotifierProvider` or `localeNotifierProvider`) updates its state.
5.  The `MyApp` widget (which watches these providers) rebuilds, applying the new theme or locale to the entire application.
