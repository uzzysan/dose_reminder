import 'package:dose_reminder/src/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemDefault),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.dark),
                ),
              ],
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  ref.read(themeNotifierProvider.notifier).setTheme(newMode);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              items: [
                DropdownMenuItem(
                  value: const Locale('en', ''),
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: const Locale('pl', ''),
                  child: Text(l10n.polish),
                ),
              ],
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(localeNotifierProvider.notifier).setLocale(newLocale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}