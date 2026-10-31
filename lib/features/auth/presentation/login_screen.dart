import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/user_role.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../domain/user_session.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'mariam@lumyra.health');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin([UserRole? forcedRole]) async {
    setState(() => _isLoading = true);
    try {
      final UserRole role = forcedRole ?? ref.read(userRoleProvider);

      if (forcedRole != null) {
        // Fast verified demo login with interactive sample data
        await ref.read(authSessionProvider.notifier).loginWithDevRole(role);
      } else {
        // Standard user email/password sign-in
        final email = _emailController.text.trim();
        if (email == 'mariam@lumyra.health') {
          // Demo account with preloaded data
          await ref.read(authSessionProvider.notifier).loginWithDevRole(role);
        } else {
          // Real user account without pre-filled demo appointments/medications
          final realSession = UserSession(
            id: 'usr-real-${DateTime.now().millisecondsSinceEpoch}',
            email: email.isNotEmpty ? email : 'user@lumyra.health',
            displayName: email.isNotEmpty ? email.split('@').first : (context.isArabic ? 'مريضة جديدة' : 'New User'),
            role: role,
            status: 'ACTIVE',
            token: 'real-token-${DateTime.now().millisecondsSinceEpoch}',
          );
          ref.read(authSessionProvider.notifier).setSession(realSession);
        }
      }

      if (mounted) {
        switch (role) {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'تعذر تسجيل الدخول: $e'
                  : 'Authentication failed: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('login'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('tagline'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: context.tr('email'),
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: context.tr('password'),
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.secondaryText,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Forgot password
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              context.tr('forgotPassword'),
                              style: const TextStyle(fontSize: 13, color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sign In CTA
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          )
                        else
                          PillButton(
                            label: context.tr('login'),
                            icon: Icons.login_rounded,
                            onPressed: () => _handleLogin(),
                          ),
                        const SizedBox(height: 20),

                        // Explicit Development Fast Auth Options
                        if (AppConfig.isDevAuthAllowed) ...[
                          const Divider(height: 32, color: AppColors.outline),
                          Text(
                            context.isArabic
                                ? 'بيئة التطوير: تسجيل دخول سريع بهوية معتمدة'
                                : 'Dev Mode: Verified Role Login',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.softDustyBlush),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isLoading ? null : () => _handleLogin(UserRole.patient),
                            icon: const Icon(Icons.person_outline, size: 18),
                            label: Text(
                              context.isArabic ? 'دخول كمريضة (مريم علي)' : 'Login as Patient (Mariam)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isLoading ? null : () => _handleLogin(UserRole.doctor),
                            icon: const Icon(Icons.medical_services_outlined, size: 18),
                            label: Text(
                              context.isArabic ? 'دخول كطبيب معتمد (د. نور الدين)' : 'Login as Doctor (Dr. Nour)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondaryText,
                              side: const BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isLoading ? null : () => _handleLogin(UserRole.admin),
                            icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                            label: Text(
                              context.isArabic ? 'دخول كمسؤول النظام (Admin)' : 'Login as Admin',
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Register Redirect
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.tr('dontHaveAccount'),
                              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () => context.go('/auth/register'),
                              child: Text(
                                context.tr('register'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
