import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? displayText;
  final VoidCallback onTap;
  final String? errorText;

  const AppDateField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onTap,
    this.displayText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge(context)),
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
                Icon(
                  Icons.calendar_today_outlined,
                  color: context.colors.textHint,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    displayText ?? hintText,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: displayText != null
                          ? context.colors.textPrimary
                          : context.colors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_month_outlined,
                  color: context.colors.textSecondary,
                  size: 20,
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
