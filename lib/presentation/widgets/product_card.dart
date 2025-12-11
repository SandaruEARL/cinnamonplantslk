import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/app_colors.dart';
import '../../../domain/entities/advertisement.dart';
import '../../../data/services/cloudinary/cloudinary_service.dart';

class ProductCard extends StatelessWidget {
  final Advertisement ad;
  final bool isHorizontal;

  const ProductCard({
    super.key,
    required this.ad,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildGridCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optimized Image - Use thumbnail URL
          Expanded(
            child: _buildOptimizedImage(
              size: 400, // Thumbnail size
              aspectRatio: 1.0,
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ad.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${ad.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ad.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Optimized Image - Use thumbnail URL
          SizedBox(
            width: 120,
            height: 120,
            child: _buildOptimizedImage(
              size: 240, // 2x for retina
              aspectRatio: 1.0,
            ),
          ),

          // Product Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${ad.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ad.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedImage({
    required int size,
    required double aspectRatio,
  }) {
    final imageUrl = ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '';

    if (imageUrl.isEmpty) {
      return _buildPlaceholder(aspectRatio);
    }

    // ✅ USE CLOUDINARY THUMBNAIL - significantly faster loading
    final thumbnailUrl = CloudinaryService.getThumbnailUrl(imageUrl, size: size);
    final placeholderUrl = CloudinaryService.getPlaceholderUrl(imageUrl);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,

        // Memory cache optimization - reduce memory usage
        memCacheWidth: size,
        memCacheHeight: size,
        maxWidthDiskCache: size,
        maxHeightDiskCache: size,

        // Instant blur placeholder
        placeholder: (context, url) => Image.network(
          placeholderUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildShimmer(),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 100),
              child: child,
            );
          },
        ),

        errorWidget: (context, url, error) => _buildErrorWidget(),

        // Fast fade animation
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  Widget _buildPlaceholder(double aspectRatio) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.image,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}