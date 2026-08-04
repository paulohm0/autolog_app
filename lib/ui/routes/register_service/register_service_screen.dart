import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/core/utils/currency_input_formatter.dart';
import 'package:autolog_app/core/utils/date_formatter.dart';
import 'package:autolog_app/core/utils/snackbar_utils.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_cubit.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_state.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/app_date_field.dart';
import 'package:autolog_app/ui/widgets/app_dropdown_field.dart';
import 'package:autolog_app/ui/widgets/app_text_field.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
import 'package:autolog_app/ui/widgets/vehicle_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterServiceScreen extends StatefulWidget {
  final MaintenanceEntity? existingMaintenance;

  const RegisterServiceScreen({super.key, this.existingMaintenance});

  @override
  State<RegisterServiceScreen> createState() => _RegisterServiceScreenState();
}

class _RegisterServiceScreenState extends State<RegisterServiceScreen> {
  late final RegisterServiceCubit _cubit;
  late final TextEditingController _workshopController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _valueController;

  List<VehicleEntity> _vehicles = [];
  VehicleEntity? _selectedVehicle;
  DateTime? _selectedDate;

  String? _vehicleError;
  String? _dateError;
  String? _workshopError;
  String? _descriptionError;
  String? _valueError;

  bool get _isEditing => widget.existingMaintenance != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMaintenance;
    _workshopController = TextEditingController(text: existing?.workshop);
    _descriptionController = TextEditingController(text: existing?.description);
    _valueController = TextEditingController(
      text: existing != null ? formatCurrencyInputValue(existing.value) : null,
    );
    _selectedDate = existing?.date;
    _cubit = getIt<RegisterServiceCubit>();
    _cubit.loadVehicles();
  }

  @override
  void dispose() {
    _cubit.close();
    _workshopController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
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

  Future<void> _pickVehicle() async {
    final selected = await showVehiclePicker(context, _vehicles);
    if (selected != null) setState(() => _selectedVehicle = selected);
  }

  void _save() {
    final workshop = _workshopController.text.trim();
    final description = _descriptionController.text.trim();
    final value = parseCurrencyInput(_valueController.text);

    setState(() {
      _vehicleError = _selectedVehicle == null
          ? AppStrings.requiredFieldError
          : null;
      _dateError = _selectedDate == null ? AppStrings.requiredFieldError : null;
      _workshopError = workshop.isEmpty ? AppStrings.requiredFieldError : null;
      _descriptionError = description.isEmpty
          ? AppStrings.requiredFieldError
          : null;
      _valueError = (value == null || value <= 0)
          ? AppStrings.valueMustBePositive
          : null;
    });

    if (_vehicleError != null ||
        _dateError != null ||
        _workshopError != null ||
        _descriptionError != null ||
        _valueError != null) {
      return;
    }

    if (_isEditing) {
      _cubit.updateMaintenance(
        id: widget.existingMaintenance!.id!,
        vehicleId: _selectedVehicle!.id!,
        date: _selectedDate!,
        workshop: workshop,
        description: description,
        value: value!,
      );
    } else {
      _cubit.saveMaintenance(
        vehicleId: _selectedVehicle!.id!,
        date: _selectedDate!,
        workshop: workshop,
        description: description,
        value: value!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const AppBrandTitle(),
          centerTitle: true,
        ),
        body: BlocListener<RegisterServiceCubit, RegisterServiceState>(
          listener: (context, state) {
            switch (state) {
              case RegisterServiceVehiclesLoaded():
                setState(() {
                  _vehicles = state.vehicles;
                  final existing = widget.existingMaintenance;
                  if (existing != null && _selectedVehicle == null) {
                    final matches = state.vehicles.where(
                      (v) => v.id == existing.vehicleId,
                    );
                    _selectedVehicle = matches.isEmpty ? null : matches.first;
                  }
                });
              case RegisterServiceSuccess():
                showAppSnackBar(
                  context,
                  _isEditing
                      ? AppStrings.updateMaintenanceSnackBarMessage
                      : AppStrings.saveMaintenanceSnackBarMessage,
                );
                Navigator.of(context).pop();
              case RegisterServiceError():
                showAppSnackBar(context, state.message, isError: true);
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
                  _PageTitle(isEditing: _isEditing),
                  const SizedBox(height: AppSpacing.xxl),
                  _Form(
                    selectedVehicle: _selectedVehicle,
                    onVehicleTap: _pickVehicle,
                    selectedDate: _selectedDate,
                    onDateTap: _pickDate,
                    workshopController: _workshopController,
                    descriptionController: _descriptionController,
                    vehicleError: _vehicleError,
                    dateError: _dateError,
                    workshopError: _workshopError,
                    descriptionError: _descriptionError,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FinancialSection(
                    valueController: _valueController,
                    valueError: _valueError,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: _isEditing
                        ? AppStrings.updateMaintenanceButton
                        : AppStrings.saveMaintenanceButton,
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
}

class _PageTitle extends StatelessWidget {
  final bool isEditing;

  const _PageTitle({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.maintenanceSection,
          style: AppTextStyles.labelLarge(context).copyWith(
            color: context.colors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isEditing
              ? AppStrings.editMaintenanceTitle
              : AppStrings.registerServiceTitle,
          style: AppTextStyles.displayMedium(context),
        ),
      ],
    );
  }
}

class _Form extends StatelessWidget {
  final VehicleEntity? selectedVehicle;
  final VoidCallback onVehicleTap;
  final DateTime? selectedDate;
  final VoidCallback onDateTap;
  final TextEditingController workshopController;
  final TextEditingController descriptionController;
  final String? vehicleError;
  final String? dateError;
  final String? workshopError;
  final String? descriptionError;

  const _Form({
    required this.selectedVehicle,
    required this.onVehicleTap,
    required this.selectedDate,
    required this.onDateTap,
    required this.workshopController,
    required this.descriptionController,
    this.vehicleError,
    this.dateError,
    this.workshopError,
    this.descriptionError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppDropdownField(
          label: AppStrings.vehicleLabel,
          hintText: AppStrings.selectCarHint,
          value: selectedVehicle != null
              ? '${selectedVehicle!.brand} ${selectedVehicle!.model}'
              : null,
          prefixIcon: Icons.directions_car_outlined,
          onTap: onVehicleTap,
          errorText: vehicleError,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppDateField(
          label: AppStrings.maintenanceDateLabel,
          hintText: AppStrings.dateHint,
          displayText: selectedDate != null ? formatDate(selectedDate!) : null,
          onTap: onDateTap,
          errorText: dateError,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: workshopController,
          label: AppStrings.workshopLabel,
          hintText: AppStrings.workshopHint,
          prefixIcon: Icons.storefront_outlined,
          errorText: workshopError,
          maxLength: 60,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: descriptionController,
          label: AppStrings.servicesDescriptionLabel,
          hintText: AppStrings.servicesDescriptionHint,
          prefixIcon: Icons.build_outlined,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          errorText: descriptionError,
          maxLength: 1000,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.servicesDescriptionCaption,
          style: AppTextStyles.bodySmall(context).copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _FinancialSection extends StatelessWidget {
  final TextEditingController valueController;
  final String? valueError;

  const _FinancialSection({required this.valueController, this.valueError});

  @override
  Widget build(BuildContext context) {
    final hasError = valueError != null;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                color: context.colors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.totalValueLabel,
                style: AppTextStyles.titleMedium(context),
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
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasError ? context.colors.error : context.colors.border,
              ),
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.moneySignLabel,
                  style: AppTextStyles.titleMedium(context).copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                    maxLength: 15,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.headlineMedium(context).copyWith(
                      color: context.colors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: '0,00',
                      hintStyle: AppTextStyles.headlineMedium(context).copyWith(
                        color: context.colors.textHint,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 4),
            Text(
              valueError!,
              style: AppTextStyles.bodySmall(context).copyWith(color: context.colors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.valueWarning,
            style: AppTextStyles.bodySmall(context).copyWith(
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
