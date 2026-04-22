import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/widgets/app_text_field.dart';
import 'package:autolog_app/ui/widgets/autolog_brand.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
import 'package:flutter/material.dart';

class RegisterVehicleScreen extends StatelessWidget {
  const RegisterVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                text: 'Auto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'Log',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              const SizedBox(height: AppSpacing.xxl),
              _buildRequiredFields(),
              const SizedBox(height: AppSpacing.lg),
              _buildOptionalDetails(),
              const SizedBox(height: AppSpacing.xxl),
              _buildSaveButton(),
              const SizedBox(height: AppSpacing.lg),
              _buildBrandFooter(),
              const SizedBox(height: AppSpacing.xxl),
            ],
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
          'VEÍCULO',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Registrar Veículo', style: AppTextStyles.displayMedium),
      ],
    );
  }

  Widget _buildRequiredFields() {
    return Column(
      children: const [
        AppTextField(
          label: 'Marca',
          hintText: 'Ex: BMW, Porsche, Honda',
          prefixIcon: Icons.business_outlined,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Modelo',
          hintText: 'Ex: 320i, 911, Civic',
          prefixIcon: Icons.directions_car_outlined,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Placa',
          hintText: 'ABC-1234 OU ABC1D23',
          prefixIcon: Icons.tag_rounded,
        ),
      ],
    );
  }

  Widget _buildOptionalDetails() {
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
              Text('Detalhes Opcionais', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _OptionalField(label: 'ANO', value: '2024'),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _OptionalField(label: 'COR', value: 'Prata'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Column(
      children: [
        const PrimaryButton(
          label: 'Salvar Veículo',
          icon: Icons.save_alt_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ao salvar, este veículo será adicionado à sua\ngaragem digital e sincronizado com sua conta.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBrandFooter() {
    return const Center(child: AutoLogBrand());
  }
}

class _OptionalField extends StatelessWidget {
  final String label;
  final String value;

  const _OptionalField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headlineMedium),
        ],
      ),
    );
  }
}
