import 'package:flutter/material.dart';
import 'package:care_talk/models/patient_model.dart';
import 'package:care_talk/core/services/firebase_service.dart';
import 'package:logger/logger.dart';

/// Provider quản lý trạng thái bệnh nhân
class PatientProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final Logger _logger = Logger();

  // ─── State ─────────────────────────────────────────────────────────
  List<PatientModel> _patients = [];
  List<PatientModel> _waitingPatients = [];
  PatientModel? _selectedPatient;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // ─── Getters ───────────────────────────────────────────────────────
  List<PatientModel> get patients => _patients;
  List<PatientModel> get waitingPatients => _waitingPatients;
  PatientModel? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Lọc theo trạng thái
  List<PatientModel> getByStatus(PatientStatus status) {
    return _patients
        .where((p) =>
            p.status == status &&
            (_searchQuery.isEmpty ||
                p.fullName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
        .toList();
  }

  /// Đếm theo trạng thái
  int countByStatus(PatientStatus status) => getByStatus(status).length;

  // ═══════════════════════════════════════════════════════════════════
  // LOAD DATA
  // ═══════════════════════════════════════════════════════════════════

  /// Load tất cả bệnh nhân từ Firestore
  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final patientsData = await _firebase.getDocuments(
        collection: 'patients',
        orderBy: 'created_at',
        descending: true,
      );

      _patients =
          patientsData.map((p) => PatientModel.fromJson(p)).toList();
    } catch (e) {
      _logger.e('Load patients error: $e');
      _errorMessage = 'Không thể tải danh sách bệnh nhân';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load bệnh nhân đang chờ (realtime)
  void listenWaitingPatients() {
    _firebase.waitingPatientsStream().listen(
      (patientsData) {
        _waitingPatients =
            patientsData.map((p) => PatientModel.fromJson(p)).toList();
        notifyListeners();
      },
      onError: (e) {
        _logger.e('Listen waiting patients error: $e');
      },
    );
  }

  /// Load chi tiết bệnh nhân
  Future<void> loadPatientDetail(String patientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _firebase.getDocument(
        collection: 'patients',
        documentId: patientId,
      );

      if (data != null) {
        _selectedPatient = PatientModel.fromJson(data);
      }
    } catch (e) {
      _logger.e('Load patient detail error: $e');
      _errorMessage = 'Không thể tải thông tin bệnh nhân';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE / UPDATE / DELETE
  // ═══════════════════════════════════════════════════════════════════

  /// Tạo bệnh nhân mới
  Future<String?> createPatient(PatientModel patient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final patientId = await _firebase.createDocument(
        collection: 'patients',
        data: patient.toJson(),
      );

      if (patientId != null) {
        // Thêm vào list local
        final newPatient = patient.copyWith(id: patientId);
        _patients.insert(0, newPatient);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return patientId;
    } catch (e) {
      _logger.e('Create patient error: $e');
      _errorMessage = 'Không thể tạo bệnh nhân';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cập nhật thông tin bệnh nhân
  Future<bool> updatePatient(PatientModel patient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _firebase.updateDocument(
        collection: 'patients',
        documentId: patient.id,
        data: patient.toJson(),
      );

      if (success) {
        // Cập nhật trong list local
        final index = _patients.indexWhere((p) => p.id == patient.id);
        if (index != -1) {
          _patients[index] = patient;
        }
        if (_selectedPatient?.id == patient.id) {
          _selectedPatient = patient;
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _logger.e('Update patient error: $e');
      _errorMessage = 'Không thể cập nhật bệnh nhân';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật trạng thái bệnh nhân
  Future<bool> updatePatientStatus(
      String patientId, PatientStatus status) async {
    try {
      final success = await _firebase.updateDocument(
        collection: 'patients',
        documentId: patientId,
        data: {'status': status.value},
      );

      if (success) {
        final index = _patients.indexWhere((p) => p.id == patientId);
        if (index != -1) {
          _patients[index] = _patients[index].copyWith(status: status);
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _logger.e('Update patient status error: $e');
      return false;
    }
  }

  /// Xóa bệnh nhân
  Future<bool> deletePatient(String patientId) async {
    try {
      final success = await _firebase.deleteDocument(
        collection: 'patients',
        documentId: patientId,
      );

      if (success) {
        _patients.removeWhere((p) => p.id == patientId);
        if (_selectedPatient?.id == patientId) {
          _selectedPatient = null;
        }
        notifyListeners();
      }

      return success;
    } catch (e) {
      _logger.e('Delete patient error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ─── Clear ─────────────────────────────────────────────────────────
  void clear() {
    _patients = [];
    _waitingPatients = [];
    _selectedPatient = null;
    _isLoading = false;
    _errorMessage = null;
    _searchQuery = '';
    notifyListeners();
  }
}
