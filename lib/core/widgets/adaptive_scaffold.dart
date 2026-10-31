import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/localization/app_localization.dart';
import '../../app/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../models/user_role.dart';

class NavItemData {
  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
  final String routePath;

  const NavItemData({
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
    required this.routePath,
  });
}

class AdaptiveScaffold extends ConsumerWidget {
  final Widget body;
  final String titleKey;
  final List<Widget>? actions;
  final int selectedIndex;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.titleKey,
    this.actions,
    this.selectedIndex = 0,
  });

  List<NavItemData> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return const [
          NavItemData(labelKey: 'navHome', icon: Icons.home_outlined, selectedIcon: Icons.home, routePath: '/patient'),
          NavItemData(labelKey: 'navRisk', icon: Icons.shield_outlined, selectedIcon: Icons.shield, routePath: '/patient/risk'),
          NavItemData(labelKey: 'navCare', icon: Icons.medication_outlined, selectedIcon: Icons.medication, routePath: '/patient/care'),
          NavItemData(labelKey: 'navCenters', icon: Icons.map_outlined, selectedIcon: Icons.map, routePath: '/patient/centers'),
          NavItemData(labelKey: 'navJournal', icon: Icons.book_outlined, selectedIcon: Icons.book, routePath: '/patient/journal'),
        ];
      case UserRole.doctor:
        return const [
          NavItemData(labelKey: 'navHome', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, routePath: '/doctor'),
          NavItemData(labelKey: 'navPatients', icon: Icons.people_outline, selectedIcon: Icons.people, routePath: '/doctor/patients'),
          NavItemData(labelKey: 'navImaging', icon: Icons.image_search_outlined, selectedIcon: Icons.image_search, routePath: '/doctor/imaging'),
          NavItemData(labelKey: 'navEducation', icon: Icons.article_outlined, selectedIcon: Icons.article, routePath: '/doctor/education'),
        ];
      case UserRole.admin:
        return const [
          NavItemData(labelKey: 'navHome', icon: Icons.admin_panel_settings_outlined, selectedIcon: Icons.admin_panel_settings, routePath: '/admin'),
          NavItemData(labelKey: 'navApprovals', icon: Icons.verified_user_outlined, selectedIcon: Icons.verified_user, routePath: '/admin/approvals'),
          NavItemData(labelKey: 'navCenters', icon: Icons.local_hospital_outlined, selectedIcon: Icons.local_hospital, routePath: '/admin/centers'),
          NavItemData(labelKey: 'navAnalytics', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, routePath: '/admin/analytics'),
        ];
    }
  }

  void _onNavigate(BuildContext context, String routePath) {
    context.go(routePath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final navItems = _getNavItems(userRole);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;
    final isTablet = width >= 650 && width < 1100;
    

    // Language switcher button (Compact icon on mobile to prevent header overflow)
    final langButton = isMobile
        ? IconButton(
            tooltip: context.isArabic ? 'English' : 'العربية',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            icon: const Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
          )
        : TextButton.icon(
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            icon: const Icon(Icons.language, size: 18, color: AppColors.primary),
            label: Text(
              context.isArabic ? 'English' : 'العربية',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          );

    // Role switcher dropdown pill for prototyping & testing
    final roleChip = Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.softDustyBlush.withAlpha(120),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: userRole,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 16),
          items: [
            DropdownMenuItem(
              value: UserRole.patient,
              child: Text(context.isArabic ? 'مريضة' : 'Patient', style: TextStyle(fontSize: isMobile ? 11.5 : 13, fontWeight: FontWeight.w700)),
            ),
            DropdownMenuItem(
              value: UserRole.doctor,
              child: Text(context.isArabic ? 'طبيب' : 'Doctor', style: TextStyle(fontSize: isMobile ? 11.5 : 13, fontWeight: FontWeight.w700)),
            ),
            DropdownMenuItem(
              value: UserRole.admin,
              child: Text(context.isArabic ? 'إدارة' : 'Admin', style: TextStyle(fontSize: isMobile ? 11.5 : 13, fontWeight: FontWeight.w700)),
            ),
          ],
          onChanged: (newRole) async {
            if (newRole != null) {
              ref.read(userRoleProvider.notifier).selectRole(newRole);
              await ref.read(authSessionProvider.notifier).loginWithDevRole(newRole);
              if (!context.mounted) return;
              if (newRole == UserRole.patient) context.go('/patient');
              if (newRole == UserRole.doctor) context.go('/doctor');
              if (newRole == UserRole.admin) context.go('/admin');
            }
          },
        ),
      ),
    );

    // Global Logout Button with confirmation
    final logoutButton = IconButton(
      tooltip: context.isArabic ? 'تسجيل الخروج' : 'Log out',
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
      icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.primary),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              context.isArabic ? 'تسجيل الخروج' : 'Log Out',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Text(
              context.isArabic
                  ? 'هل ترغب في تسجيل الخروج والعودة لشاشة الدخول؟'
                  : 'Are you sure you want to log out and return to the login screen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.isArabic ? 'إلغاء' : 'Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.isArabic ? 'خروج' : 'Log out'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          await ref.read(authSessionProvider.notifier).logout();
          if (context.mounted) {
            context.go('/auth/login');
          }
        }
      },
    );

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 12,
          title: Text(
            context.tr(titleKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.primary),
          ),
          actions: [
            roleChip,
            langButton,
            logoutButton,
            if (actions != null) ...actions!,
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
                overflow: TextOverflow.ellipsis,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
              );
            }),
            indicatorColor: AppColors.primaryContainer,
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex.clamp(0, navItems.length - 1),
            onDestinationSelected: (idx) => _onNavigate(context, navItems[idx].routePath),
            destinations: navItems.map((item) {
              return NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: context.tr(item.labelKey),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          selectedIndex: selectedIndex.clamp(0, navItems.length - 1),
                          onDestinationSelected: (idx) => _onNavigate(context, navItems[idx].routePath),
                          labelType: NavigationRailLabelType.all,
                          leading: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.powderBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryAction, width: 2),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.favorite, color: AppColors.primary, size: 22),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.tr('appName'),
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                roleChip,
                                const SizedBox(height: 8),
                                IconButton(
                                  onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
                                  icon: const Icon(Icons.language, color: AppColors.primary),
                                  tooltip: context.isArabic ? 'English' : 'العربية',
                                ),
                                const SizedBox(height: 4),
                                logoutButton,
                              ],
                            ),
                          ),
                          destinations: navItems.map((item) {
                            return NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(context.tr(item.labelKey)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const VerticalDivider(thickness: 1, width: 1, color: AppColors.outline),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      color: AppColors.powderBackground,
                      child: Row(
                        children: [
                          Text(
                            context.tr(titleKey),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.primary),
                          ),
                          const Spacer(),
                          if (actions != null) ...actions!,
                        ],
                      ),
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Desktop & Web Layout (>1100px)
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Persistent Wide Sidebar
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: AppColors.whiteSurface,
                border: Border(
                  right: BorderSide(color: Color(0xFFF0DEE2), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.powderBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryAction, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.favorite, color: AppColors.primary, size: 26),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('appName'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              userRole.displayNameEn,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3E4E8)),
                  const SizedBox(height: 12),
                  // Nav Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: navItems.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = index == selectedIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.powderBackground : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? AppColors.primary : AppColors.secondaryText,
                            ),
                            title: Text(
                              context.tr(item.labelKey),
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.mainText,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onTap: () => _onNavigate(context, item.routePath),
                          ),
                        );
                      },
                    ),
                  ),
                  // Bottom Switchers (Role & Language)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: Color(0xFFF3E4E8))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        roleChip,
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: langButton),
                            logoutButton,
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.powderBackground,
                      border: Border(bottom: BorderSide(color: Color(0xFFF0DEE2))),
                    ),
                    child: Row(
                      children: [
                        Text(
                          context.tr(titleKey),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.primary),
                        ),
                        const Spacer(),
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
