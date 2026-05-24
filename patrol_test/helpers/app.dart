import 'package:cinnamonmarketplace/core/app_theme.dart';
import 'package:cinnamonmarketplace/core/di/injection_container.dart' as di;
import 'package:cinnamonmarketplace/data/services/ai/tflite_service.dart';
import 'package:cinnamonmarketplace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cinnamonmarketplace/features/auth/presentation/bloc/auth_event.dart';
import 'package:cinnamonmarketplace/features/auth/presentation/screens/login_screen.dart';
import 'package:cinnamonmarketplace/features/auth/presentation/screens/register_screen.dart';
import 'package:cinnamonmarketplace/features/home/presentation/screens/home_screen.dart';
import 'package:cinnamonmarketplace/features/locale/presentation/bloc/locale_bloc.dart';
import 'package:cinnamonmarketplace/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:cinnamonmarketplace/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:cinnamonmarketplace/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:cinnamonmarketplace/firebase_options.dart';
import 'package:cinnamonmarketplace/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _initialized = false;

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  if (!_initialized) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await dotenv.load(fileName: '.env');
    await di.init();
    await di.sl<TFLiteService>().initialize();
    _initialized = true;
  }

  await FirebaseAuth.instance.signOut();

  final prefs = di.sl<SharedPreferences>();
  await prefs.setBool('onboarding_complete', true);

  final authBloc         = di.sl<AuthBloc>();
  final notificationBloc = di.sl<NotificationBloc>();
  final localeBloc       = LocaleBloc(prefs);
  final onboardingCubit  = di.sl<OnboardingCubit>();

  runApp(TestApp(
    authBloc:         authBloc,
    notificationBloc: notificationBloc,
    localeBloc:       localeBloc,
    onboardingCubit:  onboardingCubit,
  ));

  await Future<void>.delayed(const Duration(seconds: 3));

  if (!authBloc.isClosed) {
    authBloc.add(const AuthCheckRequested());
  }

  await Future<void>.delayed(const Duration(seconds: 2));
}

class TestApp extends StatelessWidget {
  final AuthBloc authBloc;
  final NotificationBloc notificationBloc;
  final LocaleBloc localeBloc;
  final OnboardingCubit onboardingCubit;

  const TestApp({
    super.key,
    required this.authBloc,
    required this.notificationBloc,
    required this.localeBloc,
    required this.onboardingCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: notificationBloc),
        BlocProvider.value(value: localeBloc),
        BlocProvider.value(value: onboardingCubit),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            title: 'Cinnamon Marketplace',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: localeState.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/login',
            routes: {
              '/login':      (_) => const LoginScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/home':       (_) => const HomeScreen(),
              '/register':   (_) => const RegisterScreen(),
            },
          );
        },
      ),
    );
  }
}