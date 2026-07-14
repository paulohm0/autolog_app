import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
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
  const RegisterVehicleScreen({super.key});

  @override
  State<RegisterVehicleScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehicleScreen> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterVehicleCubit>(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const AppBrandTitle(),
            centerTitle: true,
          ),
          body: BlocListener<RegisterVehicleCubit, RegisterVehicleState>(
            listener: (context, state) {
              switch (state) {
                case SuccessState():
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.saveVehicleSnackBarMessage),
                    ),
                  );
                  Navigator.of(context).pop();
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
                    _PageTitle(),
                    const SizedBox(height: AppSpacing.xxl),
                    _RequiredFields(
                      _brandController,
                      _modelController,
                      _plateController,
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
                          label: AppStrings.saveVehicleButton,
                          icon: Icons.save_alt_rounded,
                          onPressed: () {
                            context
                                .read<RegisterVehicleCubit>()
                                .saveVehicleFromForm(
                                  brand: _brandController.text.trim(),
                                  model: _modelController.text.trim(),
                                  licensePlate: _plateController.text.trim(),
                                  year: _yearController.text.trim(),
                                  color: _colorController.text.trim(),
                                );
                          },
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

class _PageTitle extends StatelessWidget {
  const _PageTitle();

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
          AppStrings.registerVehicleTitle,
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

  const _RequiredFields(
    this.brandController,
    this.modelController,
    this.plateController,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: brandController,
          label: AppStrings.brandLabel,
          hintText: AppStrings.brandHint,
          prefixIcon: Icons.business_outlined,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: modelController,
          label: AppStrings.modelLabel,
          hintText: AppStrings.modelHint,
          prefixIcon: Icons.directions_car_outlined,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: plateController,
          label: AppStrings.plateLabel,
          hintText: AppStrings.plateHint,
          prefixIcon: Icons.tag_rounded,
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
