import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/services/notification/fcm_service.dart';
import '../../../injection_container.dart' as di;
import '../../locale/presentation/bloc/locale_bloc.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';

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
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final enabled = await di.sl<FcmService>().isNotificationsEnabled();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.preferencesSection,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.grey),
            title: Text(l10n.languageLabel),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.grey),
            title: Text(l10n.darkModeLabel),
            subtitle: Text(l10n.darkModeSubtitle),
            value: _darkModeEnabled,
            activeColor: Colors.grey,
            onChanged: (val) {
              setState(() => _darkModeEnabled = val);
              Fluttertoast.showToast(msg: 'Dark mode coming soon!');
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.notificationsSection,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary)),
          ),
          SwitchListTile(
            secondary:
            const Icon(Icons.notifications, color: Colors.grey),
            title: Text(l10n.pushNotificationsLabel),
            subtitle: Text(l10n.pushNotificationsSubtitle),
            value: _notificationsEnabled,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) async {
              setState(() => _notificationsEnabled = val);
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                await di.sl<FcmService>().setNotificationsEnabled(
                  authState.user.id,
                  val,
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.accountSection,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary)),
          ),
          ListTile(
            leading:
            const Icon(Icons.privacy_tip, color: Colors.grey),
            title: Text(l10n.privacyPolicyLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading:
            const Icon(Icons.description, color: Colors.grey),
            title: Text(l10n.termsOfServiceLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.grey),
            title: Text(l10n.aboutLabel),
            subtitle: Text(l10n.aboutVersion),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new,
                color: Colors.grey),
            title: Text(l10n.logoutLabel),
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
            _langTile(dialogContext, 'English', 'en'),
            _langTile(dialogContext, 'සිංහල', 'si'),
            _langTile(dialogContext, 'தமிழ்', 'ta'),
          ],
        ),
      ),
    );
  }

  RadioListTile<String> _langTile(
      BuildContext dialogContext,
      String label,
      String code,
      ) {
    return RadioListTile<String>(
      title: Text(label),
      value: code,
      groupValue: _selectedLanguage,
      onChanged: (val) {
        setState(() => _selectedLanguage = val!);
        context.read<LocaleBloc>().add(LocaleChanged(Locale(val!)));
        Navigator.pop(dialogContext);
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Cinnamon Marketplace',
      applicationVersion: '1.0.0',
      children: [
        const Text(
            "Sri Lanka's premier marketplace for cinnamon trading."),
      ],
    );
  }

  void _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.logoutLabel,
                  style:
                  const TextStyle(color: AppColors.accentRed))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }
}