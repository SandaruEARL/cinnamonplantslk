import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../data/services/cloudinary/cloudinary_service.dart';
import '../../../domain/entities/advertisement.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../chat/chat_detail_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Advertisement ad;

  const ProductDetailsScreen({super.key, required this.ad});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Product Details'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : Colors.white,
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            color: Colors.white,
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: widget.ad.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildOptimizedImage(widget.ad.imageUrls[index]);
                      },
                    ),
                    // Image indicator
                    if (widget.ad.imageUrls.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.ad.imageUrls.length,
                                (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Verified Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.ad.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (widget.ad.sellerVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: AppColors.accentGreen,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'Rs. ${widget.ad.price.toStringAsFixed(2)}${widget.ad.category.contains('Bales') ? '/kg' : ''}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBrown,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category and Grade
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(widget.ad.category),
                        backgroundColor: AppColors.primaryBrown.withOpacity(0.1),
                      ),
                      if (widget.ad.grade != null)
                        Chip(
                          label: Text('Grade: ${widget.ad.grade}'),
                          backgroundColor: AppColors.accentGreen.withOpacity(0.1),
                        ),
                      if (widget.ad.quantity != null)
                        Chip(
                          label: Text('Qty: ${widget.ad.quantity}'),
                          backgroundColor: AppColors.accentYellow.withOpacity(0.1),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ad.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primaryBrown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.ad.location,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Seller Info
                  const Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryBrown,
                      backgroundImage: widget.ad.sellerProfilePic != null
                          ? CachedNetworkImageProvider(
                        CloudinaryService.getThumbnailUrl(
                          widget.ad.sellerProfilePic!,
                          size: 200,
                        ),
                      )
                          : null,
                      child: widget.ad.sellerProfilePic == null
                          ? Text(
                        widget.ad.sellerName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          widget.ad.sellerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.ad.sellerVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: AppColors.accentGreen,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      widget.ad.sellerPhone,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Call Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callSeller,
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primaryBrown),
                    foregroundColor: AppColors.primaryBrown,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // WhatsApp Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openWhatsApp,
                  icon: const Icon(Icons.whatshot),
                  label: const Text('WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    foregroundColor: const Color(0xFF25D366),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Chat Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _chatWithSeller,
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primaryBrown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ OPTIMIZED: Progressive image loading with placeholders
  Widget _buildOptimizedImage(String imageUrl) {
    final detailUrl = CloudinaryService.getDetailUrl(imageUrl, maxWidth: 1200);
    final placeholderUrl = CloudinaryService.getPlaceholderUrl(imageUrl);

    return CachedNetworkImage(
      imageUrl: detailUrl,
      fit: BoxFit.contain,

      // Memory optimization
      memCacheWidth: 1200,
      maxWidthDiskCache: 1200,

      // Progressive loading: blur placeholder → full image
      placeholder: (context, url) => Image.network(
        placeholderUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),

      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error),
      ),

      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  void _toggleFavorite() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      final firestoreService = context.read<FirestoreService>();
      if (_isFavorite) {
        await firestoreService.addToFavorites(authState.user.id, widget.ad.id);
      } else {
        await firestoreService.removeFromFavorites(
            authState.user.id, widget.ad.id);
      }
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _callSeller() async {
    final uri = Uri(scheme: 'tel', path: widget.ad.sellerPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  void _openWhatsApp() async {
    final phone = widget.ad.sellerPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final message = Uri.encodeComponent(
        'Hi, I\'m interested in your product: ${widget.ad.title}');
    final uri = Uri.parse('https://wa.me/$phone?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  void _chatWithSeller() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to chat')),
      );
      return;
    }

    // Prevent chatting with yourself
    if (widget.ad.sellerId == authState.user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          otherUserId: widget.ad.sellerId,
          otherUserName: widget.ad.sellerName,
          otherUserImage: widget.ad.sellerProfilePic,
        ),
      ),
    );
  }
}