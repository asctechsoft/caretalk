import 'package:equatable/equatable.dart';

/// Trạng thái bệnh nhân
enum PatientStatus {
  waiting,    // Đang chờ tư vấn
  inProgress, // Đang tư vấn
  completed,  // Đã hoàn thành
  cancelled,  // Đã hủy
}

/// Extension để parse PatientStatus từ/to String
extension PatientStatusExt on PatientStatus {
  String get value {
    switch (this) {
      case PatientStatus.waiting:
        return 'waiting';
      case PatientStatus.inProgress:
        return 'in_progress';
      case PatientStatus.completed:
        return 'completed';
      case PatientStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case PatientStatus.waiting:
        return 'Đang chờ';
      case PatientStatus.inProgress:
        return 'Đang tư vấn';
      case PatientStatus.completed:
        return 'Hoàn thành';
      case PatientStatus.cancelled:
        return 'Đã hủy';
    }
  }

  static PatientStatus fromString(String value) {
    switch (value) {
      case 'waiting':
        return PatientStatus.waiting;
      case 'in_progress':
        return PatientStatus.inProgress;
      case 'completed':
        return PatientStatus.completed;
      case 'cancelled':
        return PatientStatus.cancelled;
      default:
        return PatientStatus.waiting;
    }
  }
}

/// Model bệnh nhân
class PatientModel extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String gender; // 'Nam', 'Nữ', 'Khác'
  final String? address;
  final String symptoms;
  final String? note;
  final PatientStatus status;
  final String? assignedDoctorId;
  final String? chatSessionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PatientModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.dateOfBirth,
    this.gender = 'Nam',
    this.address,
    required this.symptoms,
    this.note,
    this.status = PatientStatus.waiting,
    this.assignedDoctorId,
    this.chatSessionId,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      gender: json['gender'] ?? 'Nam',
      address: json['address'],
      symptoms: json['symptoms'] ?? '',
      note: json['note'],
      status: PatientStatusExt.fromString(json['status'] ?? 'waiting'),
      assignedDoctorId: json['assigned_doctor_id'],
      chatSessionId: json['chat_session_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'symptoms': symptoms,
      'note': note,
      'status': status.value,
      'assigned_doctor_id': assignedDoctorId,
      'chat_session_id': chatSessionId,
    };
  }

  PatientModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? symptoms,
    String? note,
    PatientStatus? status,
    String? assignedDoctorId,
    String? chatSessionId,
  }) {
    return PatientModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
      status: status ?? this.status,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Tính tuổi
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        email,
        dateOfBirth,
        gender,
        address,
        symptoms,
        note,
        status,
        assignedDoctorId,
        chatSessionId,
      ];
}
