import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

part 'rsvp.g.dart';

enum RSVPStatus {
  @JsonValue('yes')
  yes,
  @JsonValue('no')
  no,
  @JsonValue('maybe')
  maybe,
  @JsonValue('pending')
  pending,
}

extension RSVPStatusExtension on RSVPStatus {
  String get displayName {
    switch (this) {
      case RSVPStatus.yes:
        return 'Yes';
      case RSVPStatus.no:
        return 'No';
      case RSVPStatus.maybe:
        return 'Maybe';
      case RSVPStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case RSVPStatus.yes:
        return AppTheme.rsvpYesColor;
      case RSVPStatus.no:
        return AppTheme.rsvpNoColor;
      case RSVPStatus.maybe:
        return AppTheme.rsvpMaybeColor;
      case RSVPStatus.pending:
        return AppTheme.rsvpPendingColor;
    }
  }

  IconData get icon {
    switch (this) {
      case RSVPStatus.yes:
        return Icons.check_circle;
      case RSVPStatus.no:
        return Icons.cancel;
      case RSVPStatus.maybe:
        return Icons.help_outline;
      case RSVPStatus.pending:
        return Icons.schedule;
    }
  }

  String get emoji {
    switch (this) {
      case RSVPStatus.yes:
        return '✅';
      case RSVPStatus.no:
        return '❌';
      case RSVPStatus.maybe:
        return '🤔';
      case RSVPStatus.pending:
        return '⏳';
    }
  }
}

@JsonSerializable()
class RSVP {
  final String id;
  final String guestId;
  final String eventId;
  final RSVPStatus status;
  final String? message;
  final String? qrCode;
  final bool qrCodeUsed;
  final DateTime? qrCodeUsedAt;
  final DateTime respondedAt;
  final DateTime createdAt;

  // Guest information (denormalized for easier querying)
  final String guestName;
  final String guestPhone;

  RSVP({
    required this.id,
    required this.guestId,
    required this.eventId,
    required this.status,
    this.message,
    this.qrCode,
    this.qrCodeUsed = false,
    this.qrCodeUsedAt,
    required this.respondedAt,
    required this.createdAt,
    required this.guestName,
    required this.guestPhone,
  });

  // Computed properties
  bool get hasQRCode => qrCode != null && qrCode!.isNotEmpty;

  bool get canCheckIn => status == RSVPStatus.yes && hasQRCode && !qrCodeUsed;

