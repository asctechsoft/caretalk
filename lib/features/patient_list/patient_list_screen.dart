import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/widgets/app_common.dart';
import 'package:care_talk/core/widgets/app_text_field.dart';

/// Màn hình danh sách bệnh nhân đang chờ tư vấn
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data - TODO: Thay bằng data thật từ Firestore
  final List<_PatientItem> _patients = [
    _PatientItem(
      id: '1',
      name: 'Nguyễn Văn An',
      phone: '0912345678',
      symptom: 'Đau đầu, chóng mặt',
      status: 'waiting',
      time: '10:30',
    ),
    _PatientItem(
      id: '2',
      name: 'Trần Thị Bình',
      phone: '0987654321',
      symptom: 'Ho kéo dài, sốt nhẹ',
      status: 'waiting',
      time: '10:45',
    ),
    _PatientItem(
      id: '3',
      name: 'Lê Hoàng Cường',
      phone: '0909090909',
      symptom: 'Đau bụng, buồn nôn',
      status: 'in_progress',
      time: '09:15',
    ),
    _PatientItem(
      id: '4',
      name: 'Phạm Minh Đức',
      phone: '0933333333',
      symptom: 'Mất ngủ, stress',
      status: 'completed',
      time: '08:00',
    ),
    _PatientItem(
      id: '5',
      name: 'Hoàng Thị Em',
      phone: '0944444444',
      symptom: 'Đau răng, sưng nướu',
      status: 'waiting',
      time: '11:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_PatientItem> _filterByStatus(String status) {
    return _patients
        .where((p) =>
            p.status == status &&
            (_searchQuery.isEmpty ||
                p.name.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.patientListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => context.push(AppRouter.patientInfoPath),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: '${AppStrings.patientListWaiting} (${_filterByStatus('waiting').length})'),
            Tab(text: '${AppStrings.patientListInProgress} (${_filterByStatus('in_progress').length})'),
            Tab(text: '${AppStrings.patientListCompleted} (${_filterByStatus('completed').length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: AppSearchField(
              controller: _searchController,
              hint: 'Tìm kiếm bệnh nhân...',
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              onClear: () {
                setState(() => _searchQuery = '');
              },
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientList('waiting'),
                _buildPatientList('in_progress'),
                _buildPatientList('completed'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.patientInfoPath),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildPatientList(String status) {
    final patients = _filterByStatus(status);

    if (patients.isEmpty) {
      return AppEmptyState(
        icon: Icons.people_outline_rounded,
        title: AppStrings.patientListEmpty,
        subtitle: 'Không tìm thấy bệnh nhân nào trong danh sách này',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        return _buildPatientCard(patients[index]);
      },
    );
  }

  Widget _buildPatientCard(_PatientItem patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      child: InkWell(
        onTap: () => context.push(
          '${AppRouter.patientInfoPath}?patientId=${patient.id}',
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Row(
            children: [
              AppAvatar(name: patient.name, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            patient.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(patient.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.symptom,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          patient.phone,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          patient.time,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (patient.status == 'waiting')
                IconButton(
                  icon: const Icon(Icons.chat_rounded,
                      color: AppColors.primary, size: 22),
                  onPressed: () => context.push(AppRouter.chatPath),
                  tooltip: 'Bắt đầu tư vấn',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'waiting':
        return AppStatusBadge.waiting(isSmall: true);
      case 'in_progress':
        return AppStatusBadge.inProgress(isSmall: true);
      case 'completed':
        return AppStatusBadge.completed(isSmall: true);
      default:
        return AppStatusBadge(text: status, color: AppColors.disabled, isSmall: true);
    }
  }
}

class _PatientItem {
  final String id;
  final String name;
  final String phone;
  final String symptom;
  final String status;
  final String time;

  const _PatientItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.symptom,
    required this.status,
    required this.time,
  });
}
