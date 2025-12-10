import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors. textSecondary,
              ),
            ),
          ),

          // Language
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primaryBrown),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),

          // Theme
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: AppColors. primaryBrown),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: _darkModeEnabled,
            activeColor: AppColors.primaryBrown,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // TODO: Implement theme switching
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon!')),
              );
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppColors.primaryBrown),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications for new messages and updates'),
            value: _notificationsEnabled,
            activeColor: AppColors.primaryBrown,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppColors.primaryBrown),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),

          // Terms of Service
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.primaryBrown),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show terms of service
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.primaryBrown),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons. chevron_right),
            onTap: _showAboutDialog,
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.accentRed),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.accentRed),
            ),
            onTap: () => _logout(context),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value! ;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Sinhala'),
              value: 'Sinhala',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value! ;
                });
                Navigator. pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sinhala language coming soon!')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Tamil'),
              value: 'Tamil',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tamil language coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Cinnamon Marketplace',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.eco, color: Colors.white, size: 32),
      ),
      children: [
        const Text(
          'Sri Lanka\'s premier marketplace for cinnamon trading with AI-powered features.',
        ),
      ],
    );
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AuthBloc>(). add(AuthSignOutRequested());
      Navigator.of(context).popUntil((route) => route. isFirst);
    }
  }
}