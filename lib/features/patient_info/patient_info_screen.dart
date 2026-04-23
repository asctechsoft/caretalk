import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:care_talk/core/widgets/app_text_field.dart';
import 'package:care_talk/core/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/core/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_talk/core/constants/pref_const.dart';

/// Màn hình nhập thông tin bệnh nhân
class PatientInfoScreen extends StatefulWidget {
  final String? patientId;

  const PatientInfoScreen({super.key, this.patientId});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  String _selectedGender = 'Nam';
  DateTime? _selectedDob;
  bool _isLoading = false;

  bool get _isEditing => widget.patientId != null;

  @override
  void initState() {
    super.initState();

    // Khởi tạo data người dùng hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final savedFullName = prefs.getString(PrefConst.fullName);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        setState(() {
          _nameCtrl.text = (savedFullName != null && savedFullName.isNotEmpty)
              ? savedFullName
              : user.fullName;
          _emailCtrl.text = user.email;
          if (user.phone.isNotEmpty) {
            _phoneCtrl.text = user.phone;
          }
        });

        // Tải thêm các trường bổ sung từ Firestore (địa chỉ, ngày sinh, giới tính...)
        final doc = await FirebaseService().getDocument(
          collection: 'users',
          documentId: user.id,
        );
        if (doc != null && mounted) {
          setState(() {
            if (doc['full_name'] != null &&
                doc['full_name'].toString().isNotEmpty) {
              if (savedFullName == null || savedFullName.isEmpty) {
                _nameCtrl.text = doc['full_name'];
              }
            }
            if (doc['address'] != null) _addressCtrl.text = doc['address'];
            if (doc['symptoms'] != null) _symptomsCtrl.text = doc['symptoms'];
            if (doc['note'] != null) _noteCtrl.text = doc['note'];

            if (doc['date_of_birth'] != null) {
              final dobParts = doc['date_of_birth'].toString().split('-');
              if (dobParts.length == 3) {
                _selectedDob = DateTime(
                  int.parse(dobParts[0]),
                  int.parse(dobParts[1]),
                  int.parse(dobParts[2]),
                );
                _dobCtrl.text =
                    '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}';
              }
            }
            if (doc['gender'] != null) {
              if (doc['gender'] == 'MALE')
                _selectedGender = 'Nam';
              else if (doc['gender'] == 'FEMALE')
                _selectedGender = 'Nữ';
              else
                _selectedGender = 'Khác';
            }
          });
        }
      }
    });

    if (_isEditing) {
      // TODO: Load patient data from Firestore
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _symptomsCtrl.dispose();
    _noteCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    bool success = false;
    if (user != null) {
      final dobStr = _selectedDob != null
          ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
          : '1990-01-15';

      String genderEnum = 'OTHER';
      if (_selectedGender == 'Nam') genderEnum = 'MALE';
      if (_selectedGender == 'Nữ') genderEnum = 'FEMALE';

      // Update local profile and Firestore directly
      success = await authProvider.updateProfile({
        'full_name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'phone': _phoneCtrl.text,
        'date_of_birth': dobStr,
        'gender': genderEnum,
        'address': _addressCtrl.text.isEmpty ? "Hà Nội" : _addressCtrl.text,
        'symptoms': _symptomsCtrl.text,
        'note': _noteCtrl.text,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefConst.fullName, _nameCtrl.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Cập nhật thất bại'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa thông tin' : AppStrings.patientInfoTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Thông tin cá nhân
              _buildSectionTitle('Thông tin cá nhân'),
              const SizedBox(height: 16),

              AppTextField(
                label: AppStrings.patientName,
                hint: 'Nguyễn Văn A',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.fullName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: AppStrings.patientPhone,
                hint: '0912345678',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: AppStrings.patientEmail,
                hint: 'example@email.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Date of birth
              AppTextField(
                label: AppStrings.patientDob,
                hint: 'Chọn ngày sinh',
                readOnly: true,
                prefixIcon: Icons.calendar_today_outlined,
                controller: _dobCtrl,
                onTap: _selectDate,
                suffixIcon: Icons.arrow_drop_down_rounded,
              ),
              const SizedBox(height: 16),

              // Gender
              Text(
                AppStrings.patientGender,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Nam', 'Nữ', 'Khác'].map((gender) {
                  final isSelected = _selectedGender == gender;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(gender),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedGender = gender);
                      },
                      selectedColor: AppColors.primarySurface,
                      labelStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: AppStrings.patientAddress,
                hint: 'Địa chỉ hiện tại',
                controller: _addressCtrl,
                prefixIcon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Section: Thông tin y tế
              _buildSectionTitle('Thông tin y tế'),
              const SizedBox(height: 16),

              AppTextField(
                label: AppStrings.patientSymptoms,
                hint: 'Mô tả triệu chứng...',
                controller: _symptomsCtrl,
                maxLines: 3,
                prefixIcon: Icons.medical_information_outlined,
                validator: (value) => Validators.required(value, 'Triệu chứng'),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: AppStrings.patientNote,
                hint: 'Ghi chú thêm (không bắt buộc)',
                controller: _noteCtrl,
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: 32),

              // Submit button
              AppGradientButton(
                text: _isEditing ? 'Cập nhật' : AppStrings.patientSubmit,
                isLoading: _isLoading,
                onPressed: _onSubmit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
