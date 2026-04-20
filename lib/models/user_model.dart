import 'package:equatable/equatable.dart';

/// Model người dùng
class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String role; // 'patient', 'doctor', 'admin'
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.role = 'patient',
    this.isProfileComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'patient',
      isProfileComplete: json['is_profile_complete'] ?? (json['role'] == 'patient'), // Patients are complete by default for now
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
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'is_profile_complete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? role,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, fullName, email, phone, avatarUrl, role, isProfileComplete, createdAt, updatedAt];
}
