import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:care_talk/core/widgets/app_text_field.dart';
import 'package:care_talk/core/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/providers/auth_provider.dart';

/// Màn hình Đăng nhập
class LoginScreen extends StatefulWidget {
  final String? role;
  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted && success) {
      final user = authProvider.currentUser;
      if (user?.role == 'doctor' && !user!.isProfileComplete) {
        context.go(AppRouter.doctorSupplementInfoPath);
      } else if (widget.role == 'patient') {
        context.go(AppRouter.patientHomePath);
      } else {
        context.go(AppRouter.homePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/img_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Center(
                  child: Text(
                    AppStrings.loginTitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    AppStrings.loginSubtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                AppTextField(
                  label: AppStrings.loginEmail,
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),

                // Password field
                AppTextField(
                  label: AppStrings.loginPassword,
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: Validators.password,
                ),
                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password
                    },
                    child: const Text(AppStrings.loginForgotPassword),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                AppGradientButton(
                  text: AppStrings.loginButton,
                  isLoading: _isLoading,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: 24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.loginNoAccount,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRouter.registerPath),
                      child: const Text(
                        AppStrings.loginRegister,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
