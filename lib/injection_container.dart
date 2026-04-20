import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth
import 'data/services/ai/tflite_service.dart';
import 'data/services/ml/ml_preprocessing_service.dart';
import 'data/services/ml/model_update_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/update_profile.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Marketplace
import 'features/chat/domain/usecases/block_user.dart';
import 'features/chat/domain/usecases/delete_message.dart';
import 'features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'features/marketplace/domain/repositories/marketplace_repository.dart';
import 'features/marketplace/domain/usecases/create_advertisement.dart';
import 'features/marketplace/domain/usecases/get_advertisements.dart';
import 'features/marketplace/domain/usecases/get_anouncements.dart';
import 'features/marketplace/domain/usecases/get_user_advertisements.dart';
import 'features/marketplace/domain/usecases/toggle_favorite.dart';
import 'features/marketplace/presentation/bloc/marketplace_bloc.dart';

// Chat
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/get_messages.dart';
import 'features/chat/domain/usecases/get_user_chats.dart';
import 'features/chat/domain/usecases/mark_as_read.dart';
import 'features/chat/domain/usecases/send_message.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';

// Expense
import 'features/expense/data/datasources/expense_remote_datasource.dart';
import 'features/expense/data/repositories/expense_repository_impl.dart';
import 'features/expense/domain/repositories/expense_repository.dart';
import 'features/expense/domain/usecases/create_expense.dart';
import 'features/expense/domain/usecases/get_expenses_by_date_range.dart';
import 'features/expense/domain/usecases/get_user_expenses.dart';
import 'features/expense/presentation/bloc/expense_bloc.dart';

// Location
import 'features/location/data/datasources/location_remote_datasource.dart';
import 'features/location/data/repositories/location_repository_impl.dart';
import 'features/location/domain/repositories/location_repository.dart';
import 'features/location/domain/usecases/delete_location.dart';
import 'features/location/domain/usecases/get_approved_locations.dart';
import 'features/location/domain/usecases/get_user_locations.dart';
import 'features/location/domain/usecases/save_location.dart';
import 'features/location/presentation/bloc/location_bloc.dart';

// AI
import 'features/ai/data/datasources/ai_local_datasource.dart';
import 'features/ai/data/repositories/ai_repository_impl.dart';
import 'features/ai/domain/repositories/ai_repository.dart';
import 'features/ai/domain/usecases/predict_price.dart';
import 'features/ai/presentation/bloc/ai_bloc.dart';

