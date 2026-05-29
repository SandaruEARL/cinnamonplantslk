import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/marketplace/presentation/screens/post_ad_screen.dart';
import '../../../../features/marketplace/presentation/screens/product_details_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_state.dart';
import '../../../notification/presentation/screens/notifications_screen.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../widgets/anouncement_card.dart';
import '../widgets/product_card.dart';
import '../../../auth/presentation/screens/profile_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MarketplaceBloc>()
        ..add(const MarketplaceLoadRequested()),
      child: const _MarketplaceView(),
    );
  }
}

class _MarketplaceView extends StatefulWidget {
  const _MarketplaceView();

  @override
  State<_MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<_MarketplaceView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final bloc = context.read<MarketplaceBloc>();
      if (_tabController.index == 0) {
        bloc.add(const MarketplaceLoadRequested());
      } else {
        bloc.add(const MarketplaceAnnouncementsLoadRequested());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPostTypeSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.createPostTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.createPostSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 20),
              _SheetOption(
                icon: Icons.storefront_outlined,
                title: l10n.postTypeListing,
                subtitle: l10n.postTypeListingSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PostAdScreen(type: 'listing'),
                  ));
                },
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.campaign_outlined,
                title: l10n.postTypeAnnouncement,
                subtitle: l10n.postTypeAnnouncementSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PostAdScreen(type: 'announcement'),
                  ));
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(l10n.marketplaceTitle),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 24),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  icon: const Icon(Icons.login,
                      color: Colors.white, size: 20),
                  label: Text(l10n.loginTitle,
                      style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final unread =
              state is NotificationLoaded ? state.unreadCount : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: l10n.tabListings),
            Tab(text: l10n.tabAnnouncements),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ListingsTab(),
          _AnnouncementsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostTypeSheet(context),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        tooltip: 'Create post',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// ── Sheet option tile ────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Listings tab ─────────────────────────────────────────────────────────────

class _ListingsTab extends StatelessWidget {
  const _ListingsTab();

  double _getAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // card width accounts for outer padding (16*2) and spacing between cards (16)
    final cardWidth = (screenWidth - 48) / 2;
    // image is square (cardWidth x cardWidth) + ~100dp for info section
    final cardHeight = cardWidth + 100;
    return cardWidth / cardHeight;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchProducts,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        BlocBuilder<MarketplaceBloc, MarketplaceState>(
          builder: (context, state) {
            if (state is MarketplaceLoading) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is MarketplaceError) {
              return SliverFillRemaining(
                child: Center(child: Text(state.message)),
              );
            }
            if (state is MarketplaceLoaded) {
              if (state.ads.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noProductsFound,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: Builder(
                  builder: (context) => SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: _getAspectRatio(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final ad = state.ads[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(ad: ad),
                            ),
                          ),
                          child: ProductCard(ad: ad),
                        );
                      },
                      childCount: state.ads.length,
                    ),
                  ),
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
      ],
    );
  }
}

// ── Announcements tab ────────────────────────────────────────────────────────

class _AnnouncementsTab extends StatelessWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        if (state is MarketplaceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MarketplaceError) {
          return Center(child: Text(state.message));
        }
        if (state is MarketplaceAnnouncementsLoaded) {
          if (state.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.noBuyingAnnouncementsYet,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.beFirstToPostAnnouncement,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.announcements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                AnnouncementCard(ad: state.announcements[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
