import 'package:autolog_app/core/utils/license_plate_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final formatter = LicensePlateInputFormatter();

  group(
    'formatEditUpdate',
    () {
      test('inserts automatic space after the first 3 characters', () {
        final newValue = TextEditingValue(
          text: 'ABC1234',
          selection: TextSelection.collapsed(offset: 7),
        );
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          newValue,
        );
        expect(
          result,
          TextEditingValue(
            text: 'ABC 1234',
            selection: TextSelection.collapsed(offset: 8),
          ),
        );
      });

      test('converts letters to uppercase and strips invalid characters', () {
        final newValue = TextEditingValue(
          text: 'abc-1234',
          selection: TextSelection.collapsed(offset: 8),
        );
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          newValue,
        );
        expect(
          result,
          TextEditingValue(
            text: 'ABC 1234',
            selection: TextSelection.collapsed(offset: 8),
          ),
        );
      });

      test('restricts total length to 7 characters', () {
        final newValue = TextEditingValue(
          text: 'ABC12345',
          selection: TextSelection.collapsed(offset: 8),
        );
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          newValue,
        );
        expect(
          result,
          TextEditingValue(
            text: 'ABC 1234',
            selection: TextSelection.collapsed(offset: 8),
          ),
        );
      });

      test(
        'keeps cursor position when deleting a character before the automatic space',
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
    },
  );
}
