import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: TextField(
            maxLines: maxLines,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.textHint, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? AppSpacing.sm : AppSpacing.lg,
                vertical: maxLines > 1 ? AppSpacing.lg : AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
