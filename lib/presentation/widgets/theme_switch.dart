import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class ThemeSwitchTile extends ConsumerWidget {
  const ThemeSwitchTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Modo ${isDarkMode ? "oscuro" : "claro"}',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Switch(
        value: isDarkMode,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (_) async {
          // 👇 Delay para evitar conflictos con rebuild inmediato
          await Future.delayed(const Duration(milliseconds: 150));
          ref.read(themeProvider.notifier).toggleTheme();
        },
      ),
    );
  }
}
