import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AutoLogBrand extends StatelessWidget {
  final bool showPro;
  final Color? textColor;

  const AutoLogBrand({super.key, this.showPro = true, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.appBrandName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor ?? AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
        if (showPro) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              AppStrings.proBadge,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: textColor ?? AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
