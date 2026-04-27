import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/widgets/app_dropdown_field.dart';
import 'package:autolog_app/ui/widgets/app_text_field.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
import 'package:flutter/material.dart';

class RegisterServiceScreen extends StatelessWidget {
  const RegisterServiceScreen({super.key});

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
      body: SingleChildScrollView(
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
              const PrimaryButton(
                label: AppStrings.saveMaintenanceButton,
                icon: Icons.save_alt_rounded,
              ),
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
          hintText: AppStrings.selectCarHint,
          prefixIcon: Icons.directions_car_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildDateField(),
        const SizedBox(height: AppSpacing.lg),
        const AppTextField(
          label: AppStrings.workshopLabel,
          hintText: AppStrings.workshopHint,
          prefixIcon: Icons.storefront_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppTextField(
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
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
