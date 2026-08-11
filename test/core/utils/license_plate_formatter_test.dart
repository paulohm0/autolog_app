import 'package:autolog_app/core/utils/license_plate_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final formatter = LicensePlateInputFormatter();

  test('insere espaço automático depois dos 3 primeiros caracteres', () {
    final newValue = TextEditingValue(
      text: 'ABC1234',
      selection: TextSelection.collapsed(offset: 7),
    );
    final result = formatter.formatEditUpdate(TextEditingValue.empty, newValue);
    expect(
      result,
      TextEditingValue(
        text: 'ABC 1234',
        selection: TextSelection.collapsed(offset: 8),
      ),
    );
  });

  test('transforma letras em maiúsculo e exclui caracteres inválidos', () {
    final newValue = TextEditingValue(
      text: 'abc-1234',
      selection: TextSelection.collapsed(offset: 8),
    );
    final result = formatter.formatEditUpdate(TextEditingValue.empty, newValue);
    expect(
      result,
      TextEditingValue(
        text: 'ABC 1234',
        selection: TextSelection.collapsed(offset: 8),
      ),
    );
  });

  test('restringe ao total de 7 caracteres', () {
    final newValue = TextEditingValue(
      text: 'ABC12345',
      selection: TextSelection.collapsed(offset: 8),
    );
    final result = formatter.formatEditUpdate(TextEditingValue.empty, newValue);
    expect(
      result,
      TextEditingValue(
        text: 'ABC 1234',
        selection: TextSelection.collapsed(offset: 8),
      ),
    );
  });

  test(
    'mantém a posição do cursor ao apagar um caractere antes do espaço automático',
    () {
      final oldValue = TextEditingValue(
        text: 'ABC 1234',
        selection: TextSelection.collapsed(offset: 8),
      );
      final newValue = TextEditingValue(
        text: 'BC 1234',
        selection: TextSelection.collapsed(offset: 0),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(
        result,
        TextEditingValue(
          text: 'BC1 234',
          selection: TextSelection.collapsed(offset: 0),
        ),
      );
    },
  );
}
