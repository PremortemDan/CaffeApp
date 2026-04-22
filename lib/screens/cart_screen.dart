import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafe_app/providers/cart_provider.dart';
import 'package:cafe_app/providers/delivery_provider.dart';
import 'package:cafe_app/models/delivery_info.dart';
import 'package:cafe_app/screens/delivery_selection_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E2D1E),
        title: Text(
          'Mi Carrito',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.items.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmClear(context, cart),
                    child: const Text(
                      'Vaciar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C1A0E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega productos desde el menú',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.15), width: 0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5E6D3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  item.product.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Color(0xFF2C1A0E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)} c/u',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _CartQtyBtn(
                                  icon: Icons.remove,
                                  onTap: () => cart.decreaseQuantity(
                                      item.product.id),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                _CartQtyBtn(
                                  icon: Icons.add,
                                  onTap: () =>
                                      cart.addItem(item.product),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '\$${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFFC8943A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Order summary + checkout
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Consumer<DeliveryProvider>(
                  builder: (context, deliveryProvider, _) {
                    return Column(
                      children: [
                        // Información de envío
                        _buildDeliverySection(context, cart, deliveryProvider),
                        const SizedBox(height: 16),
                        // Desglose de precios
                        _buildPriceBreakdown(cart),
                        const SizedBox(height: 16),
                        // Botón confirmar
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: cart.deliveryInfo == null
                                ? null
                                : () => _showOrderConfirmation(context, cart),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E2D1E),
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              cart.deliveryInfo == null
                                  ? 'Selecciona tipo de envío'
                                  : '✓  Confirmar pedido',
                              style: TextStyle(
                                color: cart.deliveryInfo == null
                                    ? Colors.grey[600]
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Vaciar carrito?'),
        content: const Text('Se eliminarán todos los productos del carrito.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: const Text('Vaciar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de selección de envío
  Widget _buildDeliverySection(
    BuildContext context,
    CartProvider cart,
    DeliveryProvider deliveryProvider,
  ) {
    final deliveryInfo = cart.deliveryInfo;

    return GestureDetector(
      onTap: () {
        // Inicializar el proveedor de envío con el tipo actual
        deliveryProvider.initialize(
          deliveryInfo?.type ?? DeliveryType.pickup,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeliverySelectionScreen(
              onConfirm: () {
                // Guardar la información de envío en el carrito
                if (deliveryProvider.deliveryInfo != null) {
                  cart.setDeliveryInfo(deliveryProvider.deliveryInfo!);
                }
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: deliveryInfo == null
              ? Colors.orange.withOpacity(0.1)
              : const Color(0xFF4E2D1E).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: deliveryInfo == null
                ? Colors.orange.withOpacity(0.3)
                : const Color(0xFF4E2D1E).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              deliveryInfo?.type == DeliveryType.domicile
                  ? Icons.location_on
                  : Icons.store,
              color: deliveryInfo == null ? Colors.orange : Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deliveryInfo == null ? 'Selecciona tipo de envío' : 'Tipo de envío',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deliveryInfo == null ? 'Requerido' : cart.deliveryTypeLabel,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C1A0E),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el desglose de precios
  Widget _buildPriceBreakdown(CartProvider cart) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${cart.itemCount} producto${cart.itemCount != 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              '\$${cart.subtotal.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (cart.deliveryFee > 0) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Costo de envío',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                '\$${cart.deliveryFee.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1A0E),
              ),
            ),
            Text(
              '\$${cart.totalPrice.toStringAsFixed(2)}',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4E2D1E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showOrderConfirmation(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(
              '¡Pedido confirmado!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu pedido por \$${cart.totalPrice.toStringAsFixed(2)} está en preparación.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    cart.deliveryInfo?.type == DeliveryType.domicile
                        ? Icons.location_on
                        : Icons.store,
                    size: 18,
                    color: const Color(0xFF4E2D1E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cart.deliveryTypeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C1A0E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  cart.clear();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E2D1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Aceptar',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CartQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CartQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF4E2D1E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF4E2D1E)),
      ),
    );
  }
}
