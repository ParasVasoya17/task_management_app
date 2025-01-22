import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/notifiers/theme_notifier.dart';
import 'package:task_management_app/providers/preferences_provider.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesService = ref.watch(preferencesServiceProvider);

    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: preferencesService.isDarkMode,
      onChanged: (bool value) {
        preferencesService.setDarkMode = value;
        ref.read(themeNotifierProvider.notifier).setTheme(value);
      },
    );
  }
}
