import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_widgets.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Build a personalized study hub in minutes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Full name',
            hint: 'Jane Doe',
            controller: _nameController,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.mail_outline,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Password',
            hint: 'Create a password',
            controller: _passwordController,
            isPassword: true,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Confirm password',
            hint: 'Re-enter password',
            controller: _confirmController,
            isPassword: true,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Switch(
                value: _acceptTerms,
                onChanged: (value) => setState(() => _acceptTerms = value),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'I agree to the Terms and Privacy Policy',
                  style: AppTextStyles.labelSM.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _acceptTerms ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Create Account',
              style: AppTextStyles.buttonMD.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(Icons.auto_fix_high, color: AppColors.textPrimary),
            label: Text(
              'Generate study profile',
              style: AppTextStyles.buttonMD.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: AppTextStyles.labelSM.copyWith(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(
                  'Log in',
                  style: AppTextStyles.labelSM.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
