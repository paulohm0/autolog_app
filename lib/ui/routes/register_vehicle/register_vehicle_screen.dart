import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_cubit.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_state.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/app_text_field.dart';
import 'package:autolog_app/ui/widgets/autolog_brand.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _plateController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;

  String? _brandError;
  String? _modelError;
  String? _plateError;

  bool get _isEditing => widget.existingVehicle != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingVehicle;
    _brandController = TextEditingController(text: existing?.brand);
    _modelController = TextEditingController(text: existing?.model);
    _plateController = TextEditingController(text: existing?.licensePlate);
    _yearController = TextEditingController(text: existing?.year?.toString());
    _colorController = TextEditingController(text: existing?.color);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
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

    if (_isEditing) {
      context.read<RegisterVehicleCubit>().updateVehicleFromForm(
        id: widget.existingVehicle!.id!,
        brand: brand,
        model: model,
        licensePlate: plate,
        year: _yearController.text.trim(),
        color: _colorController.text.trim(),
      );
    } else {
      context.read<RegisterVehicleCubit>().saveVehicleFromForm(
        brand: brand,
        model: model,
        licensePlate: plate,
        year: _yearController.text.trim(),
        color: _colorController.text.trim(),
      );
    }
  }

  Future<void> _signOut() async {
    await getIt<IAuthRepository>().signOut();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterVehicleCubit>(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
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
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ]
                : null,
          ),
          body: BlocListener<RegisterVehicleCubit, RegisterVehicleState>(
            listener: (context, state) {
              switch (state) {
                case SuccessState():
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isEditing
                            ? AppStrings.updateVehicleSnackBarMessage
                            : AppStrings.saveVehicleSnackBarMessage,
                      ),
                    ),
                  );
                  if (widget.isOnboarding) {
                    widget.onVehicleRegistered?.call();
                  } else {
                    Navigator.of(context).pop();
                  }
                case ErrorState():
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
                      brandError: _brandError,
                      modelError: _modelError,
                      plateError: _plateError,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _OptionalDetails(
                      _yearController,
                      _colorController,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Column(
                      children: [
                        PrimaryButton(
                          label: _isEditing
                              ? AppStrings.updateVehicleButton
                              : AppStrings.saveVehicleButton,
                          icon: Icons.save_alt_rounded,
                          onPressed: () => _save(context),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          AppStrings.saveVehicleDescription,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BrandFooter(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
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
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.directions_car_filled_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppStrings.onboardingVehicleMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
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
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isEditing
              ? AppStrings.editVehicleTitle
              : AppStrings.registerVehicleTitle,
          style: AppTextStyles.displayMedium,
        ),
      ],
    );
  }
}

class _RequiredFields extends StatelessWidget {
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController plateController;
  final String? brandError;
  final String? modelError;
  final String? plateError;

  const _RequiredFields(
    this.brandController,
    this.modelController,
    this.plateController, {
    this.brandError,
    this.modelError,
    this.plateError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: brandController,
          label: AppStrings.brandLabel,
          hintText: AppStrings.brandHint,
          prefixIcon: Icons.business_outlined,
          errorText: brandError,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: modelController,
          label: AppStrings.modelLabel,
          hintText: AppStrings.modelHint,
          prefixIcon: Icons.directions_car_outlined,
          errorText: modelError,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: plateController,
          label: AppStrings.plateLabel,
          hintText: AppStrings.plateHint,
          prefixIcon: Icons.tag_rounded,
          errorText: plateError,
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
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(AppStrings.optionalDetails, style: AppTextStyles.titleLarge),
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
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: colorController,
                  label: AppStrings.colorLabel,
                  hintText: AppStrings.colorHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandFooter extends StatelessWidget {
  const _BrandFooter();

  @override
  Widget build(BuildContext context) {
    return const Center(child: AutoLogBrand());
  }
}
