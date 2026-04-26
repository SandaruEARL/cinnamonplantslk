import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../domain/entities/advertisement_entity.dart';
import '../screens/anouncement_details.dart';


class AnnouncementCard extends StatelessWidget {
  final AdvertisementEntity ad;
  const AnnouncementCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AnnouncementDetailScreen(ad: ad),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: badge + time ─────────────────────────────────
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'BUYING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(ad.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Title ─────────────────────────────────────────────────
            Text(
              ad.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // ── Key info row ──────────────────────────────────────────
            Row(
              children: [
                _MetaItem(
                  label: 'LKR ${ad.price.toStringAsFixed(0)}/kg',
                  color: AppColors.primaryGreen,
                ),
                if (ad.grade != null) ...[
                  const SizedBox(width: 10),
                  _MetaItem(label: ad.grade!),
                ],
                const Spacer(),
                Text(
                  ad.location,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Seller row ────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.grey.shade100,
                  child: Text(
                    ad.sellerName.isNotEmpty
                        ? ad.sellerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  ad.sellerName,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaItem({required this.label, this.color = AppColors.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}