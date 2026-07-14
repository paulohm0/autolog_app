import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_cubit.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_state.dart';
import 'package:autolog_app/ui/widgets/app_dropdown_field.dart';
import 'package:autolog_app/ui/widgets/app_text_field.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class RegisterServiceScreen extends StatefulWidget {
  const RegisterServiceScreen({super.key});

  @override
  State<RegisterServiceScreen> createState() => _RegisterServiceScreenState();
}

class _RegisterServiceScreenState extends State<RegisterServiceScreen> {
  late final RegisterServiceCubit _cubit;
  final _workshopController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();

  List<VehicleEntity> _vehicles = [];
  VehicleEntity? _selectedVehicle;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<RegisterServiceCubit>();
    _cubit.loadVehicles();
  }

  @override
  void dispose() {
    _cubit.close();
    _workshopController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _dateController.dispose();
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = formatDate(picked);
      });
    }
  }

  Future<void> _pickVehicle() async {
    final selected = await showModalBottomSheet<VehicleEntity>(
      context: context,
      builder: (context) {
        if (_vehicles.isEmpty) {
          return const SizedBox(
            height: 150,
            child: Center(child: Text(AppStrings.noVehiclesRegistered)),
          );
        }
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final vehicle in _vehicles)
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
        );
      },
    );
    if (selected != null) setState(() => _selectedVehicle = selected);
  }

  void _save() {
    if (_selectedVehicle == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.missingVehicleOrDate)),
      );
      return;
    }

    _cubit.saveMaintenance(
      vehicleId: _selectedVehicle!.id!,
      date: _selectedDate!,
      workshop: _workshopController.text.trim(),
      description: _descriptionController.text.trim(),
      value: double.tryParse(
            _valueController.text.trim().replaceAll(',', '.'),
          ) ??
          0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppStrings.appBrandNameSplit1,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: AppStrings.appBrandNameSplit2,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: BlocListener<RegisterServiceCubit, RegisterServiceState>(
          listener: (context, state) {
            switch (state) {
              case RegisterServiceVehiclesLoaded():
                setState(() => _vehicles = state.vehicles);
              case RegisterServiceSuccess():
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.saveMaintenanceSnackBarMessage),
                  ),
                );
                Navigator.of(context).pop();
              case RegisterServiceError():
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              default:
                break;
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageTitle(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildForm(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFinancialSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: AppStrings.saveMaintenanceButton,
                    icon: Icons.save_alt_rounded,
                    onPressed: _save,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.maintenanceSection,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.registerServiceTitle,
          style: AppTextStyles.displayMedium,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppDropdownField(
          label: AppStrings.vehicleLabel,
          hintText: _selectedVehicle != null
              ? '${_selectedVehicle!.brand} ${_selectedVehicle!.model}'
              : AppStrings.selectCarHint,
          prefixIcon: Icons.directions_car_outlined,
          onTap: _pickVehicle,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildDateField(),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _workshopController,
          label: AppStrings.workshopLabel,
          hintText: AppStrings.workshopHint,
          prefixIcon: Icons.storefront_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _descriptionController,
          label: AppStrings.servicesDescriptionLabel,
          hintText: AppStrings.servicesDescriptionHint,
          prefixIcon: Icons.build_outlined,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.maintenanceDateLabel, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: _dateController,
                    onTap: _pickDate,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: AppStrings.dateHint,
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textHint,
                      ),
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.totalValueLabel,
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.moneySignLabel,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.right,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: '0,00',
                      hintStyle: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.valueWarning,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
