import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/user_role.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.patient;

  Widget _buildRoleCard({
    required UserRole role,
    required String titleKey,
    required String descKey,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return AppCard(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      color: isSelected ? AppColors.powderBackground : AppColors.whiteSurface,
      border: Border.all(
        color: isSelected ? AppColors.primaryAction : const Color(0xFFF0DEE2),
        width: isSelected ? 2 : 1,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.whiteSurface : AppColors.powderBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryAction : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.secondary,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.tr(titleKey),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.mainText,
                      ),
                    ),
                    const Spacer(),
                    Radio<UserRole>(
                      value: role,
                      groupValue: _selectedRole,
                      activeColor: AppColors.primaryAction,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(descKey),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onConfirmRole() {
    ref.read(userRoleProvider.notifier).selectRole(_selectedRole);

    switch (_selectedRole) {
      case UserRole.patient:
        context.go('/patient');
        break;
      case UserRole.doctor:
        context.go('/doctor');
        break;
      case UserRole.admin:
        context.go('/admin');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powderBackground,
      appBar: AppBar(
        title: Text(
          context.tr('appName'),
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            icon: const Icon(Icons.language, color: AppColors.primary),
            tooltip: context.isArabic ? 'English' : 'العربية',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('chooseRoleTitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('chooseRoleSubtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Role Cards
                  _buildRoleCard(
                    role: UserRole.patient,
                    titleKey: 'rolePatient',
                    descKey: 'rolePatientDesc',
                    icon: Icons.favorite_border_rounded,
                  ),
                  _buildRoleCard(
                    role: UserRole.doctor,
                    titleKey: 'roleDoctor',
                    descKey: 'roleDoctorDesc',
                    icon: Icons.medical_services_outlined,
                  ),
                  _buildRoleCard(
                    role: UserRole.admin,
                    titleKey: 'roleAdmin',
                    descKey: 'roleAdminDesc',
                    icon: Icons.admin_panel_settings_outlined,
                  ),

                  const SizedBox(height: 28),
                  PillButton(
                    label: '${context.tr('continueAs')} ${_selectedRole.id.toUpperCase()}',
                    icon: Icons.check_circle_outline,
                    onPressed: _onConfirmRole,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: Text(
                      context.tr('alreadyHaveAccount'),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
