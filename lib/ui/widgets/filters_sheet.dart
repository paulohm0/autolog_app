import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Mostra o bottom sheet de filtros (veículo + ano) e retorna a seleção
/// feita ao apertar "Aplicar Filtros", ou null se o usuário fechar sem
/// aplicar nada.
Future<(VehicleEntity?, int?)?> showFiltersSheet(
  BuildContext context, {
  required List<VehicleEntity> vehicles,
  required List<int> years,
  VehicleEntity? selectedVehicle,
  int? selectedYear,
}) {
  return showModalBottomSheet<(VehicleEntity?, int?)>(
    context: context,
    builder: (_) => FiltersSheet(
      vehicles: vehicles,
      years: years,
      initialVehicle: selectedVehicle,
      initialYear: selectedYear,
    ),
  );
}

class FiltersSheet extends StatefulWidget {
  final List<VehicleEntity> vehicles;
  final List<int> years;
  final VehicleEntity? initialVehicle;
  final int? initialYear;

  const FiltersSheet({
    super.key,
    required this.vehicles,
    required this.years,
    this.initialVehicle,
    this.initialYear,
  });

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  VehicleEntity? _vehicle;
  int? _year;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.initialVehicle;
    _year = widget.initialYear;
  }

  Future<void> _pickVehicle() async {
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => _OptionsDialog<VehicleEntity>(
        title: AppStrings.vehicleFilter,
        allLabel: AppStrings.allVehicles,
        options: widget.vehicles,
        selected: _vehicle,
        labelBuilder: (v) => '${v.brand} ${v.model}',
      ),
    );
    if (result == null) return;
    setState(() => _vehicle = result is VehicleEntity ? result : null);
  }

  Future<void> _pickYear() async {
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => _OptionsDialog<int>(
        title: AppStrings.yearFilter,
        allLabel: AppStrings.allYears,
        options: widget.years,
        selected: _year,
        labelBuilder: (y) => y.toString(),
      ),
    );
    if (result == null) return;
    setState(() => _year = result is int ? result : null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.filters, style: AppTextStyles.headlineLarge(context)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: AppStrings.vehicleFilter,
                  value: _vehicle != null
                      ? '${_vehicle!.brand} ${_vehicle!.model}'
                      : AppStrings.allVehicles,
                  trailing: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.colors.textPrimary,
                  ),
                  onTap: _pickVehicle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FilterChip(
                  label: AppStrings.yearFilter,
                  value: _year?.toString() ?? AppStrings.allYears,
                  trailing: Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: context.colors.textPrimary,
                  ),
                  onTap: _pickYear,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: AppStrings.applyFiltersButton,
            icon: Icons.check_rounded,
            onPressed: () => Navigator.of(context).pop((_vehicle, _year)),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: AppTextStyles.labelMedium(context)),
                  Text(
                    value,
                    style: AppTextStyles.titleMedium(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionsDialog<T> extends StatelessWidget {
  final String title;
  final String allLabel;
  final List<T> options;
  final T? selected;
  final String Function(T) labelBuilder;

  const _OptionsDialog({
    required this.title,
    required this.allLabel,
    required this.options,
    required this.selected,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headlineMedium(context)),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _OptionTile(
                      label: allLabel,
                      selected: selected == null,
                      onTap: () => Navigator.of(context).pop(_allMarker),
                    ),
                    for (final option in options)
                      _OptionTile(
                        label: labelBuilder(option),
                        selected: selected == option,
                        onTap: () => Navigator.of(context).pop(option),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: context.colors.primary,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _AllMarker {
  const _AllMarker();
}

const _allMarker = _AllMarker();
