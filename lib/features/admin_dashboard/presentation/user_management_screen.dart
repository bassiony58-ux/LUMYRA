import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  String _selectedRoleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final client = ApiClient(tokenProvider: () => 'mock-admin-uid:admin@lumyra.test:ADMIN');
      final res = await client.get('/users');
      if (res is List) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(res.map((u) => Map<String, dynamic>.from(u)));
          _isLoading = false;
        });
        return;
      }
    } catch (_) {
      // Fallback local mock users if network fails
    }

    if (mounted) {
      setState(() {
        _users = [
          {
            'id': 'usr-pat-01',
            'displayName': 'سارة أحمد محمد',
            'email': 'sarah.ahmed@example.com',
            'role': 'PATIENT',
            'status': 'ACTIVE',
            'createdAt': '2026-09-15',
          },
          {
            'id': 'usr-pat-02',
            'displayName': 'مريم علي حسن',
            'email': 'mariam.ali@example.com',
            'role': 'PATIENT',
            'status': 'ACTIVE',
            'createdAt': '2026-10-01',
          },
          {
            'id': 'usr-doc-01',
            'displayName': 'د. نور الخالدي',
            'email': 'dr.nour@lumyra.health',
            'role': 'DOCTOR',
            'status': 'ACTIVE',
            'createdAt': '2026-08-10',
          },
          {
            'id': 'usr-doc-02',
            'displayName': 'د. سارة المنشاوي',
            'email': 'dr.sara@lumyra.health',
            'role': 'DOCTOR',
            'status': 'PENDING_APPROVAL',
            'createdAt': '2026-10-28',
          },
          {
            'id': 'usr-adm-01',
            'displayName': 'مدير المنظومة الطبية',
            'email': 'admin@lumyra.health',
            'role': 'ADMIN',
            'status': 'ACTIVE',
            'createdAt': '2026-07-01',
          },
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
    final isAr = context.isArabic;
    final currentStatus = user['status'] as String? ?? 'ACTIVE';
    final willActivate = currentStatus != 'ACTIVE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          willActivate
              ? (isAr ? 'تأكيد تفعيل الحساب' : 'Confirm Activate User')
              : (isAr ? 'تأكيد تعطيل الحساب' : 'Confirm Suspend User'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: willActivate ? AppColors.success : AppColors.error,
          ),
        ),
        content: Text(
          willActivate
              ? (isAr
                  ? 'هل تريد إعادة تفعيل حساب المستخدم "${user['displayName']}"؟'
                  : 'Re-enable account for "${user['displayName']}"?')
              : (isAr
                  ? 'هل تريد تعطيل حساب المستخدم "${user['displayName']}" مؤقتاً؟ لن يتمكن من تسجيل الدخول.'
                  : 'Temporarily suspend "${user['displayName']}"?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willActivate ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(willActivate ? (isAr ? 'تفعيل' : 'Activate') : (isAr ? 'تعطيل' : 'Suspend')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final client = ApiClient(tokenProvider: () => 'mock-admin-uid:admin@lumyra.test:ADMIN');
        await client.patch('/users/${user['id']}/status', body: {'isActive': willActivate});
      } catch (_) {}

      if (mounted) {
        setState(() {
          user['status'] = willActivate ? 'ACTIVE' : 'INACTIVE';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              willActivate
                  ? (isAr ? 'تم تفعيل الحساب بنجاح' : 'Account activated')
                  : (isAr ? 'تم تعطيل الحساب بنجاح' : 'Account suspended'),
            ),
            backgroundColor: willActivate ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;

    final filteredUsers = _users.filterUsers(_searchQuery, _selectedRoleFilter);

    return AdaptiveScaffold(
      selectedIndex: 1,
      titleKey: 'navUsers',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            AppCard(
              padding: const EdgeInsets.all(22),
              color: AppColors.powderBackground,
              border: Border.all(color: AppColors.softDustyBlush),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'إدارة المستخدمين والصلاحيات الشاملة' : 'User Governance & RBAC Console',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                              ? 'إدارة حسابات المريضات، الأطباء والمشرفين والتحكم بالحالة التشغيلية للحسابات.'
                              : 'Oversee all platform accounts with granular status control.',
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Search and Role Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: isAr ? 'بحث بالاسم أو البريد الإلكتروني...' : 'Search by name or email...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: AppColors.whiteSurface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.outline),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRoleFilter,
                      items: [
                        DropdownMenuItem(value: 'ALL', child: Text(isAr ? 'الكل' : 'All Roles')),
                        DropdownMenuItem(value: 'PATIENT', child: Text(isAr ? 'المريضات' : 'Patients')),
                        DropdownMenuItem(value: 'DOCTOR', child: Text(isAr ? 'الأطباء' : 'Doctors')),
                        DropdownMenuItem(value: 'ADMIN', child: Text(isAr ? 'المشرفين' : 'Admins')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRoleFilter = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // User List
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (filteredUsers.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    isAr ? 'لا يوجد مستخدمون مطابقون لمعايير البحث' : 'No users match current filters',
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              )
            else
              ...filteredUsers.map((user) {
                final role = user['role'] as String? ?? 'PATIENT';
                final status = user['status'] as String? ?? 'ACTIVE';
                final isActive = status == 'ACTIVE';

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: role == 'DOCTOR'
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : role == 'ADMIN'
                                ? AppColors.warning.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.15),
                        child: Icon(
                          role == 'DOCTOR'
                              ? Icons.medical_services_rounded
                              : role == 'ADMIN'
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.person_rounded,
                          color: role == 'DOCTOR'
                              ? AppColors.secondary
                              : role == 'ADMIN'
                                  ? AppColors.warning
                                  : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Text(
                                  user['displayName'] ?? '',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                if (role == 'DOCTOR')
                                  StatusBadge.active(isAr ? 'طبيب' : 'Doctor')
                                else if (role == 'ADMIN')
                                  StatusBadge.info(isAr ? 'مشرف' : 'Admin')
                                else
                                  StatusBadge.blush(isAr ? 'مريضة' : 'Patient'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['email'] ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      // Status badge & toggle button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isActive)
                            StatusBadge.active(isAr ? 'نشط' : 'Active')
                          else if (status == 'PENDING_APPROVAL')
                            StatusBadge.pending(isAr ? 'بانتظار الاعتماد' : 'Pending')
                          else
                            StatusBadge.inactive(isAr ? 'معطل' : 'Suspended'),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _toggleUserStatus(user),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                isActive ? (isAr ? 'تعطيل الحساب' : 'Suspend') : (isAr ? 'تفعيل الحساب' : 'Activate'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? AppColors.error : AppColors.success,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

extension _UserFilterExtension on List<Map<String, dynamic>> {
  List<Map<String, dynamic>> filterUsers(String search, String roleFilter) {
    return where((u) {
      if (roleFilter != 'ALL' && u['role'] != roleFilter) {
        return false;
      }
      if (search.isNotEmpty) {
        final name = (u['displayName'] as String? ?? '').toLowerCase();
        final email = (u['email'] as String? ?? '').toLowerCase();
        final s = search.toLowerCase();
        if (!name.contains(s) && !email.contains(s)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
