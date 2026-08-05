import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/constants/vehicle_catalog.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/core/utils/license_plate_formatter.dart';
import 'package:autolog_app/core/utils/snackbar_utils.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_cubit.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_cubit.dart';
import 'package:autolog_app/ui/widgets/app_autocomplete_field.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/app_text_field.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
import 'package:flutter/material.dart';

class RegisterVehicleScreen extends StatefulWidget {
  final bool isOnboarding;
  final VoidCallback? onVehicleRegistered;
  final VoidCallback? onSkip;
  final VehicleEntity? existingVehicle;

  const RegisterVehicleScreen({
    super.key,
    this.isOnboarding = false,
    this.onVehicleRegistered,
    this.onSkip,
    this.existingVehicle,
  });

  @override
  State<RegisterVehicleScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehicleScreen> {
  late final RegisterVehicleCubit _cubit;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _plateController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;

  String? _brandError;
  String? _modelError;
  String? _plateError;
  List<String> _modelOptions = const [];
  bool _submitted = false;

  bool get _isEditing => widget.existingVehicle != null;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<RegisterVehicleCubit>();
    final existing = widget.existingVehicle;
    _brandController = TextEditingController(text: existing?.brand);
    _modelController = TextEditingController(text: existing?.model);
    _plateController = TextEditingController(text: existing?.licensePlate);
    _yearController = TextEditingController(text: existing?.year?.toString());
    _colorController = TextEditingController(text: existing?.color);
    _modelOptions = modelsForBrand(_brandController.text);
    _brandController.addListener(_updateModelOptions);
  }

