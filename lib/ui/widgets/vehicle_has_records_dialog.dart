import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_cubit.dart';
import 'package:flutter/material.dart';

String _maintenanceLabel(int count) =>
    count == 1 ? '1 manutenção' : '$count manutenções';
String _oilChangeLabel(int count) =>
    count == 1 ? '1 troca de óleo' : '$count trocas de óleo';
String _batteryChangeLabel(int count) =>
    count == 1 ? '1 troca de bateria' : '$count trocas de bateria';

/// Mostra o aviso de exclusão de um veículo que já possui histórico
/// (manutenções, trocas de óleo/bateria) vinculado a ele. Retorna `true`
/// só se o usuário confirmar a exclusão em cascata de tudo.
Future<bool> showVehicleHasRecordsDialog(
  BuildContext context, {
  required VehicleLinkedRecords linkedRecords,
}) async {
  final items = [
    if (linkedRecords.maintenances.isNotEmpty)
      _maintenanceLabel(linkedRecords.maintenances.length),
    if (linkedRecords.oilChanges.isNotEmpty)
      _oilChangeLabel(linkedRecords.oilChanges.length),
    if (linkedRecords.batteryChanges.isNotEmpty)
      _batteryChangeLabel(linkedRecords.batteryChanges.length),
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
