import 'package:dose_reminder/src/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget wyświetlający logo aplikacji w tle z odpowiedną przezroczystością
/// i wersją zależną od motywu kolorystycznego.
class BackgroundLogo extends ConsumerWidget {
  const BackgroundLogo({
    super.key,
    this.opacity = 0.06,
    this.size = 0.8,
  });

  /// Przezroczystość logo (0.0 - 1.0)
  final double opacity;
  
  /// Rozmiar logo jako procent szerokości ekranu (0.0 - 1.0)
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final logoAsset = isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_bright.png';
    final backgroundColor = isDarkMode 
        ? const Color.fromARGB(255, 18, 27, 36) 
        : Colors.white;

    return Positioned.fill(
      child: Container(
        color: backgroundColor,
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              logoAsset,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * size,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image doesn't exist
                return Icon(
                  Icons.medical_services_outlined,
                  size: MediaQuery.of(context).size.width * size * 0.5,
                  color: isDarkMode ? Colors.white : Colors.grey[400],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
