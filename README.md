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

## 3. Development Plan

### Phase 1: Project Setup & Foundation (Complete)
- [x] Initialize Flutter Project.
- [x] Establish a clean directory structure.
- [x] Add all necessary dependencies (`riverpod`, `hive`, `image_picker`, etc.).

### Phase 2: Core Models & Business Logic
- [ ] Define core data models (`Medicine`, `Dose`) with Hive annotations.
- [ ] Initialize the Hive database on app startup.
- [ ] Create a placeholder `main.dart` to serve as the app's entry point.

### Phase 3: UI - Screens & Widgets
- [ ] Develop the main dashboard screen with medicine cards.
- [ ] Build the "Add/Edit Medicine" form.
- [ ] Create the detailed "Medicine Schedule" view.
- [ ] Implement the "Settings" screen for user preferences.

### Phase 4: System Integration & Notifications
- [ ] Implement a service for scheduling and triggering local notifications.
- [ ] Handle notification actions ("Taken", "Snooze").
- [ ] Integrate permission handling for notifications and camera.

### Phase 5: Final Polish & Localization
- [ ] Connect UI to business logic using Riverpod state management.
- [ ] Implement localization for English and Polish.
- [ ] Implement theme, font, and format switching.
- [ ] Conduct final testing and debugging.