import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/ui/routes/login/login_cubit.dart';
import 'package:autolog_app/ui/routes/login/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginCubit _cubit;

  @override
  void initState() {
    _cubit = getIt<LoginCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<LoginCubit, LoginState>(
          bloc: _cubit,
          listener: (context, state) {
            switch (state) {
              case LoginSuccess():
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              case LoginError():
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              default:
                break;
            }
          },
          builder: (context, state) {
            return switch (state) {
              LoginLoading() => const CircularProgressIndicator(),
              LoginSuccess() => const SizedBox.shrink(),
              LoginInitial() || LoginError() => ElevatedButton.icon(
                onPressed: () => _cubit.signIn(),
                icon: Image.asset(
                  'assets/images/google-logo.png',
                  width: 30,
                  height: 30,
                ),
                label: Text(AppStrings.signInGoogleLabel),
              ),
            };
          },
        ),
      ),
    );
  }
}
