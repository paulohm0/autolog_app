import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.textPrimary,
          elevation: 2,
          shadowColor: context.colors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        icon: Image.asset(
          'assets/images/google-logo.png',
          width: 22,
          height: 22,
        ),
        label: Text(
          AppStrings.signInGoogleLabel,
          style: AppTextStyles.titleMedium(context),
        ),
      ),
    );
  }
}
