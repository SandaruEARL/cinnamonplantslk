import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/app_colors.dart';
import '../../../../data/services/cloudinary/cloudinary_service.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/chat/presentation/screens/chat_detail_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../../domain/entities/advertisement_entity.dart';

class ProductDetailsScreen extends StatefulWidget {
  final AdvertisementEntity ad;
  const ProductDetailsScreen({super.key, required this.ad});

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<MarketplaceBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(l10n.productDetails,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () => _toggleFavorite(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image gallery
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
                        itemCount: widget.ad.imageUrls.isEmpty
                            ? 1
                            : widget.ad.imageUrls.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImageIndex = i),
                        itemBuilder: (context, index) {
                          if (widget.ad.imageUrls.isEmpty) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey),
                            );
                          }
                          return _buildImage(
                              widget.ad.imageUrls[index]);
                        },
                      ),
                      if (widget.ad.imageUrls.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.ad.imageUrls.length,
                                  (i) => Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == i
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

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.ad.title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                        'Rs.${widget.ad.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),

                    // Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.ad.quantity != null)
                          Chip(
                            label: Text(
                                l10n.quantityLabel(
                                    widget.ad.quantity ?? 0),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            backgroundColor:
                            const Color(0xFFB8E98D),
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
                                    fontSize: 13)),
                            backgroundColor: AppColors.primaryGreen,
                            shape: const StadiumBorder(),
                            side: BorderSide.none,
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(l10n.descriptionLabel,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(widget.ad.description,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFFB8E98D), size: 18),
                        const SizedBox(width: 4),
                        Text(widget.ad.location,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(l10n.sellerInformation,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                        '${widget.ad.sellerName} - ${widget.ad.sellerPhone}',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary)),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callSeller,
                  icon: const Icon(Icons.phone,
                      size: 18, color: Color(0xFFB8E98D)),
                  label: Text(l10n.callButton),
                  style: OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                        color: Colors.black, width: 1.5),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _openWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8E98D),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(
                        color: Colors.black, width: 1.5),
                  ),
                  child: Text(l10n.whatsappButton,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _chatWithSeller(context),
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: 16, color: Color(0xFFB8E98D)),
                  label: Text(l10n.chatButton),
                  style: OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                        color: Colors.black, width: 1.5),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    final detailUrl =
    CloudinaryService.getDetailUrl(url, maxWidth: 1200);
    return CachedNetworkImage(
      imageUrl: detailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorWidget: (_, __, ___) =>
          Container(color: Colors.grey[200], child: const Icon(Icons.error)),
    );
  }

  void _toggleFavorite(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() => _isFavorite = !_isFavorite);
    context.read<MarketplaceBloc>().add(MarketplaceFavoriteToggled(
      userId: authState.user.id,
      adId: widget.ad.id,
      isFavorite: _isFavorite,
    ));
  }

  void _callSeller() async {
    final uri = Uri(scheme: 'tel', path: widget.ad.sellerPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openWhatsApp() async {
    final phone =
    widget.ad.sellerPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final msg = Uri.encodeComponent(
        'Hi, I\'m interested in: ${widget.ad.title}');
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _chatWithSeller(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to chat')));
      return;
    }
    if (widget.ad.sellerId == authState.user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot chat with yourself')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatDetailScreen(
        otherUserId: widget.ad.sellerId,
        otherUserName: widget.ad.sellerName,
        otherUserImage: widget.ad.sellerProfilePic,
      ),
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}