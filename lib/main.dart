import 'package:cinnamon_marketplace_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:cinnamon_marketplace_app/presentation/bloc/auth/auth_event.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/home/home_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/splash/splash_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/auth/login_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_theme.dart';
import 'data/services/ai/tflite_service.dart';
import 'data/services/firebase/auth_service.dart';
import 'data/services/firebase/firestore_service.dart';
import 'data/services/firebase/messaging_service.dart';
import 'data/services/firebase/storage_service.dart';
import 'data/services/ml/ml_preprocessing_service.dart';
import 'data/services/ml/model_update_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize services
  final preprocessingService = MLPreprocessingService();
  final modelUpdateService = ModelUpdateService(prefs);
  final tfliteService = TFLiteService(modelUpdateService, preprocessingService);

  // Initialize TFLite models
  await tfliteService.initialize();

  runApp(MyApp(
    tfliteService: tfliteService,
    preprocessingService: preprocessingService,
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  final TFLiteService tfliteService;
  final MLPreprocessingService preprocessingService;
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.tfliteService,
    required this.preprocessingService,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Firebase Services
        RepositoryProvider(create: (context) => AuthService()),
        RepositoryProvider(create: (context) => FirestoreService()),
        RepositoryProvider(create: (context) => StorageService()),
        RepositoryProvider(create: (context) => MessagingService()),

        // AI/ML Services
        RepositoryProvider.value(value: tfliteService),
        RepositoryProvider.value(value: preprocessingService),

        // SharedPreferences
        RepositoryProvider.value(value: prefs),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authService: context.read<AuthService>(),
        )..add(AuthCheckRequested()),
        child: MaterialApp(
          title: 'Cinnamon Marketplace',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
          },
        ),
      ),
    );
  }
}