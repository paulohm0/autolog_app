import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Decoração compartilhada entre [AppTextField] e [AppAutocompleteField],
/// pra manter os dois com a mesma aparência sem duplicar o estilo.
BoxDecoration appFieldBoxDecoration({required bool hasError}) {
  return BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: hasError ? Border.all(color: AppColors.error) : null,
  );
}

InputDecoration appFieldInputDecoration({
  required String hintText,
  IconData? prefixIcon,
  int? maxLength,
  bool multiline = false,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: AppColors.textHint, size: 20)
        : null,
    border: InputBorder.none,
    counterText: maxLength != null ? '' : null,
    contentPadding: EdgeInsets.symmetric(
      horizontal: prefixIcon != null ? AppSpacing.sm : AppSpacing.lg,
      vertical: multiline ? AppSpacing.lg : AppSpacing.md,
    ),
  );
}

Widget appFieldErrorText(String message) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      message,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
    ),
  );
}
