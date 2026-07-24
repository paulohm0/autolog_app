import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/home/home_state.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/maintenance_card.dart';
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

  @override
  void initState() {
    super.initState();
    _homeCubit = getIt<HomeCubit>();
    _homeCubit.loadHomeData();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  Future<void> _openRegisterVehicle(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.registerVehicle);
    _homeCubit.loadHomeData();
  }

  Future<void> _openRegisterService(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.registerService);
    _homeCubit.loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const AppBrandTitle(), centerTitle: true),
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => _homeCubit.loadHomeData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      _QuickStats(
                        state: state,
                        onVehiclesTap: () => _openRegisterVehicle(context),
                      ),
                      const _HistorySection(),
                      _MaintenanceList(state: state),
                    ],
                  ),
                ),
              );
            },
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
  final HomeState state;
  final VoidCallback onVehiclesTap;

  const _QuickStats({required this.state, required this.onVehiclesTap});

  @override
  Widget build(BuildContext context) {
    final vehicleCount = state is HomeLoaded
        ? (state as HomeLoaded).vehicleCount.toString().padLeft(2, '0')
        : '--';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: _StatRow(
        icon: Icons.directions_car,
        label: AppStrings.activeVehiclesLabel,
        value: vehicleCount,
        onTap: onVehiclesTap,
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                AppStrings.maintenanceHistory,
                style: AppTextStyles.headlineLarge,
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                color: AppColors.textSecondary,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => const _FiltersSheet(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.filters, style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: AppStrings.vehicleFilter,
                  value: AppStrings.allVehicles,
                  trailing: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _FilterChip(
                label: AppStrings.yearFilter,
                value: '2024',
                trailing: const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _MaintenanceList extends StatelessWidget {
  final HomeState state;

  const _MaintenanceList({required this.state});

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

    if (loaded.maintenances.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxl,
        ),
        child: Center(
          child: Text(
            AppStrings.emptyMaintenanceHistory,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          for (final maintenance in loaded.maintenances) ...[
            _MaintenanceListItem(
              maintenance: maintenance,
              vehiclesById: loaded.vehiclesById,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _MaintenanceListItem extends StatelessWidget {
  final MaintenanceEntity maintenance;
  final Map<String, VehicleEntity> vehiclesById;

  const _MaintenanceListItem({
    required this.maintenance,
    required this.vehiclesById,
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
      title: maintenance.description,
      workshop: maintenance.workshop,
      vehicle: vehicleLabel,
      amount: _formatCurrency(maintenance.value),
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.edit_note, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _FilterChip({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              Text(value, style: AppTextStyles.titleMedium),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
        ],
      ),
    );
  }
}
