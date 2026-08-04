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
      backgroundColor: isError ? context.colors.error : null,
    ),
  );
}

/// Igual a [showAppSnackBar], mas recebe o [ScaffoldMessengerState] já
/// resolvido em vez de um [BuildContext] — usado quando a tela que disparou
/// a ação (salvar otimista) já pode ter sido fechada quando a resposta
/// chega, então não dá pra usar `context` de novo.
void showAppSnackBarOn(
  ScaffoldMessengerState messenger,
  String message, {
  Color? errorColor,
}) {
  messenger.showSnackBar(
    SnackBar(content: Text(message), backgroundColor: errorColor),
  );
}
