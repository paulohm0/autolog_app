import 'package:flutter/services.dart';

/// Formata a digitação da placa do veículo: converte para maiúsculas,
/// aceita só letras e números, limita a 7 caracteres (padrão antigo
/// "ABC1234" ou Mercosul "ABC1D23") e insere um espaço automático depois
/// dos 3 primeiros caracteres.
class LicensePlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursorIndex = newValue.selection.end.clamp(0, newValue.text.length);
    final rawBeforeCursor = newValue.text
        .substring(0, cursorIndex)
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    final chars = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final truncated = chars.length > 7 ? chars.substring(0, 7) : chars;
    final charsBeforeCursor = rawBeforeCursor.length > 7
        ? 7
        : rawBeforeCursor.length;

    final buffer = StringBuffer();
    var cursorOffset = charsBeforeCursor;
    for (var i = 0; i < truncated.length; i++) {
      if (i == 3) {
        buffer.write(' ');
        if (i < charsBeforeCursor) cursorOffset++;
      }
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
