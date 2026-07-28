import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/firebase_options.dart';
import 'package:autolog_app/ui/routes/login/login_screen.dart';
import 'package:autolog_app/ui/routes/main_navigation/main_navigation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupDependencyInjection();
  getIt<FirebaseAuth>().setLanguageCode('pt-BR');
  runApp(const AutoLogApp());
}

class AutoLogApp extends StatelessWidget {
  const AutoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appBrandName,
      theme: AppTheme.theme,
      home: _AuthGate(),
      routes: AppRoutes.routes,
    );
  }
}

/// Decide, uma única vez na inicialização do app, se existe uma sessão
/// já persistida (usuário continua logado ao reabrir o app). A partir
/// daí, toda navegação entre login/home é feita explicitamente pelas
/// telas (LoginScreen, ProfileScreen) via rotas nomeadas — este widget
/// não fica escutando o stream de auth continuamente, pra evitar
/// disputar a navegação com essas rotas.
class _AuthGate extends StatefulWidget {
  const _AuthGate({super.key});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Future<User?> _initialUser = getIt<FirebaseAuth>()
      .authStateChanges()
      .first;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _initialUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: Image.asset('assets/images/autolog-logo.png', width: 150),
            ),
          );
        }
        if (snapshot.data != null) return const MainNavigationScreen();
        return const LoginScreen();
      },
    );
  }
}
