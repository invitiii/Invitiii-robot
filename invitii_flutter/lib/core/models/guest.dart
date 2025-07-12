import 'package:json_annotation/json_annotation.dart';
import 'package:validators/validators.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

part 'guest.g.dart';

@JsonSerializable()
class Guest {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String eventId;
  final String? rsvpLink;
  final String? qrCode;
  final bool hasOpened;
  final DateTime? invitationSentAt;
  final DateTime createdAt;

  Guest({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.eventId,
    this.rsvpLink,
    this.qrCode,
    this.hasOpened = false,
    this.invitationSentAt,
    required this.createdAt,
  });

  // Computed properties
  String get formattedPhoneNumber {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If it doesn't start with +, assume it's a GCC number and add +965 (Kuwait)
    if (!cleaned.startsWith('+')) {
      cleaned = '${AppConstants.defaultCountryCode}$cleaned';
    }
    
    return cleaned;
  }

  bool get isValidPhoneNumber {
    final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(formattedPhoneNumber);
  }

  bool get isValidEmail {
    if (email == null || email!.isEmpty) return true; // Email is optional
    return isEmail(email!);
  }

  bool get hasValidContact => isValidPhoneNumber && isValidEmail;

  String get displayPhoneNumber {
    final formatted = formattedPhoneNumber;
    if (formatted.startsWith('+965')) {
      // Kuwait format: +965 1234 5678
      final number = formatted.substring(4);
      if (number.length == 8) {
        return '+965 ${number.substring(0, 4)} ${number.substring(4)}';
      }
    } else if (formatted.startsWith('+966')) {
      // Saudi Arabia format: +966 50 123 4567
      final number = formatted.substring(4);
      if (number.length == 9) {
        return '+966 ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
      }
    }
    return formatted; // Fallback to original format
  }

  String get invitationStatus {
    if (invitationSentAt == null) return 'Not Sent';
    if (hasOpened) return 'Opened';
    return 'Sent';
  }

  Color get invitationStatusColor {
    switch (invitationStatus) {
      case 'Opened':
        return const Color(0xFF06D6A0); // Green
      case 'Sent':
        return const Color(0xFF4361EE); // Blue
      default:
        return const Color(0xFF9CA3AF); // Gray
    }
  }

  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  // Factory constructor for JSON deserialization
  factory Guest.fromJson(Map<String, dynamic> json) => _$GuestFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$GuestToJson(this);

  // Copy with method for immutability
  Guest copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? eventId,
    String? rsvpLink,
    String? qrCode,
    bool? hasOpened,
    DateTime? invitationSentAt,
    DateTime? createdAt,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      eventId: eventId ?? this.eventId,
      rsvpLink: rsvpLink ?? this.rsvpLink,
      qrCode: qrCode ?? this.qrCode,
      hasOpened: hasOpened ?? this.hasOpened,
      invitationSentAt: invitationSentAt ?? this.invitationSentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Guest && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Guest{id: $id, name: $name, phoneNumber: $phoneNumber}';
  }
}

// CSV Import functionality
class GuestImportData {
  final String name;
  final String phoneNumber;
  final String? email;
  final bool isValid;
  final List<String> errors;

  GuestImportData({
    required this.name,
    required this.phoneNumber,
    this.email,
    this.isValid = true,
    this.errors = const [],
  });

  static List<GuestImportData> parseCSV(String csvContent) {
    final List<GuestImportData> guests = [];
    final lines = csvContent.split('\n');
    
    // Skip header row if present
    final dataLines = lines.length > 1 && 
        lines[0].toLowerCase().contains('name') ? 
        lines.skip(1) : lines;
    
    for (int i = 0; i < dataLines.length; i++) {
      final line = dataLines.elementAt(i).trim();
      if (line.isEmpty) continue;
      
      final columns = line.split(',');
      if (columns.length < 2) continue;
      
      final name = columns[0].trim().replaceAll('"', '');
      final phone = columns[1].trim().replaceAll('"', '');
      final email = columns.length > 2 ? 
          columns[2].trim().replaceAll('"', '') : null;
      
      final errors = <String>[];
      
      // Validate name
      if (name.isEmpty) {
        errors.add('Name is required');
      }
      
      // Validate phone
      if (phone.isEmpty) {
        errors.add('Phone number is required');
      } else {
        final tempGuest = Guest(
          id: 'temp',
          name: name,
          phoneNumber: phone,
          eventId: 'temp',
          createdAt: DateTime.now(),
        );
        if (!tempGuest.isValidPhoneNumber) {
          errors.add('Invalid phone number format');
        }
      }
      
      // Validate email (if provided)
      if (email != null && email.isNotEmpty && !isEmail(email)) {
        errors.add('Invalid email format');
      }
      
      guests.add(GuestImportData(
        name: name,
        phoneNumber: phone,
        email: email?.isEmpty == true ? null : email,
        isValid: errors.isEmpty,
        errors: errors,
      ));
    }
    
    return guests;
  }

  Guest toGuest(String eventId) {
    return Guest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      eventId: eventId,
      createdAt: DateTime.now(),
    );
  }
}

// Sample guests for testing
class SampleGuests {
  static final List<Guest> sampleGuests = [
    Guest(
      id: 'guest_001',
      name: 'Ahmed Al-Rashid',
      phoneNumber: '+96512345678',
      email: 'ahmed@example.com',
      eventId: 'event_001',
      hasOpened: true,
      invitationSentAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Guest(
      id: 'guest_002',
      name: 'Fatima Al-Zahra',
      phoneNumber: '+96512345679',
      email: 'fatima@example.com',
      eventId: 'event_001',
      hasOpened: false,
      invitationSentAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Guest(
      id: 'guest_003',
      name: 'Mohammed Al-Kuwaiti',
      phoneNumber: '+96512345680',
      eventId: 'event_001',
      hasOpened: true,
      invitationSentAt: DateTime.now().subtract(const Duration(hours: 12)),
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Guest(
      id: 'guest_004',
      name: 'Aisha Al-Mansouri',
      phoneNumber: '+97150123456',
      email: 'aisha@example.com',
      eventId: 'event_001',
      hasOpened: true,
      invitationSentAt: DateTime.now().subtract(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Guest(
      id: 'guest_005',
      name: 'Omar Al-Saudi',
      phoneNumber: '+966501234567',
      email: 'omar@example.com',
      eventId: 'event_001',
      hasOpened: false,
      invitationSentAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}

// Guest creation request model
@JsonSerializable()
class CreateGuestRequest {
  final String name;
  final String phoneNumber;
  final String? email;
  final String eventId;

  CreateGuestRequest({
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.eventId,
  });

  factory CreateGuestRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateGuestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGuestRequestToJson(this);
}

// Bulk import request model
@JsonSerializable()
class BulkImportGuestsRequest {
  final String eventId;
  final List<CreateGuestRequest> guests;

  BulkImportGuestsRequest({
    required this.eventId,
    required this.guests,
  });

  factory BulkImportGuestsRequest.fromJson(Map<String, dynamic> json) => 
      _$BulkImportGuestsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BulkImportGuestsRequestToJson(this);
}