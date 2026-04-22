class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String emoji;
  final String category;
  final bool isFeatured;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.category,
    this.isFeatured = false,
  });
}

class ProductData {
  static const List<Product> products = [
    // Bebidas
    Product(
      id: 'p1',
      name: 'Cappuccino',
      description: 'Espresso con leche vaporizada y espuma cremosa. El clásico italiano.',
      price: 2.50,
      emoji: '☕',
      category: 'Bebidas',
      isFeatured: true,
    ),
    Product(
      id: 'p2',
      name: 'Latte',
      description: 'Espresso suave con mucha leche vaporizada. Perfecto para cualquier momento.',
      price: 2.80,
      emoji: '🥛',
      category: 'Bebidas',
      isFeatured: true,
    ),
    Product(
      id: 'p3',
      name: 'Americano',
      description: 'Espresso con agua caliente. Intenso y sin complicaciones.',
      price: 2.00,
      emoji: '☕',
      category: 'Bebidas',
    ),
    Product(
      id: 'p4',
      name: 'Té Verde',
      description: 'Té verde japonés con notas herbales y frescas.',
      price: 1.80,
      emoji: '🍵',
      category: 'Bebidas',
    ),
    Product(
      id: 'p5',
      name: 'Chocolate Caliente',
      description: 'Chocolate artesanal con leche entera. Reconfortante y delicioso.',
      price: 3.00,
      emoji: '🍫',
      category: 'Bebidas',
      isFeatured: true,
    ),
    Product(
      id: 'p6',
      name: 'Frappé de Café',
      description: 'Café helado batido con crema. Refrescante y energizante.',
      price: 3.50,
      emoji: '🧋',
      category: 'Bebidas',
    ),
    // Snacks
    Product(
      id: 'p7',
      name: 'Croissant',
      description: 'Croissant francés de mantequilla, recién horneado cada mañana.',
      price: 1.80,
      emoji: '🥐',
      category: 'Snacks',
      isFeatured: true,
    ),
    Product(
      id: 'p8',
      name: 'Tostada con Aguacate',
      description: 'Pan artesanal tostado con aguacate fresco, sal y limón.',
      price: 3.20,
      emoji: '🥑',
      category: 'Snacks',
    ),
    Product(
      id: 'p9',
      name: 'Sandwich de Queso',
      description: 'Queso suizo y tomate en pan ciabatta tostado.',
      price: 2.90,
      emoji: '🥪',
      category: 'Snacks',
    ),
    Product(
      id: 'p10',
      name: 'Muffin de Arándanos',
      description: 'Muffin esponjoso relleno de arándanos frescos.',
      price: 2.20,
      emoji: '🫐',
      category: 'Snacks',
    ),
    // Postres
    Product(
      id: 'p11',
      name: 'Cheesecake',
      description: 'Cheesecake cremoso con base de galleta y coulis de frutos rojos.',
      price: 3.20,
      emoji: '🍰',
      category: 'Postres',
      isFeatured: true,
    ),
    Product(
      id: 'p12',
      name: 'Brownie',
      description: 'Brownie de chocolate intenso con nueces. Servido tibio.',
      price: 2.50,
      emoji: '🍫',
      category: 'Postres',
    ),
    Product(
      id: 'p13',
      name: 'Tiramisú',
      description: 'Postre italiano clásico con mascarpone y café espresso.',
      price: 3.80,
      emoji: '🍮',
      category: 'Postres',
    ),
    // Especiales
    Product(
      id: 'p14',
      name: 'Desayuno Completo',
      description: 'Café, croissant, jugo natural y fruta fresca. El combo perfecto.',
      price: 6.50,
      emoji: '🍳',
      category: 'Especiales',
      isFeatured: true,
    ),
    Product(
      id: 'p15',
      name: 'Combo Tarde',
      description: 'Cappuccino grande más cheesecake. Ideal para una pausa.',
      price: 5.00,
      emoji: '🌅',
      category: 'Especiales',
    ),
  ];

  static List<String> get categories {
    final cats = products.map((p) => p.category).toSet().toList();
    cats.insert(0, 'Todos');
    return cats;
  }

  static List<Product> byCategory(String category) {
    if (category == 'Todos') return products;
    return products.where((p) => p.category == category).toList();
  }

  static List<Product> get featured =>
      products.where((p) => p.isFeatured).toList();

  static List<Product> search(String query) {
    final q = query.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }
}
