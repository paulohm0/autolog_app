import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SimpleHistoryCard extends StatelessWidget {
  final String month;
  final String day;
  final String vehicle;
  final String detail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SimpleHistoryCard({
    super.key,
    required this.month,
    required this.day,
    required this.vehicle,
    required this.detail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _DateBadge(month: month, day: day),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 15,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        vehicle,
                        style: AppTextStyles.titleLarge(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _IconAction(
            icon: Icons.edit_outlined,
            color: context.colors.textSecondary,
            onTap: onEdit,
          ),
          _IconAction(
            icon: Icons.delete_outline_rounded,
            color: context.colors.error,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String month;
  final String day;

  const _DateBadge({required this.month, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            month.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            day,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.colors.primary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
