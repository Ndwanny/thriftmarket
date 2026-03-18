import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final success = await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

    if (success && mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.createAccount,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Join thousands of shoppers today',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                    ),
              ),
              const SizedBox(height: 28),

              // Error
              if (authState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(authState.error!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTextField(
                      controller: _nameController,
                      label: AppStrings.fullName,
                      hint: 'John Banda',
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.validateFullName,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _phoneController,
                      label: '${AppStrings.phoneNumber} (Optional)',
                      hint: '+260 97X XXX XXX',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      hint: 'Min 8 chars, 1 uppercase, 1 number',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.grey500,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      hint: 'Re-enter password',
                      obscureText: _obscureConfirm,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.grey500,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) => Validators.validateConfirmPassword(
                          v, _passwordController.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Terms
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall,
                          children: const [
                            TextSpan(text: AppStrings.iAgreeToThe),
                            TextSpan(
                              text: AppStrings.termsOfService,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: AppStrings.and),
                            TextSpan(
                              text: AppStrings.privacyPolicy,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.createAccount),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      AppStrings.signIn,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AppStrings {
  static const String createAccount = 'Create Account';
}
