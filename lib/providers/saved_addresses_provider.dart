import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cafe_app/models/saved_address.dart';

/// Proveedor que gestiona direcciones guardadas con persistencia local
class SavedAddressesProvider extends ChangeNotifier {
  final List<SavedAddress> _addresses = [];
  static const String _storageKey = 'saved_addresses';
  static const String _defaultAddressKey = 'default_address_id';

  SharedPreferences? _prefs;

  // Getters públicos
  List<SavedAddress> get addresses => List.unmodifiable(_addresses);
  int get count => _addresses.length;
  bool get isEmpty => _addresses.isEmpty;
  bool get isNotEmpty => _addresses.isNotEmpty;

  SavedAddress? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return null;
    }
  }

  /// Inicializa el proveedor y carga direcciones guardadas
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAddresses();
  }

  /// Carga direcciones del almacenamiento local
  Future<void> _loadAddresses() async {
    try {
      final jsonString = _prefs?.getString(_storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        _addresses.clear();
        notifyListeners();
        return;
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      _addresses.clear();
      for (var json in jsonList) {
        _addresses.add(SavedAddress.fromJson(json as Map<String, dynamic>));
      }
      notifyListeners();
    } catch (e) {
      print('Error cargando direcciones: $e');
      _addresses.clear();
      notifyListeners();
    }
  }

  /// Guarda direcciones en almacenamiento local
  Future<void> _saveAddresses() async {
    try {
      final jsonList = _addresses.map((addr) => addr.toJson()).toList();
      await _prefs?.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error guardando direcciones: $e');
    }
  }

  /// Agrega una nueva dirección guardada
  Future<void> addAddress(SavedAddress address) async {
    // Si es la primera dirección, hacerla por defecto
    if (_addresses.isEmpty) {
      _addresses.add(address.copyWith(isDefault: true));
    } else {
      _addresses.add(address);
    }
    
    await _saveAddresses();
    notifyListeners();
  }

  /// Actualiza una dirección existente
  Future<void> updateAddress(SavedAddress address) async {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      _addresses[index] = address;
      await _saveAddresses();
      notifyListeners();
    }
  }

  /// Elimina una dirección
  Future<void> deleteAddress(String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
    
    // Si era la dirección por defecto, hacer por defecto la primera
    if (_addresses.isNotEmpty && defaultAddress == null) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    
    await _saveAddresses();
    notifyListeners();
  }

  /// Establece una dirección como por defecto
  Future<void> setDefaultAddress(String addressId) async {
    // Remover default de todas
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    
    // Establecer como default
    final index = _addresses.indexWhere((a) => a.id == addressId);
    if (index != -1) {
      _addresses[index] = _addresses[index].copyWith(isDefault: true);
      await _saveAddresses();
      notifyListeners();
    }
  }

  /// Obtiene una dirección por ID
  SavedAddress? getAddressById(String id) {
    try {
      return _addresses.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Genera un ID único para una nueva dirección
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Limpia todas las direcciones
  Future<void> clearAll() async {
    _addresses.clear();
    await _prefs?.remove(_storageKey);
    notifyListeners();
  }
}
