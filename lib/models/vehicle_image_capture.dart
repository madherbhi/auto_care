/// Metadata captured at vehicle photo time (GPS, compass, etc.).
class VehicleImageMetadata {
  const VehicleImageMetadata({
    required this.capturedAt,
    required this.indexNumber,
    this.latitude,
    this.longitude,
    this.altitudeMeters,
    this.speedKmh,
    this.headingDegrees,
    this.city,
    this.pincode,
    this.addressLine,
  });

  final DateTime capturedAt;
  final int indexNumber;
  final double? latitude;
  final double? longitude;
  final double? altitudeMeters;
  final double? speedKmh;
  final double? headingDegrees;
  final String? city;
  final String? pincode;
  final String? addressLine;

  VehicleImageMetadata copyWith({
    DateTime? capturedAt,
    int? indexNumber,
    double? latitude,
    double? longitude,
    double? altitudeMeters,
    double? speedKmh,
    double? headingDegrees,
    String? city,
    String? pincode,
    String? addressLine,
  }) {
    return VehicleImageMetadata(
      capturedAt: capturedAt ?? this.capturedAt,
      indexNumber: indexNumber ?? this.indexNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      speedKmh: speedKmh ?? this.speedKmh,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      addressLine: addressLine ?? this.addressLine,
    );
  }

  Map<String, dynamic> toJson() => {
        'capturedAt': capturedAt.toIso8601String(),
        'indexNumber': indexNumber,
        'latitude': latitude,
        'longitude': longitude,
        'altitudeMeters': altitudeMeters,
        'speedKmh': speedKmh,
        'headingDegrees': headingDegrees,
        'city': city,
        'pincode': pincode,
        'addressLine': addressLine,
      };

  factory VehicleImageMetadata.fromJson(Map<String, dynamic> json) {
    return VehicleImageMetadata(
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      indexNumber: json['indexNumber'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble(),
      speedKmh: (json['speedKmh'] as num?)?.toDouble(),
      headingDegrees: (json['headingDegrees'] as num?)?.toDouble(),
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      addressLine: json['addressLine'] as String?,
    );
  }
}

/// A stamped vehicle image file plus its capture metadata.
class VehicleImageCapture {
  const VehicleImageCapture({
    required this.path,
    required this.metadata,
  });

  final String path;
  final VehicleImageMetadata metadata;
}
