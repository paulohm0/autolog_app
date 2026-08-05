import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_cubit.dart';
import 'package:flutter/material.dart';

String _maintenanceLabel(int count) =>
    count == 1 ? '1 manutenção' : '$count manutenções';

/// Mostra o aviso de exclusão de um veículo que já possui histórico de
/// manutenção (inclui as marcadas como óleo/bateria) vinculado a ele.
/// Retorna `true` só se o usuário confirmar a exclusão em cascata de tudo.
Future<bool> showVehicleHasRecordsDialog(
  BuildContext context, {
  required VehicleLinkedRecords linkedRecords,
}) async {
  final items = [
    if (linkedRecords.maintenances.isNotEmpty)
      _maintenanceLabel(linkedRecords.maintenances.length),
  ];

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AppStrings.deleteVehicleWithRecordsTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.deleteVehicleWithRecordsWarning),
          const SizedBox(height: AppSpacing.md),
          ...items.map(
            (label) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(label, style: AppTextStyles.bodyMedium(context)),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            AppStrings.deleteVehicleWithRecordsConfirmButton,
            style: TextStyle(color: context.colors.error),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
