import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/core/utils/date_formatter.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_cubit.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_state.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/home/home_state.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/filters_sheet.dart';
import 'package:autolog_app/ui/widgets/simple_history_card.dart';
import 'package:autolog_app/ui/widgets/year_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Histórico de troca de óleo/bateria — não tem cadastro próprio, é só um
/// filtro sobre o histórico de manutenção (ver MaintenanceEntity.hasOilChange
/// /hasBatteryChange, marcados no formulário de Manutenção). Criar, editar
/// e excluir um item de óleo/bateria acontece de lá; essa tela só mostra.
class OilBatteryScreen extends StatefulWidget {
  const OilBatteryScreen({super.key});

  @override
  State<OilBatteryScreen> createState() => _OilBatteryScreenState();
}

class _OilBatteryScreenState extends State<OilBatteryScreen> {
  late final HomeCubit _homeCubit;
  late final VehicleListCubit _vehicleListCubit;
  bool _showOil = true;
  VehicleEntity? _filterVehicle;
  int? _filterYear;

  @override
  void initState() {
    super.initState();
    _homeCubit = getIt<HomeCubit>()..ensureLoaded();
    _vehicleListCubit = getIt<VehicleListCubit>()..ensureLoaded();
  }

  @override
  void dispose() {
    // _homeCubit e _vehicleListCubit são singletons compartilhados com
    // outras telas — não devem ser fechados aqui.
    super.dispose();
  }

  Future<void> _openFilters() async {
    final homeState = _homeCubit.state;
    final vehicleState = _vehicleListCubit.state;
    final vehicles = vehicleState is VehicleListLoaded
        ? vehicleState.vehicles
        : <VehicleEntity>[];

    final relevant = homeState is HomeLoaded
        ? homeState.maintenances.where(
            (m) => _showOil ? m.hasOilChange : m.hasBatteryChange,
          )
        : const Iterable<MaintenanceEntity>.empty();
    final years = relevant.map((m) => m.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));

    final result = await showFiltersSheet(
      context,
      vehicles: vehicles,
      years: years,
      selectedVehicle: _filterVehicle,
      selectedYear: _filterYear,
    );

    if (result == null) return;
    final (vehicle, year) = result;
    setState(() {
      _filterVehicle = vehicle;
      _filterYear = year;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const AppBrandTitle(), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: _MaintenanceTypeToggle(
                showOil: _showOil,
                onChanged: (showOil) => setState(() => _showOil = showOil),
              ),
            ),
            _ListHeader(
              title: _showOil
                  ? AppStrings.oilChangeHistoryTitle
                  : AppStrings.batteryChangeHistoryTitle,
              filterActive: _filterVehicle != null || _filterYear != null,
              onFilterTap: _openFilters,
            ),
            if (_filterVehicle != null || _filterYear != null)
              _ActiveFilterChip(
                label: [
                  if (_filterVehicle != null)
                    '${_filterVehicle!.brand} ${_filterVehicle!.model}',
                  if (_filterYear != null) _filterYear.toString(),
                ].join(' • '),
                onClear: () => setState(() {
                  _filterVehicle = null;
                  _filterYear = null;
                }),
              ),
            Expanded(
              child: BlocBuilder<VehicleListCubit, VehicleListState>(
                bloc: _vehicleListCubit,
                builder: (context, vehicleState) {
                  final vehiclesById = vehicleState is VehicleListLoaded
                      ? vehicleState.vehiclesById
                      : <String, VehicleEntity>{};

                  return BlocBuilder<HomeCubit, HomeState>(
                    bloc: _homeCubit,
                    builder: (context, homeState) {
                      return _ServiceList(
                        state: homeState,
                        showOil: _showOil,
                        vehiclesById: vehiclesById,
                        filterVehicleId: _filterVehicle?.id,
                        filterYear: _filterYear,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  final HomeState state;
  final bool showOil;
  final Map<String, VehicleEntity> vehiclesById;
  final String? filterVehicleId;
  final int? filterYear;

  const _ServiceList({
    required this.state,
    required this.showOil,
    required this.vehiclesById,
    this.filterVehicleId,
    this.filterYear,
  });

  @override
  Widget build(BuildContext context) {
    if (state is HomeLoading || state is HomeInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is HomeError) {
      return _ErrorMessage(message: (state as HomeError).message);
    }

    final loaded = state as HomeLoaded;
    final items = loaded.maintenances.where((m) {
      if (showOil ? !m.hasOilChange : !m.hasBatteryChange) return false;
      if (filterVehicleId != null && m.vehicleId != filterVehicleId) {
        return false;
      }
      if (filterYear != null && m.date.year != filterYear) return false;
      return true;
    }).toList();

    if (items.isEmpty) {
      final hasFilter = filterVehicleId != null || filterYear != null;
      return _EmptyMessage(
        message: hasFilter
            ? AppStrings.emptyFilteredHistory
            : (showOil
                  ? AppStrings.emptyOilChangeHistory
                  : AppStrings.emptyBatteryChangeHistory),
      );
    }

    final children = buildYearGroupedChildren(
      items: items,
      dateOf: (m) => m.date,
      spacingAfterItem: AppSpacing.md,
      itemBuilder: (maintenance) => _ServiceListItem(
        maintenance: maintenance,
        showOil: showOil,
        vehiclesById: vehiclesById,
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        100,
      ),
      children: children,
    );
  }
}

class _ServiceListItem extends StatelessWidget {
  final MaintenanceEntity maintenance;
  final bool showOil;
  final Map<String, VehicleEntity> vehiclesById;

  const _ServiceListItem({
    required this.maintenance,
    required this.showOil,
    required this.vehiclesById,
  });

  @override
  Widget build(BuildContext context) {
    final vehicle = vehiclesById[maintenance.vehicleId];
    final detail = showOil
        ? '${maintenance.oilBrand} • ${maintenance.oilLiters} litros'
        : '${maintenance.batteryModel} • ${maintenance.batteryCapacity}';

    return SimpleHistoryCard(
      month: formatMonthAbbrev(maintenance.date),
      day: maintenance.date.day.toString().padLeft(2, '0'),
      vehicle: vehicle != null ? '${vehicle.brand} ${vehicle.model}' : '',
      detail: detail,
    );
  }
}

class _ListHeader extends StatelessWidget {
  final String title;
  final bool filterActive;
  final VoidCallback onFilterTap;

  const _ListHeader({
    required this.title,
    required this.filterActive,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headlineLarge(context)),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: filterActive
                ? context.colors.primary
                : context.colors.textSecondary,
            onPressed: onFilterTap,
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _ActiveFilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: context.colors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 14,
                color: context.colors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium(
                    context,
                  ).copyWith(color: context.colors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaintenanceTypeToggle extends StatelessWidget {
  final bool showOil;
  final ValueChanged<bool> onChanged;

  const _MaintenanceTypeToggle({
    required this.showOil,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: AppStrings.oilToggleLabel,
              selected: showOil,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: AppStrings.batteryToggleLabel,
              selected: !showOil,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? context.colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium(context).copyWith(
            color: selected ? context.colors.primary : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          message,
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(color: context.colors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;
  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxl,
        ),
        child: Text(
          message,
          style: AppTextStyles.bodyMedium(context),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
