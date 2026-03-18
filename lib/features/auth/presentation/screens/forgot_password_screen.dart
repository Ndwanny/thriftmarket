import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authStateProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _emailSent = true);
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
        title: const Text(AppStrings.forgotPassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _emailSent ? _buildSuccess() : _buildForm(authState),
      ),
    );
  }

  Widget _buildForm(authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 24),
        Text('Reset your password',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we\'ll send you a link to reset your password.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.grey600, height: 1.6),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: AuthTextField(
            controller: _emailController,
            label: AppStrings.email,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
        ),
        const SizedBox(height: 24),
        if (authState.error != null) ...[
          Text(authState.error!,
              style: const TextStyle(color: AppColors.error, fontSize: 13)),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isLoading ? null : _sendResetEmail,
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send Reset Link'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 48),
        ),
        const SizedBox(height: 32),
        Text('Check your inbox',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to\n${_emailController.text.trim()}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.grey600, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Login'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _sendResetEmail,
          child: const Text('Resend email'),
        ),
      ],
    );
  }
}