// External services
import 'data/services/cloudinary/cloudinary_service.dart';
import 'data/services/firebase/auth_service.dart';
import 'data/services/firebase/storage_service.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── BLoCs (factory = fresh instance per BlocProvider) ──────────
  sl.registerFactory(() => AuthBloc(
    signIn:         sl(),
    signUp:         sl(),
    signOut:        sl(),
    getCurrentUser: sl(),
    updateProfile:  sl(),
  ));

  sl.registerFactory(() => MarketplaceBloc(
    getAdvertisements: sl(),
    getUserAdvertisements: sl(),
    getAnnouncements: sl(),
    createAdvertisement: sl(),
    addToFavorites: sl(),
    removeFromFavorites: sl(),
  ));

  sl.registerFactory(() => ChatBloc(
    getUserChats: sl(),
    getMessages: sl(),
    sendMessage: sl(),
    sendImageMessage: sl(),
    markAsRead: sl(),
    deleteMessageForMe: sl(),
    deleteMessageForEveryone: sl(),
    blockUser: sl(),
    unblockUser: sl(),
  ));

  sl.registerFactory(() => ExpenseBloc(
    getExpensesByDateRange: sl(),
    getUserExpenses: sl(),
    createExpense: sl(),
  ));

  sl.registerFactory(() => LocationBloc(
    getApprovedLocations: sl(),
    getUserLocations: sl(),
    saveLocation: sl(),
    deleteLocation: sl(),
  ));

  // registerFactory so each screen navigation gets a clean state
  sl.registerFactory(() => AiBloc(predictPrice: sl()));

  // ── Use Cases ──────────────────────────────────────────────────
  // Auth
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => BlockUser(sl()));
  sl.registerLazySingleton(() => UnblockUser(sl()));

  // Marketplace
  sl.registerLazySingleton(() => GetAdvertisements(sl()));
  sl.registerLazySingleton(() => GetUserAdvertisements(sl()));
  sl.registerLazySingleton(() => CreateAdvertisement(sl()));
  sl.registerLazySingleton(() => AddToFavorites(sl()));
  sl.registerLazySingleton(() => RemoveFromFavorites(sl()));
  sl.registerLazySingleton(() => GetAnnouncements(sl()));

  // Chat
  sl.registerLazySingleton(() => GetUserChats(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => SendImageMessage(sl()));
  sl.registerLazySingleton(() => MarkAsRead(sl()));
  sl.registerLazySingleton(() => DeleteMessageForMe(sl()));
  sl.registerLazySingleton(() => DeleteMessageForEveryone(sl()));

  // Expense
  sl.registerLazySingleton(() => GetExpensesByDateRange(sl()));
  sl.registerLazySingleton(() => GetUserExpenses(sl()));
  sl.registerLazySingleton(() => CreateExpense(sl()));

  // Location
  sl.registerLazySingleton(() => GetApprovedLocations(sl()));
  sl.registerLazySingleton(() => GetUserLocations(sl()));
  sl.registerLazySingleton(() => SaveLocation(sl()));
  sl.registerLazySingleton(() => DeleteLocation(sl()));

  // AI
  sl.registerLazySingleton(() => PredictPrice(sl()));

  // ── Repositories (interface → implementation) ──────────────────
  sl.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<MarketplaceRepository>(
          () => MarketplaceRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<ChatRepository>(
          () => ChatRepositoryImpl(remoteDataSource: sl(), authService: sl()));

  sl.registerLazySingleton<ExpenseRepository>(
          () => ExpenseRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<LocationRepository>(
          () => LocationRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<AiRepository>(
          () => AiRepositoryImpl(datasource: sl()));

  // ── Data Sources ───────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
          () => AuthRemoteDataSourceImpl(
          firebaseAuth: sl(), firestore: sl()));

  sl.registerLazySingleton<MarketplaceRemoteDataSource>(
          () => MarketplaceRemoteDataSourceImpl(
          firestore: sl(), cloudinary: sl()));

  sl.registerLazySingleton<ChatRemoteDataSource>(
          () => ChatRemoteDataSourceImpl(
          firestore: sl(), storage: sl()));

  sl.registerLazySingleton<ExpenseRemoteDataSource>(
          () => ExpenseRemoteDataSourceImpl(firestore: sl()));

  sl.registerLazySingleton<LocationRemoteDataSource>(
          () => LocationRemoteDataSourceImpl(
          firestore: sl(), cloudinary: sl()));


  // TFLiteService is lazySingleton — one shared model instance across the app.
  // The model file is loaded once and reused; reloading on every screen
  // would be slow and wasteful.
  sl.registerLazySingleton<AiLocalDatasource>(
          () => AiLocalDatasourceImpl(sl()));


  sl.registerLazySingleton<OnboardingRepository>(
        () => OnboardingRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => CompleteOnboarding(sl()));
  sl.registerFactory(() => OnboardingCubit(sl()));

  // ── External ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => CloudinaryService());
  sl.registerLazySingleton(() => StorageService());
  sl.registerLazySingleton(() => AuthService());

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // AI services
  // MLPreprocessingService first — TFLiteService depends on it
  sl.registerLazySingleton(() => MLPreprocessingService());
  sl.registerLazySingleton(() => ModelUpdateService(sl()));
  sl.registerLazySingleton(() => TFLiteService(sl(), sl()));
}