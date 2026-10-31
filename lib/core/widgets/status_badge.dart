import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.active(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.successContainer,
      textColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  factory StatusBadge.pending(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.warningContainer,
      textColor: AppColors.warning,
      icon: Icons.access_time_rounded,
    );
  }

  factory StatusBadge.info(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.infoContainer,
      textColor: AppColors.info,
      icon: Icons.info_outline,
    );
  }

  factory StatusBadge.blush(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.powderBackground,
      textColor: AppColors.primary,
      icon: Icons.favorite_border,
    );
  }

  factory StatusBadge.inactive(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: const Color(0xFFFFDAD6),
      textColor: AppColors.error,
      icon: Icons.cancel_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
