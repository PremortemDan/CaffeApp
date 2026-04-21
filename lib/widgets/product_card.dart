import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafe_app/models/product.dart';
import 'package:cafe_app/providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.grey.withOpacity(0.15), width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji container
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Hero(
                    tag: 'product-${product.id}',
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2C1A0E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                product.category,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFFC8943A),
                    ),
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return GestureDetector(
                        onTap: () {
                          cart.addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} agregado ✓'),
                              backgroundColor: const Color(0xFF4E2D1E),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cart.contains(product.id)
                                ? const Color(0xFF4E2D1E)
                                : const Color(0xFF4E2D1E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            cart.contains(product.id)
                                ? Icons.shopping_cart
                                : Icons.add,
                            size: 16,
                            color: cart.contains(product.id)
                                ? Colors.white
                                : const Color(0xFF4E2D1E),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
