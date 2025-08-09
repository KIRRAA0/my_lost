import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Utils/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final String? lightLabel;
  final String? darkLabel;

  const ThemeToggleButton({
    super.key,
    this.showLabel = true,
    this.lightLabel = 'Light Mode',
    this.darkLabel = 'Dark Mode',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.themeMode == AppThemeMode.dark;
        
        if (showLabel) {
          return ListTile(
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              isDarkMode ? darkLabel! : lightLabel!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<ThemeCubit>().toggleTheme();
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            onTap: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          );
        } else {
          return IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          );
        }
      },
    );
  }
}

class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred theme',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const ThemeToggleButton(),
          ],
        ),
      ),
    );
  }
} 