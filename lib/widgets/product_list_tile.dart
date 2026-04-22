import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafe_app/models/product.dart';
import 'package:cafe_app/providers/cart_provider.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductListTile(
      {super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.grey.withOpacity(0.15), width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(product.emoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF2C1A0E),
                          ),
                        ),
                        if (product.isFeatured) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFC8943A).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '⭐ Top',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFC8943A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFFC8943A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Consumer<CartProvider>(
                builder: (context, cart, _) => GestureDetector(
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cart.contains(product.id)
                          ? const Color(0xFF4E2D1E)
                          : const Color(0xFF4E2D1E).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      cart.contains(product.id)
                          ? Icons.check
                          : Icons.add,
                      size: 18,
                      color: cart.contains(product.id)
                          ? Colors.white
                          : const Color(0xFF4E2D1E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
