import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../../domain/entities/advertisement_entity.dart';
import 'ad_edit_screen.dart';


class MyAdsScreen extends StatelessWidget {
  final String userId;
  const MyAdsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<MarketplaceBloc>()
        ..add(MarketplaceUserAdsLoadRequested(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.myAdvertisements),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient),
          ),
        ),
        body: BlocBuilder<MarketplaceBloc, MarketplaceState>(
          builder: (context, state) {
            if (state is MarketplaceLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MarketplaceError) {
              return Center(child: Text(state.message));
            }
            if (state is MarketplaceLoaded) {
              if (state.ads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store_outlined,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l10n.noAdsPosted),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.ads.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _AdStatusCard(
                  ad: state.ads[i],
                  onTap: () {
                    final bloc = context.read<MarketplaceBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: AdEditScreen(ad: state.ads[i]),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _AdStatusCard extends StatelessWidget {
  final AdvertisementEntity ad;
  final VoidCallback onTap;
  const _AdStatusCard({required this.ad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl:
                  ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusBadge(ad: ad),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(ad.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Rs. ${ad.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600)),
                    if (ad.isRejected && ad.rejectionReason != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          'Reason: ${ad.rejectionReason}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AdvertisementEntity ad;
  const _StatusBadge({required this.ad});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    if (ad.isApproved) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
      icon = Icons.check_circle_outline;
      label = 'Live';
    } else if (ad.isPending) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
      icon = Icons.hourglass_top_rounded;
      label = 'Pending review';
    } else {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
      icon = Icons.cancel_outlined;
      label = 'Rejected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}