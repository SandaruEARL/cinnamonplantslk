import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/locale/locale_bloc.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.preferencesSection,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors. textSecondary,
              ),
            ),
          ),

          // Language
          ListTile(
            leading: const Icon(Icons.language, color: Colors.grey),
            title: Text(l10n.languageLabel),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),

          // Theme
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.grey),
            title: Text(l10n.darkModeLabel),
            subtitle: Text(l10n.darkModeSubtitle),
            value: _darkModeEnabled,
            activeColor: Colors.grey,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // TODO: Implement theme switching
              Fluttertoast.showToast(
                msg: 'Dark mode coming soon!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            },
          ),



          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
            l10n.notificationsSection,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.grey),
            title: Text(l10n.pushNotificationsLabel),
            subtitle: Text(l10n.pushNotificationsSubtitle),
            value: _notificationsEnabled,
            activeColor: Colors.grey,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),



          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.accountSection,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.grey),
            title: Text(l10n.privacyPolicyLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),

          // Terms of Service
          ListTile(
            leading: const Icon(Icons.description, color: Colors.grey),
            title: Text(l10n.termsOfServiceLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show terms of service
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info, color: Colors.grey),
            title: Text(l10n.aboutLabel),
            subtitle: Text(l10n.aboutVersion),
            trailing: const Icon(Icons. chevron_right),
            onTap: _showAboutDialog,
          ),


          // Logout
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.grey),
            title: Text(
              l10n.logoutLabel,
              style: const TextStyle(color: Colors.black87),
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
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                context.read<LocaleBloc>().add(LocaleChanged(const Locale('en')));
                Navigator.pop(dialogContext);
              },
            ),
            RadioListTile<String>(
              title: const Text('සිංහල'),
              value: 'si',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                context.read<LocaleBloc>().add(LocaleChanged(const Locale('si')));
                Navigator.pop(dialogContext);
              },
            ),
            RadioListTile<String>(
              title: const Text('தமிழ்'),
              value: 'ta',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                context.read<LocaleBloc>().add(LocaleChanged(const Locale('ta')));
                Navigator.pop(dialogContext);
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
      children: [
        const Text(
          'Sri Lanka\'s premier marketplace for cinnamon trading with AI-powered features.',
        ),
      ],
    );
  }

  void _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logoutLabel, style: const TextStyle(color: AppColors.accentRed)),
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