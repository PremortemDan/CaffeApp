import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:cafe_app/models/delivery_info.dart';
import 'package:cafe_app/models/location.dart';

/// Estados posibles del proveedor de envío
enum DeliveryState {
  initial,
  loading,
  locationGranted,
  locationDenied,
  locationError,
  success,
}

/// Proveedor que gestiona la lógica completa de envío a domicilio
/// 
/// Ciclo de vida:
/// 1. INITIAL: Estado inicial cuando se instancia
/// 2. LOADING: Solicitando permisos o ubicación
/// 3. locationGranted: Permisos aceptados
/// 4. locationDenied: Permisos negados
/// 5. locationError: Error obteniendo ubicación
/// 6. SUCCESS: Ubicación obtenida correctamente
class DeliveryProvider extends ChangeNotifier {
  // Propiedades privadas
  DeliveryState _state = DeliveryState.initial;
  DeliveryInfo? _deliveryInfo;
  String? _errorMessage;
  Location? _currentLocation;

  // Getters públicos
  DeliveryState get state => _state;
  DeliveryInfo? get deliveryInfo => _deliveryInfo;
  String? get errorMessage => _errorMessage;
  Location? get currentLocation => _currentLocation;
  bool get isLoading => _state == DeliveryState.loading;
  bool get hasLocation => _currentLocation != null;

  /// Inicializa el proveedor con un tipo de envío
  /// 
  /// Parámetri deInicio:
  /// - [initialType]: Tipo de envío inicial (pickup o domicile)
  void initialize(DeliveryType type) {
    _state = DeliveryState.initial;
    _deliveryInfo = DeliveryInfo(type: type);
    _errorMessage = null;
    _currentLocation = null;
    notifyListeners();
  }

  /// Solicita la ubicación del usuario
  /// 
  /// Pasos:
  /// 1. Verifica los permisos de ubicación
  /// 2. Solicita permisos si es necesario
  /// 3. Obtiene la posición actual
  /// 4. Decodifica las coordenadas a dirección
  /// 5. Actualiza el estado y notifica a los listeners
  Future<bool> requestLocation() async {
    _state = DeliveryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Paso 1: Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Paso 2: Solicitar permisos
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _state = DeliveryState.locationDenied;
          _errorMessage = 'Permiso de ubicación denegado';
          notifyListeners();
          return false;
        }

        if (permission == LocationPermission.deniedForever) {
          _state = DeliveryState.locationDenied;
          _errorMessage =
              'Permiso de ubicación denegado permanentemente. Habilítalo en configuración.';
          notifyListeners();
          return false;
        }
      }

      _state = DeliveryState.locationGranted;
      notifyListeners();

      // Paso 3: Obtener posición actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      // Paso 4: Decodificar coordenadas a dirección
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final placemark = placemarks.isNotEmpty ? placemarks[0] : null;

      // Paso 5: Crear objeto Location
      _currentLocation = Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address: placemark?.street,
        city: placemark?.locality,
        postalCode: placemark?.postalCode,
        fetchedAt: DateTime.now(),
      );

      // Actualizar la información de envío
      if (_deliveryInfo != null) {
        _deliveryInfo!.location = _currentLocation;
      }

      _state = DeliveryState.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _state = DeliveryState.locationError;
      _errorMessage = 'Error obteniendo ubicación: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Cambia el tipo de envío entre pickup y domicile
  void setDeliveryType(DeliveryType type) {
    if (_deliveryInfo != null) {
      _deliveryInfo = DeliveryInfo(
        type: type,
        location: type == DeliveryType.domicile ? _deliveryInfo!.location : null,
      );
      notifyListeners();
    }
  }

  /// Establece la ubicación desde una dirección guardada
  void setLocationFromSavedAddress(Location location) {
    _currentLocation = location;
    _state = DeliveryState.success;
    _errorMessage = null;
    notifyListeners();

    // Actualizar la información de envío
    if (_deliveryInfo != null) {
      _deliveryInfo!.location = location;
      notifyListeners();
    }
  }

  /// Confirma la información del envío
  /// Marca la hora de confirmación y prepara para el checkout
  bool confirmDelivery() {
    if (_deliveryInfo == null || !_deliveryInfo!.isValid) {
      _errorMessage = 'Información de envío incompleta';
      return false;
    }

    _deliveryInfo!.confirm();
    notifyListeners();
    return true;
  }

  /// Reinicia el estado del proveedor
  void reset() {
    _state = DeliveryState.initial;
    _deliveryInfo = null;
    _errorMessage = null;
    _currentLocation = null;
    notifyListeners();
  }

  /// Limpia los recursos cuando el proveedor ya no se necesita
  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
