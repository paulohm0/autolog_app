import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/core/utils/snackbar_utils.dart';
import 'package:autolog_app/ui/routes/login/google_sign_in_button.dart';
import 'package:autolog_app/ui/routes/login/login_benefits.dart';
import 'package:autolog_app/ui/routes/login/login_cubit.dart';
import 'package:autolog_app/ui/routes/login/login_header.dart';
import 'package:autolog_app/ui/routes/login/login_state.dart';
import 'package:autolog_app/ui/routes/login/login_top_image.dart';
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.colors.primaryLight, context.colors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const LoginTopImage(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      const LoginHeader(),
                      SizedBox(height: AppSpacing.lg),
                      const LoginBenefits(),
                      SizedBox(height: AppSpacing.xxxxl),
                      BlocConsumer<LoginCubit, LoginState>(
                        bloc: _cubit,
                        listener: (context, state) {
                          switch (state) {
                            case LoginSuccess():
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.home,
                              );
                            case LoginError():
                              showAppSnackBar(
                                context,
                                state.message,
                                isError: true,
                              );
                            default:
                              break;
                          }
                        },
                        builder: (context, state) {
                          return switch (state) {
                            LoginLoading() => CircularProgressIndicator(
                              color: context.colors.primary,
                            ),
                            LoginSuccess() => const SizedBox.shrink(),
                            LoginInitial() ||
                            LoginError() => GoogleSignInButton(
                              onPressed: () => _cubit.signIn(),
                            ),
                          };
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
