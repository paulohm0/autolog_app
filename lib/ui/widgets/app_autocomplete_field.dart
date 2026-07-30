import 'package:autolog_app/core/constants/vehicle_catalog.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/widgets/app_field_style.dart';
import 'package:flutter/material.dart';

// Campo de texto igual ao [AppTextField], mas que sugere itens de
// [options] conforme o usuário digita. Nunca obriga a escolher e tambem
// aceita qualquer texto livre normalmente.
class AppAutocompleteField extends StatefulWidget {
  final String label;
  final String hintText;
  final List<String> options;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final String? errorText;
  final int? maxLength;

  const AppAutocompleteField({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.controller,
    this.prefixIcon,
    this.errorText,
    this.maxLength,
  });

  @override
  State<AppAutocompleteField> createState() => _AppAutocompleteFieldState();
}

class _AppAutocompleteFieldState extends State<AppAutocompleteField> {
  // RawAutocomplete exige que textEditingController e focusNode sejam
  // fornecidos juntos — por isso o campo precisa gerenciar seu próprio
  // FocusNode em vez de deixar o RawAutocomplete criar um implícito.
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        RawAutocomplete<String>(
          textEditingController: widget.controller,
          focusNode: _focusNode,
          optionsBuilder: (textEditingValue) {
            return matchingOptions(
              widget.options,
              textEditingValue.text,
            ).take(6);
          },
          onSelected: (_) {},
          fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
            return Container(
              decoration: appFieldBoxDecoration(hasError: hasError),
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                maxLength: widget.maxLength,
                style: AppTextStyles.bodyLarge,
                decoration: appFieldInputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon,
                  maxLength: widget.maxLength,
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, optionsToShow) {
            final list = optionsToShow.toList();
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final option = list[index];
                      return ListTile(
                        dense: true,
                        title: Text(option, style: AppTextStyles.bodyMedium),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (hasError) appFieldErrorText(widget.errorText!),
      ],
    );
  }
}
