import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'User Name',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'user@example.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            title: Text(
              themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to help
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}

