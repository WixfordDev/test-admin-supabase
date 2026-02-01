enum FacilityType {
  parking,
  wudu,
  toilets,
  shower,
  womenSection,
  accessibility,
  wifi,
  library,
  childcare,
  kitchen,
  conferenceRoom,
  bookstore,
}

enum FacilityAvailability {
  available,
  notAvailable,
  unknown,
  easilyAvailable,
  limitedAvailability,
}

class MosqueFacility {
  final String mosqueId;
  final FacilityType facilityType;
  final FacilityAvailability availability;
  final String? description;
  final String? additionalInfo;
  final DateTime? lastUpdated;
  final String? updatedBy;

  const MosqueFacility({
    required this.mosqueId,
    required this.facilityType,
    required this.availability,
    this.description,
    this.additionalInfo,
    this.lastUpdated,
    this.updatedBy,
  });

  // Convert to database map for Supabase
  Map<String, dynamic> toDbMap() {
    return {
      'mosque_id': mosqueId,
      'facility_type': facilityType.name,
      'availability': availability.name,
      'description': description,
      'additional_info': additionalInfo,
      'last_updated': lastUpdated?.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  // Create from database map
  factory MosqueFacility.fromDbMap(Map<String, dynamic> map) {
    return MosqueFacility(
      mosqueId: map['mosque_id'],
      facilityType: FacilityType.values.firstWhere(
        (e) => e.name == map['facility_type'],
        orElse: () => FacilityType.parking,
      ),
      availability: FacilityAvailability.values.firstWhere(
        (e) => e.name == map['availability'],
        orElse: () => FacilityAvailability.unknown,
      ),
      description: map['description'],
      additionalInfo: map['additional_info'],
      lastUpdated: map['last_updated'] != null 
          ? DateTime.parse(map['last_updated'])
          : null,
      updatedBy: map['updated_by'],
    );
  }

  MosqueFacility copyWith({
    String? mosqueId,
    FacilityType? facilityType,
    FacilityAvailability? availability,
    String? description,
    String? additionalInfo,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return MosqueFacility(
      mosqueId: mosqueId ?? this.mosqueId,
      facilityType: facilityType ?? this.facilityType,
      availability: availability ?? this.availability,
      description: description ?? this.description,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

extension FacilityTypeExtension on FacilityType {
  String get displayName {
    switch (this) {
      case FacilityType.parking:
        return 'Parking';
      case FacilityType.wudu:
        return 'Wudu/Ablution';
      case FacilityType.toilets:
        return 'Toilets';
      case FacilityType.shower:
        return 'Shower';
      case FacilityType.womenSection:
        return 'Women Section';
      case FacilityType.accessibility:
        return 'Accessibility';
      case FacilityType.wifi:
        return 'WiFi';
      case FacilityType.library:
        return 'Library';
      case FacilityType.childcare:
        return 'Childcare';
      case FacilityType.kitchen:
        return 'Kitchen';
      case FacilityType.conferenceRoom:
        return 'Conference Room';
      case FacilityType.bookstore:
        return 'Bookstore';
    }
  }

  String get category {
    switch (this) {
      case FacilityType.parking:
      case FacilityType.wudu:
      case FacilityType.toilets:
      case FacilityType.shower:
        return 'General';
      case FacilityType.womenSection:
      case FacilityType.childcare:
        return 'For Women';
      case FacilityType.accessibility:
      case FacilityType.wifi:
      case FacilityType.library:
      case FacilityType.conferenceRoom:
      case FacilityType.bookstore:
      case FacilityType.kitchen:
        return 'Accessibility';
    }
  }
}

extension FacilityAvailabilityExtension on FacilityAvailability {
  String get displayText {
    switch (this) {
      case FacilityAvailability.available:
        return 'Available';
      case FacilityAvailability.notAvailable:
        return 'Not Available';
      case FacilityAvailability.unknown:
        return 'Unknown';
      case FacilityAvailability.easilyAvailable:
        return 'Easily Available';
      case FacilityAvailability.limitedAvailability:
        return 'Limited Availability';
    }
  }

  String get description {
    switch (this) {
      case FacilityAvailability.available:
        return 'This facility is available';
      case FacilityAvailability.notAvailable:
        return 'This facility is not available';
      case FacilityAvailability.unknown:
        return 'Availability is unknown';
      case FacilityAvailability.easilyAvailable:
        return 'This facility is easily available';
      case FacilityAvailability.limitedAvailability:
        return 'This facility has limited availability';
    }
  }
} 