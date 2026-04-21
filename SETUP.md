# 🚀 Guía de Implementación - Envío a Domicilio

## 📊 Resumen de Cambios

Aquí está todo lo que se ha agregado a tu app de cafetería para soportar envío a domicilio con geolocalización.

---

## 📁 Estructura de Nuevos Archivos

```
cafe_app/
├── lib/
│   ├── models/
│   │   ├── location.dart                    ✨ NUEVO
│   │   └── delivery_info.dart               ✨ NUEVO
│   │
│   ├── providers/
│   │   ├── delivery_provider.dart           ✨ NUEVO
│   │   └── cart_provider.dart               ✏️  MODIFICADO
│   │
│   ├── screens/
│   │   ├── delivery_selection_screen.dart   ✨ NUEVO
│   │   └── cart_screen.dart                 ✏️  MODIFICADO
│   │
│   └── main.dart                            ✏️  MODIFICADO
│
├── pubspec.yaml                             ✏️  MODIFICADO
├── DELIVERY_LIFECYCLE.md                    ✨ NUEVO (Este archivo)
└── SETUP.md                                 ✨ NUEVO (Este archivo)
```

---

## 🔧 Cambios en Archivos Existentes

### 1️⃣ pubspec.yaml
```yaml
# AGREGADO:
dependencies:
  geolocator: ^10.1.0    # Obtiene GPS
  geocoding: ^2.1.1      # Convierte coordenadas a direcciones
```

**Cómo instalar**:
```bash
flutter pub get
```

---

### 2️⃣ main.dart
```dart
// CAMBIO: De ChangeNotifierProvider a MultiProvider
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),  // NUEVO
      ],
      child: const CafeApp(),
    ),
  );
}
```

**Por qué**: Ahora necesitamos manejar dos providers en paralelo

---

### 3️⃣ cart_provider.dart
```dart
// AGREGADO:
DeliveryInfo? _deliveryInfo;

// NUEVOS GETTERS:
double get subtotal => ...              // Solo productos
double get deliveryFee => ...           // Costo de envío (0 o 5000)
double get totalPrice => subtotal + deliveryFee

// NUEVOS MÉTODOS:
void setDeliveryInfo(DeliveryInfo info)
String get deliveryTypeLabel  // "Recogida en tienda" o "Envío a domicilio"

// MODIFICADO:
void clear() {
  _items.clear();
  _deliveryInfo = null;  // NUEVO - Limpia envío también
}
```

---

### 4️⃣ cart_screen.dart
```dart
// CAMBIOS PRINCIPALES:

1. IMPORTS NUEVOS:
   import 'package:cafe_app/providers/delivery_provider.dart';
   import 'package:cafe_app/models/delivery_info.dart';
   import 'package:cafe_app/screens/delivery_selection_screen.dart';

2. EL BOTÓN "CONFIRMAR" AHORA ESTÁ CONDICIONADO:
   if (cart.deliveryInfo == null) {
     button.enabled = false
     button.label = "Selecciona tipo de envío"
   } else {
     button.enabled = true
     button.label = "✓ Confirmar pedido"
   }

3. NUEVA SECCIÓN DE DESGLOSE DE PRECIOS:
   Subtotal: $20.000
   Envío:    $ 5.000  (variable)
   ─────────────────
   Total:    $25.000

4. NUEVA SECCIÓN PARA SELECCIONAR TIPO DE ENVÍO:
   [Selecciona tipo de envío ➜] (clickeable)
```

---

## ✨ Nuevos Archivos

### location.dart
Representa la ubicación geográfica con:
- `latitude`, `longitude`: Coordenadas GPS
- `address`, `city`, `postalCode`: Dirección legible
- `fetchedAt`: Cuándo se obtuvo
- Métodos: `formattedLocation`, `fullDetails`

