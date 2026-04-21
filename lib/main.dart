import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafe_app/providers/cart_provider.dart';
import 'package:cafe_app/providers/delivery_provider.dart';
import 'package:cafe_app/screens/home_screen.dart';
import 'package:cafe_app/screens/cart_screen.dart';
import 'package:cafe_app/screens/profile_screen.dart';
import 'package:cafe_app/screens/menu_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(),
        ),
      ],
      child: const CafeApp(),
    ),
  );
}

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaféApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E2D1E),
          primary: const Color(0xFF4E2D1E),
          secondary: const Color(0xFFC8943A),
          surface: const Color(0xFFFAF7F2),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        textTheme: GoogleFonts.latoTextTheme(),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MenuScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF4E2D1E).withOpacity(0.12),
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF4E2D1E)),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF4E2D1E)),
            label: 'Menú',
          ),
          NavigationDestination(
            icon: Consumer<CartProvider>(
              builder: (_, cart, __) => Badge(
                isLabelVisible: cart.itemCount > 0,
                label: Text('${cart.itemCount}'),
                backgroundColor: const Color(0xFFC8943A),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            selectedIcon: const Icon(Icons.shopping_cart, color: Color(0xFF4E2D1E)),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF4E2D1E)),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