  @override
  void dispose() {
    _brandController.removeListener(_updateModelOptions);
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _updateModelOptions() {
    setState(() => _modelOptions = modelsForBrand(_brandController.text));
  }

  // Padrão otimista (ver RegisterServiceScreen._save): fora do onboarding,
  // sai da tela na hora do toque e só avisa depois se der erro. No
  // onboarding não tem like pra "descurtir" se falhar — o MainGate troca de
  // tela com base nisso, então ali espera a gravação confirmar antes de
  // avançar.
  void _save() {
    if (_submitted) return;

    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final plate = _plateController.text.trim();

    setState(() {
      _brandError = brand.isEmpty ? AppStrings.requiredFieldError : null;
      _modelError = model.isEmpty ? AppStrings.requiredFieldError : null;
      _plateError = plate.isEmpty ? AppStrings.requiredFieldError : null;
    });

    if (_brandError != null || _modelError != null || _plateError != null) {
      return;
    }

    final year = _yearController.text.trim();
    final color = _colorController.text.trim();
    final isEditing = _isEditing;

    final future = isEditing
        ? _cubit.updateVehicleFromForm(
            id: widget.existingVehicle!.id!,
            brand: brand,
            model: model,
            licensePlate: plate,
            year: year,
            color: color,
          )
        : _cubit.saveVehicleFromForm(
            brand: brand,
            model: model,
            licensePlate: plate,
            year: year,
            color: color,
          );

    if (widget.isOnboarding) {
      _submitted = true;
      future.then((result) {
        if (!mounted) return;
        result.fold(
          (failure) {
            _submitted = false;
            showAppSnackBar(context, failure.message, isError: true);
          },
          (_) {
            getIt<VehicleListCubit>().loadVehicles();
            showAppSnackBar(context, AppStrings.saveVehicleSnackBarMessage);
            widget.onVehicleRegistered?.call();
          },
        );
      });
      return;
    }

    _submitted = true;
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = context.colors.error;
    final successMessage = isEditing
        ? AppStrings.updateVehicleSnackBarMessage
        : AppStrings.saveVehicleSnackBarMessage;

    Navigator.of(context).pop();

    future.then((result) {
      result.fold(
        (failure) => showAppSnackBarOn(
          messenger,
          failure.message,
          errorColor: errorColor,
        ),
        (_) {
          showAppSnackBarOn(messenger, successMessage);
          getIt<VehicleListCubit>().loadVehicles();
        },
      );
    });
  }

  Future<void> _signOut() async {
    await getIt<IAuthRepository>().signOut();
    getIt<VehicleListCubit>().reset();
    getIt<HomeCubit>().reset();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        leading: widget.isOnboarding
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
        automaticallyImplyLeading: !widget.isOnboarding,
        title: const AppBrandTitle(),
        centerTitle: true,
        actions: widget.isOnboarding
            ? [
                TextButton(
                  onPressed: widget.onSkip,
                  child: const Text(AppStrings.skipButton),
                ),
                TextButton(
                  onPressed: _signOut,
                  child: Text(
                    AppStrings.signOutButton,
                    style: TextStyle(color: context.colors.error),
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isOnboarding) ...[
                const _OnboardingBanner(),
                const SizedBox(height: AppSpacing.xxl),
              ],
              _PageTitle(isEditing: _isEditing),
              const SizedBox(height: AppSpacing.xxl),
              _RequiredFields(
                _brandController,
                _modelController,
                _plateController,
                modelOptions: _modelOptions,
                brandError: _brandError,
                modelError: _modelError,
                plateError: _plateError,
              ),
              const SizedBox(height: AppSpacing.lg),
              _OptionalDetails(_yearController, _colorController),
              const SizedBox(height: AppSpacing.xxl),
              Column(
                children: [
                  PrimaryButton(
                    label: _isEditing
                        ? AppStrings.updateVehicleButton
                        : AppStrings.saveVehicleButton,
                    icon: Icons.save_alt_rounded,
                    onPressed: _save,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.saveVehicleDescription,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall(
                      context,
                    ).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingBanner extends StatelessWidget {
  const _OnboardingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.directions_car_filled_rounded,
            color: context.colors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppStrings.onboardingVehicleMessage,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
          AppStrings.vehicleSection,
          style: AppTextStyles.labelLarge(context).copyWith(
            color: context.colors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isEditing
              ? AppStrings.editVehicleTitle
              : AppStrings.registerVehicleTitle,
          style: AppTextStyles.displayMedium(context),
        ),
      ],
    );
  }
}

class _RequiredFields extends StatelessWidget {
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController plateController;
  final List<String> modelOptions;
  final String? brandError;
  final String? modelError;
  final String? plateError;

  const _RequiredFields(
    this.brandController,
    this.modelController,
    this.plateController, {
    required this.modelOptions,
    this.brandError,
    this.modelError,
    this.plateError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppAutocompleteField(
          controller: brandController,
          label: AppStrings.brandLabel,
          hintText: AppStrings.brandHint,
          prefixIcon: Icons.business_outlined,
          errorText: brandError,
          maxLength: 30,
          options: vehicleBrands,
        ),
        SizedBox(height: AppSpacing.lg),
        AppAutocompleteField(
          controller: modelController,
          label: AppStrings.modelLabel,
          hintText: AppStrings.modelHint,
          prefixIcon: Icons.directions_car_outlined,
          errorText: modelError,
          maxLength: 30,
          options: modelOptions,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: plateController,
          label: AppStrings.plateLabel,
          hintText: AppStrings.plateHint,
          prefixIcon: Icons.tag_rounded,
          errorText: plateError,
          maxLength: 8,
          inputFormatters: [LicensePlateInputFormatter()],
        ),
      ],
    );
  }
}

class _OptionalDetails extends StatelessWidget {
  final TextEditingController yearController;
  final TextEditingController colorController;

  const _OptionalDetails(
    this.yearController,
    this.colorController,
  );

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.optionalDetails,
                style: AppTextStyles.titleLarge(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: yearController,
                  label: AppStrings.yearLabel,
                  hintText: AppStrings.yearHint,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppAutocompleteField(
                  controller: colorController,
                  label: AppStrings.colorLabel,
                  hintText: AppStrings.colorHint,
                  maxLength: 20,
                  options: vehicleColors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
