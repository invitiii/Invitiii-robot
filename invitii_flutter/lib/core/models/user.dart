import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue('host')
  host,
  @JsonValue('door_staff')
  doorStaff,
  @JsonValue('admin')
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.host:
        return 'Host';
      case UserRole.doorStaff:
        return 'Door Staff';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.host:
        return 'Can create events, manage guests, and view analytics';
      case UserRole.doorStaff:
        return 'Can scan QR codes and check-in guests';
      case UserRole.admin:
        return 'Full access to all features';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.host:
        return Icons.event;
      case UserRole.doorStaff:
        return Icons.qr_code_scanner;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.host:
        return const Color(0xFF7B2CBF);
      case UserRole.doorStaff:
        return const Color(0xFF4361EE);
      case UserRole.admin:
        return const Color(0xFFEF476F);
    }
  }

  // Permissions
  bool get canCreateEvents {
    switch (this) {
      case UserRole.host:
      case UserRole.admin:
        return true;
      case UserRole.doorStaff:
        return false;
    }
  }

  bool get canManageGuests {
    switch (this) {
      case UserRole.host:
      case UserRole.admin:
        return true;
      case UserRole.doorStaff:
        return false;
    }
  }

  bool get canScanQRCodes {
    return true; // All roles can scan QR codes
  }

  bool get canViewAnalytics {
    switch (this) {
      case UserRole.host:
      case UserRole.admin:
        return true;
      case UserRole.doorStaff:
        return false;
    }
  }

  bool get canManageUsers {
    switch (this) {
      case UserRole.admin:
        return true;
      case UserRole.host:
      case UserRole.doorStaff:
        return false;
    }
  }
}

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final String? profileImageUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.role = UserRole.host,
    this.profileImageUrl,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.lastLoginAt,
  });

  // Computed properties
  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  String get firstName {
    final words = name.trim().split(' ');
    return words.isNotEmpty ? words[0] : '';
  }

  String get displayName => firstName.isNotEmpty ? firstName : name;

  bool get hasProfileImage => profileImageUrl != null && profileImageUrl!.isNotEmpty;

  String get lastSeenFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt);

    if (difference.inMinutes < 1) {
      return 'Online';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  // Permission helpers
  bool get canCreateEvents => role.canCreateEvents;
  bool get canManageGuests => role.canManageGuests;
  bool get canScanQRCodes => role.canScanQRCodes;
  bool get canViewAnalytics => role.canViewAnalytics;
  bool get canManageUsers => role.canManageUsers;

  // Factory constructor for JSON deserialization
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Copy with method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profileImageUrl,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, role: $role}';
  }
}

// Authentication models
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => 
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => 
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final User user;
  final String token;
  final String refreshToken;
  final DateTime expiresAt;

  AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AuthResponse.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => 
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  final String? name;
  final String? phoneNumber;
  final String? profileImageUrl;

  UpdateProfileRequest({
    this.name,
    this.phoneNumber,
    this.profileImageUrl,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable()
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => 
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) => 
      _$ForgotPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => 
      _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

// Sample users for testing
class SampleUsers {
  static final User sampleHost = User(
    id: 'user_001',
    name: 'Sarah Al-Mansouri',
    email: 'sarah@invitii.com',
    phoneNumber: '+96512345678',
    role: UserRole.host,
    isVerified: true,
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    lastLoginAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  static final User sampleDoorStaff = User(
    id: 'user_002',
    name: 'Ahmed Al-Kuwaiti',
    email: 'ahmed@invitii.com',
    phoneNumber: '+96512345679',
    role: UserRole.doorStaff,
    isVerified: true,
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  static final User sampleAdmin = User(
    id: 'user_003',
    name: 'Fatima Al-Zahra',
    email: 'fatima@invitii.com',
    phoneNumber: '+96512345680',
    role: UserRole.admin,
    isVerified: true,
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    lastLoginAt: DateTime.now().subtract(const Duration(minutes: 1)),
  );
}