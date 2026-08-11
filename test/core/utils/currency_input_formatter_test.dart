import 'package:autolog_app/core/utils/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyInputFormatter', () {
    test('interpreta os dígitos digitados como centavos', () {
      final formatter = CurrencyInputFormatter();
      final newValue = TextEditingValue(
        text: '150',
        selection: TextSelection.collapsed(offset: 3),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        newValue,
      );
      expect(
        result,
        TextEditingValue(
          text: '1,50',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
    });

    test('ignora caracteres não numéricos', () {
      final formatter = CurrencyInputFormatter();
      final newValue = TextEditingValue(
        text: '1a5b0',
        selection: TextSelection.collapsed(offset: 5),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        newValue,
      );
      expect(
        result,
        TextEditingValue(
          text: '1,50',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
    });

    test('insere separador de milhar a cada 3 dígitos', () {
      final formatter = CurrencyInputFormatter();
      final newValue = TextEditingValue(
        text: '100000',
        selection: TextSelection.collapsed(offset: 6),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        newValue,
      );
      expect(
        result,
        TextEditingValue(
          text: '1.000,00',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
    });

    test('corta dígitos além do limite de R\$ 999.999.999,00', () {
      final formatter = CurrencyInputFormatter();
      final newValue = TextEditingValue(
        text: '123456789012',
        selection: TextSelection.collapsed(offset: 12),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        newValue,
      );
      expect(
        result,
        TextEditingValue(
          text: '123.456.789,01',
          selection: TextSelection.collapsed(offset: 14),
        ),
      );
    });

    test('entrada sem nenhum dígito resulta em texto vazio', () {
      final formatter = CurrencyInputFormatter();
      final newValue = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        newValue,
      );
      expect(
        result,
        TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0)),
      );
    });
  });

  group('formatCurrencyInputValue', () {
    test('formata um double como texto de moeda', () {
      expect(formatCurrencyInputValue(1000.0), '1.000,00');
    });

    test('formata zero como 0,00', () {
      expect(formatCurrencyInputValue(0.0), '0,00');
    });
  });

  group('parseCurrencyInput', () {
    test('converte o texto formatado de volta pra double', () {
      expect(parseCurrencyInput('1.000,00'), 1000.0);
    });
    test('texto vazio deve retornar null', () {
      expect(parseCurrencyInput(""), null);
    });
    test('texto sem dígitos numéricos deve retornar null', () {
      expect(parseCurrencyInput("abc"), null);
    });
  });
}
