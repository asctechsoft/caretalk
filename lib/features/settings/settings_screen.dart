import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          final isLoggedIn = user != null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Thông tin cá nhân
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: isLoggedIn
                          ? Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 32,
                              color: AppColors.primary,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn ? user.fullName : 'Khách',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoggedIn ? user.email : 'Chưa đăng nhập',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!isLoggedIn)
                      TextButton(
                        onPressed: () =>
                            context.push('${AppRouter.loginPath}?role=patient'),
                        child: const Text('Đăng nhập'),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          // TODO: Chỉnh sửa thông tin
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'TÙY CHỈNH HỆ THỐNG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Đổi giao diện',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildListTile(
                      icon: Icons.language_outlined,
                      title: 'Đổi ngôn ngữ',
                      trailing: const Text(
                        'Tiếng Việt',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildListTile(
                      icon: Icons.security_outlined,
                      title: 'Bảo mật',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              if (isLoggedIn) ...[
                const Text(
                  'TÀI KHOẢN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.logout_rounded,
                        iconColor: Colors.red,
                        title: 'Đăng xuất',
                        titleColor: Colors.red,
                        onTap: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            context.go(AppRouter.onboardingPath);
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildListTile(
                        icon: Icons.delete_forever_outlined,
                        iconColor: Colors.red,
                        title: 'Xóa tài khoản',
                        titleColor: Colors.red,
                        onTap: () {
                          // TODO: Xóa tài khoản
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
