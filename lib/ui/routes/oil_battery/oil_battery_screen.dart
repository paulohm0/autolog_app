import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/core/utils/date_formatter.dart';
import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/ui/routes/oil_battery/battery_change_cubit.dart';
import 'package:autolog_app/ui/routes/oil_battery/battery_change_state.dart';
import 'package:autolog_app/ui/routes/oil_battery/oil_change_cubit.dart';
import 'package:autolog_app/ui/routes/oil_battery/oil_change_state.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/app_date_field.dart';
import 'package:autolog_app/ui/widgets/app_dropdown_field.dart';
import 'package:autolog_app/ui/widgets/app_text_field.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/simple_history_card.dart';
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

class OilBatteryScreen extends StatefulWidget {
  const OilBatteryScreen({super.key});

  @override
  State<OilBatteryScreen> createState() => _OilBatteryScreenState();
}

class _OilBatteryScreenState extends State<OilBatteryScreen> {
  late final OilChangeCubit _oilCubit;
  late final BatteryChangeCubit _batteryCubit;
  bool _showOil = true;

  @override
  void initState() {
    super.initState();
    _oilCubit = getIt<OilChangeCubit>()..loadData();
    _batteryCubit = getIt<BatteryChangeCubit>()..loadData();
  }

  @override
  void dispose() {
    _oilCubit.close();
    _batteryCubit.close();
    super.dispose();
  }

