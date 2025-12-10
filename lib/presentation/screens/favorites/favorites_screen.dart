import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/advertisement.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/product_card.dart';
import '../marketplace/product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is!  AuthAuthenticated) {
            return const Center(child: Text('Please login to view favorites'));
          }

          return StreamBuilder<List<String>>(
            stream: context.read<FirestoreService>().getUserFavorites(state.user. id),
            builder: (context, favoriteSnapshot) {
              if (favoriteSnapshot.connectionState == ConnectionState. waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (! favoriteSnapshot.hasData || favoriteSnapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: AppColors.textSecondary. withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start adding products to your favorites',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final favoriteIds = favoriteSnapshot.data!;

              return FutureBuilder<List<Advertisement?>>(
                future: Future.wait(
                  favoriteIds.map((id) =>
                      context.read<FirestoreService>().getAdvertisement(id)),
                ),
                builder: (context, adsSnapshot) {
                  if (adsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final ads = adsSnapshot.data
                      ?.where((ad) => ad != null)
                      .cast<Advertisement>()
                      .toList() ??
                      [];

                  if (ads.isEmpty) {
                    return const Center(child: Text('No favorites available'));
                  }

                  if (_isGridView) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: ads. length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToDetails(ads[index]),
                          child: ProductCard(ad: ads[index]),
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: ads.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToDetails(ads[index]),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ProductCard(ad: ads[index], isHorizontal: true),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetails(Advertisement ad) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(ad: ad),
      ),
    );
  }
}