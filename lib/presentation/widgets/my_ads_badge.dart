import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/advertisement.dart';
import '../screens/marketplace/my_ads_screen.dart';


class _MyAdsBadge extends StatelessWidget {
  final String userId;
  const _MyAdsBadge({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Advertisement>>(
      stream: context.read<FirestoreService>().getUserAdvertisements(userId),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data
            ?.where((ad) => ad.isPending)
            .length ?? 0;

        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.store_outlined, color: Colors.white),
                tooltip: 'My Ads',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MyAdsScreen(userId: userId)),
                ),
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}