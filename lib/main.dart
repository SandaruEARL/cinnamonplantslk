import 'package:cinnamon_marketplace_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:cinnamon_marketplace_app/presentation/bloc/auth/auth_event.dart';
import 'package:cinnamon_marketplace_app/presentation/bloc/auth/auth_state.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/home/home_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:cinnamon_marketplace_app/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/app_theme.dart';
import 'data/services/ai/tflite_service.dart';
import 'data/services/firebase/auth_service.dart';
import 'data/services/firebase/firestore_service.dart';
import 'data/services/firebase/messaging_service.dart';
import 'data/services/firebase/storage_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding. ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AI models
  final tfliteService = TFLiteService();
  await tfliteService.loadQualityGradingModel();
  await tfliteService.loadPricePredictionModel();

  runApp(MyApp(tfliteService: tfliteService));

}

class MyApp extends StatelessWidget {

  final TFLiteService tfliteService;

  const MyApp({super.key, required this.tfliteService});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [

        RepositoryProvider(create: (context) => AuthService()),
        RepositoryProvider(create: (context) => FirestoreService()),
        RepositoryProvider(create: (context) => StorageService()),
        RepositoryProvider(create: (context) => MessagingService()),
        RepositoryProvider. value(value: tfliteService),


      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authService: context.read<AuthService>(),
        ).. add(AuthCheckRequested()),
        child: MaterialApp(
          title: 'Cinnamon Marketplace',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading || state is AuthInitial) {
                return const SplashScreen();
              } else if (state is AuthAuthenticated) {
                return const HomeScreen();
              } else {
                return const OnboardingScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}