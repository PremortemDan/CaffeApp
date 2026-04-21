import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E2D1E),
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              color: const Color(0xFF4E2D1E),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: Color(0xFFC8943A),
                    child: Text(
                      'JD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Juan Doe',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'juan@email.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBadge(value: '12', label: 'Pedidos'),
                      _StatBadge(value: '3', label: 'Favoritos'),
                      _StatBadge(value: '🥇', label: 'Gold Club'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu options
            _SectionTitle('Mi cuenta'),
            _ProfileTile(
              icon: Icons.receipt_long_outlined,
              label: 'Historial de pedidos',
              subtitle: '12 pedidos realizados',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.favorite_border,
              label: 'Favoritos',
              subtitle: '3 productos guardados',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.location_on_outlined,
              label: 'Mis direcciones',
              subtitle: 'Añade una dirección de entrega',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.payment_outlined,
              label: 'Métodos de pago',
              subtitle: 'Gestiona tus tarjetas',
              onTap: () {},
            ),

            const SizedBox(height: 8),
            _SectionTitle('Preferencias'),
            _ProfileTile(
              icon: Icons.notifications_outlined,
              label: 'Notificaciones',
              subtitle: 'Activas',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.language_outlined,
              label: 'Idioma',
              subtitle: 'Español',
              onTap: () {},
            ),

            const SizedBox(height: 8),
            _SectionTitle('Soporte'),
            _ProfileTile(
              icon: Icons.help_outline,
              label: 'Ayuda y soporte',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.star_outline,
              label: 'Calificar la app',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.info_outline,
              label: 'Acerca de CaféApp',
              subtitle: 'Versión 1.0.0',
              onTap: () {},
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFC8943A),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.grey.withOpacity(0.15), width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF4E2D1E).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF4E2D1E)),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C1A0E),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              )
            : null,
        trailing: const Icon(Icons.chevron_right,
            size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF5C57A),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}
