import '../../domain/entities/advertisement_entity.dart';

abstract class MarketplaceState {
  const MarketplaceState();
}

class MarketplaceInitial extends MarketplaceState {
  const MarketplaceInitial();
}

class MarketplaceLoading extends MarketplaceState {
  const MarketplaceLoading();
}

class MarketplaceLoaded extends MarketplaceState {
  final List<AdvertisementEntity> ads;
  const MarketplaceLoaded(this.ads);
}

class MarketplaceAnnouncementsLoaded extends MarketplaceState {
  final List<AdvertisementEntity> announcements;
  const MarketplaceAnnouncementsLoaded(this.announcements);
}

class MarketplaceAdCreating extends MarketplaceState {
  const MarketplaceAdCreating();
}

class MarketplaceAdCreated extends MarketplaceState {
  const MarketplaceAdCreated();
}

class MarketplaceError extends MarketplaceState {
  final String message;
  const MarketplaceError(this.message);
}