import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafe_app/providers/delivery_provider.dart';
import 'package:cafe_app/models/delivery_info.dart';
import 'package:cafe_app/models/location.dart';

class DeliverySelectionScreen extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeliverySelectionScreen({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E2D1E),
        title: Text(
          'Tipo de Envío',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, deliveryProvider, _) {
          final deliveryInfo = deliveryProvider.deliveryInfo;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la sección
                Text(
                  'Elige tu opción de envío',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C1A0E),
                  ),
                ),
                const SizedBox(height: 20),

                // Opción 1: Recogida en tienda
                _buildDeliveryOption(
                  context: context,
                  isSelected: deliveryInfo?.type == DeliveryType.pickup,
                  title: 'Recogida en Tienda',
                  subtitle: 'Retira tu pedido en nuestro local',
                  icon: Icons.store,
                  fee: 'Gratis',
                  onTap: () => _selectPickup(context, deliveryProvider),
                ),
                const SizedBox(height: 16),

                // Opción 2: Envío a domicilio
                _buildDeliveryOption(
                  context: context,
                  isSelected: deliveryInfo?.type == DeliveryType.domicile,
                  title: 'Envío a Domicilio',
                  subtitle: 'Recibe tu pedido en tu ubicación',
                  icon: Icons.location_on,
                  fee: '+\$5.000',
                  onTap: () => _selectDomicile(context, deliveryProvider),
                ),
                const SizedBox(height: 24),

                // Mostrar ubicación si está seleccionado envío a domicilio
                if (deliveryInfo?.type == DeliveryType.domicile)
                  _buildLocationSection(context, deliveryProvider),

                const SizedBox(height: 24),

                // Botón de confirmar
                if (deliveryInfo?.isValid ?? false)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E2D1E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        deliveryProvider.confirmDelivery();
                        onConfirm();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Continuar al Pago',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construye una tarjeta de opción de envío
  Widget _buildDeliveryOption({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required IconData icon,
    required String fee,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4E2D1E).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4E2D1E)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4E2D1E)
                    : const Color(0xFFC8943A).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFFC8943A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C1A0E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              fee,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4E2D1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la sección de ubicación
  Widget _buildLocationSection(
    BuildContext context,
    DeliveryProvider deliveryProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mi Ubicación',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C1A0E),
          ),
        ),
        const SizedBox(height: 12),
        if (deliveryProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (deliveryProvider.hasLocation)
          _buildLocationCard(deliveryProvider.currentLocation!)
        else
          _buildGetLocationButton(context, deliveryProvider),
        if (deliveryProvider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                deliveryProvider.errorMessage!,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Construye la tarjeta de ubicación obtenida
  Widget _buildLocationCard(Location location) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4E2D1E).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4E2D1E).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ubicación obtenida',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            location.fullDetails,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2C1A0E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coordenadas: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón para obtener ubicación
  Widget _buildGetLocationButton(
    BuildContext context,
    DeliveryProvider deliveryProvider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => deliveryProvider.requestLocation(),
        icon: const Icon(Icons.location_on),
        label: Text(
          'Obtener Mi Ubicación',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(
            color: Color(0xFF4E2D1E),
            width: 1.5,
          ),
          foregroundColor: const Color(0xFF4E2D1E),
        ),
      ),
    );
  }

  /// Maneja la selección de recogida en tienda
  void _selectPickup(
    BuildContext context,
    DeliveryProvider deliveryProvider,
  ) {
    deliveryProvider.setDeliveryType(DeliveryType.pickup);
  }

  /// Maneja la selección de envío a domicilio
  void _selectDomicile(
    BuildContext context,
    DeliveryProvider deliveryProvider,
  ) {
    deliveryProvider.setDeliveryType(DeliveryType.domicile);
  }
}
