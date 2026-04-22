# 🏗️ Arquitectura del Sistema de Envío a Domicilio

## Diagrama de Capas

```
┌──────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
│                      (Interfaz de Usuario)                          │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    CartScreen                               │  │
│  │  - Muestra productos en carrito                             │  │
│  │  - Desglose de precios (productos + envío)                  │  │
│  │  - Botón "Selecciona tipo de envío" (clickeable)            │  │
│  │  - Botón "Confirmar pedido"                                 │  │
│  └────────┬──────────────────────────────────────────────────────┘  │
│           │                                                          │
│           │ Navigator.push()                                        │
│           ▼                                                          │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │           DeliverySelectionScreen                           │  │
│  │  - Opciones: Recogida / Envío a domicilio                   │  │
│  │  - Botón "Obtener Mi Ubicación" (si domicile)               │  │
│  │  - Muestra dirección obtenida                               │  │
│  │  - Botón "Continuar al Pago"                                │  │
│  └────────┬──────────────────────────────────────────────────────┘  │
│           │                                                          │
│           │ cart.setDeliveryInfo()                                  │
│           │ Navigator.pop()                                        │
│           ▼                                                          │
│     Vuelve a CartScreen                                            │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Lee/Escribe
                              │
┌──────────────────────────────┴──────────────────────────────────────┐
│                      BUSINESS LOGIC LAYER                           │
│                    (Gestión de Estado)                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────┐      ┌──────────────────────────────┐ │
│  │   CartProvider          │      │  DeliveryProvider            │ │
│  │   (ChangeNotifier)      │      │  (ChangeNotifier)            │ │
│  ├─────────────────────────┤      ├──────────────────────────────┤ │
│  │ - _items{}              │      │ - _state                     │ │
│  │ - _deliveryInfo         │      │ - _deliveryInfo              │ │
│  │                         │      │ - _currentLocation           │ │
│  │ Methods:                │      │ - _errorMessage              │ │
│  │ + addItem()             │      │                              │ │
│  │ + removeItem()          │      │ Methods:                     │ │
│  │ + setDeliveryInfo() ◄───┼──────┼─→ + initialize()             │ │
│  │ + clear()               │      │ + requestLocation()          │ │
│  │ + totalPrice (getter)   │      │ + setDeliveryType()          │ │
│  │ + deliveryFee (getter)  │      │ + confirmDelivery()          │ │
│  └─────────────────────────┘      │ + reset()                    │ │
│                                   └──────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Lee/Escribe
                              │
┌──────────────────────────────┴──────────────────────────────────────┐
│                          MODEL LAYER                                │
│                      (Estructuras de Datos)                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    DeliveryInfo                               │ │
│  │  ┌────────────────────────────────────────────────────────┐  │ │
│  │  │ - type: DeliveryType (pickup | domicile)             │  │ │
│  │  │ - location: Location?                                │  │ │
│  │  │ - createdAt: DateTime                                │  │ │
│  │  │ - confirmedAt: DateTime?                             │  │ │
│  │  │                                                       │  │ │
│  │  │ Methods:                                             │  │ │
│  │  │ + deliveryFee: double (0 o 5000)                     │  │ │
│  │  │ + isValid: bool                                      │  │ │
│  │  │ + confirm()                                          │  │ │
│  │  └────────┬───────────────────────────────────────────────┘  │ │
│  │           │                                                    │ │
│  │           ▼                                                    │ │
│  │  ┌────────────────────────────────────────────────────────┐  │ │
│  │  │                     Location                           │  │ │
│  │  │  - latitude: double                                   │  │ │
│  │  │  - longitude: double                                  │  │ │
│  │  │  - address: String?                                   │  │ │
│  │  │  - city: String?                                      │  │ │
│  │  │  - postalCode: String?                                │  │ │
│  │  │  - fetchedAt: DateTime                                │  │ │
│  │  │                                                       │  │ │
│  │  │  Methods:                                             │  │ │
│  │  │  + formattedLocation: String                          │  │ │
│  │  │  + fullDetails: String                                │  │ │
│  │  └────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Llamadas
                              │
┌──────────────────────────────┴──────────────────────────────────────┐
│                        EXTERNAL SERVICES                            │
│                    (APIs de Geolocalización)                        │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────────┐          ┌──────────────────────────────┐ │
│  │  geolocator ^10.1.0  │          │  geocoding ^2.1.1            │ │
│  │                      │          │                              │ │
│  │ Obtiene:             │          │ Convierte:                   │ │
│  │ • GPS actuales       │          │ • Coordenadas → Dirección    │ │
│  │ • Solicita permisos  │          │ • Usa Google Geocoding API   │ │
│  │ • Maneja errores     │          │ • Retorna Placemark          │ │
│  │                      │          │                              │ │
│  │ Retorna:             │          │ Retorna:                     │ │
│  │ Position {           │          │ Placemark {                  │ │
│  │  latitude,           │          │  name,                       │ │
│  │  longitude,          │          │  street,                     │ │
│  │  altitude,           │          │  locality,                   │ │
│  │  timestamp           │          │  postalCode,                 │ │
│  │ }                    │          │  country                     │ │
│  └──────────────────────┘          └──────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Diagrama de Flujo de Datos

```
                            START
                              │
                              ▼
                    ┌─────────────────┐
                    │  Usuario abre   │
                    │  Carrito        │
                    └────────┬────────┘
                             │
                             ▼
        ┌────────────────────────────────────────────┐
        │   CartScreen muestra                       │
        │   - Lista de productos                     │
        │   - Subtotal                               │
        │   - Botón "Selecciona tipo envío"          │
        │   - Botón "Confirmar" (DISABLED)           │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ DeliveryProvider.initialize(                │
        │   type: DeliveryType.initial                │
        │ )                                           │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │   DeliverySelectionScreen                  │
        │   Estado: DeliveryState.initial             │
        │   Opción 1: Recogida en tienda (Click)      │
        │   Opción 2: Envío a domicilio (Click)       │
        └────────────┬─────────────────────────────┘
                     │
         ┌───────────┴────────────┐
         │                        │
         ▼                        ▼
    [PICKUP]               [DOMICILE]
         │                        │
         │                        ▼
         │              ┌──────────────────────────┐
         │              │ deliveryProvider        │
         │              │ .setDeliveryType(       │
         │              │   DeliveryType.domicile │
         │              │ )                       │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ DeliveryInfo.isValid?   │
         │              │ NO (sin ubicación)      │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ Usuario toca:            │
         │              │ "Obtener Mi Ubicación"   │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ deliveryProvider        │
         │              │ .requestLocation()       │
         │              │ _state = loading         │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ checkPermission()        │
         │              │ • granted    → continua  │
         │              │ • denied     → solicita  │
         │              │ • forever    → error     │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ Geolocator.              │
         │              │ getCurrentPosition(      │
         │              │  timeout: 30s            │
         │              │ )                        │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ ¿Posición obtenida?      │
         │              │ • SI → geocoding         │
         │              │ • NO → error             │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ placemarkFromCoordinates │
         │              │ (latitude, longitude)    │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ _state = success         │
         │              │ _currentLocation =       │
         │              │   Location(...)          │
         │              │ isValid = true           │
         │              └──────────┬───────────────┘
         │                         │
         │                         ▼
         │              ┌──────────────────────────┐
         │              │ UI muestra:              │
         │              │ ✅ Ubicación obtenida    │
         │              │    Jr. Ucayali 267       │
         │              │ [Continuar al Pago]      │
         │              └──────────┬───────────────┘
         │                         │
         └──────────┬──────────────┘
                    │
                    ▼
        ┌────────────────────────────────────────────┐
        │ deliveryProvider                           │
        │ .confirmDelivery()                         │
        │ • confirmedAt = now()                      │
        │ • cart.setDeliveryInfo(deliveryInfo)       │
        │ • Navigator.pop()                          │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ CartScreen actualizado                     │
        │ - Subtotal: $20.000                        │
        │ - Envío: $5.000 (PICKUP = $0)              │
        │ - Total: $25.000                           │
        │ - Botón "Confirmar" (ENABLED!)             │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ Usuario toca "Confirmar pedido"            │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ _showOrderConfirmation():                  │
        │ 🎉 ¡Pedido confirmado!                     │
        │ Total: $25.000                             │
        │ Tipo: Envío a domicilio                    │
        │ [Aceptar]                                  │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ cart.clear()                               │
        │ • _items = {}                              │
        │ • _deliveryInfo = null                     │
        │ • notifyListeners()                        │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ CartScreen vacío                           │
        │ "Tu carrito está vacío"                    │
        │ Listo para nueva orden                     │
        └────────────┬─────────────────────────────┘
                     │
                     ▼
                    END
