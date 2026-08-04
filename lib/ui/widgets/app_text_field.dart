import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/widgets/app_field_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? errorText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.controller,
    this.errorText,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: appFieldBoxDecoration(context, hasError: hasError),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            readOnly: readOnly,
            onTap: onTap,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            style: AppTextStyles.bodyLarge(context),
            decoration: appFieldInputDecoration(
              context,
              hintText: hintText,
              prefixIcon: prefixIcon,
              maxLength: maxLength,
              multiline: maxLines > 1,
            ),
          ),
        ),
        if (hasError) appFieldErrorText(context, errorText!),
      ],
    );
  }
}
