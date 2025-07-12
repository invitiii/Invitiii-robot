import 'package:json_annotation/json_annotation.dart';
import 'guest.dart';
import 'rsvp.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final String id;
  final String name;
  final DateTime date;
  final String time;
  final String venue;
  final String description;
  final String? coverImageUrl;
  final String? coverVideoUrl;
  final String hostId;
  final List<Guest> guests;
  final List<RSVP> rsvps;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.venue,
    this.description = '',
    this.coverImageUrl,
    this.coverVideoUrl,
    required this.hostId,
    this.guests = const [],
    this.rsvps = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties for RSVP statistics
  int get totalGuests => guests.length;

  int get confirmedCount => rsvps.where((rsvp) => rsvp.status == RSVPStatus.yes).length;

  int get declinedCount => rsvps.where((rsvp) => rsvp.status == RSVPStatus.no).length;

  int get maybeCount => rsvps.where((rsvp) => rsvp.status == RSVPStatus.maybe).length;

  int get pendingCount => totalGuests - confirmedCount - declinedCount - maybeCount;

  double get rsvpRate {
    if (totalGuests == 0) return 0.0;
    return (confirmedCount + declinedCount + maybeCount) / totalGuests * 100;
  }

  int get checkedInCount => rsvps.where((rsvp) => rsvp.qrCodeUsed).length;

  double get confirmationRate {
    if (totalGuests == 0) return 0.0;
    return confirmedCount / totalGuests * 100;
  }

  bool get hasMedia => coverImageUrl != null || coverVideoUrl != null;

  bool get isUpcoming => date.isAfter(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get shortFormattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Factory constructor for JSON deserialization
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$EventToJson(this);

  // Copy with method for immutability
  Event copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? time,
    String? venue,
    String? description,
    String? coverImageUrl,
    String? coverVideoUrl,
    String? hostId,
    List<Guest>? guests,
    List<RSVP>? rsvps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverVideoUrl: coverVideoUrl ?? this.coverVideoUrl,
      hostId: hostId ?? this.hostId,
      guests: guests ?? this.guests,
      rsvps: rsvps ?? this.rsvps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Event{id: $id, name: $name, date: $date, venue: $venue}';
  }
}

// Sample events for testing and previews
class SampleEvents {
  static final List<Event> sampleEvents = [
    Event(
      id: 'event_001',
      name: 'Sarah\'s Wedding',
      date: DateTime.now().add(const Duration(days: 30)),
      time: '18:00',
      venue: 'The Grand Hotel, Kuwait City',
      description: 'Join us for a magical evening as we celebrate our special day!',
      hostId: 'host_001',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      guests: SampleGuests.sampleGuests,
      rsvps: SampleRSVPs.sampleRSVPs,
    ),
    Event(
      id: 'event_002',
      name: 'Corporate Gala',
      date: DateTime.now().add(const Duration(days: 45)),
      time: '19:30',
      venue: 'Four Seasons Hotel, Riyadh',
      description: 'Annual corporate celebration and awards ceremony.',
      hostId: 'host_001',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    Event(
      id: 'event_003',
      name: 'Birthday Celebration',
      date: DateTime.now().add(const Duration(days: 15)),
      time: '15:00',
      venue: 'Private Villa, Dubai',
      description: 'Celebrating Ahmed\'s 30th birthday with friends and family.',
      hostId: 'host_001',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
  ];

  static Event get sampleEvent => sampleEvents.first;
}

// Event creation request model
@JsonSerializable()
class CreateEventRequest {
  final String name;
  final DateTime date;
  final String time;
  final String venue;
  final String description;
  final String? coverImageUrl;
  final String? coverVideoUrl;

  CreateEventRequest({
    required this.name,
    required this.date,
    required this.time,
    required this.venue,
    this.description = '',
    this.coverImageUrl,
    this.coverVideoUrl,
  });

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateEventRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateEventRequestToJson(this);
}

// Event update request model
@JsonSerializable()
class UpdateEventRequest {
  final String? name;
  final DateTime? date;
  final String? time;
  final String? venue;
  final String? description;
  final String? coverImageUrl;
  final String? coverVideoUrl;

  UpdateEventRequest({
    this.name,
    this.date,
    this.time,
    this.venue,
    this.description,
    this.coverImageUrl,
    this.coverVideoUrl,
  });

  factory UpdateEventRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateEventRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateEventRequestToJson(this);
}