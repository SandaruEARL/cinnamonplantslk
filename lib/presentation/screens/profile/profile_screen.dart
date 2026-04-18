import 'dart:io';
import 'package:cinnamon_marketplace_app/presentation/screens/marketplace/my_ads_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
                  (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.accountTitle),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            children: [
              // User Name Header
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // My Ads
              _ProfileMenuItem(
                icon: Icons.local_offer,
                title: l10n.myAdsLabel,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyAdsScreen(userId: user.id),
                    ),
                  );
                },
              ),

              /** My membership
              _ProfileMenuItem(
                icon: Icons.store,
                title: 'My membership',
                onTap: () {
                  // Navigate to membership
                },
              ),
               **/

              /** Favorites
              _ProfileMenuItem(
                icon: Icons.star_border,
                title: 'Favorites',
                onTap: () {
                  // Navigate to favorites
                },
              ),
               **/

              // Saved searches
              _ProfileMenuItem(
                icon: Icons.bookmark_border,
                title: l10n.savedSearchesLabel,
                onTap: () {
                  // Navigate to saved searches
                },
              ),

              /** Phone Numbers
              _ProfileMenuItem(
                icon: Icons.phone,
                title: 'Phone Numbers',
                onTap: () {
                  // Navigate to phone numbers
                },
              ),
               **/

              const Divider(height: 1),

              // My Profile
              _ProfileMenuItem(
                icon: Icons.description,
                title: l10n.myProfileLabel,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: user),
                    ),
                  );
                },
              ),

              /** Stay safe
              _ProfileMenuItem(
                icon: Icons.shield,
                title: 'Stay safe',
                onTap: () {
                  // Navigate to safety tips
                },
              ),
               **/

             /**
              // FAQ
              _ProfileMenuItem(
                icon: Icons.help_outline,
                title: l10n.faqLabel,
                onTap: () {
                  // Navigate to FAQ
                },
              ),
            **/

              /** How to sell fast?
              _ProfileMenuItem(
                icon: Icons.trending_up,
                title: 'How to sell fast?',
                onTap: () {
                  // Navigate to selling tips
                },
              ),
               **/

              /** More
              _ProfileMenuItem(
                icon: Icons.more_horiz,
                title: 'More',
                onTap: () {
                  // Navigate to more options
                },
              ),
                  **/

              const Divider(height: 1,),

              // Log out
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
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutLabel),
        content: Text(l10n.areYouSureLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logoutLabel,
                style: const TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AuthBloc>().add(AuthSignOutRequested());

      // Replace entire stack with HomeScreen — marketplace is shown to guests too
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
            (route) => false,
      );
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
      leading: Icon(
        icon,
        color: Colors.grey[600],
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}