/// Modelo que representa una dirección guardada por el usuario
class SavedAddress {
  final String id;
  final String name; // Ej: "Casa", "Oficina", "Mi departamento"
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? postalCode;
  final DateTime createdAt;
  bool isDefault;

  SavedAddress({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.postalCode,
    DateTime? createdAt,
    this.isDefault = false,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  /// Crea desde JSON
  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Retorna la dirección formateada
  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (postalCode != null) parts.add(postalCode!);
    return parts.isNotEmpty ? parts.join(', ') : '$latitude, $longitude';
  }

  /// Copia con cambios
  SavedAddress copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? postalCode,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() =>
      'SavedAddress(id: $id, name: $name, address: $address)';
}