```

---

## Diagrama de Estados del DeliveryProvider

```
                    ┌─────────────────┐
                    │    INITIAL      │ ← DeliveryProvider()
                    │ (App starts)    │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
         [PICKUP]                     [DOMICILE]
         Seleccionado                 Seleccionado
         isValid = true               isValid = false
         No cambia estado             → LOADING
              │                             │
              │                             ▼
              │                    ┌──────────────────┐
              │                    │   LOADING        │
              │                    │ (Solicita datos) │
              │                    └────────┬─────────┘
              │                             │
              │         ┌───────────────────┼───────────────┐
              │         │                   │               │
              │         ▼                   ▼               ▼
              │    [GRANTED]          [DENIED]      [ERROR/TIMEOUT]
              │  Permisos OK       Permisos NO    Error de GPS
              │  → GPS             _state = DENIED (POSITION_UNAVAIL)
              │                    errorMsg =      _state = ERROR
              │                    "Permiso..."    errorMsg = "..."
              │                                    
              │         ▼
              │  [SUCCESS]
              │  isValid = true
              │  _currentLocation ≠ null
              │
              ├──────────────────────────────┐
              │ Usuario toca                 │
              │ "Continuar al Pago"          │
              │                              │
              ▼                              ▼
        [CONFIRMED]                  [CONFIRMED]
        - createdAt                  - createdAt
        - confirmedAt (ahora)       - confirmedAt (ahora)
        - Guardado en cartProvider   - Guardado en cartProvider
        
        (Orden completada)                 │
                                           ▼
                            cart.clear() - RESET
                            
                                 └─────→ INITIAL
                                       (Nueva orden)
