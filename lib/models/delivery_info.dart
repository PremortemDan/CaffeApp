import 'package:cafe_app/models/location.dart';

/// Tipos de envío disponibles
enum DeliveryType { pickup, domicile }

/// Modelo que contiene la información del envío
class DeliveryInfo {
  final DeliveryType type;
  Location? location;
  DateTime createdAt;
  DateTime? confirmedAt;

  DeliveryInfo({
    required this.type,
    this.location,
    DateTime? createdAt,
    this.confirmedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Calcula el costo de envío según la ubicación
  /// Por ahora retorna un valor fijo, puede mejorarse con lógica de distancia
  double get deliveryFee {
    if (type == DeliveryType.pickup) return 0.0;
    return 5000.0; // Costo fijo de envío en pesos
  }

  /// Verifica si el envío está completo y válido
  bool get isValid {
    if (type == DeliveryType.domicile) {
      return location != null;
    }
    return true;
  }

  /// Marca el envío como confirmado
  void confirm() {
    confirmedAt = DateTime.now();
  }

  @override
  String toString() =>
      'DeliveryInfo(type: $type, location: $location, valid: $isValid)';
}
