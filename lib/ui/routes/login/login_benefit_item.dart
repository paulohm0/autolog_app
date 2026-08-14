import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginBenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double scale;

  const LoginBenefitItem({
    super.key,
    required this.icon,
    required this.label,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40 * scale,
          height: 40 * scale,
          alignment: Alignment.center,
          child: Icon(icon, color: context.colors.primary, size: 20 * scale),
        ),

        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(fontSize: 14 * scale),
          ),
        ),
      ],
    );
  }
}
