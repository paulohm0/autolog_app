import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/core/utils/date_formatter.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/ui/cubit/vehicle_list_cubit.dart';
import 'package:autolog_app/ui/cubit/vehicle_list_state.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/home/home_state.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_screen.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_screen.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/filters_sheet.dart';
import 'package:autolog_app/ui/widgets/maintenance_card.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/year_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _monthAbbreviations = [
  'JAN',
  'FEV',
  'MAR',
  'ABR',
  'MAI',
  'JUN',
  'JUL',
  'AGO',
  'SET',
  'OUT',
  'NOV',
  'DEZ',
];

String _monthAbbrev(DateTime date) => _monthAbbreviations[date.month - 1];

String _formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts[0];
  final cents = parts[1];
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final posFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'R\$ $buffer,$cents';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _homeCubit;
  late final VehicleListCubit _vehicleListCubit;
  VehicleEntity? _filterVehicle;
  int? _filterYear;
  bool _checkedEmptyVehicles = false;
  String? _expandedMaintenanceId;

  @override
  void initState() {
    super.initState();
    _homeCubit = getIt<HomeCubit>();
    _homeCubit.loadHomeData();
    _vehicleListCubit = getIt<VehicleListCubit>()..ensureLoaded();
  }

  @override
  void dispose() {
    _homeCubit.close();
    // _vehicleListCubit é um singleton compartilhado com outras telas —
    // não deve ser fechado aqui.
    super.dispose();
  }

  Future<void> _openRegisterVehicle(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.registerVehicle);
    _vehicleListCubit.loadVehicles();
  }

  Future<void> _openVehiclesDialog(BuildContext context) async {
    final state = _vehicleListCubit.state;
    final vehicles = state is VehicleListLoaded
        ? state.vehicles
        : <VehicleEntity>[];

    final result = await showDialog<(String, VehicleEntity?)>(
      context: context,
      builder: (_) => _VehicleListDialog(vehicles: vehicles),
    );

    if (!context.mounted || result == null) return;
    final (action, vehicle) = result;

    if (action == 'add') {
      await _openRegisterVehicle(context);
    } else if (action == 'edit' && vehicle != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegisterVehicleScreen(existingVehicle: vehicle),
        ),
      );
      _vehicleListCubit.loadVehicles();
    } else if (action == 'delete' && vehicle != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.deleteVehicleConfirmTitle),
          content: const Text(AppStrings.deleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                AppStrings.deleteButton,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final deleteResult = await _vehicleListCubit.deleteVehicle(vehicle.id!);
      if (!context.mounted) return;
      deleteResult.fold(
        (failure) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message))),
        (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.deleteVehicleSnackBarMessage),
          ),
        ),
      );
    }
  }

  Future<void> _openRegisterService(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.registerService);
    _homeCubit.loadHomeData();
  }

  Future<void> _showNoVehicleDialog(BuildContext context) async {
    final action = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.noVehicleDialogTitle),
        content: const Text(AppStrings.noVehicleDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.laterButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.addVehicleLabel),
          ),
        ],
      ),
    );

    if (action == true && context.mounted) {
      await _openRegisterVehicle(context);
    }
  }

  Future<void> _openFilters(BuildContext context, HomeState state) async {
    final vehicleState = _vehicleListCubit.state;
    final vehicles = vehicleState is VehicleListLoaded
        ? vehicleState.vehicles
        : <VehicleEntity>[];
    final years = state is HomeLoaded
        ? state.maintenances.map((m) => m.date.year).toSet().toList()
        : <int>[];
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
    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const AppBrandTitle(), centerTitle: true),
        body: SafeArea(
          child: BlocListener<VehicleListCubit, VehicleListState>(
            bloc: _vehicleListCubit,
            listener: (context, vehicleState) {
              if (vehicleState is VehicleListLoaded && !_checkedEmptyVehicles) {
                _checkedEmptyVehicles = true;
                if (vehicleState.vehicles.isEmpty) {
                  _showNoVehicleDialog(context);
                }
              }
            },
            child: BlocBuilder<VehicleListCubit, VehicleListState>(
              bloc: _vehicleListCubit,
              builder: (context, vehicleState) {
                final vehiclesById = vehicleState is VehicleListLoaded
                    ? vehicleState.vehiclesById
                    : <String, VehicleEntity>{};
                final vehicleCount = vehicleState is VehicleListLoaded
                    ? vehicleState.vehicles.length
                    : null;

                return BlocBuilder<HomeCubit, HomeState>(
                  bloc: _homeCubit,
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await _homeCubit.loadHomeData();
                        await _vehicleListCubit.loadVehicles();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            _QuickStats(
                              vehicleCount: vehicleCount,
                              onVehiclesTap: () => _openVehiclesDialog(context),
                            ),
                            _HistorySection(
                              filterVehicle: _filterVehicle,
                              filterYear: _filterYear,
                              onFilterTap: () => _openFilters(context, state),
                              onClearFilters: () => setState(() {
                                _filterVehicle = null;
                                _filterYear = null;
                              }),
                            ),
                            _MaintenanceList(
                              state: state,
                              vehiclesById: vehiclesById,
                              filterVehicleId: _filterVehicle?.id,
                              filterYear: _filterYear,
                              expandedId: _expandedMaintenanceId,
                              onToggleExpand: (id) => setState(() {
                                _expandedMaintenanceId =
                                    _expandedMaintenanceId == id ? null : id;
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'home_fab',
          onPressed: () => _openRegisterService(context),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final int? vehicleCount;
  final VoidCallback onVehiclesTap;

  const _QuickStats({required this.vehicleCount, required this.onVehiclesTap});

  @override
  Widget build(BuildContext context) {
    final vehicleCountLabel = vehicleCount != null
        ? vehicleCount.toString().padLeft(2, '0')
        : '--';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: _StatRow(
        icon: Icons.directions_car,
        label: AppStrings.activeVehiclesLabel,
        value: vehicleCountLabel,
        onTap: onVehiclesTap,
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final VehicleEntity? filterVehicle;
  final int? filterYear;
  final VoidCallback onFilterTap;
  final VoidCallback onClearFilters;

  const _HistorySection({
    required this.filterVehicle,
    required this.filterYear,
    required this.onFilterTap,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final filterActive = filterVehicle != null || filterYear != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.maintenanceHistory,
                style: AppTextStyles.headlineLarge,
              ),
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                color: filterActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
                onPressed: onFilterTap,
              ),
            ],
          ),
          if (filterActive) ...[
            const SizedBox(height: AppSpacing.sm),
            _ActiveFiltersRow(
              filterVehicle: filterVehicle,
              filterYear: filterYear,
              onClear: onClearFilters,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveFiltersRow extends StatelessWidget {
  final VehicleEntity? filterVehicle;
  final int? filterYear;
  final VoidCallback onClear;

  const _ActiveFiltersRow({
    required this.filterVehicle,
    required this.filterYear,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final label = [
      if (filterVehicle != null)
        '${filterVehicle!.brand} ${filterVehicle!.model}',
      if (filterYear != null) filterYear.toString(),
    ].join(' • ');

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_list_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceList extends StatelessWidget {
  final HomeState state;
  final Map<String, VehicleEntity> vehiclesById;
  final String? filterVehicleId;
  final int? filterYear;
  final String? expandedId;
  final ValueChanged<String> onToggleExpand;

  const _MaintenanceList({
    required this.state,
    required this.vehiclesById,
    required this.expandedId,
    required this.onToggleExpand,
    this.filterVehicleId,
    this.filterYear,
  });

  @override
  Widget build(BuildContext context) {
    if (state is HomeLoading || state is HomeInitial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is HomeError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          (state as HomeError).message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      );
    }

    final loaded = state as HomeLoaded;
    final maintenances = loaded.maintenances.where((m) {
      if (filterVehicleId != null && m.vehicleId != filterVehicleId) {
        return false;
      }
      if (filterYear != null && m.date.year != filterYear) {
        return false;
      }
      return true;
    }).toList();

    if (maintenances.isEmpty) {
      final hasFilter = filterVehicleId != null || filterYear != null;
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxl,
        ),
        child: Center(
          child: Text(
            hasFilter
                ? AppStrings.emptyFilteredHistory
                : AppStrings.emptyMaintenanceHistory,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final showYearHeaders =
        maintenances.map((m) => m.date.year).toSet().length > 1;
    int? lastYear;
    final children = <Widget>[];

    for (final maintenance in maintenances) {
      if (showYearHeaders && maintenance.date.year != lastYear) {
        children.add(
          YearSectionHeader(
            year: maintenance.date.year,
            isFirst: lastYear == null,
          ),
        );
        lastYear = maintenance.date.year;
      }
      children.add(
        _MaintenanceListItem(
          maintenance: maintenance,
          vehiclesById: vehiclesById,
          expanded: expandedId == maintenance.id,
          onToggleExpand: () => onToggleExpand(maintenance.id!),
        ),
      );
      children.add(const SizedBox(height: AppSpacing.sm));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(children: children),
    );
  }
}

class _MaintenanceListItem extends StatelessWidget {
  final MaintenanceEntity maintenance;
  final Map<String, VehicleEntity> vehiclesById;
  final bool expanded;
  final VoidCallback onToggleExpand;

  const _MaintenanceListItem({
    required this.maintenance,
    required this.vehiclesById,
    required this.expanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final vehicle = vehiclesById[maintenance.vehicleId];
    final vehicleLabel = vehicle != null
        ? '${vehicle.brand} ${vehicle.model}'
        : '';

    return MaintenanceCard(
      month: _monthAbbrev(maintenance.date),
      day: maintenance.date.day.toString().padLeft(2, '0'),
      workshop: maintenance.workshop,
      vehicle: vehicleLabel,
      amount: _formatCurrency(maintenance.value),
      expanded: expanded,
      onToggleExpand: onToggleExpand,
      dateLabel: formatDate(maintenance.date),
      description: maintenance.description,
      onEdit: () => _edit(context),
      onDelete: () => _confirmAndDelete(context),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final homeCubit = context.read<HomeCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterServiceScreen(existingMaintenance: maintenance),
      ),
    );
    homeCubit.loadHomeData();
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final homeCubit = context.read<HomeCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              AppStrings.deleteButton,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final result = await homeCubit.deleteMaintenance(maintenance.id!);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.deleteMaintenanceSnackBarMessage),
        ),
      ),
    );
  }
}

class _VehicleListDialog extends StatelessWidget {
  final List<VehicleEntity> vehicles;

  const _VehicleListDialog({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 450),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.myVehiclesTitle,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              if (vehicles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    AppStrings.noVehiclesRegistered,
                    style: AppTextStyles.bodyMedium,
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: vehicles.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return _VehicleRow(
                        vehicle: vehicle,
                        onEdit: () =>
                            Navigator.of(context).pop(('edit', vehicle)),
                        onDelete: () =>
                            Navigator.of(context).pop(('delete', vehicle)),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: AppStrings.addVehicleLabel,
                icon: Icons.add,
                onPressed: () => Navigator.of(context).pop(('add', null)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleRow({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: AppTextStyles.titleMedium,
                ),
                if (vehicle.licensePlate.isNotEmpty)
                  Text(vehicle.licensePlate, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.titleMedium),
            const SizedBox(width: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
