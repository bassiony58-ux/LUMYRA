import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/user_role.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../domain/user_session.dart';
import 'providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    final role = ref.read(userRoleProvider);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final userEmail = email.isNotEmpty ? email : 'user@lumyra.health';
    final userDisplayName = name.isNotEmpty
        ? name
        : (context.isArabic ? 'مستخدمة لوميرا' : 'Lumyra User');

    // Create a real (non-demo) user session
    final realSession = UserSession(
      id: 'usr-real-${DateTime.now().millisecondsSinceEpoch}',
      email: userEmail,
      displayName: userDisplayName,
      role: role,
      status: 'ACTIVE',
      token: 'real-token-${DateTime.now().millisecondsSinceEpoch}',
    );

    ref.read(authSessionProvider.notifier).setSession(realSession);

    if (mounted) {
      if (role == UserRole.patient) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'مرحباً بكِ في لوميرا 🌸 خطوتكِ الأولى: إكمال التقييم الصحي المبدئي (يتجدد كل 30 يوماً)'
                  : 'Welcome to Lumyra 🌸 Step 1: Complete your baseline health assessment',
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
          ),
        );
        // Direct route to the 30-day recurring baseline assessment as requested
        context.go('/patient/risk');
      } else if (role == UserRole.doctor) {
        context.go('/doctor');
      } else {
        context.go('/admin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = ref.watch(userRoleProvider);

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
              constraints: const BoxConstraints(maxWidth: 540),
              child: AppCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('register'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${context.tr('rolePatient')}: ${currentRole.displayNameEn}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: context.isArabic ? 'الاسم الكامل' : 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.tr('email'),
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
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
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    PillButton(
                      label: context.tr('register'),
                      icon: Icons.person_add_alt_1_outlined,
                      onPressed: _onRegister,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('alreadyHaveAccount'),
                          style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () => context.go('/auth/login'),
                          child: Text(
                            context.tr('login'),
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
            ),
          ),
        ),
      ),
    );
  }
}
