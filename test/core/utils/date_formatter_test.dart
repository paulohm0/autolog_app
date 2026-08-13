import 'package:autolog_app/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Formatting', () {
    test('formatDate -> formats day/month/year with leading zero', () {
      final date = DateTime(2026, 8, 6);
      final result = formatDate(date);
      expect(result, '06/08/2026');
    });

    test('formatMonthAbbrev -> returns the corresponding month abbreviation', () {
      final date = DateTime(2026, 8, 6);
      final result = formatMonthAbbrev(date);
      expect(result, 'AGO');
    });
  });
}
