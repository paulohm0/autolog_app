import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Decoração compartilhada entre [AppTextField] e [AppAutocompleteField],
/// pra manter os dois com a mesma aparência sem duplicar o estilo.
BoxDecoration appFieldBoxDecoration(
  BuildContext context, {
  required bool hasError,
}) {
  final colors = context.colors;
  return BoxDecoration(
    color: colors.surfaceVariant,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: hasError ? Border.all(color: colors.error) : null,
  );
}

InputDecoration appFieldInputDecoration(
  BuildContext context, {
  required String hintText,
  IconData? prefixIcon,
  int? maxLength,
  bool multiline = false,
}) {
  final colors = context.colors;
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.bodyLarge(context).copyWith(color: colors.textHint),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: colors.textHint, size: 20)
        : null,
    border: InputBorder.none,
    counterText: maxLength != null ? '' : null,
    contentPadding: EdgeInsets.symmetric(
      horizontal: prefixIcon != null ? AppSpacing.sm : AppSpacing.lg,
      vertical: multiline ? AppSpacing.lg : AppSpacing.md,
    ),
  );
}

Widget appFieldErrorText(BuildContext context, String message) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      message,
      style: AppTextStyles.bodySmall(context).copyWith(color: context.colors.error),
    ),
  );
}
