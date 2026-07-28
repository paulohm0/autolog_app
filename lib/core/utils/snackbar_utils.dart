import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Mostra um SnackBar seguindo o tema do app (ver [AppTheme]). Passe
/// [isError] pra usar a cor de erro em vez do azul padrão de sucesso.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : null,
    ),
  );
}
