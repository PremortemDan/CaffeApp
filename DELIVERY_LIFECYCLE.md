# Ciclo de Vida de la Funcionalidad de Envío a Domicilio

## 📋 Índice
1. [Descripción General](#descripción-general)
2. [Componentes del Sistema](#componentes-del-sistema)
3. [Fases del Ciclo de Vida](#fases-del-ciclo-de-vida)
4. [Flujo de Datos](#flujo-de-datos)
5. [Manejo de Errores y Estados](#manejo-de-errores-y-estados)
6. [Integración con el Carrito](#integración-con-el-carrito)
7. [Diagrama de Secuencia](#diagrama-de-secuencia)

---

## 🎯 Descripción General

La funcionalidad de envío a domicilio permite que los usuarios de la aplicación de cafetería seleccionen cómo desean recibir su pedido:

- **Recogida en tienda**: Gratis, sin requerir ubicación
- **Envío a domicilio**: Costo adicional de $5.000, requiere obtener la ubicación exacta del usuario

El sistema utiliza **geolocalización GPS** para obtener las coordenadas precisas, y **geocodificación inversa** para convertir esas coordenadas en una dirección legible.

---

## 🏗️ Componentes del Sistema

### 1. **Models** (Modelos de Datos)
```
├── location.dart           # Representa ubicación geográfica
├── delivery_info.dart      # Información del tipo y estado del envío
```

### 2. **Providers** (Gestores de Estado)
```
├── delivery_provider.dart  # Gestiona lógica de ubicación y envío
└── cart_provider.dart      # Almacena cartItems + información de envío
```

### 3. **Screens** (Interfaces de Usuario)
```
├── cart_screen.dart                    # Panel de carrito con opción de envío
└── delivery_selection_screen.dart      # Pantalla de selección de tipo de envío
```

### 4. **Dependencias Externas**
```
- geolocator ^10.1.0       # Obtiene coordenadas GPS
- geocoding ^2.1.1         # Convierte coordenadas a dirección
- provider ^6.1.1          # Gestor de estado
```

---

## 📈 Fases del Ciclo de Vida

### **FASE 1: INICIALIZACIÓN**

#### 🔴 Estado: `DeliveryState.initial`

**Cuándo ocurre**: 
- Cuando la app inicia (en `main.dart`)
- Cuando el usuario abre nuevamente la pantalla de carrito

**Qué sucede**:
```dart
DeliveryProvider()
  ↓
_state = DeliveryState.initial
_deliveryInfo = null
_errorMessage = null
_currentLocation = null
```

**Componentes activos**:
- `DeliveryProvider` se instancia en `MultiProvider`
- `CartProvider` también se instancia
- La pantalla de carrito está lista pero sin información de envío

**Duración**: Inmediata
**Usuario no interactúa**: Sucede en segundo plano

---

### **FASE 2: SELECCIÓN DE TIPO DE ENVÍO**

#### 🟡 Estado: `DeliveryState.initial` (sin cambios)

**Cuándo ocurre**:
- Usuario toca el botón "Selecciona tipo de envío" en el carrito

**Qué sucede**:
```
CartScreen
  ↓ (Usuario toca botón)
Navigator.push()
  ↓
DeliverySelectionScreen
  ↓
Usuario selecciona:
  - Recogida en tienda (DeliveryType.pickup)
  - Envío a domicilio (DeliveryType.domicile)
```

**Detalles de la selección**:

**Si selecciona RECOGIDA EN TIENDA**:
```dart
deliveryProvider.setDeliveryType(DeliveryType.pickup)
  ↓
_deliveryInfo = DeliveryInfo(type: DeliveryType.pickup)
_currentLocation = null  // No se necesita ubicación
_deliveryInfo.isValid = true  // Válido sin ubicación
notifyListeners()
```

**Si selecciona ENVÍO A DOMICILIO**:
```dart
deliveryProvider.setDeliveryType(DeliveryType.domicile)
  ↓
_deliveryInfo = DeliveryInfo(type: DeliveryType.domicile)
_currentLocation = null  // No se ha obtenido aún
_deliveryInfo.isValid = false  // No válido sin ubicación
notifyListeners()
  ↓
Se muestra botón "Obtener Mi Ubicación"
```

**Componentes activos**:
- `DeliverySelectionScreen` está en pantalla
- `DeliveryProvider` se actualiza
- UI se reconstruye mostrando `_buildLocationSection()`

**Duración**: Espera interacción del usuario

---

### **FASE 3: SOLICITUD DE PERMISOS**

#### 🟠 Estado: `DeliveryState.loading` → `DeliveryState.locationGranted/Denied`

**Cuándo ocurre**:
- Solo si usuario seleccionó "Envío a domicilio"
- Usuario toca "Obtener Mi Ubicación"

**Paso 3.1: Verificación de Permisos**
```dart
LocationPermission permission = await Geolocator.checkPermission()
```

**Posibles resultados**:
```
1. LocationPermission.granted
   ↓ (Ya tiene permiso)
   Pasar a FASE 4

2. LocationPermission.denied
   ↓ (Nunca pidió permiso)
   Solicitar permiso → mostrar diálogo del SO

3. LocationPermission.deniedForever
   ↓ (Usuario rechazó permanentemente)
   _state = DeliveryState.locationDenied
   _errorMessage = "Permiso de ubicación denegado permanentemente..."
   Mostrar instrucciones para habilitar en configuración
```

**UI en esta fase**:
```
┌─────────────────────────────────────┐
│     Obteniendo tu ubicación...      │
│                                     │
│          ⏳ Cargando...              │
│                                     │
└─────────────────────────────────────┘
```

**Duración**: 1-3 segundos

---

### **FASE 4: OBTENCIÓN DE COORDENADAS GPS**

#### 🟠 Estado: `DeliveryState.loading`

**Cuándo ocurre**:
- Después del permiso otorgado
- Usuario está en envío a domicilio

**Proceso**:
```dart
// Obtener posición con alta precisión
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  timeLimit: Duration(seconds: 30),
)

Resultado:
{
  latitude: -12.0464,
  longitude: -77.0428,
  altitude: 500.2,
  speed: 0.0,
  timestamp: DateTime.now()
}
```

**Parámetros importantes**:
- `desiredAccuracy: LocationAccuracy.high`: Precisión de ~10-30 metros
- `timeLimit: 30 segundos`: Máximo tiempo de espera
- Requiere que el GPS esté activado en el dispositivo

**Posibles errores en esta fase**:
```
1. PERMISSION_DENIED
   → El usuario denegó el permiso

2. POSITION_UNAVAILABLE
   → El GPS no está disponible/activado

3. TIMEOUT (30 segundos)
   → No se pudo obtener posición en tiempo límite
   → Frecuente en interiores

4. LOCATION_SERVICES_DISABLED
   → Los servicios de ubicación están desactivados
```

**Duración**: 2-30 segundos (depende de GPS)

**UI en esta fase**:
```
┌─────────────────────────────────────┐
│  Obteniendo tu ubicación GPS...     │
│                                     │
│     📍 Buscando posición exacta...  │
│                                     │
│        ⏳ Puede tomar unos segundos  │
└─────────────────────────────────────┘
```

---

### **FASE 5: GEOCODIFICACIÓN INVERSA**

#### 🟠 Estado: `DeliveryState.loading`

**Cuándo ocurre**:
- Inmediatamente después de obtener GPS
- Convierte coordenadas a dirección legible

**Proceso**:
```dart
// Convertir coordenadas a dirección humana
List<Placemark> placemarks = await placemarkFromCoordinates(
  position.latitude,    // -12.0464
  position.longitude,   // -77.0428
)

Resultado:
[
  Placemark(
    name: "Jr. Ucayali 267",
    street: "Jr. Ucayali 267",
    locality: "Lima",
    administrativeArea: "Lima",
    postalCode: "15001",
    country: "Peru"
  )
]
```

**Atributos extraídos**:
```dart
Location(
  latitude: -12.0464,
  longitude: -77.0428,
  address: "Jr. Ucayali 267",      // De placemark.street
  city: "Lima",                     // De placemark.locality
  postalCode: "15001",              // De placemark.postalCode
  fetchedAt: DateTime.now()
)
```

**Precisión**:
- Depende de bases de datos de Google/Apple
- A veces puede ser imprecisa en calles nuevas
- Siempre muestra aproximadamente correcto

**Duración**: 1-3 segundos (llamada HTTP a servidor)

---

### **FASE 6: ACTUALIZACIÓN DE ESTADO**

#### 🟢 Estado: `DeliveryState.success` O 🔴 `DeliveryState.locationError`

**Caso 1: Éxito**
```dart
_currentLocation = Location(...)
_deliveryInfo.location = _currentLocation
_state = DeliveryState.success
_errorMessage = null
notifyListeners()
```

**UI en caso de éxito**:
```
┌──────────────────────────────────────────┐
│  ✅ Ubicación obtenida                    │
├──────────────────────────────────────────┤
│  Jr. Ucayali 267, Lima, 15001            │
│  Coordenadas: -12.0464, -77.0428         │
└──────────────────────────────────────────┘

[Continuar al Pago]  ← Botón habilitado
```

**Caso 2: Error**
```dart
_state = DeliveryState.locationError
_errorMessage = "Error obteniendo ubicación: ${e.toString()}"
_currentLocation = null
_deliveryInfo.location = null
notifyListeners()
```

**UI en caso de error**:
```
┌──────────────────────────────────────────┐
│  ⚠️  Error obteniendo ubicación:          │
│  TIMEOUT - No se pudo obtener posición    │
│  en 30 segundos. Intenta de nuevo.        │
│                                           │
│  [Reintentar]                             │
└──────────────────────────────────────────┘

[Continuar al Pago]  ← Botón deshabilitado
```

**Duración**: Inmediata

---

### **FASE 7: CONFIRMACIÓN DEL ENVÍO**

#### 🔵 Estado: `DeliveryState.success`

**Cuándo ocurre**:
- Usuario toca "Continuar al Pago" en `DeliverySelectionScreen`
- Solo disponible si `DeliveryInfo.isValid == true`

**Proceso**:
```dart
deliveryProvider.confirmDelivery()
  ↓
if (_deliveryInfo.isValid) {
  _deliveryInfo.confirm()  // Marca hora de confirmación
  return true
} else {
  return false
}
```

**Qué se guarda**:
```dart
DeliveryInfo {
  type: DeliveryType.domicile,
  location: Location(...),
  createdAt: DateTime,
  confirmedAt: DateTime  // AHORA SE ESTABLECE
}
```

**Integración con CartProvider**:
```dart
// En DeliverySelectionScreen, onConfirm:
if (deliveryProvider.deliveryInfo != null) {
  cart.setDeliveryInfo(deliveryProvider.deliveryInfo!)
}

// CartProvider ahora tiene:
_deliveryInfo = DeliveryInfo(...)
notifyListeners()
```

**UI**:
```
DeliverySelectionScreen desaparece
Usuario regresa a CartScreen
CartScreen muestra:
  - Tipo de envío confirmado ✅
  - Costo de envío agregado al total
  - Botón "Confirmar pedido" HABILITADO
```

**Duración**: Inmediata

---

### **FASE 8: CHECKOUT Y CONFIRMACIÓN FINAL**

#### 🎯 Estado: Completado

**Cuándo ocurre**:
- Usuario toca "Confirmar pedido" en CartScreen
- Se ha validado que `DeliveryInfo` está presente

**Proceso**:
```dart
CarritoScreen._showOrderConfirmation()
  ↓
Mostrar modal de confirmación:
┌──────────────────────────┐
│  🎉 ¡Pedido confirmado!  │
│                          │
│  Total: $25.000          │
│  Envío: Envío a domicilio│
└──────────────────────────┘
  ↓
Usuario toca "Aceptar"
  ↓
cart.clear()  // Limpia todo:
  - _items = {}
  - _deliveryInfo = null
  ↓
notifyListeners()
  ↓
CartScreen se reconstruye (carrito vacío)
```

**Duración**: Acción completada

---

## 🔄 Flujo de Datos

```
┌────────────────────────────────────────────────────────────────┐
│                        INICIO DE LA APP                        │
│                      (main.dart - runApp)                      │
└────────────────────┬─────────────────────────────────────────┘
                     │
    ┌────────────────┴─────────────────┐
    │                                  │
┌───▼──────────────────┐    ┌──────────▼──────────────────┐
│   CartProvider()     │    │   DeliveryProvider()        │
│   - _items = {}      │    │   - _state = initial        │
│   - _deliveryInfo=null   │   - _deliveryInfo = null    │
│                      │    │   - _errorMessage = null    │
└─────────────────────┘    └─────────────────────────────┘
        │                            │
        │     ┌──────────────────────┘
        │     │ MultiProvider
        └─────┼──────────────────────────┐
              │                          │
        ┌─────▼─────┐         ┌─────────▼──────┐
        │ MainShell │         │  Pantallas      │
        │IndexedStack        │                 │
        └───────────┘         └─────────────────┘
              │
              ├─ CartScreen
              │    │
              │    ├─ Consumer<CartProvider>
              │    └─ Consumer<DeliveryProvider>
              │         │
              │         └─ [Selecciona tipo envío]
              │              │
              │              ├─ NavigatorPush
              │              │  DeliverySelectionScreen
              │              │         │
              │              ├─ [Recogida en tienda]
              │              │         ↓
              │              │    setDeliveryType(pickup)
              │              │         │
              │              │         └─→ isValid = true
              │              │
              │              └─ [Envío a domicilio]
              │                    ↓
              │                setDeliveryType(domicile)
              │                    │
              │                    └─ [Obtener Mi Ubicación]
              │                         │
              │                         ├─ requestLocation() START
              │                         │
              │                         ├─ checkPermission()
              │                         │  - granted → continua
              │                         │  - denied → request
              │                         │  - deniedForever → error
              │                         │
              │                         ├─ Geolocator.getCurrentPosition()
              │                         │  GPS coordinates obtained
              │                         │
              │                         ├─ placemarkFromCoordinates()
              │                         │  Address decoded
              │                         │
              │                         └─ _state = success
              │                             _currentLocation = Location
              │                             notifyListeners()
              │
              │         [Continuar al Pago]
              │              │
              │              └─ confirmDelivery()
              │                  cart.setDeliveryInfo()
              │                  Navigator.pop()
              │
              │         Regresa a CartScreen
              │              │
              │              └─ DeliveryInfo ahora visible
              │                 - Tipo de envío confirmado ✅
              │                 - Costo de envío agregado
              │                 - Botón "Confirmar" ENABLED
              │
              └─ [Confirmar pedido]
                   │
                   ├─ _showOrderConfirmation()
                   │
                   ├─ [Aceptar]
                   │  │
                   │  └─ cart.clear()
                   │     - _items = {}
                   │     - _deliveryInfo = null
                   │     notifyListeners()
                   │
                   └─ Carrito vacío - nueva orden
```

---

## 🚨 Manejo de Errores y Estados

### Estados Posibles del DeliveryProvider

```
┌──────────────────────┐
│ DeliveryState.initial│ (Inicio)
└──────────┬───────────┘
           │
           ├─→ [Usuario selecciona recogida]
           │   └─→ isValid = true
           │       (Sin cambio de estado)
           │
           └─→ [Usuario selecciona envío]
               └─→ Inicia requestLocation()
                   │
                   ├─→ DeliveryState.loading
                   │
                   ├─→ checkPermission()
                   │   │
                   │   ├─ granted
                   │   │  └─ locationGranted
                   │   │
                   │   ├─ denied
                   │   │  └─ locationDenied
                   │   │     _errorMessage = "Permiso denegado"
                   │   │
                   │   └─ deniedForever
                   │      └─ locationDenied
                   │         _errorMessage = "Permiso permanente..."
                   │
                   └─→ Si granted:
                       ├─ getCurrentPosition()
                       │  Timeout 30s
                       │
                       ├─ placemarkFromCoordinates()
                       │  HTTP call
                       │
                       └─→ Resultado:
                           ├─ SUCCESS
                           │  └─ DeliveryState.success
                           │     _currentLocation = Location
                           │     isValid = true
                           │
                           └─ ERROR
                              └─ DeliveryState.locationError
                                 _errorMessage = "..."
                                 isValid = false
```

### Manejo Específico de Errores

**Error 1: GPS no disponible**
```dart
// LocationServiceDisabledException
_state = DeliveryState.locationError
_errorMessage = "Servicios de ubicación desactivados. Actívalos en configuración."
```

**Error 2: Timeout**
```dart
// TimeoutException (después de 30 segundos)
_state = DeliveryState.locationError
_errorMessage = "No se pudo obtener la posición. Intenta en un lugar abierto con mejor señal GPS."
```

**Error 3: Geocodificación fallida**
```dart
// Si no hay placemarks
Usar fallback:
Location(
  latitude: ...,
  longitude: ...,
  address: null,  // Mostrar solo coordenadas
  city: null
)
```

**Error 4: Sin permisos**
```dart
// LocationPermission.deniedForever
_state = DeliveryState.locationDenied
_errorMessage = "Habilita permisos de ubicación en Configuración > Aplicaciones > CaféApp > Permisos"
```

---

## 🛒 Integración con el Carrito

### CartProvider - Cambios Introducidos

```dart
class CartProvider extends ChangeNotifier {
  // Nuevo
  DeliveryInfo? _deliveryInfo;
  
  // Propiedades actualizadas
  double get subtotal => ...          // Solo productos
  double get deliveryFee => ...       // Del envío
  double get totalPrice => subtotal + deliveryFee  // Total
  
  // Métodos nuevos
  void setDeliveryInfo(DeliveryInfo info) { ... }
  String get deliveryTypeLabel { ... }
  
  // Método modificado
  void clear() {
    _items.clear();
    _deliveryInfo = null;  // Nuevo
    notifyListeners();
  }
}
```

### CartScreen - Validaciones Nuevas

```dart
// Botón "Confirmar pedido" está DESHABILITADO si:
if (cart.deliveryInfo == null) {
  button.enabled = false
  button.label = "Selecciona tipo de envío"
}

// Botón está HABILITADO si:
if (cart.deliveryInfo != null && cart.deliveryInfo.isValid) {
  button.enabled = true
  button.label = "✓ Confirmar pedido"
}
```

---

## 📊 Diagrama de Secuencia UML

```
Usuario              CartScreen        DeliveryProvider    GPS/Geocoding
  │                      │                  │                    │
  ├─ Toca carrito       ┌─┤                  │                    │
  │                     │ └─ Se muestra      │                    │
  │                     │   DeliverySection  │                    │
  │                     │   (gris, error)    │                    │
  │                     │                    │                    │
  ├─ Toca "Tipo envío"─→├─ Navigate Push    │                    │
  │                     │                  ┌─┤                    │
  │                     │ DeliverySelection │ │                    │
  │                     │ Screen abierta    │ │                    │
  │                     │                    │ │                    │
  ├─ Selecciona "Domicilio"              ─→└─┤                    │
  │                     │                    │ setDeliveryType()  │
  │                     │                    │ (domicile)         │
  │                     │                    │                    │
  ├─ Toca "Obtener Mi Ubicación"            │ requestLocation() │
  │                     │                    ├───────────┐       │
  │  [Cargando...]     │←───────┐           │           │       │
  │  ⏳                │        │           │           │       │
  │                     │      notifyListener()        │       │
  │                     │        │           │           │       │
  │                     │        │           │        checkPermission()
  │                     │        │           │           ├──────→ ✅
  │                     │        │           │        ←──┤
  │                     │        │           │        getCurrentPosition()
  │                     │        │           │           ├──────→ 📍
  │                     │        │           │        ←──┤
  │                     │        │           │        placemarkFromCoordinates()
  │                     │        │           │           ├──────→ 🗺️
  │                     │        │           │        ←──┤
  │                     │        │           │  _state = success
  │                     │        │           │
  │  ✅ Jr. Ucayali 267│←───────┴───────────┤
  │     Lima, 15001    │   rebuild UI       │
  │                     │                    │
  ├─ Toca "Continuar a Pago"───→├─ confirmDelivery() ←┤
  │                     │        ├─ cart.setDeliveryInfo()
  │                     │        │
  │                     │ Navigator.pop()
  │                     │       ├────────────────────────────────┐
  │                     │ Vuelve a CartScreen                  │
  │                     │       │                               │
  │  [Envío]           │←──────┤ DeliverySection actualizada   │
  │  Envío a domicilio │       │ (verde, confirmado)           │
  │  +$5.000           │       │                               │
  │                     │       │ Botón "Confirmar" ENABLED     │
  │                     │       │                               │
  ├─ Toca "Confirmar pedido"───→├─ _showOrderConfirmation()
  │                     │        │
  │  🎉                │        │
  │  ¡Pedido confirmado!        │
  │                     │        ├─ cart.clear()
  │                     │        │
  │  [Aceptar]         │        └─ rebuild UI (carrito vacío)
  │
  └─ Carrito vacío     └─ ready para nueva orden
```

---

## 🔐 Seguridad y Privacidad

### Permisos Requeridos

**Android** (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (Info.plist):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para confirmar el envío de tu pedido</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para confirmar el envío</string>
```

### Protección de Datos

- La ubicación se obtiene **una sola vez por orden**
- Se limpia cuando el usuario **limpia el carrito**
- No se almacena de forma permanente
- Se muestra solo en formato legible (dirección)
- Coordenadas se redondean a 4 decimales para privacidad

---

## 📝 Resumen de Tareas en Cada Etapa

| Etapa | Responsable | Acción | Validación |
|-------|-------------|--------|-----------|
| 1. Instancia | DeliveryProvider() | Resetea todo a inicial | _state == initial |
| 2. Selección | Usuario | Elige tipo envío | UI muestra opciones |
| 3. Permisos | SO + DeliveryProvider | Solicita permisos | PermissionStatus |
| 4. GPS | Geolocator | Obtiene coordenadas | Position != null |
| 5. Geocoding | Geocoding | Convierte a dirección | Placemark != null |
| 6. Actualización | DeliveryProvider | Actualiza _currentLocation | _state == success |
| 7. Confirmación | Usuario | Confirma envío | deliveryInfo.isValid |
| 8. Checkout | CartProvider | Guarda en carrito | cart.deliveryInfo != null |

---

## 🔄 Ciclo Completo (Resumen Ejecutivo)

```
TIEMPO        ESTADO                    ACCIÓN
────────────────────────────────────────────────────────────────
0s            initial                   App inicia
              ↓ Usuario abre carrito
              ↓ Toca "Selecciona tipo"
              ↓ Navega a DeliverySelection
              ↓ Elige "Envío a domicilio"
    
1s            initial → loading         "Obtener Mi Ubicación" clicked
              ↓ Solicita permisos
              
2-3s          loading                   "Aceptar permisos" en diálogo SO
              
4s            loading → locationGranted Permisos otorgados
              ↓ Inicia GPS
              
5-15s         loading                   Buscando señal GPS (tiempo variable)
              ↓ GPS encontrado
              ↓ Convirtiendo coordenadas
              
16s           loading → success         Ubicación confirmada ✅
              ↓ Actualiza UI
              
17s           success                   Usuario ve "Jr. Ucayali 267..."
              ↓ Toca "Continuar al Pago"
              
18s           success                   Confirma envío
              ↓ Regresa a CartScreen
              
19s           success                   DeliveryInfo guardado en cart
              ↓ Usuario toca "Confirmar"
              
20s           N/A                       Modal de confirmación
              ↓ "Aceptar"
              ↓ cart.clear()
              
21s           initial (reset)           Carrito vacío, listo para nueva orden
```

---

## 🚀 Futuras Mejoras Sugeridas

1. **Cálculo de costo dinámico**: Basarse en distancia real
2. **Guardar ubicaciones favoritas**: Para futuras órdenes
3. **Mapa interactivo**: Permitir seleccionar ubicación manualmente
4. **Notificaciones en tiempo real**: Estado del pedido y entrega
5. **Estimado de entrega**: Basado en dirección y horario
6. **Integración con Uber Maps o Google Maps**: Para mejores direcciones
7. **Historial de direcciones**: De órdenes anteriores
8. **Validación de direcciones**: Antes de confirmar

---

**Última actualización**: 21 de abril de 2026
**Versión de la app**: 1.0.0
**Framework**: Flutter 3.0+
