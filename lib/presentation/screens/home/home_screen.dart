import 'dart:math';

import 'package:cinnamon_marketplace_app/presentation/screens/tools/tools_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/advertisement.dart';
import '../../../domain/entities/location.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/product_card.dart';
import '../ai/price_prediction_screen.dart';
import '../chat/chat_list_screen.dart';
import '../expense/expense_dashboard_screen.dart';
import '../map/ads_map_screen.dart';
import '../map/my_locations_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../profile/settings_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const ChatListScreen(),
    const PricePredictionScreen(),
    const ToolsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(

      // ── Drawer ───────────────────────────────────────────────────────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    // Icon box
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        'assets/images/explore_map.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryGreen,
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.exploreMap,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.exploreMapSubtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              const SizedBox(height: 8),

              // ── Nursery Plantations ───────────────────────────────
              _DrawerTile(
                iconPath: 'assets/images/nursery.png',
                title: AppLocalizations.of(context)!.nurseryPlantations,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AdsMapScreen(
                      title: AppLocalizations.of(context)!.nurseryPlantations,
                      locationType: LocationType.nursery,
                      pinColor: Colors.green,
                    ),
                  ));
                },
              ),

              // ── Bale Buyers ───────────────────────────────────────
              _DrawerTile(
                iconPath: 'assets/images/bale_buyers.png',
                title: AppLocalizations.of(context)!.baleBuyingShops,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AdsMapScreen(
                      title: AppLocalizations.of(context)!.baleBuyingShops,
                      locationType: LocationType.shop,
                      pinColor: AppColors.primaryGreen,
                    ),
                  ));
                },
              ),

              // ── Register / My Locations ───────────────────────────
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isAuthenticated = state is AuthAuthenticated;
                  final isAllowedType = isAuthenticated &&
                      (state.user.userType == AppConstants.userTypeNurseryOwner ||
                          state.user.userType == AppConstants.userTypeBaleBuyer);

                  return _DrawerTile(
                    iconPath: 'assets/images/location.png',
                    title: isAuthenticated
                        ? AppLocalizations.of(context)!.myRegisteredLocations
                        : AppLocalizations.of(context)!.registerYourLocations,
                    disabled: !isAuthenticated || (isAuthenticated && !isAllowedType),
                    onTap: () {

                      if (!isAuthenticated) {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.toastLoginRequired,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: const Color(0xFF323232),
                          textColor: Colors.white,
                          fontSize: 13.0,
                        );

                      } else if (isAllowedType) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MyLocationsScreen(userId: state.user.id),
                        ));
                      } else {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.toastLocationRestricted,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: const Color(0xFF323232),
                          textColor: Colors.white,
                          fontSize: 13.0,
                        );
                      }
                    },
                  );
                },
              ),

              _DrawerTile(
                iconData: Icons.settings,
                title: AppLocalizations.of(context)!.settingsTitle,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ));
                },
              ),

              const Spacer(),

              // ── Footer ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'v.1.0.10 by EarlixLabs',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: _screens[_selectedIndex],

      // ── Bottom Navigation ────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.feed), label: l10n.navHome),
          BottomNavigationBarItem(
              icon: const Icon(Icons.chat), label: l10n.navChat),
          BottomNavigationBarItem(
              icon: const FaIcon(FontAwesomeIcons.chartLine, size: 20),
              label: l10n.navPredictions),
          BottomNavigationBarItem(
              icon: const Icon(Icons.apps), label: l10n.navTools),
        ],
      ),
    );
  }
}

// ── Drawer Tile ──────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  final String? iconPath;       // make nullable
  final IconData? iconData;     // add this
  final String title;
  final VoidCallback onTap;
  final bool disabled;

  const _DrawerTile({
    this.iconPath,
    this.iconData,
    required this.title,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = iconPath != null
        ? ColorFiltered(
      colorFilter: disabled
          ? const ColorFilter.matrix([])
          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      child: Image.asset(
        iconPath!,
        width: 26,
        height: 26,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          iconData ?? Icons.image_outlined,
          size: 24,
          color: disabled ? Colors.grey.shade300 : AppColors.textSecondary,
        ),
      ),
    )
        : Icon(
      iconData ?? Icons.settings,
      size: 24,
      color: disabled ? Colors.grey.shade300 : Colors.black,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: disabled ? Colors.grey.shade400 : AppColors.textPrimary,
                ),
              ),
            ),
            if (disabled)
              Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ── Home Content ─────────────────────────────────────────────────────────────

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(l10n.navPredictions),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // AI Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Features',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.trending_up,
                          title: 'Price Predict',
                          subtitle: 'Forecast',
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentGreen,
                              Color(0xFF059669)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                              const PricePredictionScreen(),
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.eco,
                          title: 'Buy Plants',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.attach_money,
                          title: 'Expenses',
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                              const ExpenseDashboardScreen(),
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Ads
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Ads',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            StreamBuilder<List<Advertisement>>(
              stream: context
                  .read<FirestoreService>()
                  .getAdvertisements(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No ads yet')),
                  );
                }
                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 200,
                          child:
                          ProductCard(ad: snapshot.data![index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action Card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: AppColors.primaryGreen, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}