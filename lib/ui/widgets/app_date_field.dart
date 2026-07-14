import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? displayText;
  final VoidCallback onTap;

  const AppDateField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onTap,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textHint,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    displayText ?? hintText,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: displayText != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
