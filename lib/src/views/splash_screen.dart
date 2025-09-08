import 'package:dose_reminder/src/providers/settings_provider.dart';
import 'package:dose_reminder/src/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final logoAsset = isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_bright.png';

    return Scaffold(
      body: Container(
        color: isDarkMode ? const Color.fromARGB(255, 18, 27, 36) : Colors.white, // Background color
        child: Center(
          child: Image.asset(
            logoAsset,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 0.6, // Adjust size as needed
          ),
        ),
      ),
    );
  }
}
