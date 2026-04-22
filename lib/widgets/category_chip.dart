import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  String get _emoji {
    switch (label) {
      case 'Bebidas':
        return '☕ ';
      case 'Snacks':
        return '🥐 ';
      case 'Postres':
        return '🍰 ';
      case 'Especiales':
        return '⭐ ';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4E2D1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4E2D1E)
                : Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          '$_emoji$label',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4E2D1E),
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
