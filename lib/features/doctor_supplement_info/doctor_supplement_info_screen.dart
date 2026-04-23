import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/constants/pref_const.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:care_talk/core/widgets/app_text_field.dart';
import 'package:care_talk/core/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/core/services/firebase_service.dart';

/// Màn hình bổ sung thông tin cho bác sĩ
class DoctorSupplementInfoScreen extends StatefulWidget {
  /// [allowBack] = true: mở từ Hồ sơ cá nhân → có thể back bình thường
  /// [allowBack] = false (mặc định): mở sau đăng nhập → bắt buộc nhập thông tin
  final bool allowBack;
  const DoctorSupplementInfoScreen({super.key, this.allowBack = false});

  @override
  State<DoctorSupplementInfoScreen> createState() =>
      _DoctorSupplementInfoScreenState();
}

class _DoctorSupplementInfoScreenState
    extends State<DoctorSupplementInfoScreen> {
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
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản để tiếp tục'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    final doctorData = {
      'uid': currentUser?.id ?? '',
      'full_name': _nameController.text.trim(),
      'birth_year': _birthYearController.text.trim(),
      'gender': _gender,
      'address': _addressController.text.trim(),
      'specialty': _specialty,
      'workplace': _workplaceController.text.trim(),
      'job_title': _jobTitleController.text.trim(),
      'experience': _experienceController.text.trim(),
      'email': currentUser?.email ?? '',
      'role': 'doctor',
      'is_profile_complete': true,
      'isVerified': false,
    };

    // Lưu vào bảng 'doctors' trên Firestore
    await FirebaseService().createDocument(
      collection: 'doctors',
      documentId: currentUser?.id,
      data: doctorData,
    );

    // Lưu specialty vào local SharedPreferences để đọc nhanh không cần fetch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.doctorSpecialty, _specialty);

    // Cập nhật lại profile trong bảng 'users' (đánh dấu is_profile_complete)
    final success = await authProvider.updateProfile({
      'full_name': _nameController.text.trim(),
      'birth_year': _birthYearController.text.trim(),
      'gender': _gender,
      'address': _addressController.text.trim(),
      'specialty': _specialty,
      'workplace': _workplaceController.text.trim(),
      'job_title': _jobTitleController.text.trim(),
      'experience': _experienceController.text.trim(),
      'is_profile_complete': true,
      'isVerified': false,
    });

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thông tin bác sĩ đã được lưu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRouter.homePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Lưu thông tin thất bại',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: const Text(
          'Bắt buộc nhập thông tin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn phải điền đầy đủ thông tin bác sĩ trước khi sử dụng ứng dụng. Bạn có muốn thoát không?',
          style: TextStyle(height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.go(AppRouter.roleSelectionPath);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Thoát',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.allowBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'CareTalk',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 24,
            ),
            onPressed: () {
              if (widget.allowBack) {
                context.pop();
              } else {
                _showExitDialog(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                  _buildSectionHeader(
                    AppStrings.sectionPersonalInfo,
                    Icons.person_outline_rounded,
                  ),
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
                  _buildSectionHeader(
                    AppStrings.sectionProfessionalInfo,
                    Icons.work_outline_rounded,
                  ),
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
                      'Tâm thần',
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

                  // Agreement Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _isAgreed,
                          onChanged: (val) =>
                              setState(() => _isAgreed = val ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
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
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách bảo mật',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ' dành cho Đối tác chuyên môn.'),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
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
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
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
