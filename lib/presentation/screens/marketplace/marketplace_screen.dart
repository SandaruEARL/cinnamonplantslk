import 'package:cinnamon_marketplace_app/presentation/screens/marketplace/post_ad_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/marketplace/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/advertisement.dart';
import '../../widgets/product_card.dart';


class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String?  _selectedCategory;
  String _sortBy = 'Latest';
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Marketplace'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
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

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products.. .',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterSheet,
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search
                },
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                  ... AppConstants.productCategories.map((category) {
                    return _CategoryChip(
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Products Grid/List
          StreamBuilder<List<Advertisement>>(
            stream: context.read<FirestoreService>(). getAdvertisements(
              category: _selectedCategory,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (! snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: AppColors.textSecondary. withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final ads = snapshot.data!;

              if (_isGridView) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToDetails(ads[index]),
                          child: ProductCard(ad: ads[index]),
                        );
                      },
                      childCount: ads.length,
                    ),
                  ),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return GestureDetector(
                        onTap: () => _navigateToDetails(ads[index]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ProductCard(ad: ads[index], isHorizontal: true),
                        ),
                      );
                    },
                    childCount: ads. length,
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton. extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PostAdScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryBrown,
        icon: const Icon(Icons.add),
        label: const Text('Post Ad'),
      ),
    );
  }

  void _navigateToDetails(Advertisement ad) {
    Navigator.of(context). push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(ad: ad),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Latest'),
                leading: Radio(
                  value: 'Latest',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value. toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Price: Low to High'),
                leading: Radio(
                  value: 'PriceLow',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Price: High to Low'),
                leading: Radio(
                  value: 'PriceHigh',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value. toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this. isSelected,
    required this. onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryBrown,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}