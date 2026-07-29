import 'package:flutter/services.dart';

/// 999.999.999,00 em centavos = 11 dígitos.
const _maxCurrencyDigits = 11;

/// Formata uma sequência de dígitos (interpretados como centavos) em
/// texto de moeda: separador de milhar (.) e vírgula decimal.
String _formatDigitsAsCurrency(String digits) {
  if (digits.isEmpty) return '';
  final cents = int.parse(digits);
  final reais = cents ~/ 100;
  final centavos = (cents % 100).toString().padLeft(2, '0');

  final reaisStr = reais.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < reaisStr.length; i++) {
    final posFromEnd = reaisStr.length - i;
    buffer.write(reaisStr[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }
  return '$buffer,$centavos';
}

/// Formata a digitação de um campo de valor em reais em tempo real:
/// aceita só dígitos, interpreta a entrada como centavos (preenchendo da
/// direita pra esquerda, como numa calculadora) e limita o valor a
/// R$ 999.999.999,00.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > _maxCurrencyDigits) {
      digits = digits.substring(0, _maxCurrencyDigits);
    }

    final formatted = _formatDigitsAsCurrency(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formata um valor já existente (ex: vindo do banco) no mesmo padrão do
/// [CurrencyInputFormatter], pra pré-preencher o campo ao editar.
String formatCurrencyInputValue(double value) {
  final cents = (value * 100).round().toString();
  return _formatDigitsAsCurrency(cents);
}

/// Extrai o valor numérico digitado num campo com [CurrencyInputFormatter].
double? parseCurrencyInput(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.parse(digits) / 100;
}
