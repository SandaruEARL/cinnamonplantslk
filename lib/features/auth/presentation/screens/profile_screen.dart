import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/settings_screen.dart';
import '../../../../features/marketplace/presentation/screens/my_ads_screen.dart';
import '../../../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (r) => false);
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.accountTitle),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: ListView(
            children: [
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(16),
                child: Text(user.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              _ProfileMenuItem(
                icon: Icons.local_offer,
                title: l10n.myAdsLabel,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MyAdsScreen(userId: user.id),
                )),
              ),
              _ProfileMenuItem(
                icon: Icons.bookmark_border,
                title: l10n.savedSearchesLabel,
                onTap: () {},
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.description,
                title: l10n.myProfileLabel,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: user),
                )),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.power_settings_new,
                title: l10n.logoutLabel,
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.logoutLabel),
        content: Text(l10n.areYouSureLogout),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.logoutLabel,
                  style: const TextStyle(color: AppColors.accentRed))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (r) => false);
    }
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600], size: 28),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}