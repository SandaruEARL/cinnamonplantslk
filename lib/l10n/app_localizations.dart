import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @categoryAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAllLabel;

  /// No description provided for @categoryCinnamonPlants.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon Plants'**
  String get categoryCinnamonPlants;

  /// No description provided for @categoryCinnamonBales.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon Bales'**
  String get categoryCinnamonBales;

  /// No description provided for @categoryCinnamonOil.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon Oil'**
  String get categoryCinnamonOil;

  /// No description provided for @categoryCinnamonSoap.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon Soap'**
  String get categoryCinnamonSoap;

  /// No description provided for @categoryCinnamonScents.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon Scents'**
  String get categoryCinnamonScents;

  /// No description provided for @categoryOtherProducts.
  ///
  /// In en, this message translates to:
  /// **'Other Products'**
  String get categoryOtherProducts;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to Cinnamon Marketplace'**
  String get loginSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @exploreMap.
  ///
  /// In en, this message translates to:
  /// **'Explore Map'**
  String get exploreMap;

  /// No description provided for @exploreMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find nurseries and bale\nbuyers near you'**
  String get exploreMapSubtitle;

  /// No description provided for @nurseryPlantations.
  ///
  /// In en, this message translates to:
  /// **'Nursery Plantations'**
  String get nurseryPlantations;

  /// No description provided for @baleBuyers.
  ///
  /// In en, this message translates to:
  /// **'Bale Buyers'**
  String get baleBuyers;

  /// No description provided for @baleBuyingShops.
  ///
  /// In en, this message translates to:
  /// **'Bale Buying Shops'**
  String get baleBuyingShops;

  /// No description provided for @myRegisteredLocations.
  ///
  /// In en, this message translates to:
  /// **'My Registered Locations'**
  String get myRegisteredLocations;

  /// No description provided for @registerYourLocations.
  ///
  /// In en, this message translates to:
  /// **'Register your locations'**
  String get registerYourLocations;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navHome;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navPredictions.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get navPredictions;

  /// No description provided for @navTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// No description provided for @aiFeatures.
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get aiFeatures;

  /// No description provided for @pricePredict.
  ///
  /// In en, this message translates to:
  /// **'Price Predict'**
  String get pricePredict;

  /// No description provided for @pricePredictSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get pricePredictSubtitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @buyPlants.
  ///
  /// In en, this message translates to:
  /// **'Buy Plants'**
  String get buyPlants;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @recentAds.
  ///
  /// In en, this message translates to:
  /// **'Recent Ads'**
  String get recentAds;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noAdsYet.
  ///
  /// In en, this message translates to:
  /// **'No ads yet'**
  String get noAdsYet;

  /// No description provided for @toastLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in with a Nursery Owner or Bale Buyer account.'**
  String get toastLoginRequired;

  /// No description provided for @toastLocationRestricted.
  ///
  /// In en, this message translates to:
  /// **'Only Nursery Owners and Bale Buyers can register locations.'**
  String get toastLocationRestricted;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'v.1.0.10 by EarlixLabs'**
  String get appVersion;

  /// No description provided for @registerNurseryTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Nursery / Plantation location'**
  String get registerNurseryTitle;

  /// No description provided for @registerShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Bale Buying Shop location'**
  String get registerShopTitle;

  /// No description provided for @updateNurseryTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Nursery / Plantation'**
  String get updateNurseryTitle;

  /// No description provided for @updateShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Bale Buying Shop'**
  String get updateShopTitle;

  /// No description provided for @hintNurseryName.
  ///
  /// In en, this message translates to:
  /// **'Nursery / Plantation Name'**
  String get hintNurseryName;

  /// No description provided for @hintShopName.
  ///
  /// In en, this message translates to:
  /// **'Bale Buying Shop Name'**
  String get hintShopName;

  /// No description provided for @hintContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get hintContactNumber;

  /// No description provided for @hintDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hintDescription;

  /// No description provided for @hintOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get hintOpeningHours;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// No description provided for @pickLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Pick your location from the map'**
  String get pickLocationHint;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForReview;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocation;

  /// No description provided for @locationSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Submitted'**
  String get locationSubmittedTitle;

  /// No description provided for @locationSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Your {typeLabel} location is pending approval. It will appear on the map once approved.'**
  String locationSubmittedBody(String typeLabel);

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @snackPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Please pick a location on the map'**
  String get snackPickLocation;

  /// No description provided for @myLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Registered Locations'**
  String get myLocationsTitle;

  /// No description provided for @plantationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Plantations'**
  String get plantationsLabel;

  /// No description provided for @baleBuyersLabel.
  ///
  /// In en, this message translates to:
  /// **'Bale Buyers'**
  String get baleBuyersLabel;

  /// No description provided for @plantationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Register your nursery so buyers can find you on the map.'**
  String get plantationsDescription;

  /// No description provided for @baleBuyersDescription.
  ///
  /// In en, this message translates to:
  /// **'List your shop so sellers nearby can locate you easily.'**
  String get baleBuyersDescription;

  /// No description provided for @locationsReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Locations are reviewed before appearing on the map.'**
  String get locationsReviewNotice;

  /// No description provided for @noLocationsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t registered any locations yet'**
  String get noLocationsYet;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get addLocation;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLocation;

  /// No description provided for @statusVisibleOnMap.
  ///
  /// In en, this message translates to:
  /// **'Visible on map'**
  String get statusVisibleOnMap;

  /// No description provided for @statusPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get statusPendingReview;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @removeLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove location?'**
  String get removeLocationTitle;

  /// No description provided for @removeNurseryBody.
  ///
  /// In en, this message translates to:
  /// **'Your nursery location will be removed from the map.'**
  String get removeNurseryBody;

  /// No description provided for @removeShopBody.
  ///
  /// In en, this message translates to:
  /// **'Your shop location will be removed from the map.'**
  String get removeShopBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @pickLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick Location'**
  String get pickLocationTitle;

  /// No description provided for @searchLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Search for location'**
  String get searchLocationHint;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLocation;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @tapMapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap map to select location'**
  String get tapMapToSelect;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get locationNotFound;

  /// No description provided for @couldNotFindLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not find that location'**
  String get couldNotFindLocation;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location: {error}'**
  String couldNotGetLocation(String error);

  /// No description provided for @loadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Loading locations...'**
  String get loadingLocations;

  /// No description provided for @locationCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{location} other{locations}}'**
  String locationCount(int count);

  /// No description provided for @noLocationsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No {typeName} registered yet'**
  String noLocationsRegistered(String typeName);

  /// No description provided for @callButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// No description provided for @directionsButton.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsButton;

  /// No description provided for @nurseryBadge.
  ///
  /// In en, this message translates to:
  /// **'Nursery'**
  String get nurseryBadge;

  /// No description provided for @baleBuyerBadge.
  ///
  /// In en, this message translates to:
  /// **'Bale Buyer'**
  String get baleBuyerBadge;

  /// No description provided for @addedBadge.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get addedBadge;

  /// No description provided for @marketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get marketplaceTitle;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @postAd.
  ///
  /// In en, this message translates to:
  /// **'Post Advertisement'**
  String get postAd;

  /// No description provided for @submitForAdReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForAdReview;

  /// No description provided for @adPostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Advertisement posted successfully!'**
  String get adPostedSuccess;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title ( nursery / plantation name )'**
  String get titleHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionHint;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'Price (Rs)'**
  String get priceHint;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantityHint;

  /// No description provided for @gradeHint.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get gradeHint;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Location (Ex. Galle, batapola, matara)'**
  String get locationHint;

  /// No description provided for @pleaseAddImage.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image'**
  String get pleaseAddImage;

  /// No description provided for @myAdvertisements.
  ///
  /// In en, this message translates to:
  /// **'My Advertisements'**
  String get myAdvertisements;

  /// No description provided for @noAdsPosted.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any ads yet'**
  String get noAdsPosted;

  /// No description provided for @adStatusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get adStatusLive;

  /// No description provided for @adStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get adStatusPending;

  /// No description provided for @adStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adStatusRejected;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String rejectionReason(String reason);

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @sellerInformation.
  ///
  /// In en, this message translates to:
  /// **'Seller Information'**
  String get sellerInformation;

  /// No description provided for @whatsappButton.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp'**
  String get whatsappButton;

  /// No description provided for @chatButton.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatButton;

  /// No description provided for @shareFunctionSoon.
  ///
  /// In en, this message translates to:
  /// **'Share functionality coming soon!'**
  String get shareFunctionSoon;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer'**
  String get couldNotLaunchDialer;

  /// No description provided for @couldNotOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get couldNotOpenWhatsapp;

  /// No description provided for @pleaseLoginToChat.
  ///
  /// In en, this message translates to:
  /// **'Please login to chat'**
  String get pleaseLoginToChat;

  /// No description provided for @cannotChatWithSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot chat with yourself'**
  String get cannotChatWithSelf;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty {qty}'**
  String quantityLabel(int qty);

  /// No description provided for @gradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade: {grade}'**
  String gradeLabel(String grade);

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @pleaseLoginToViewMessages.
  ///
  /// In en, this message translates to:
  /// **'Please login to view messages'**
  String get pleaseLoginToViewMessages;

  /// No description provided for @errorLoadingChats.
  ///
  /// In en, this message translates to:
  /// **'Error loading chats: {error}'**
  String errorLoadingChats(String error);

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startChattingWithSellers.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with sellers'**
  String get startChattingWithSellers;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startTheConversation;

  /// No description provided for @writeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get writeAMessage;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failedToSendMessage(String error);

  /// No description provided for @failedToSendImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send image: {error}'**
  String failedToSendImage(String error);

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'📷 Photo'**
  String get photoLabel;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (10 digits)'**
  String get validationPhoneInvalid;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String validationFieldRequired(String fieldName);

  /// No description provided for @validationPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get validationPriceRequired;

  /// No description provided for @validationPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get validationPriceInvalid;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @pricePredictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Predictions'**
  String get pricePredictionsTitle;

  /// No description provided for @samplePrice.
  ///
  /// In en, this message translates to:
  /// **'Sample Price'**
  String get samplePrice;

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get currentPrice;

  /// No description provided for @demoLabel.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get demoLabel;

  /// No description provided for @monthlyChangeSuffix.
  ///
  /// In en, this message translates to:
  /// **'(4 weeks)'**
  String get monthlyChangeSuffix;

  /// No description provided for @monthlyChangeText.
  ///
  /// In en, this message translates to:
  /// **'{change} % (4 weeks)'**
  String monthlyChangeText(String change);

  /// No description provided for @vsNationalLabel.
  ///
  /// In en, this message translates to:
  /// **'vs National'**
  String get vsNationalLabel;

  /// No description provided for @vsNationalWithPrice.
  ///
  /// In en, this message translates to:
  /// **'{change} vs National (Rs. {price})'**
  String vsNationalWithPrice(String change, String price);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @weekForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'4 - week forecast'**
  String get weekForecastTitle;

  /// No description provided for @districtLegend.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLegend;

  /// No description provided for @nationalLegend.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get nationalLegend;

  /// No description provided for @weeklyBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Breakdown'**
  String get weeklyBreakdownTitle;

  /// No description provided for @nextWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Week'**
  String get nextWeekLabel;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String weekLabel(int week);

  /// No description provided for @highestPrice.
  ///
  /// In en, this message translates to:
  /// **'Highest: Rs. {price}'**
  String highestPrice(String price);

  /// No description provided for @upwardTrend.
  ///
  /// In en, this message translates to:
  /// **'UPWARD TREND'**
  String get upwardTrend;

  /// No description provided for @downwardTrend.
  ///
  /// In en, this message translates to:
  /// **'DOWNWARD TREND'**
  String get downwardTrend;

  /// No description provided for @nationalLabel.
  ///
  /// In en, this message translates to:
  /// **'National: '**
  String get nationalLabel;

  /// No description provided for @predictionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Weekly predictions based on 3 months of historical data and national benchmarks. Actual prices may vary.'**
  String get predictionDisclaimer;

  /// No description provided for @noPredictionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No predictions available'**
  String get noPredictionsAvailable;

  /// No description provided for @selectDistrictAndGrade.
  ///
  /// In en, this message translates to:
  /// **'Select a district and grade'**
  String get selectDistrictAndGrade;

  /// No description provided for @allDistricts.
  ///
  /// In en, this message translates to:
  /// **'All Districts'**
  String get allDistricts;

  /// No description provided for @allGrades.
  ///
  /// In en, this message translates to:
  /// **'All Grades'**
  String get allGrades;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// No description provided for @managementTools.
  ///
  /// In en, this message translates to:
  /// **'Management Tools'**
  String get managementTools;

  /// No description provided for @expenseTracker.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get expenseTracker;

  /// No description provided for @expenseTrackerDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your farm expenses'**
  String get expenseTrackerDescription;

  /// No description provided for @cropManagement.
  ///
  /// In en, this message translates to:
  /// **'Crop Management'**
  String get cropManagement;

  /// No description provided for @cropManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your crops and harvest schedule'**
  String get cropManagementDescription;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'View insights and statistics about your farm'**
  String get analyticsDescription;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Expense - {farmerType}'**
  String addExpenseTitle(String farmerType);

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (Rs.)'**
  String get amountLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @expenseAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully!'**
  String get expenseAddedSuccess;

  /// No description provided for @expenseTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get expenseTrackerTitle;

  /// No description provided for @switchFarmerType.
  ///
  /// In en, this message translates to:
  /// **'Switch farmer type'**
  String get switchFarmerType;

  /// No description provided for @landOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Land Owner'**
  String get landOwnerLabel;

  /// No description provided for @nurseryOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Nursery Owner'**
  String get nurseryOwnerLabel;

  /// No description provided for @baleBuyerShopLabel.
  ///
  /// In en, this message translates to:
  /// **'Bale Buyer Shop'**
  String get baleBuyerShopLabel;

  /// No description provided for @trackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking: {term}'**
  String trackingLabel(String term);

  /// No description provided for @totalExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'{farmerType} — Total Expenses'**
  String totalExpensesLabel(String farmerType);

  /// No description provided for @transactionsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions this month'**
  String transactionsThisMonth(int count);

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get noExpensesThisMonth;

  /// No description provided for @startTrackingCosts.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your {farmerType} costs'**
  String startTrackingCosts(String farmerType);

  /// No description provided for @revenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenueLabel;

  /// No description provided for @revenueRs.
  ///
  /// In en, this message translates to:
  /// **'Revenue: Rs. {amount}'**
  String revenueRs(String amount);

  /// No description provided for @netProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Net Profit / Loss'**
  String get netProfitLoss;

  /// No description provided for @enterRevenue.
  ///
  /// In en, this message translates to:
  /// **'Enter your revenue for this period'**
  String get enterRevenue;

  /// No description provided for @tapToEnterRevenue.
  ///
  /// In en, this message translates to:
  /// **'Tap to enter revenue & see profit'**
  String get tapToEnterRevenue;

  /// No description provided for @peelerShareReminder.
  ///
  /// In en, this message translates to:
  /// **'Remember: Cinnamon peelers typically take 1/3 to 1/2 of the processed cinnamon value. Make sure you\'ve included this under \"Processing Workers Share\" expenses.'**
  String get peelerShareReminder;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get pleaseLogin;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'{emoji} History'**
  String historyTitle(String emoji);

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @farmerTypeTermLandOwner.
  ///
  /// In en, this message translates to:
  /// **'Season (6 months)'**
  String get farmerTypeTermLandOwner;

  /// No description provided for @farmerTypeTermNurseryOwner.
  ///
  /// In en, this message translates to:
  /// **'Batch / Month'**
  String get farmerTypeTermNurseryOwner;

  /// No description provided for @farmerTypeTermBaleBuyer.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get farmerTypeTermBaleBuyer;

  /// No description provided for @farmerTypeProfitLabelLandOwner.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon Sale Revenue'**
  String get farmerTypeProfitLabelLandOwner;

  /// No description provided for @farmerTypeProfitLabelNurseryOwner.
  ///
  /// In en, this message translates to:
  /// **'Seedling Sales Revenue'**
  String get farmerTypeProfitLabelNurseryOwner;

  /// No description provided for @farmerTypeProfitLabelBaleBuyer.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon Sales Revenue'**
  String get farmerTypeProfitLabelBaleBuyer;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeLabel;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @darkModeSoon.
  ///
  /// In en, this message translates to:
  /// **'Dark mode coming soon!'**
  String get darkModeSoon;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @pushNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotificationsLabel;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for new messages and updates'**
  String get pushNotificationsSubtitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLabel;

  /// No description provided for @termsOfServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutVersion;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutLabel;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmBody;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Sri Lanka\'s premier marketplace for cinnamon trading with AI-powered features.'**
  String get appDescription;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @myAdsLabel.
  ///
  /// In en, this message translates to:
  /// **'My Ads'**
  String get myAdsLabel;

  /// No description provided for @savedSearchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved searches'**
  String get savedSearchesLabel;

  /// No description provided for @myProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileLabel;

  /// No description provided for @faqLabel.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqLabel;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHintEdit.
  ///
  /// In en, this message translates to:
  /// **'e.g., Matale, Central Province'**
  String get locationHintEdit;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