```

---

## Diagrama de Clases

```
┌────────────────────────────────────┐
│          DeliveryType              │
│         (Enum)                     │
├────────────────────────────────────┤
│ PICKUP                             │
│ DOMICILE                           │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│          Location                  │
│        (Data Class)                │
├────────────────────────────────────┤
│ - latitude : double                │
│ - longitude : double               │
│ - address : String?                │
│ - city : String?                   │
│ - postalCode : String?             │
│ - fetchedAt : DateTime             │
├────────────────────────────────────┤
│ + formattedLocation() : String     │
│ + fullDetails() : String           │
└────────────────────────────────────┘

┌────────────────────────────────────────────┐
│           DeliveryInfo                     │
│         (Data Class)                       │
├────────────────────────────────────────────┤
│ - type : DeliveryType             │
│ - location : Location?                    │
│ - createdAt : DateTime                    │
│ - confirmedAt : DateTime?                 │
├────────────────────────────────────────────┤
│ + get deliveryFee() : double               │
│ + get isValid() : bool                     │
│ + confirm() : void                        │
└────────────────────────────────────────────┘

┌───────────────────────────────────────────┐
│       DeliveryProvider                    │
│  extends ChangeNotifier                   │
├───────────────────────────────────────────┤
│ - _state : DeliveryState                  │
│ - _deliveryInfo : DeliveryInfo?           │
│ - _currentLocation : Location?            │
│ - _errorMessage : String?                 │
├───────────────────────────────────────────┤
│ + get state() : DeliveryState              │
│ + get deliveryInfo() : DeliveryInfo?       │
│ + get currentLocation() : Location?        │
│ + get isLoading() : bool                   │
│ + get hasLocation() : bool                 │
│ + initialize() : void                      │
│ + requestLocation() : Future<bool>         │
│ + setDeliveryType() : void                 │
│ + confirmDelivery() : bool                 │
│ + reset() : void                          │
└───────────────────────────────────────────┘


