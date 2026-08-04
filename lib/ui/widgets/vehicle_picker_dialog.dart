import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:flutter/material.dart';

Future<VehicleEntity?> showVehiclePicker(
  BuildContext context,
  List<VehicleEntity> vehicles,
) {
  return showDialog<VehicleEntity>(
    context: context,
    builder: (_) => VehiclePickerDialog(vehicles: vehicles),
  );
}

class VehiclePickerDialog extends StatelessWidget {
  final List<VehicleEntity> vehicles;

  const VehiclePickerDialog({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.vehicleLabel,
                style: AppTextStyles.headlineMedium(context),
              ),
              const SizedBox(height: AppSpacing.md),
              if (vehicles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Text(
                    AppStrings.noVehiclesRegistered,
                    style: AppTextStyles.bodyMedium(context),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final vehicle in vehicles)
                        ListTile(
                          leading: Icon(
                            Icons.directions_car_outlined,
                            color: context.colors.primary,
                          ),
                          title: Text('${vehicle.brand} ${vehicle.model}'),
                          onTap: () => Navigator.of(context).pop(vehicle),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
