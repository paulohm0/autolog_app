import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/ui/routes/login/login_benefit_item.dart';
import 'package:flutter/material.dart';

class LoginBenefits extends StatelessWidget {
  const LoginBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LoginBenefitItem(
          icon: Icons.build_rounded,
          label: AppStrings.loginBenefitMaintenance,
        ),
        LoginBenefitItem(
          icon: Icons.oil_barrel_rounded,
          label: AppStrings.loginBenefitOilBattery,
        ),
        LoginBenefitItem(
          icon: Icons.directions_car_filled_rounded,
          label: AppStrings.loginBenefitMultiVehicle,
        ),
      ],
    );
  }
}