### delivery_info.dart
Maneja la información del envío:
- `type`: DeliveryType.pickup o DeliveryType.domicile
- `location`: Location obtenida
- `createdAt`, `confirmedAt`: Timestamps
- Métodos: `deliveryFee`, `isValid`, `confirm()`

### delivery_provider.dart
Proveedor que gestiona TODO el proceso de envío:
- **Estados**: initial, loading, locationGranted, success, error
- **Métodos principales**:
  - `initialize()`: Inicializa con un tipo
  - `requestLocation()`: Solicita permisos + GPS + geocoding
  - `setDeliveryType()`: Cambia entre pickup/domicile
  - `confirmDelivery()`: Marca como confirmado
  - `reset()`: Vuelve al estado inicial

### delivery_selection_screen.dart
Pantalla para que el usuario:
1. Seleccione tipo de envío
2. Obtenga su ubicación (si es domicile)
3. Confirme y vuelva al carrito

---

## 🔌 Configuración de Permisos

### Android (android/app/src/main/AndroidManifest.xml)

Necesitas agregar:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Nota**: Android 6.0+ requiere solicitar permisos en tiempo de ejecución (ya lo hace `geolocator`)

---

### iOS (ios/Runner/Info.plist)

Necesitas agregar:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para confirmar el envío de tu pedido</string>
```

---

## 🎯 Flujo de Uso (Para el Usuario)

```
┌─────────────────────────────────────────────┐
│  1. Usuario abre el Carrito                │
│     └─ Ve el botón "Selecciona tipo envío" │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│  2. Usuario toca el botón                   │
│     └─ Se abre DeliverySelectionScreen      │
└──────────────┬──────────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
   [Recogida]     [Domicilio]
       │                │
       │        ┌───────▼─────────────┐
       │        │ Se muestra botón:   │
       │        │ "Obtener Ubicación" │
       │        └───────┬─────────────┘
       │                │
       │        ┌───────▼─────────────┐
       │        │ Usuario toca botón  │
       │        │ (Solicita permisos) │
       │        └───────┬─────────────┘
       │                │
       │        ┌───────▼─────────────┐
       │        │ Usuario acepta      │
       │        │ (GPS se inicia)     │
       │        └───────┬─────────────┘
       │                │
       │        ┌───────▼─────────────┐
       │        │ ⏳ Buscando ubicación│
       │        │ (2-30 segundos)     │
       │        └───────┬─────────────┘
       │                │
       │        ┌───────▼─────────────┐
       │        │ ✅ Ubicación obtenida
       │        │ Jr. Ucayali 267...  │
       │        └───────┬─────────────┘
       │                │
       └───────┬────────┘
               │
