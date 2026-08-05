import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/firebase_options.dart';
import 'package:autolog_app/ui/cubit/theme/theme_cubit.dart';
import 'package:autolog_app/ui/routes/login/login_screen.dart';
import 'package:autolog_app/ui/routes/main_navigation/main_navigation_screen.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  setupDependencyInjection(prefs);
  getIt<FirebaseAuth>().setLanguageCode('pt-BR');

  // Config de report de crash da versões de release para o painel do Crashlytics.
  // Crashs em desenvolvimento local não são enviados
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const AutoLogApp());
}

class AutoLogApp extends StatelessWidget {
  const AutoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appBrandName,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: _AuthGate(),
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}

// Verifica se existe uma sessão já persistida (usuário continua logado ao reabrir o app).
class _AuthGate extends StatefulWidget {
  const _AuthGate({super.key});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<User?> _initialUser;

  @override
  void initState() {
    super.initState();
    _initialUser = _loadInitialUser();
  }

  // Sem timeout aqui, a splash ficaria presa pra sempre se
  // authStateChanges() nunca emitir (ex: rede instável no boot do app).
  Future<User?> _loadInitialUser() {
    return getIt<FirebaseAuth>().authStateChanges().first.timeout(
      const Duration(seconds: 12),
    );
  }

  void _retry() {
    setState(() {
      _initialUser = _loadInitialUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _initialUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: context.colors.primary,
            body: Center(
              child: Image.asset('assets/images/autolog-logo.png', width: 150),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: context.colors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 48,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppStrings.authGateErrorMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: AppStrings.retryButton,
                      onPressed: _retry,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (snapshot.data != null) return const MainNavigationScreen();
        return const LoginScreen();
      },
    );
  }
}
