import 'package:flutter/foundation.dart';
import 'package:cafe_app/models/product.dart';
import 'package:cafe_app/models/cart_item.dart';
import 'package:cafe_app/models/delivery_info.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  DeliveryInfo? _deliveryInfo;

  Map<String, CartItem> get items => Map.unmodifiable(_items);
  DeliveryInfo? get deliveryInfo => _deliveryInfo;

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.total);

  double get deliveryFee => _deliveryInfo?.deliveryFee ?? 0.0;

  double get totalPrice => subtotal + deliveryFee;

  bool contains(String productId) => _items.containsKey(productId);

  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId]!.quantity--;
    }
    notifyListeners();
  }

  /// Establece la información de envío
  void setDeliveryInfo(DeliveryInfo deliveryInfo) {
    _deliveryInfo = deliveryInfo;
    notifyListeners();
  }

  /// Obtiene la información de envío formateada
  String get deliveryTypeLabel {
    if (_deliveryInfo == null) return 'No especificado';
    return _deliveryInfo!.type.toString().split('.').last == 'pickup'
        ? 'Recogida en tienda'
        : 'Envío a domicilio';
  }

  void clear() {
    _items.clear();
    _deliveryInfo = null;
    notifyListeners();
  }
}

