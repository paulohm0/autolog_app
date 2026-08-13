import 'package:autolog_app/core/utils/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyInputFormatter', () {
    test('interprets typed digits as cents', () {
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

    test('ignores non-numeric characters', () {
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

    test('inserts thousands separator every 3 digits', () {
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

    test('truncates digits beyond the R\$ 999.999.999,00 limit', () {
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

    test('empty input (no digits) results in empty text', () {
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
    test('formats a double as currency text', () {
      expect(formatCurrencyInputValue(1000.0), '1.000,00');
    });

    test('formats zero as 0,00', () {
      expect(formatCurrencyInputValue(0.0), '0,00');
    });
  });

  group('parseCurrencyInput', () {
    test('converts formatted text back to a double', () {
      expect(parseCurrencyInput('1.000,00'), 1000.0);
    });
    test('empty text should return null', () {
      expect(parseCurrencyInput(""), null);
    });
    test('text without numeric digits should return null', () {
      expect(parseCurrencyInput("abc"), null);
    });
  });
}
