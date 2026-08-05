import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/ui/routes/login/login_benefit_item.dart';
import 'package:flutter/material.dart';

class LoginBenefits extends StatelessWidget {
  final double scale;

  const LoginBenefits({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginBenefitItem(
          icon: Icons.build_rounded,
          label: AppStrings.loginBenefitMaintenance,
          scale: scale,
        ),
        LoginBenefitItem(
          icon: Icons.oil_barrel_rounded,
          label: AppStrings.loginBenefitOilBattery,
          scale: scale,
        ),
        LoginBenefitItem(
          icon: Icons.directions_car_filled_rounded,
          label: AppStrings.loginBenefitMultiVehicle,
          scale: scale,
        ),
      ],
    );
  }
}
