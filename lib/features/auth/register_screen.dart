import 'package:care_talk/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:care_talk/core/widgets/app_text_field.dart';
import 'package:care_talk/core/utils/validators.dart';
import 'package:care_talk/providers/auth_provider.dart';

/// Màn hình Đăng ký
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký tài khoản thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Quay lại login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.onboardingPath);
            }
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/img_logo.png',
                      fit: BoxFit.contain,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: const Text(
                      AppStrings.registerTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: const Text(
                      AppStrings.registerSubtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full name
                  // AppTextField(
                  //   label: AppStrings.registerFullName,
                  //   hint: 'Nguyễn Văn A',
                  //   controller: _nameController,
                  //   textInputAction: TextInputAction.next,
                  //   prefixIcon: Icons.person_outline_rounded,
                  //   validator: Validators.fullName,
                  // ),
                  // const SizedBox(height: 20),

                  // Email
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

                  // // Phone
                  // AppTextField(
                  //   label: AppStrings.registerPhone,
                  //   hint: '0912345678',
                  //   controller: _phoneController,
                  //   keyboardType: TextInputType.phone,
                  //   textInputAction: TextInputAction.next,
                  //   prefixIcon: Icons.phone_outlined,
                  //   validator: Validators.phone,
                  // ),
                  // const SizedBox(height: 20),

                  // Password
                  AppTextField(
                    label: AppStrings.loginPassword,
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 32),

                  // Register button
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return AppGradientButton(
                        text: AppStrings.registerButton,
                        isLoading: auth.isLoading,
                        onPressed: _onRegister,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.registerHasAccount,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          AppStrings.registerLogin,
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
      ),
    );
  }
}
