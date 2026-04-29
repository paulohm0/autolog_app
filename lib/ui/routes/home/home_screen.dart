import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/widgets/maintenance_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildSummaryCard(),
              _buildQuickStats(context),
              _buildHistorySection(context),
              _buildMaintenanceList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.registerService);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.totalExpenseLabel,
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'R\$ 4.250,00',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontSize: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.directions_car,
            label: AppStrings.activeVehiclesLabel,
            value: '03',
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (context) => SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    children: [
                      const Text('Components'),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.registerVehicle,
                          );
                        },
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        elevation: 4,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.add, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatRow(
            icon: Icons.water_drop,
            label: AppStrings.nextOilChangeLabel,
            value: '85.500 km',
            valueColor: AppColors.warning,
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (context) => const SizedBox(
                height: 200,
                child: Center(child: Text('Conteúdo aqui')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
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
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.filters,
                          style: AppTextStyles.headlineLarge,
                        ),
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
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          MaintenanceCard(
            month: 'MAIO',
            day: '18',
            title: 'Troca de Óleo e Filtros',
            workshop: 'HighTech Motors',
            vehicle: 'BMW 320i M-Sport',
            amount: 'R\$ 850,00',
          ),
          const SizedBox(height: AppSpacing.md),
          MaintenanceCard(
            month: 'ABR',
            day: '05',
            title: 'Troca de Discos e Pastilhas',
            workshop: 'Precision Brake Center',
            vehicle: 'Porsche Macan S',
            amount: 'R\$ 2.400,00',
          ),
          const SizedBox(height: AppSpacing.md),
          MaintenanceCard(
            month: 'MAR',
            day: '22',
            title: 'Alinhamento e Balanceamento',
            workshop: 'Pneus & Cia',
            vehicle: 'Toyota Hilux SRX',
            amount: 'R\$ 350,00',
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
  final Color? valueColor;
  final VoidCallback? onTap;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
                      color: valueColor ?? AppColors.textSecondary,
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