  Future<void> _openAddOilSheet() async {
    final state = _oilCubit.state;
    final vehicles = state is OilChangeLoaded ? state.vehicles : <VehicleEntity>[];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OilChangeFormSheet(
        vehicles: vehicles,
        onSave: (vehicleId, brand, liters, date) async {
          Navigator.of(context).pop();
          await _oilCubit.saveOilChange(
            vehicleId: vehicleId,
            brand: brand,
            liters: liters,
            date: date,
          );
          _handleSaveResult(
            state: _oilCubit.state,
            successMessage: AppStrings.saveOilChangeSnackBarMessage,
          );
          _oilCubit.loadData();
        },
      ),
    );
  }

  Future<void> _openAddBatterySheet() async {
    final state = _batteryCubit.state;
    final vehicles = state is BatteryChangeLoaded
        ? state.vehicles
        : <VehicleEntity>[];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BatteryChangeFormSheet(
        vehicles: vehicles,
        onSave: (vehicleId, model, date) async {
          Navigator.of(context).pop();
          await _batteryCubit.saveBatteryChange(
            vehicleId: vehicleId,
            model: model,
            date: date,
          );
          _handleSaveResult(
            state: _batteryCubit.state,
            successMessage: AppStrings.saveBatteryChangeSnackBarMessage,
          );
          _batteryCubit.loadData();
        },
      ),
    );
  }

  void _handleSaveResult({required Object? state, required String successMessage}) {
    if (!mounted) return;
    final message = switch (state) {
      OilChangeError(:final message) => message,
      BatteryChangeError(:final message) => message,
      _ => successMessage,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            Expanded(
              child: _showOil ? _buildOilList() : _buildBatteryList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'oil_battery_fab',
        onPressed: _showOil ? _openAddOilSheet : _openAddBatterySheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildOilList() {
    return BlocBuilder<OilChangeCubit, OilChangeState>(
      bloc: _oilCubit,
      builder: (context, state) {
        if (state is OilChangeLoading || state is OilChangeInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OilChangeError) {
          return _ErrorMessage(message: state.message);
        }

        final loaded = state as OilChangeLoaded;
        if (loaded.oilChanges.isEmpty) {
          return const _EmptyMessage(
            message: AppStrings.emptyOilChangeHistory,
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            100,
          ),
          children: [
            for (final oilChange in loaded.oilChanges) ...[
              _buildOilCard(oilChange, loaded.vehiclesById),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBatteryList() {
    return BlocBuilder<BatteryChangeCubit, BatteryChangeState>(
      bloc: _batteryCubit,
      builder: (context, state) {
        if (state is BatteryChangeLoading || state is BatteryChangeInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BatteryChangeError) {
          return _ErrorMessage(message: state.message);
        }

        final loaded = state as BatteryChangeLoaded;
        if (loaded.batteryChanges.isEmpty) {
          return const _EmptyMessage(
            message: AppStrings.emptyBatteryChangeHistory,
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            100,
          ),
          children: [
            for (final batteryChange in loaded.batteryChanges) ...[
              _buildBatteryCard(batteryChange, loaded.vehiclesById),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOilCard(
    OilChangeEntity oilChange,
    Map<String, VehicleEntity> vehiclesById,
  ) {
    final vehicle = vehiclesById[oilChange.vehicleId];
    return SimpleHistoryCard(
      month: _monthAbbrev(oilChange.date),
      day: oilChange.date.day.toString().padLeft(2, '0'),
      title: oilChange.brand,
      subtitle: '${oilChange.liters} litros',
      vehicle: vehicle != null ? '${vehicle.brand} ${vehicle.model}' : '',
    );
  }

  Widget _buildBatteryCard(
    BatteryChangeEntity batteryChange,
    Map<String, VehicleEntity> vehiclesById,
  ) {
    final vehicle = vehiclesById[batteryChange.vehicleId];
    return SimpleHistoryCard(
      month: _monthAbbrev(batteryChange.date),
      day: batteryChange.date.day.toString().padLeft(2, '0'),
      title: batteryChange.model,
      subtitle: formatDate(batteryChange.date),
      vehicle: vehicle != null ? '${vehicle.brand} ${vehicle.model}' : '',
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
        color: AppColors.surfaceVariant,
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
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
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
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          message,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

Future<VehicleEntity?> _pickVehicle(
  BuildContext context,
  List<VehicleEntity> vehicles,
) {
  if (vehicles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.noVehiclesRegistered)),
    );
    return Future.value(null);
  }
  return showModalBottomSheet<VehicleEntity>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final vehicle in vehicles)
            ListTile(
              leading: const Icon(
                Icons.directions_car_outlined,
                color: AppColors.primary,
              ),
              title: Text('${vehicle.brand} ${vehicle.model}'),
              onTap: () => Navigator.of(context).pop(vehicle),
            ),
        ],
      ),
    ),
  );
}

class _OilChangeFormSheet extends StatefulWidget {
  final List<VehicleEntity> vehicles;
  final void Function(String vehicleId, String brand, double liters, DateTime date)
  onSave;

  const _OilChangeFormSheet({required this.vehicles, required this.onSave});

  @override
  State<_OilChangeFormSheet> createState() => _OilChangeFormSheetState();
}

class _OilChangeFormSheetState extends State<_OilChangeFormSheet> {
  final _brandController = TextEditingController();
  final _litersController = TextEditingController();
  VehicleEntity? _selectedVehicle;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _brandController.dispose();
    _litersController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_selectedVehicle == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.missingVehicleOrDate)),
      );
      return;
    }
    widget.onSave(
      _selectedVehicle!.id!,
      _brandController.text.trim(),
      double.tryParse(_litersController.text.trim().replaceAll(',', '.')) ??
          0,
      _selectedDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.addOilChangeTitle,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdownField(
              label: AppStrings.vehicleLabel,
              hintText: _selectedVehicle != null
                  ? '${_selectedVehicle!.brand} ${_selectedVehicle!.model}'
                  : AppStrings.selectCarHint,
              prefixIcon: Icons.directions_car_outlined,
              onTap: () async {
                final selected = await _pickVehicle(context, widget.vehicles);
                if (selected != null) {
                  setState(() => _selectedVehicle = selected);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _brandController,
              label: AppStrings.oilBrandLabel,
              hintText: AppStrings.oilBrandHint,
              prefixIcon: Icons.local_gas_station_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _litersController,
              label: AppStrings.litersLabel,
              hintText: AppStrings.litersHint,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDateField(
              label: AppStrings.changeDateLabel,
              hintText: AppStrings.dateHint,
              displayText: _selectedDate != null
                  ? formatDate(_selectedDate!)
                  : null,
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: AppStrings.saveOilChangeButton,
              icon: Icons.save_alt_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _BatteryChangeFormSheet extends StatefulWidget {
  final List<VehicleEntity> vehicles;
  final void Function(String vehicleId, String model, DateTime date) onSave;

  const _BatteryChangeFormSheet({
    required this.vehicles,
    required this.onSave,
  });

  @override
  State<_BatteryChangeFormSheet> createState() =>
      _BatteryChangeFormSheetState();
}

class _BatteryChangeFormSheetState extends State<_BatteryChangeFormSheet> {
  final _modelController = TextEditingController();
  VehicleEntity? _selectedVehicle;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_selectedVehicle == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.missingVehicleOrDate)),
      );
      return;
    }
    widget.onSave(
      _selectedVehicle!.id!,
      _modelController.text.trim(),
      _selectedDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.addBatteryChangeTitle,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdownField(
              label: AppStrings.vehicleLabel,
              hintText: _selectedVehicle != null
                  ? '${_selectedVehicle!.brand} ${_selectedVehicle!.model}'
                  : AppStrings.selectCarHint,
              prefixIcon: Icons.directions_car_outlined,
              onTap: () async {
                final selected = await _pickVehicle(context, widget.vehicles);
                if (selected != null) {
                  setState(() => _selectedVehicle = selected);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _modelController,
              label: AppStrings.batteryModelLabel,
              hintText: AppStrings.batteryModelHint,
              prefixIcon: Icons.battery_charging_full_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDateField(
              label: AppStrings.changeDateLabel,
              hintText: AppStrings.dateHint,
              displayText: _selectedDate != null
                  ? formatDate(_selectedDate!)
                  : null,
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: AppStrings.saveBatteryChangeButton,
              icon: Icons.save_alt_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