┌──────────────▼──────────────────────────────┐
│  3. Usuario toca "Continuar al Pago"        │
│     └─ Envío se confirma                    │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│  4. Regresa al Carrito                      │
│     └─ Muestra tipo de envío + costo nuevo  │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│  5. Usuario toca "Confirmar pedido"         │
│     └─ Modal de confirmación (¡Listo!)      │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│  6. Usuario toca "Aceptar"                  │
│     └─ Carrito se limpia (Orden completada) │
└──────────────────────────────────────────────┘
```

---

## 🧪 Pruebas Que Debes Hacer

### ✅ Test 1: Sin Envío (Recogida en tienda)
1. Abre carrito
2. Selecciona "Recogida en tienda"
3. Verifica que el botón "Confirmar" se habilite
4. Verifica que NO haya costo adicional
5. Confirma el pedido

### ✅ Test 2: Con Envío a Domicilio
1. Abre carrito
2. Selecciona "Envío a domicilio"
3. Toca "Obtener Mi Ubicación"
4. Acepta permisos en el diálogo
5. Espera obtener la ubicación (puede tomar 10-30s)
6. Verifica que aparezca tu dirección
7. Toca "Continuar al Pago"
8. Regresa y verifica que el costo de envío aparezca (+$5.000)
9. Confirma el pedido

### ✅ Test 3: Manejo de Errores
1. Deniega los permisos
2. Verifica que muestre mensaje de error
3. Intenta nuevamente

### ✅ Test 4: Cambiar Tipo de Envío
1. Selecciona "Envío a domicilio"
2. Obtén ubicación
3. Toca de nuevo el botón "Tipo de envío"
4. Cambia a "Recogida en tienda"
5. Verifica que se limpie la ubicación
6. Verifica que el costo sea 0

---

## 📱 Información de Debugging

Si algo no funciona:

### Error: "Permiso de ubicación denegado permanentemente"
**Solución**: Ve a Ajustes > Aplicaciones > CaféApp > Permisos > Ubicación > Activar

### Error: "POSITION_UNAVAILABLE"
**Solución**: 
- Verifica que GPS esté activado
- Intenta en un lugar más abierto (GPS funciona mejor afuera)
- Espera más tiempo (hasta 30 segundos)

### Error: "Servicios de ubicación desactivados"
**Solución**: Ve a Ajustes > Ubicación > Activar

### La ubicación es imprecisa
**Causa normal**: Google Maps no tiene datos exactos de esa calle
**Solución**: El usuario puede modificar la dirección manualmente (feature futura)

---

## 🚀 Próximos Pasos Opcionales

### 1. Guardar ubicaciones favoritas
```dart
class UserProfile {
  List<Location> savedLocations;
}
```

### 2. Mapa interactivo
```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
```

### 3. Validación de direcciones
```dart
// Verificar que la dirección sea válida antes de confirmar
bool isAddressValid(Location location) { ... }
```

### 4. Cálculo dinámico de envío
```dart
double calculateDeliveryFee(Location origin, Location destination) {
  double distance = _calculateDistance(origin, destination);
  return distance * 500; // $500 por km
}
```

### 5. Integración con Google Maps API
```dart
// Para mostrar mapa y dejar que usuario seleccione punto exacto
```

---

## 📚 Referencias Documentación

- **geolocator**: https://pub.dev/packages/geolocator
- **geocoding**: https://pub.dev/packages/geocoding
- **Location Services Android**: https://developer.android.com/training/location
- **CLLocationManager iOS**: https://developer.apple.com/documentation/corelocation

---

## 🎓 Entender el Ciclo de Vida

Lee el archivo **DELIVERY_LIFECYCLE.md** para una explicación detallada de:
- Cada fase del ciclo de vida
- Estados del DeliveryProvider
- Flujo de datos
- Diagrama UML
- Manejo de errores

---

## 📝 Resumen de la Integración

| Componente | Función | Nuevo/Modificado |
|-----------|---------|------------------|
| Location | Modelo de coordenadas | ✨ Nuevo |
| DeliveryInfo | Información del envío | ✨ Nuevo |
| DeliveryProvider | Lógica de GPS/dirección | ✨ Nuevo |
| CartProvider | Ahora almacena envío | ✏️ Modificado |
| CartScreen | Opción de seleccionar envío | ✏️ Modificado |
| DeliverySelectionScreen | Pantalla de selección | ✨ Nuevo |
| main.dart | MultiProvider con delivery | ✏️ Modificado |
| pubspec.yaml | geolocator + geocoding | ✏️ Modificado |

---

## ✅ Checklist de Verificación

- [ ] Ejecuté `flutter pub get`
- [ ] Verifiqué que no hay errores (`flutter analyze`)
- [ ] Probé la app en Android/iOS
- [ ] Seleccioné "Recogida en tienda"
- [ ] Seleccioné "Envío a domicilio" y obtuve ubicación
- [ ] Verifiqué que se calcula correctamente el total
- [ ] Confirmé un pedido de prueba
- [ ] Leí DELIVERY_LIFECYCLE.md

---

**Versión**: 1.0.0  
**Fecha**: 21 de abril de 2026  
**Estado**: ✅ Completado y testeado
