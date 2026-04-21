# 🚀 Ciclo de Vida - Envío a Domicilio

## 📋 Resumen Ejecutivo

El sistema permite a usuarios seleccionar envío (recogida/domicilio), obtener ubicación mediante GPS, guardarla para futuras órdenes, y administrarla desde el perfil.

---

## 🔄 Flujo Principal

```
USUARIO ABRE CARRITO
        ↓
SELECCIONA TIPO DE ENVÍO
        ↓
    ┌───┴────────────────┐
    ↓                    ↓
RECOGIDA            DOMICILIO
(Gratis)            (+$5.000)
    │                    │
    │              ┌─────┴─────┐
    │              ↓           ↓
    │         USA DIRECCIÓN  USA UBICACIÓN
    │         GUARDADA        ACTUAL (GPS)
    │              │           │
    │              └─────┬─────┘
    │                    ↓
    │          ¿GUARDAR DIRECCIÓN?
    │          SÍ / NO
    │                    │
    └────────┬───────────┘
             ↓
    CONFIRMA ENVÍO
             ↓
    REGRESA AL CARRITO
    (Total actualizado)
             ↓
    CONFIRMA PEDIDO
             ↓
    FIN ✓
```

---

## 🎯 Estados del DeliveryProvider

```
INITIAL         → App inicia
    ↓
LOADING         → Solicitando GPS
    ↓
GRANTED/DENIED  → Permisos del SO
    ↓
SUCCESS         → Ubicación obtenida
    ↓
ERROR           → Falló obtención
```

---

## 🗺️ Componentes Clave

### **Models**
- **Location**: Coordenadas + dirección (geocodificación)
- **SavedAddress**: Dirección guardada con nombre y metadata
- **DeliveryInfo**: Tipo de envío + ubicación + costo ($0 o $5.000)

### **Providers**
- **DeliveryProvider**: Maneja GPS, permisos, geocodificación
- **SavedAddressesProvider**: Persistencia de direcciones (SharedPreferences)
- **CartProvider**: Integra envío con carrito

### **Pantallas**
- **DeliverySelectionScreen**: Selecciona tipo + opciones de ubicación
- **SavedAddressesScreen**: CRUD de direcciones guardadas

---

## 🔗 Flujo Detallado

### **PASO 1: Selección de Tipo de Envío**
```dart
Usuario → CartScreen → Toca "Selecciona tipo de envío"
    ↓
DeliverySelectionScreen abre
    ↓
Muestra opciones:
  • Recogida en tienda ($0)
  • Envío a domicilio (+$5.000)
  • Chips de direcciones guardadas
```

### **PASO 2a: Selecciona Recogida**
```dart
deliveryProvider.setDeliveryType(DeliveryType.pickup)
    ↓
DeliveryInfo.isValid = true
    ↓
Listo para confirmar (sin necesidad de ubicación)
```

### **PASO 2b: Selecciona Domicilio**
```dart
deliveryProvider.setDeliveryType(DeliveryType.domicile)
    ↓
Muestra 2 opciones:
  1. Chipps de direcciones guardadas previas
  2. Botón "Obtener Mi Ubicación" (GPS actual)
```

### **PASO 3a: Usa Dirección Guardada**
```dart
Usuario toca chip de dirección guardada
    ↓
deliveryProvider.setLocationFromSavedAddress(location)
    ↓
DeliveryInfo.location = location
DeliveryInfo.isValid = true
    ↓
Listo para continuar
```

### **PASO 3b: Obtiene Ubicación Nueva**

#### **3b.1 - Solicita Permisos**
```dart
Usuario toca "Obtener Mi Ubicación"
    ↓
Geolocator.checkPermission()
    ├─ granted    → Continúa a GPS
    ├─ denied     → OS Dialog pide permiso
    └─ deniedForever → Error: "Habilita en Configuración"
```

#### **3b.2 - Obtiene GPS (2-30s)**
```dart
Geolocator.getCurrentPosition()
    ↓
Resultado: {latitude, longitude, timestamp}
    ├─ Éxito → Continúa
    └─ Error (TIMEOUT, SERVICES_DISABLED) → Mostrar error
```

#### **3b.3 - Geocodificación (Convierte a Dirección)**
```dart
placemarkFromCoordinates(lat, lng)
    ↓
Resultado: {street, locality, postalCode, country}
    ↓
Location(
  latitude: -12.0464,
  longitude: -77.0428,
  address: "Jr. Ucayali 267",
  city: "Lima",
  postalCode: "15001"
)
```

#### **3b.4 - Mostrar y Guardar**
```dart
DeliveryProvider._state = SUCCESS
Muestra dirección en tarjeta
    ↓
Usuario ve: "Jr. Ucayali 267, Lima"
    ↓
¿Guardar dirección?
    ├─ SÍ → Dialog: "¿Nombre? (Casa/Oficina/Otro)"
    │  ├─ Ingresa nombre
    │  └─ SavedAddressesProvider.addAddress()
    │     (Persiste en SharedPreferences)
    │
    └─ NO → Continúa sin guardar
```

---

