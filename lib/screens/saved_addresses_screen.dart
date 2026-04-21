import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafe_app/providers/saved_addresses_provider.dart';
import 'package:cafe_app/models/saved_address.dart';

class SavedAddressesScreen extends StatelessWidget {
  final Function(SavedAddress)? onAddressSelected;

  const SavedAddressesScreen({
    super.key,
    this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E2D1E),
        title: Text(
          'Mis Direcciones',
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
      body: Consumer<SavedAddressesProvider>(
        builder: (context, addressProvider, _) {
          if (addressProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 64,
                    color: Color(0xFFC8943A),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes direcciones guardadas',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C1A0E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega una dirección cuando hagas tu próximo pedido',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addressProvider.count,
            itemBuilder: (context, index) {
              final address = addressProvider.addresses[index];
              return _buildAddressCard(
                context,
                address,
                addressProvider,
              );
            },
          );
        },
      ),
    );
  }

  /// Construye una tarjeta de dirección
  Widget _buildAddressCard(
    BuildContext context,
    SavedAddress address,
    SavedAddressesProvider addressProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: address.isDefault
              ? const Color(0xFF4E2D1E)
              : Colors.grey.withValues(alpha: 0.2),
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con nombre y badge
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.name,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C1A0E),
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4E2D1E)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Predeterminada',
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4E2D1E),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editAddress(context, address, addressProvider);
                    } else if (value == 'delete') {
                      _deleteAddress(context, address, addressProvider);
                    } else if (value == 'default') {
                      addressProvider.setDefaultAddress(address.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Hacer predeterminada'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer con acciones
          if (onAddressSelected != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E2D1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    onAddressSelected!(address);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Usar esta dirección',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Abre diálogo para editar dirección
  void _editAddress(
    BuildContext context,
    SavedAddress address,
    SavedAddressesProvider addressProvider,
  ) {
    final nameController = TextEditingController(text: address.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar dirección'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre (Casa, Oficina, etc)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                addressProvider.updateAddress(
                  address.copyWith(name: nameController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Elimina una dirección
  void _deleteAddress(
    BuildContext context,
    SavedAddress address,
    SavedAddressesProvider addressProvider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar dirección'),
        content: Text('¿Deseas eliminar "${address.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              addressProvider.deleteAddress(address.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
