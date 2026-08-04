import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Monta a lista de widgets de uma seção (item + espaçamento), inserindo um
/// [YearSectionHeader] antes do primeiro item de cada ano — só quando há
/// mais de um ano distinto entre os itens (evita cabeçalho redundante numa
/// lista com um único ano).
List<Widget> buildYearGroupedChildren<T>({
  required List<T> items,
  required DateTime Function(T item) dateOf,
  required Widget Function(T item) itemBuilder,
  required double spacingAfterItem,
}) {
  final showYearHeaders =
      items.map((item) => dateOf(item).year).toSet().length > 1;
  int? lastYear;
  final children = <Widget>[];

  for (final item in items) {
    final year = dateOf(item).year;
    if (showYearHeaders && year != lastYear) {
      children.add(YearSectionHeader(year: year, isFirst: lastYear == null));
      lastYear = year;
    }
    children.add(itemBuilder(item));
    children.add(SizedBox(height: spacingAfterItem));
  }

  return children;
}

class YearSectionHeader extends StatelessWidget {
  final int year;
  final bool isFirst;

  const YearSectionHeader({
    super.key,
    required this.year,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 0 : AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        year.toString(),
        style: AppTextStyles.labelLarge(context).copyWith(
          color: context.colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
