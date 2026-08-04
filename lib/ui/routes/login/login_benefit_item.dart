import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginBenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const LoginBenefitItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.colors.primary, size: 20),
        ),

        Expanded(child: Text(label, style: AppTextStyles.bodyMedium(context))),
      ],
    );
  }
}