┌─────────────────────────────────────────────┐
│         CartProvider                        │
│    extends ChangeNotifier                   │
├─────────────────────────────────────────────┤
│ - _items : Map<String, CartItem>            │
│ - _deliveryInfo : DeliveryInfo?             │
├─────────────────────────────────────────────┤
│ + get items() : Map                         │
│ + get deliveryInfo() : DeliveryInfo?        │
│ + get itemCount() : int                     │
│ + get subtotal() : double                   │
│ + get deliveryFee() : double                │
│ + get totalPrice() : double                 │
│ + addItem() : void                          │
│ + removeItem() : void                       │
│ + setDeliveryInfo() : void                  │
│ + clear() : void                            │
└─────────────────────────────────────────────┘
```

---

## Integración con Provider Package

```
┌─────────────────────────────────────────┐
│         main.dart - runApp()             │
└───────────────┬─────────────────────────┘
                │
                ▼
    ┌───────────────────────────────┐
    │     MultiProvider             │
    │   providers: [                │
    │     CartProvider(),           │
    │     DeliveryProvider(),       │
    │   ]                           │
    └───────────┬───────────────────┘
                │
    ┌───────────┴──────────┐
    │                      │
    ▼                      ▼
┌──────────────┐    ┌──────────────────┐
│CartProvider  │    │DeliveryProvider  │
│(Singleton)   │    │(Singleton)       │
└──────┬───────┘    └────────┬─────────┘
       │                     │
       │                     │
       ├─► Consumer<CartProvider>
       │     • CartScreen
       │     • OrderSummary
       │
       ├─► Provider.of<CartProvider>()
       │     • OtherScreens
       │
       └─► context.read<CartProvider>()
           • Methods
           • Métodos imperativos


       ├─► Consumer<DeliveryProvider>
       │     • DeliverySelectionScreen
       │     • CartScreen (muestra estado)
       │
       ├─► Provider.of<DeliveryProvider>()
       │     • OtherScreens
       │
       └─► context.read<DeliveryProvider>()
           • requestLocation()
           • confirmDelivery()
```

---

## Flujo de Widget Tree

```
CafeApp (MaterialApp)
│
└── MainShell (StatefulWidget)
    │
    ├── IndexedStack (muestra pantalla actual)
    │
    ├── [0] HomeScreen
    ├── [1] MenuScreen
    ├── [2] 🎯 CartScreen ◄─── NOS IMPORTA ESTA
    │   │
    │   ├── AppBar
    │   │   └── Consumer<CartProvider>
    │   │       └── Botón "Vaciar"
    │   │
    │   ├── Body
    │   │   └── Consumer<CartProvider>
    │   │       └── ListView (items)
    │   │
    │   └── BottomSection
    │       └── Consumer<DeliveryProvider>
    │           ├── _buildDeliverySection()
    │           │   └── GestureDetector
    │           │       └── Navigator.push(DeliverySelectionScreen)
    │           │
    │           ├── _buildPriceBreakdown()
    │           │
    │           └── ElevatedButton("Confirmar")
    │
    ├── [3] ProfileScreen
    │
    └── NavigationBar


