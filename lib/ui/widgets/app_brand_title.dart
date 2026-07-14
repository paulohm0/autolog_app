import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppBrandTitle extends StatelessWidget {
  const AppBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: AppStrings.appBrandNameSplit1,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(
            text: AppStrings.appBrandNameSplit2,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
