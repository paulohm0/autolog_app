import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDropdownField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? value;
  final IconData? prefixIcon;
  final VoidCallback? onTap;
  final String? errorText;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    this.value,
    this.prefixIcon,
    this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: hasError ? Border.all(color: context.colors.error) : null,
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, color: context.colors.textHint, size: 20),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    value ?? hintText,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: value != null
                          ? context.colors.textPrimary
                          : context.colors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.colors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall(context).copyWith(color: context.colors.error),
          ),
        ],
      ],
    );
  }
}