DeliverySelectionScreen (cuando se abre)
│
├── AppBar
│   └── BackButton
│
├── Body
│   └── Consumer<DeliveryProvider>
│       ├── _buildDeliveryOption(pickup)
│       │   └── GestureDetector
│       │       └── setDeliveryType(pickup)
│       │
│       ├── _buildDeliveryOption(domicile)
│       │   └── GestureDetector
│       │       └── setDeliveryType(domicile)
│       │
│       └── IF type == DOMICILE
│           └── _buildLocationSection()
│               ├── IF loading
│               │   └── CircularProgressIndicator
│               │
│               ├── IF hasLocation
│               │   └── _buildLocationCard()
│               │       └── Muestra dirección
│               │
│               └── IF no location
│                   └── _buildGetLocationButton()
│                       └── OutlinedButton
│                           └── requestLocation()
```

---

## Estados y Transiciones

```
┌─────────────┐
│  INITIAL    │ ← Estado inicial cuando DeliveryProvider se crea
└──────┬──────┘
       │ initialize()
       │
       ├─ setDeliveryType(PICKUP)
       │  └─ isValid = true
       │     (Sin cambio de estado)
       │
       └─ setDeliveryType(DOMICILE)
          └─ isValid = false
             requestLocation() →  ┌─────────────┐
                                  │  LOADING    │
                                  └──────┬──────┘
                                         │
                          ┌──────────────┼──────────────┐
                          │              │              │
                          ▼              ▼              ▼
                    ┌─────────┐    ┌─────────┐    ┌────────┐
                    │GRANTED  │    │DENIED   │    │ERROR   │
                    │Permisos │    │Permisos │    │Timeout │
                    │OK       │    │Denegado │    │/Otros  │
                    └────┬────┘    └────┬────┘    └────┬───┘
                         │              │             │
                         ▼              ▼             ▼
                    ┌─────────────────────────────────────┐
                    │ Geocoding / Error                   │
                    └────────┬────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
               ┌────────┐         ┌─────────┐
               │SUCCESS │         │ERROR    │
               │Ubicación        │Error    │
               │OK               │Geocoding│
               └────┬────┘         └────┬───┘
                    │                  │
                    │ confirmDelivery()│
                    │ (usuario decide) │
                    │                  │
                    └──────┬───────────┘
                           │
                    ┌──────▼───────┐
                    │CONFIRMED     │
                    │/Guardado en  │
                    │CartProvider  │
                    └──────┬───────┘
                           │
                    cart.clear()
                           │
                           └─→ RESET → INITIAL
```

---

## Diagrama de Responsabilidades

```
┌─────────────────────────────────────────┐
│ DeliverySelectionScreen                 │
│ RESPONSABILIDADES:                      │
│ • Mostrar opciones de envío             │
│ • Capturar selección del usuario        │
│ • Llamar a DeliveryProvider             │
│ • Mostrar UI de cargando                │
│ • Mostrar errores                       │
│ • Confirmar y volver                    │
│ • Guardar en CartProvider               │
└────────────────┬────────────────────────┘
                 │
                 ├─ LLAMA A →
                 │
    ┌────────────▼──────────────────┐
    │ DeliveryProvider              │
    │ RESPONSABILIDADES:            │
    │ • Solicitar permisos          │
    │ • Obtener GPS                 │
    │ • Decodificar ubicación       │
    │ • Manejar errores             │
    │ • Mantener estado             │
    │                               │
    └────────────┬──────────────────┘
                 │
                 ├─ LLAMA A →
                 │
    ┌────────────▼──────────────────┐
    │ geolocator package            │
    │ RESPONSABILIDADES:            │
    │ • Solicitar permisos SO       │
    │ • Obtener GPS del dispositivo │
    │ • Manejar timeouts           │
    │ • Retornar Position           │
    │                               │
    └────────────┬──────────────────┘
                 │
                 ├─ LLAMA A →
                 │
    ┌────────────▼──────────────────┐
    │ geocoding package             │
    │ RESPONSABILIDADES:            │
    │ • Llamar Google Geocoding API │
    │ • Decodificar coordenadas     │
    │ • Retornar Placemark          │
    │ • Manejar errores de red      │
    │                               │
    └───────────────────────────────┘


┌─────────────────────────────────────────┐
│ CartScreen                              │
│ RESPONSABILIDADES:                      │
│ • Mostrar productos                     │
│ • Mostrar PreviewoDelivery (opcional)   │
│ • Permitir cambiar tipo de envío        │
│ • Mostrar total actualizado             │
│ • Validar que hay delivery info         │
│ • Confirmar pedido                      │
│ • Mostrar confirmación                  │
│                               │
└────────────┬──────────────────┘
             │
             ├─ CONSULTA →
             │
  ┌──────────▼────────────┐
  │ CartProvider          │
  │ RESPONSABILIDADES:    │
  │ • Guardar envío       │
  │ • Calcular totales    │
  │ • Limpiar carrito     │
  │ • Notificar cambios   │
  │                       │
  └───────────────────────┘
```

---

**Última actualización**: 21 de abril de 2026  
**Versión**: 1.0.0
