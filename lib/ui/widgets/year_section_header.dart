import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class YearSectionHeader extends StatelessWidget {
  final int year;
  final bool isFirst;

  const YearSectionHeader({
    super.key,
    required this.year,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 0 : AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        year.toString(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
