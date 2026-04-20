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

/// Màn hình bổ sung thông tin cho bác sĩ
class DoctorSupplementInfoScreen extends StatefulWidget {
  const DoctorSupplementInfoScreen({super.key});

  @override
  State<DoctorSupplementInfoScreen> createState() => _DoctorSupplementInfoScreenState();
}

class _DoctorSupplementInfoScreenState extends State<DoctorSupplementInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers cho thông tin cá nhân
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'Nam';

  // Controllers cho thông tin chuyên môn
  String _specialty = 'Nội tổng quát';
  final _workplaceController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isAgreed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load existing data if any
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    _addressController.dispose();
    _workplaceController.dispose();
    _jobTitleController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản để tiếp tục')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Simulate updating profile
    final updatedData = {
      'full_name': _nameController.text,
      'birth_year': _birthYearController.text,
      'gender': _gender,
      'address': _addressController.text,
      'specialty': _specialty,
      'workplace': _workplaceController.text,
      'job_title': _jobTitleController.text,
      'experience': _experienceController.text,
      'is_profile_complete': true,
    };

    final success = await authProvider.updateProfile(updatedData);

    setState(() => _isLoading = false);

    if (mounted && success) {
      context.go(AppRouter.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header
                Text(
                  AppStrings.doctorSupplementTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.doctorSupplementSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Section 1: Thông tin cá nhân
                _buildSectionHeader(AppStrings.sectionPersonalInfo, Icons.person_outline_rounded),
                const SizedBox(height: 16),
                
                AppTextField(
                  label: AppStrings.registerFullName,
                  hint: 'Nguyễn Văn An',
                  controller: _nameController,
                  validator: Validators.fullName,
                  fillColor: const Color(0xFFEDF2F7),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppTextField(
                        label: AppStrings.birthYear,
                        hint: '1985',
                        controller: _birthYearController,
                        keyboardType: TextInputType.number,
                        fillColor: const Color(0xFFEDF2F7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildDropdownField(
                        label: AppStrings.gender,
                        value: _gender,
                        items: ['Nam', 'Nữ', 'Khác'],
                        onChanged: (val) => setState(() => _gender = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: AppStrings.permanentAddress,
                  hint: 'Quận 1, TP. Hồ Chí Minh',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_outlined,
                  fillColor: const Color(0xFFEDF2F7),
                ),
                const SizedBox(height: 32),

                // Section 2: Thông tin chuyên môn
                _buildSectionHeader(AppStrings.sectionProfessionalInfo, Icons.work_outline_rounded),
                const SizedBox(height: 16),

                _buildDropdownField(
                  label: AppStrings.specialty,
                  value: _specialty,
                  items: [
                    'Nội tổng quát',
                    'Ngoại khoa',
                    'Sản phụ khoa',
                    'Nhi khoa',
                    'Tai Mũi Họng',
                    'Mắt',
                    'Da liễu',
                    'Tâm thần'
                  ],
                  onChanged: (val) => setState(() => _specialty = val!),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: AppStrings.currentWorkplace,
                  hint: 'Bệnh viện Đại học Y Dược',
                  controller: _workplaceController,
                  fillColor: const Color(0xFFEDF2F7),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: AppStrings.jobTitle,
                  hint: 'Bác sĩ chuyên khoa I',
                  controller: _jobTitleController,
                  fillColor: const Color(0xFFEDF2F7),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: AppStrings.experienceYears,
                  hint: '5 năm',
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  fillColor: const Color(0xFFEDF2F7),
                ),
                const SizedBox(height: 24),

                // Agreement Text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        onChanged: (val) => setState(() => _isAgreed = val ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Tôi đồng ý với các ',
                          children: [
                            TextSpan(
                              text: 'Điều khoản dịch vụ',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' và '),
                            TextSpan(
                              text: 'Chính sách bảo mật',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' dành cho Đối tác chuyên môn.'),
                          ],
                        ),
                        style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                AppGradientButton(
                  text: AppStrings.saveAndContinue,
                  isLoading: _isLoading,
                  onPressed: _onSave,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F7), // Light grey background
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
