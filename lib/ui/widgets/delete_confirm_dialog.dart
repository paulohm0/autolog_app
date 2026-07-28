import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Mostra o diálogo padrão de confirmação de exclusão do app (título
/// específico + mensagem/botões fixos). Retorna `true` só se o usuário
/// confirmar a exclusão.
Future<bool> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(AppStrings.deleteConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            AppStrings.deleteButton,
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
