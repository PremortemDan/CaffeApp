/// Modelo que representa la ubicación geográfica del usuario
class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? postalCode;
  final DateTime fetchedAt;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.postalCode,
    required this.fetchedAt,
  });

  /// Retorna la ubicación formateada como string
  String get formattedLocation {
    return address ?? '$latitude, $longitude';
  }

  /// Retorna la ubicación completa con detalles
  String get fullDetails {
    final details = <String>[];
    if (address != null) details.add(address!);
    if (city != null) details.add(city!);
    if (postalCode != null) details.add(postalCode!);
    return details.isNotEmpty ? details.join(', ') : formattedLocation;
  }

  /// Alias para fullDetails (compatible con SavedAddress)
  String get fullAddress => fullDetails;

  @override
  String toString() =>
      'Location(lat: $latitude, lng: $longitude, address: $address)';
}
