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
    final chars = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final truncated = chars.length > 7 ? chars.substring(0, 7) : chars;

    final buffer = StringBuffer();
    for (var i = 0; i < truncated.length; i++) {
      if (i == 3) buffer.write(' ');
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
