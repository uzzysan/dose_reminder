import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/providers/settings_provider.dart';
import 'package:dose_reminder/src/services/notification_service.dart';
import 'package:dose_reminder/src/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dose_reminder/src/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dose_reminder/src/views/splash_screen.dart';

Future<void> main() async {
  // Ensure flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService().init();
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(FrequencyTypeAdapter());
  Hive.registerAdapter(DoseAdapter());
  Hive.registerAdapter(DoseStatusAdapter());

  runApp(const ProviderScope(child: MyApp()));
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
        dialogBackgroundColor: const Color.fromARGB(128, 160, 202, 247),
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
        dialogBackgroundColor: const Color.fromARGB(128, 19, 46, 73),
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
      locale: locale, // Set the locale from the provider
      home: const SplashScreen(),
    );
  }
}
