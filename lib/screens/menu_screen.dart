import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafe_app/models/product.dart';
import 'package:cafe_app/screens/detail_screen.dart';
import 'package:cafe_app/widgets/product_list_tile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ProductData.categories.where((c) => c != 'Todos').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E2D1E),
        title: Text(
          'Menú Completo',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: categories.map((category) {
          final products = ProductData.byCategory(category);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Text(
                      _categoryEmoji(category),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C1A0E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8943A).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${products.length}',
                        style: const TextStyle(
                          color: Color(0xFFC8943A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...products.map(
                (p) => ProductListTile(
                  product: p,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(product: p),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat) {
      case 'Bebidas':
        return '☕';
      case 'Snacks':
        return '🥐';
      case 'Postres':
        return '🍰';
      case 'Especiales':
        return '⭐';
      default:
        return '🍽️';
    }
  }
}
