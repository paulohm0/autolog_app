import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDropdownField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final VoidCallback? onTap;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelLarge),
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
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, color: AppColors.textHint, size: 20),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    hintText,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
