import 'dart:io';
import 'package:cinnamon_marketplace_app/presentation/screens/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/firebase/auth_service.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../data/services/firebase/storage_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Please login'));
          }

          final user = state.user;

          return CustomScrollView(
            slivers: [
              // App Bar with gradient
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Profile Picture
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: user.profilePicUrl != null
                                    ? CachedNetworkImageProvider(user.profilePicUrl!)
                                    : null,
                                child: user.profilePicUrl == null
                                    ? Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBrown,
                                  ),
                                )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _changeProfilePicture(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Name + Verified Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.isVerified) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.accentGreen,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),

                          Text(
                            user.userType,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
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

              // Profile Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.star,
                              label: 'Rating',
                              value: user.rating.toStringAsFixed(1),
                              color: AppColors.accentYellow,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StreamBuilder<List<dynamic>>(
                              stream: context
                                  .read<FirestoreService>()
                                  .getUserAdvertisements(user.id),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.length ?? 0;
                                return _StatCard(
                                  icon: Icons.shopping_bag,
                                  label: 'Ads Posted',
                                  value: count.toString(),
                                  color: AppColors.primaryBrown,
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Contact Info Card
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.email, color: AppColors.primaryBrown),
                              title: const Text('Email'),
                              subtitle: Text(user.email),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.phone, color: AppColors.primaryBrown),
                              title: const Text('Phone'),
                              subtitle: Text(user.phone),
                            ),
                            if (user.location != null) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.location_on, color: AppColors.primaryBrown),
                                title: const Text('Location'),
                                subtitle: Text(user.location!),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(user: user),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // My Advertisements Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Advertisements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      StreamBuilder<List<dynamic>>(
                        stream: context
                            .read<FirestoreService>()
                            .getUserAdvertisements(user.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 48,
                                        color: AppColors.textSecondary.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No advertisements yet',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: snapshot.data!.take(3).map((ad) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: ad.imageUrls.first,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(ad.title),
                                  subtitle: Text('Rs. ${ad.price.toStringAsFixed(0)}'),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deleteAd(context, ad.id);
                                      }
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentRed,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changeProfilePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final storageService = context.read<StorageService>();
      final imageUrl = await storageService.uploadProfilePicture(
        authState.user.id,
        File(image.path),
      );

      await context.read<AuthService>().updateUserProfile(
        uid: authState.user.id,
        profilePicUrl: imageUrl,
      );

      context.read<AuthBloc>().add(AuthCheckRequested());

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteAd(BuildContext context, String adId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Advertisement'),
        content: const Text('Are you sure you want to delete this advertisement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<FirestoreService>().deleteAdvertisement(adId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Advertisement deleted'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
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
      context.read<AuthBloc>().add(AuthSignOutRequested());
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
