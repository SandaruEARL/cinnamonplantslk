import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../data/services/cloudinary/cloudinary_service.dart';
import '../../../domain/entities/advertisement.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ────────────────────────────────────────────────────────
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.productDetails,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareProduct,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Image Gallery  ────────────────────────────────
            Container(
              height: 260,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                      itemCount: widget.ad.imageUrls.isEmpty ? 1 : widget.ad.imageUrls.length,
                      onPageChanged: (index) =>
                          setState(() => _currentImageIndex = index),
                      itemBuilder: (context, index) {
                        if (widget.ad.imageUrls.isEmpty) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported,
                                size: 60, color: Colors.grey),
                          );
                        }
                        return _buildOptimizedImage(widget.ad.imageUrls[index]);
                      },
                    ),

                    // Dot indicator
                    if (widget.ad.imageUrls.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.ad.imageUrls.length,
                                (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 7,
                              height: 7,
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

            // ── Content ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title
                  Text(
                    widget.ad.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Price
                  Text(
                    'Rs.${widget.ad.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Chips: only Qty and Grade ─────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.ad.quantity != null)
                        Chip(
                          label: Text(
                            l10n.quantityLabel(widget.ad.quantity ?? 0),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          backgroundColor: const Color(0xFFB8E98D),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          shape: const StadiumBorder(),
                          side: BorderSide.none,
                        ),
                      if (widget.ad.grade != null)
                        Chip(
                          label: Text(
                            l10n.gradeLabel(widget.ad.grade ?? ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          shape: const StadiumBorder(),
                          side: BorderSide.none,
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Description ───────────────────────────────────
                  Text(
                    l10n.descriptionLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.ad.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Location ──────────────────────────────────────
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFB8E98D),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.ad.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Seller Information ────────────────────────────
                  Text(
                    l10n.sellerInformation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.ad.sellerName} - ${widget.ad.sellerPhone}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Action Buttons ───────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        color: Colors.white,
        child: Row(
          children: [
            // Call — outlined black, light green icon
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _callSeller,
                icon: const Icon(Icons.phone, size: 18, color: Color(0xFFB8E98D)),
                label: Text(l10n.callButton),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // WhatsApp — filled #B8E98D
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _openWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8E98D),
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  l10n.whatsappButton,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Chat — outlined black, light green icon
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _chatWithSeller,
                icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFFB8E98D)),
                label: Text(l10n.chatButton),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedImage(String imageUrl) {
    final detailUrl = CloudinaryService.getDetailUrl(imageUrl, maxWidth: 1200);
    final placeholderUrl = CloudinaryService.getPlaceholderUrl(imageUrl);

    return CachedNetworkImage(
      imageUrl: detailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      memCacheWidth: 1200,
      maxWidthDiskCache: 1200,
      placeholder: (context, url) => Image.network(
        placeholderUrl,
        fit: BoxFit.cover,
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
    setState(() => _isFavorite = !_isFavorite);
    try {
      final firestoreService = context.read<FirestoreService>();
      if (_isFavorite) {
        await firestoreService.addToFavorites(authState.user.id, widget.ad.id);
      } else {
        await firestoreService.removeFromFavorites(
            authState.user.id, widget.ad.id);
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
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