  String get responseTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(respondedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
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

  String get formattedResponseTime {
    return '${respondedAt.day}/${respondedAt.month}/${respondedAt.year} at ${respondedAt.hour}:${respondedAt.minute.toString().padLeft(2, '0')}';
  }

  // Factory constructor for JSON deserialization
  factory RSVP.fromJson(Map<String, dynamic> json) => _$RSVPFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$RSVPToJson(this);

  // Copy with method for immutability
  RSVP copyWith({
    String? id,
    String? guestId,
    String? eventId,
    RSVPStatus? status,
    String? message,
    String? qrCode,
    bool? qrCodeUsed,
    DateTime? qrCodeUsedAt,
    DateTime? respondedAt,
    DateTime? createdAt,
    String? guestName,
    String? guestPhone,
  }) {
    return RSVP(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      eventId: eventId ?? this.eventId,
      status: status ?? this.status,
      message: message ?? this.message,
      qrCode: qrCode ?? this.qrCode,
      qrCodeUsed: qrCodeUsed ?? this.qrCodeUsed,
      qrCodeUsedAt: qrCodeUsedAt ?? this.qrCodeUsedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RSVP && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RSVP{id: $id, guestName: $guestName, status: $status}';
  }
}

// QR Code Scan Result
class QRScanResult {
  final String rsvpId;
  final String eventId;
  final String guestName;
  final bool isValid;
  final bool isAlreadyUsed;
  final String? errorMessage;

  QRScanResult({
    required this.rsvpId,
    required this.eventId,
    required this.guestName,
    required this.isValid,
    required this.isAlreadyUsed,
    this.errorMessage,
  });

  factory QRScanResult.success({
    required String rsvpId,
    required String eventId,
    required String guestName,
  }) {
    return QRScanResult(
      rsvpId: rsvpId,
      eventId: eventId,
      guestName: guestName,
      isValid: true,
      isAlreadyUsed: false,
    );
  }

  factory QRScanResult.alreadyUsed({
    required String rsvpId,
    required String eventId,
    required String guestName,
  }) {
    return QRScanResult(
      rsvpId: rsvpId,
      eventId: eventId,
      guestName: guestName,
      isValid: false,
      isAlreadyUsed: true,
      errorMessage: 'QR code has already been used',
    );
  }

  factory QRScanResult.invalid({required String errorMessage}) {
    return QRScanResult(
      rsvpId: '',
      eventId: '',
      guestName: '',
      isValid: false,
      isAlreadyUsed: false,
      errorMessage: errorMessage,
    );
  }

  Color get statusColor {
    if (isValid && !isAlreadyUsed) return AppTheme.successColor;
    if (isAlreadyUsed) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  IconData get statusIcon {
    if (isValid && !isAlreadyUsed) return Icons.check_circle;
    if (isAlreadyUsed) return Icons.warning;
    return Icons.error;
  }

  String get statusTitle {
    if (isValid && !isAlreadyUsed) return 'Valid Entry';
    if (isAlreadyUsed) return 'Already Used';
    return 'Invalid QR Code';
  }

  String get statusDescription {
    if (isValid && !isAlreadyUsed) return 'Guest has been checked in successfully';
    if (isAlreadyUsed) return 'This guest has already been checked in';
    return errorMessage ?? 'Please verify the QR code and try again';
  }
}

// Sample RSVPs for testing
class SampleRSVPs {
  static final List<RSVP> sampleRSVPs = [
    RSVP(
      id: 'rsvp_001',
      guestId: 'guest_001',
      eventId: 'event_001',
      status: RSVPStatus.yes,
      message: 'Can\'t wait to celebrate with you!',
      qrCode: 'QR_12345678',
      qrCodeUsed: false,
      respondedAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      guestName: 'Ahmed Al-Rashid',
      guestPhone: '+96512345678',
    ),
    RSVP(
      id: 'rsvp_002',
      guestId: 'guest_002',
      eventId: 'event_001',
      status: RSVPStatus.no,
      message: 'Unfortunately won\'t be able to make it',
      respondedAt: DateTime.now().subtract(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      guestName: 'Fatima Al-Zahra',
      guestPhone: '+96512345679',
    ),
    RSVP(
      id: 'rsvp_003',
      guestId: 'guest_003',
      eventId: 'event_001',
      status: RSVPStatus.maybe,
      message: 'Will try my best to attend',
      respondedAt: DateTime.now().subtract(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      guestName: 'Mohammed Al-Kuwaiti',
      guestPhone: '+96512345680',
    ),
    RSVP(
      id: 'rsvp_004',
      guestId: 'guest_004',
      eventId: 'event_001',
      status: RSVPStatus.yes,
      message: 'Looking forward to it!',
      qrCode: 'QR_87654321',
      qrCodeUsed: true,
      qrCodeUsedAt: DateTime.now().subtract(const Duration(hours: 1)),
      respondedAt: DateTime.now().subtract(const Duration(hours: 8)),
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      guestName: 'Aisha Al-Mansouri',
      guestPhone: '+97150123456',
    ),
  ];
}

// RSVP submission request model
@JsonSerializable()
class SubmitRSVPRequest {
  final String guestId;
  final String eventId;
  final RSVPStatus status;
  final String? message;

  SubmitRSVPRequest({
    required this.guestId,
    required this.eventId,
    required this.status,
    this.message,
  });

  factory SubmitRSVPRequest.fromJson(Map<String, dynamic> json) => 
      _$SubmitRSVPRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitRSVPRequestToJson(this);
}

// QR Code validation request model
@JsonSerializable()
class QRValidationRequest {
  final String qrCode;
  final String eventId;

  QRValidationRequest({
    required this.qrCode,
    required this.eventId,
  });

  factory QRValidationRequest.fromJson(Map<String, dynamic> json) => 
      _$QRValidationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QRValidationRequestToJson(this);
}

// QR Code validation response model
@JsonSerializable()
class QRValidationResponse {
  final bool isValid;
  final bool isAlreadyUsed;
  final String? guestName;
  final String? rsvpId;
  final String? errorMessage;

  QRValidationResponse({
    required this.isValid,
    required this.isAlreadyUsed,
    this.guestName,
    this.rsvpId,
    this.errorMessage,
  });

  factory QRValidationResponse.fromJson(Map<String, dynamic> json) => 
      _$QRValidationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QRValidationResponseToJson(this);

  QRScanResult toScanResult(String eventId) {
    if (isValid && !isAlreadyUsed) {
      return QRScanResult.success(
        rsvpId: rsvpId!,
        eventId: eventId,
        guestName: guestName!,
      );
    } else if (isAlreadyUsed) {
      return QRScanResult.alreadyUsed(
        rsvpId: rsvpId!,
        eventId: eventId,
        guestName: guestName!,
      );
    } else {
      return QRScanResult.invalid(
        errorMessage: errorMessage ?? 'Invalid QR code',
      );
    }
  }
}

// QR Code usage request model
@JsonSerializable()
class QRUseRequest {
  final String rsvpId;

  QRUseRequest({required this.rsvpId});

  factory QRUseRequest.fromJson(Map<String, dynamic> json) => 
      _$QRUseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QRUseRequestToJson(this);
}