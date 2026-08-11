import 'package:autolog_app/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Formatting', () {
    test('formatDate -> formata dia/mes/ano com zero á esquerda', () {
      final date = DateTime(2026, 8, 6);
      final result = formatDate(date);
      expect(result, '06/08/2026');
    });

    test('formatMonthAbbrev -> retorna a abreviação do mês correspondente', () {
      final date = DateTime(2026, 8, 6);
      final result = formatMonthAbbrev(date);
      expect(result, 'AGO');
    });
  });
}
