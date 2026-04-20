import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:care_talk/core/widgets/app_text_field.dart';
import 'package:care_talk/core/utils/validators.dart';

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

  String _selectedGender = 'Nam';
  DateTime? _selectedDob;
  bool _isLoading = false;

  bool get _isEditing => widget.patientId != null;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (date != null) {
      setState(() => _selectedDob = date);
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implement save to Firestore via PatientProvider
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
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
                controller: TextEditingController(
                  text: _selectedDob != null
                      ? '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}'
                      : '',
                ),
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
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
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
                validator: (value) =>
                    Validators.required(value, 'Triệu chứng'),
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