## 📁 Administración de Direcciones

### **SavedAddressesScreen** (desde Perfil → "Mis Direcciones")

```
Lista todas las direcciones guardadas:

Para cada dirección:
  • Nombre (Casa, Oficina, etc.)
  • Dirección completa
  • Badge "Predeterminada" (si aplica)
  • Menu (⋮):
    ├─ Usar esta dirección
    ├─ Hacer predeterminada
    ├─ Editar nombre
    └─ Eliminar

Si vacío: "No tienes direcciones guardadas"
```

---

## 💾 Persistencia (SharedPreferences)

```dart
Key: 'saved_addresses'
Value: JSON Array de SavedAddress

SavedAddress JSON:
{
  "id": "1719024123456",
  "name": "Casa",
  "latitude": -12.0464,
  "longitude": -77.0428,
  "address": "Jr. Ucayali 267",
  "city": "Lima",
  "postalCode": "15001",
  "createdAt": "2026-04-21T10:00:00Z",
  "isDefault": true
}

Cargas automáticamente al iniciar app
Se actualiza cada cambio CRUD
Persiste entre sesiones
```

---

## ✋ Confirmación del Envío

```dart
Usuario en DeliverySelectionScreen
    ↓
Toca "Continuar al Pago"
    ↓
if (DeliveryInfo.isValid) {
    deliveryProvider.confirmDelivery()
    cart.setDeliveryInfo(deliveryInfo)
    Navigator.pop()
}
    ↓
Regresa a CartScreen
    ↓
Muestra:
  • Tipo de envío confirmado ✅
  • Subtotal (productos)
  • Costo envío (+$5.000 si domicilio)
  • Total final
  • Botón "Confirmar pedido" ENABLED
```

---

## 📊 Timeline Completo

| Tiempo | Acción | Estado |
|--------|--------|--------|
| 0s | Usuario abre carrito | initial |
| +1s | Toca "Selecciona envío" | initial |
| +2s | Abre DeliverySelectionScreen | initial |
| +3s | Selecciona "Domicilio" | initial |
| +4s | Toca "Obtener Mi Ubicación" | loading |
| +5s | Acepta permisos en dialog SO | loading |
| +7s | GPS buscando señal | loading |
| +25s | GPS obtenido | loading |
| +26s | Dirección decodificada | SUCCESS |
| +27s | Muestra dirección en tarjeta | SUCCESS |
| +28s | Toca "Guardar dirección" | SUCCESS |
| +29s | Ingresa nombre y guarda | SUCCESS |
| +30s | Toca "Continuar al Pago" | SUCCESS |
| +31s | Confirma envío | SUCCESS |
| +32s | Regresa a CartScreen | confirmado |
| +33s | Toca "Confirmar pedido" | confirmado |
| +34s | Modal confirmación | final |
| +35s | Carrito limpio, listo | initial |

---

## 🚨 Errores Comunes

```
❌ "No location permissions are defined"
   → Agregar permisos a AndroidManifest.xml ✅

❌ "Permiso denegado"
   → Usuario debe ir a Configuración > Aplicaciones > CaféApp > Permisos

❌ "POSITION_UNAVAILABLE"
   → GPS no disponible, intenta en lugar abierto

❌ "TIMEOUT (30 segundos)"
   → GPS tardó mucho, reintentar

❌ "Servicios de ubicación desactivados"
   → Activar GPS en Configuración
```

---

## 🔐 Permisos

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para confirmar el envío</string>
```

---

## ✅ Checklist de Funcionalidad

- [x] Seleccionar tipo de envío (pickup/domicile)
- [x] Solicitar permisos de ubicación
- [x] Obtener GPS actual (2-30s)
- [x] Geocodificar coordenadas a dirección
- [x] Guardar direcciones con nombre personalizado
- [x] Listar direcciones guardadas
- [x] Marcar dirección como predeterminada
- [x] Editar nombre de dirección
- [x] Eliminar dirección
- [x] Usar dirección guardada en envío
- [x] Calcular costo de envío automático ($0 o $5.000)
- [x] Persistencia con SharedPreferences
- [x] Manejo de errores GPS

---

## 📚 Archivos Clave

```
lib/
├── models/
│   ├── location.dart                # Coordenadas + dirección
│   ├── delivery_info.dart           # Envío + ubicación + costo
│   └── saved_address.dart           # ✨ Dirección guardada
│
├── providers/
│   ├── delivery_provider.dart       # GPS + geocodificación
│   ├── saved_addresses_provider.dart # ✨ Persistencia con SharedPreferences
│   └── cart_provider.dart           # Integración
│
└── screens/
    ├── delivery_selection_screen.dart # Selecciona tipo + ubicación
    └── saved_addresses_screen.dart   # ✨ CRUD direcciones

pubspec.yaml:
  - geolocator: ^10.1.0
  - geocoding: ^2.1.1
  - shared_preferences: ^2.2.2 ✨
  - provider: ^6.1.1
```

---

**Versión**: 2.0 (Con Direcciones Guardadas)  
**Última actualización**: 21 de abril de 2026  
**Estado**: ✅ Completado
