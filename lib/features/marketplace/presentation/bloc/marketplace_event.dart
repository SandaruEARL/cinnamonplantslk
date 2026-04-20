import 'dart:io';

abstract class MarketplaceEvent {
  const MarketplaceEvent();
}

class MarketplaceLoadRequested extends MarketplaceEvent {
  final String? category;
  const MarketplaceLoadRequested({this.category});
}

class MarketplaceAnnouncementsLoadRequested extends MarketplaceEvent {
  final String? category;
  const MarketplaceAnnouncementsLoadRequested({this.category});
}

class MarketplaceUserAdsLoadRequested extends MarketplaceEvent {
  final String userId;
  const MarketplaceUserAdsLoadRequested(this.userId);
}

class MarketplaceAdCreateRequested extends MarketplaceEvent {
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String? sellerProfilePic;
  final String title;
  final String description;
  final String category;
  final double price;
  final String? grade;
  final int? quantity;
  final String location;
  final List<File> images;
  final String type; // 'listing' | 'announcement'

  const MarketplaceAdCreateRequested({
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.sellerProfilePic,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.grade,
    this.quantity,
    required this.location,
    required this.images,
    this.type = 'listing',
  });
}

class MarketplaceFavoriteToggled extends MarketplaceEvent {
  final String userId;
  final String adId;
  final bool isFavorite;
  const MarketplaceFavoriteToggled({
    required this.userId,
    required this.adId,
    required this.isFavorite,
  });
}