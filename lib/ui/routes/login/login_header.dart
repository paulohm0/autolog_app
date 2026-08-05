import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final double scale;

  const LoginHeader({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBrandTitle(fontSize: 52 * scale),
        SizedBox(height: AppSpacing.sm * scale),
        Text(
          AppStrings.loginSubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: context.colors.textSecondary,
            fontSize: 14 * scale,
          ),
        ),
      ],
    );
  }
}
