class AppConstants {
  // App Info
  static const String appName = 'Cinnamon Marketplace';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String adsCollection = 'advertisements';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String expensesCollection = 'expenses';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profilePicsPath = 'profile_pictures';
  static const String adImagesPath = 'advertisement_images';
  static const String chatImagesPath = 'chat_images';

  // User Types
  static const String userTypeNursery = 'Nursery Owner';
  static const String userTypeFarmer = 'Farmer/Landowner';
  static const String userTypeBuyer = 'Buyer';
  static const String userTypeSeller = 'Product Seller';

  // Product Categories
  static const List<String> productCategories = [
    'Cinnamon Plants',
    'Cinnamon Bales',
    'Cinnamon Oil',
    'Cinnamon Soap',
    'Cinnamon Scents',
    'Other Products',
  ];

  // Expense Categories
  static const List<String> expenseCategories = [
    'Fertilizer',
    'Labor',
    'Transport',
    'Equipment',
    'Seeds/Plants',
    'Pesticides',
    'Other',
  ];

  // Cinnamon Grades
  static const List<String> cinnamonGrades = [
    'Alba',
    'C5',
    'C4',
    'C3',
  ];

  static const String locationsCollection = 'locations';

  // Pagination
  static const int pageSize = 20;

  // Cache Duration
  static const Duration pricePredictionCacheDuration = Duration(hours: 24);
}