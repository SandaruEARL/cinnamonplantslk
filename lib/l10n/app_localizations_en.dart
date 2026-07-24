// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get categoryAllLabel => 'All';

  @override
  String get categoryCinnamonPlants => 'Cinnamon Plants';

  @override
  String get categoryCinnamonBales => 'Cinnamon Bales';

  @override
  String get categoryCinnamonOil => 'Cinnamon Oil';

  @override
  String get categoryCinnamonSoap => 'Cinnamon Soap';

  @override
  String get categoryCinnamonScents => 'Cinnamon Scents';

  @override
  String get categoryOtherProducts => 'Other Products';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Welcome back to Cinnamon Marketplace';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerNow => 'Register now';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get exploreMap => 'Explore Map';

  @override
  String get exploreMapSubtitle => 'Find nurseries and bale\nbuyers near you';

  @override
  String get nurseryPlantations => 'Nursery Plantations';

  @override
  String get baleBuyers => 'Bale Buyers';

  @override
  String get baleBuyingShops => 'Bale Buying Shops';

  @override
  String get myRegisteredLocations => 'My Registered Locations';

  @override
  String get registerYourLocations => 'Register your locations';

  @override
  String get navHome => 'Feed';

  @override
  String get navChat => 'Chat';

  @override
  String get navPredictions => 'Predictions';

  @override
  String get navTools => 'Tools';

  @override
  String get aiFeatures => 'AI Features';

  @override
  String get pricePredict => 'Price Predict';

  @override
  String get pricePredictSubtitle => 'Forecast';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get buyPlants => 'Buy Plants';

  @override
  String get expenses => 'Expenses';

  @override
  String get recentAds => 'Recent Ads';

  @override
  String get viewAll => 'View All';

  @override
  String get noAdsYet => 'No ads yet';

  @override
  String get toastLoginRequired =>
      'Please log in with a Nursery Owner or Bale Buyer account.';

  @override
  String get toastLocationRestricted =>
      'Only Nursery Owners and Bale Buyers can register locations.';

  @override
  String get appVersion => 'v.1.0.10 by EarlixLabs';

  @override
  String get registerNurseryTitle => 'Register Nursery / Plantation location';

  @override
  String get registerShopTitle => 'Register Bale Buying Shop location';

  @override
  String get updateNurseryTitle => 'Update Nursery / Plantation';

  @override
  String get updateShopTitle => 'Update Bale Buying Shop';

  @override
  String get hintNurseryName => 'Nursery / Plantation Name';

  @override
  String get hintShopName => 'Bale Buying Shop Name';

  @override
  String get hintContactNumber => 'Contact Number';

  @override
  String get hintDescription => 'Description';

  @override
  String get hintOpeningHours => 'Opening Hours';

  @override
  String get validationRequired => 'Required';

  @override
  String get pickLocationHint => 'Pick your location from the map';

  @override
  String get submitForReview => 'Submit for Review';

  @override
  String get updateLocation => 'Update Location';

  @override
  String get locationSubmittedTitle => 'Location Submitted';

  @override
  String locationSubmittedBody(String typeLabel) {
    return 'Your $typeLabel location is pending approval. It will appear on the map once approved.';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get snackPickLocation => 'Please pick a location on the map';

  @override
  String get myLocationsTitle => 'My Registered Locations';

  @override
  String get plantationsLabel => 'Plantations';

  @override
  String get baleBuyersLabel => 'Bale Buyers';

  @override
  String get plantationsDescription =>
      'Register your nursery so buyers can find you on the map.';

  @override
  String get baleBuyersDescription =>
      'List your shop so sellers nearby can locate you easily.';

  @override
  String get locationsReviewNotice =>
      'Locations are reviewed before appearing on the map.';

  @override
  String get noLocationsYet => 'You haven\'t registered any locations yet';

  @override
  String get addLocation => 'Add location';

  @override
  String get editLocation => 'Edit';

  @override
  String get statusVisibleOnMap => 'Visible on map';

  @override
  String get statusPendingReview => 'Pending review';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get removeLocationTitle => 'Remove location?';

  @override
  String get removeNurseryBody =>
      'Your nursery location will be removed from the map.';

  @override
  String get removeShopBody =>
      'Your shop location will be removed from the map.';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get pickLocationTitle => 'Pick Location';

  @override
  String get searchLocationHint => 'Search for location';

  @override
  String get confirmLocation => 'Confirm';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get tapMapToSelect => 'Tap map to select location';

  @override
  String get locationNotFound => 'Location not found';

  @override
  String get couldNotFindLocation => 'Could not find that location';

  @override
  String couldNotGetLocation(String error) {
    return 'Could not get location: $error';
  }

  @override
  String get loadingLocations => 'Loading locations...';

  @override
  String locationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'locations',
      one: 'location',
    );
    return '$count $_temp0';
  }

  @override
  String noLocationsRegistered(String typeName) {
    return 'No $typeName registered yet';
  }

  @override
  String get callButton => 'Call';

  @override
  String get directionsButton => 'Directions';

  @override
  String get nurseryBadge => 'Nursery';

  @override
  String get baleBuyerBadge => 'Bale Buyer';

  @override
  String get addedBadge => 'Added';

  @override
  String get marketplaceTitle => 'Feed';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get sortBy => 'Sort By';

  @override
  String get latest => 'Latest';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get categoryAll => 'All';

  @override
  String get postAd => 'Post Advertisement';

  @override
  String get submitForAdReview => 'Submit for Review';

  @override
  String get adPostedSuccess => 'Advertisement posted successfully!';

  @override
  String get addImage => 'Add image';

  @override
  String get titleHint => 'Title ( nursery / plantation name )';

  @override
  String get descriptionHint => 'Description';

  @override
  String get priceHint => 'Price (Rs)';

  @override
  String get quantityHint => 'Qty';

  @override
  String get gradeHint => 'Grade';

  @override
  String get locationHint => 'Location (Ex. Galle, batapola, matara)';

  @override
  String get pleaseAddImage => 'Please add at least one image';

  @override
  String get myAdvertisements => 'My Advertisements';

  @override
  String get noAdsPosted => 'You haven\'t posted any ads yet';

  @override
  String get adStatusLive => 'Live';

  @override
  String get adStatusPending => 'Pending review';

  @override
  String get adStatusRejected => 'Rejected';

  @override
  String rejectionReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get productDetails => 'Product Details';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get sellerInformation => 'Seller Information';

  @override
  String get whatsappButton => 'Whatsapp';

  @override
  String get chatButton => 'Chat';

  @override
  String get shareFunctionSoon => 'Share functionality coming soon!';

  @override
  String get couldNotLaunchDialer => 'Could not launch phone dialer';

  @override
  String get couldNotOpenWhatsapp => 'Could not open WhatsApp';

  @override
  String get pleaseLoginToChat => 'Please login to chat';

  @override
  String get cannotChatWithSelf => 'You cannot chat with yourself';

  @override
  String quantityLabel(int qty) {
    return 'Qty $qty';
  }

  @override
  String gradeLabel(String grade) {
    return 'Grade: $grade';
  }

  @override
  String get messagesTitle => 'Messages';

  @override
  String get pleaseLoginToViewMessages => 'Please login to view messages';

  @override
  String errorLoadingChats(String error) {
    return 'Error loading chats: $error';
  }

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startChattingWithSellers => 'Start chatting with sellers';

  @override
  String get startTheConversation => 'Start the conversation!';

  @override
  String get writeAMessage => 'Write a message...';

  @override
  String failedToSendMessage(String error) {
    return 'Failed to send message: $error';
  }

  @override
  String failedToSendImage(String error) {
    return 'Failed to send image: $error';
  }

  @override
  String get photoLabel => '📷 Photo';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get validationPhoneRequired => 'Phone number is required';

  @override
  String get validationPhoneInvalid => 'Enter a valid phone number (10 digits)';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get validationPriceRequired => 'Price is required';

  @override
  String get validationPriceInvalid => 'Enter a valid price';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get pricePredictionsTitle => 'Price Predictions';

  @override
  String get samplePrice => 'Sample Price';

  @override
  String get currentPrice => 'Current Price';

  @override
  String get demoLabel => 'DEMO';

  @override
  String get monthlyChangeSuffix => '(4 weeks)';

  @override
  String monthlyChangeText(String change) {
    return '$change % (4 weeks)';
  }

  @override
  String get vsNationalLabel => 'vs National';

  @override
  String vsNationalWithPrice(String change, String price) {
    return '$change vs National (Rs. $price)';
  }

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get weekForecastTitle => '4 - week forecast';

  @override
  String get districtLegend => 'District';

  @override
  String get nationalLegend => 'National';

  @override
  String get weeklyBreakdownTitle => 'Weekly Breakdown';

  @override
  String get nextWeekLabel => 'Next Week';

  @override
  String weekLabel(int week) {
    return 'Week $week';
  }

  @override
  String highestPrice(String price) {
    return 'Highest: Rs. $price';
  }

  @override
  String get upwardTrend => 'UPWARD TREND';

  @override
  String get downwardTrend => 'DOWNWARD TREND';

  @override
  String get nationalLabel => 'National: ';

  @override
  String get predictionDisclaimer =>
      'Weekly predictions based on 3 months of historical data and national benchmarks. Actual prices may vary.';

  @override
  String get noPredictionsAvailable => 'No predictions available';

  @override
  String get selectDistrictAndGrade => 'Select a district and grade';

  @override
  String get allDistricts => 'All Districts';

  @override
  String get allGrades => 'All Grades';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get managementTools => 'Management Tools';

  @override
  String get expenseTracker => 'Expense Tracker';

  @override
  String get expenseTrackerDescription => 'Track and manage your farm expenses';

  @override
  String get cropManagement => 'Crop Management';

  @override
  String get cropManagementDescription =>
      'Manage your crops and harvest schedule';

  @override
  String get analytics => 'Analytics';

  @override
  String get analyticsDescription =>
      'View insights and statistics about your farm';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String addExpenseTitle(String farmerType) {
    return 'Add Expense - $farmerType';
  }

  @override
  String get categoryLabel => 'Category';

  @override
  String get amountLabel => 'Amount (Rs.)';

  @override
  String get dateLabel => 'Date';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get expenseAddedSuccess => 'Expense added successfully!';

  @override
  String get expenseTrackerTitle => 'Expense Tracker';

  @override
  String get switchFarmerType => 'Switch farmer type';

  @override
  String get landOwnerLabel => 'Land Owner';

  @override
  String get nurseryOwnerLabel => 'Nursery Owner';

  @override
  String get baleBuyerShopLabel => 'Bale Buyer Shop';

  @override
  String trackingLabel(String term) {
    return 'Tracking: $term';
  }

  @override
  String totalExpensesLabel(String farmerType) {
    return '$farmerType — Total Expenses';
  }

  @override
  String transactionsThisMonth(int count) {
    return '$count transactions this month';
  }

  @override
  String get expenseBreakdown => 'Expense Breakdown';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noExpensesThisMonth => 'No expenses this month';

  @override
  String startTrackingCosts(String farmerType) {
    return 'Start tracking your $farmerType costs';
  }

  @override
  String get revenueLabel => 'Revenue';

  @override
  String revenueRs(String amount) {
    return 'Revenue: Rs. $amount';
  }

  @override
  String get netProfitLoss => 'Net Profit / Loss';

  @override
  String get enterRevenue => 'Enter your revenue for this period';

  @override
  String get tapToEnterRevenue => 'Tap to enter revenue & see profit';

  @override
  String get peelerShareReminder =>
      'Remember: Cinnamon peelers typically take 1/3 to 1/2 of the processed cinnamon value. Make sure you\'ve included this under \"Processing Workers Share\" expenses.';

  @override
  String get pleaseLogin => 'Please login';

  @override
  String historyTitle(String emoji) {
    return '$emoji History';
  }

  @override
  String get allCategories => 'All Categories';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get farmerTypeTermLandOwner => 'Season (6 months)';

  @override
  String get farmerTypeTermNurseryOwner => 'Batch / Month';

  @override
  String get farmerTypeTermBaleBuyer => 'Month';

  @override
  String get farmerTypeProfitLabelLandOwner => 'Cinnamon Sale Revenue';

  @override
  String get farmerTypeProfitLabelNurseryOwner => 'Seedling Sales Revenue';

  @override
  String get farmerTypeProfitLabelBaleBuyer => 'Cinnamon Sales Revenue';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get languageLabel => 'Language';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Switch between light and dark theme';

  @override
  String get darkModeSoon => 'Dark mode coming soon!';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get pushNotificationsLabel => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle =>
      'Receive notifications for new messages and updates';

  @override
  String get accountSection => 'Account';

  @override
  String get privacyPolicyLabel => 'Privacy Policy';

  @override
  String get termsOfServiceLabel => 'Terms of Service';

  @override
  String get aboutLabel => 'About';

  @override
  String get aboutVersion => 'Version 1.0.0';

  @override
  String get logoutLabel => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmBody => 'Are you sure you want to logout?';

  @override
  String get appDescription =>
      'Sri Lanka\'s premier marketplace for cinnamon trading with AI-powered features.';

  @override
  String get accountTitle => 'Account';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get myAdsLabel => 'My Ads';

  @override
  String get savedSearchesLabel => 'Saved searches';

  @override
  String get myProfileLabel => 'My Profile';

  @override
  String get faqLabel => 'FAQ';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get roleLabel => 'Role';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationHintEdit => 'e.g., Matale, Central Province';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get tabListings => 'Listings';

  @override
  String get tabAnnouncements => 'Announcements';

  @override
  String get locationDetailLabel => 'Location';

  @override
  String get createPostTitle => 'Create a post';

  @override
  String get createPostSubtitle => 'Choose what you want to post';

  @override
  String get postTypeListing => 'Listing';

  @override
  String get postTypeListingSubtitle => 'Sell your cinnamon products';

  @override
  String get postTypeAnnouncement => 'Buying announcement';

  @override
  String get postTypeAnnouncementSubtitle =>
      'Announce what cinnamon you want to buy';

  @override
  String get noBuyingAnnouncementsYet => 'No buying announcements yet';

  @override
  String get beFirstToPostAnnouncement =>
      'Be the first to post what you want to buy';

  @override
  String get buyingAnnouncementTitle => 'Buying Announcement';

  @override
  String get buyingBadge => 'BUYING';

  @override
  String get offeredPrice => 'Offered Price';

  @override
  String get detailsLabel => 'Details';

  @override
  String get postedByLabel => 'Posted by';

  @override
  String get contactBuyerButton => 'Contact Buyer';

  @override
  String get postBuyingAnnouncementTitle => 'Post Buying Announcement';

  @override
  String get announcementInfoBanner =>
      'You\'re posting a buying announcement. Sellers will contact you directly.';

  @override
  String get categoryHint => 'Category';

  @override
  String get announcementTitleHint =>
      'e.g. Looking for Alba grade cinnamon bales';

  @override
  String get announcementDescriptionHint =>
      'Describe what you are looking for, preferred quality, etc.';

  @override
  String get offeredPriceHint => 'Offered price (LKR/kg)';

  @override
  String get selectGradesLabel => 'Select grades';

  @override
  String get selectGradesTitle => 'Select Grades';

  @override
  String get clearAll => 'Clear all';

  @override
  String get confirmButton => 'Confirm';

  @override
  String confirmWithCount(int count) {
    return 'Confirm ($count)';
  }

  @override
  String get postAnnouncementButton => 'Post Announcement';

  @override
  String get announcementPostedSuccess => 'Announcement posted successfully!';

  @override
  String gradesSelectedLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'grades',
      one: 'grade',
    );
    return '$count $_temp0 selected';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get pleaseLoginToViewNotifications =>
      'Please log in to view notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet';
}
