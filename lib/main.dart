import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/providers/settings_provider.dart';
import 'package:dose_reminder/src/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dose_reminder/src/views/splash_screen.dart';
import 'dart:developer' as developer;

Future<void> main() async {
  // Ensure flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Create a ProviderContainer
  final container = ProviderContainer();

  // Initialize services
  try {
    await container.read(notificationServiceProvider).init();
    developer.log('NotificationService initialized successfully');

    // Request notification permissions
    final hasPermissions = await container.read(notificationServiceProvider).requestPermissions();
    if (hasPermissions) {
      developer.log('Notification permissions granted');
    } else {
      developer.log('Notification permissions denied or not available');
    }
  } catch (e) {
    developer.log('Error initializing NotificationService: $e');
  }

  try {
    await Hive.initFlutter();
    developer.log('Hive initialized successfully');
  } catch (e) {
    developer.log('Error initializing Hive: $e');
  }

  // Register Adapters
  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(FrequencyTypeAdapter());
  Hive.registerAdapter(DoseAdapter());
  Hive.registerAdapter(DoseStatusAdapter());

  // Open boxes
  try {
    await Hive.openBox<Medicine>('medicines');
    developer.log('Medicine box opened successfully');
    await Hive.openBox<Dose>('doses');
    developer.log('Dose box opened successfully');
  } catch (e) {
    developer.log('Error opening Hive boxes: $e');
  // Initialize Mobile Ads
  try {
    await MobileAds.instance.initialize();
    developer.log('MobileAds initialized successfully');
  } catch (e) {
    developer.log('Error initializing MobileAds: $e');
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp(
      title: 'Dose Reminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        cardColor: const Color.fromARGB(128, 160, 202, 247),
        scaffoldBackgroundColor: const Color.fromARGB(128, 160, 202, 247),
        canvasColor: const Color.fromARGB(128, 160, 202, 247),
        dialogTheme: null,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardColor: const Color.fromARGB(128, 19, 46, 73),
        scaffoldBackgroundColor: const Color.fromARGB(128, 19, 46, 73),
        canvasColor: const Color.fromARGB(128, 19, 46, 73),
        dialogTheme: null,
      ),
      themeMode: themeMode,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('pl', ''), // Polish
      ],
      locale:
          locale ??
          const Locale(
            'en',
            '',
          ), // Set the locale from the provider, default to English if null
      home: const SplashScreen(),
    );
  }
}
