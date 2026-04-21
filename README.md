# ☕ CaféApp — Flutter

Aplicación de cafetería desarrollada con Flutter para Android.

---

## 📋 Requisitos previos

Antes de ejecutar el proyecto necesitas tener instalado:

1. **Flutter SDK** (versión 3.10 o superior)
   - Descarga: https://flutter.dev/docs/get-started/install
2. **Android Studio** o **VS Code** con extensión Flutter
3. **Java JDK 17** (incluido en Android Studio)
4. Un dispositivo Android físico **o** un emulador configurado

---

## 🚀 Pasos para ejecutar

### 1. Crear el proyecto Flutter base
Abre una terminal y ejecuta:
```bash
flutter create cafe_app
cd cafe_app
```

### 2. Reemplazar los archivos
Copia los archivos de este proyecto dentro de la carpeta `cafe_app/`:
- Reemplaza `pubspec.yaml`
- Reemplaza `lib/main.dart`
- Copia todas las carpetas dentro de `lib/`

La estructura final debe quedar así:
```
cafe_app/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── product.dart
│   │   └── cart_item.dart
│   ├── providers/
│   │   └── cart_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── detail_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── cart_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/
│       ├── product_card.dart
│       ├── product_list_tile.dart
│       └── category_chip.dart
└── android/
    └── app/src/main/AndroidManifest.xml
```

### 3. Instalar dependencias
```bash
flutter pub get
```

### 4. Verificar dispositivo conectado
```bash
flutter devices
```
Deberías ver tu dispositivo Android o emulador en la lista.

### 5. Ejecutar la app
```bash
flutter run
```
Para ejecutar en modo release (más rápido):
```bash
flutter run --release
```

---

## 📱 Generar APK para Android

### APK de debug (para pruebas):
```bash
flutter build apk --debug
```
El archivo se genera en: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de release:
```bash
flutter build apk --release
```
El archivo se genera en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧩 Widgets Flutter utilizados

| Widget | Uso en la app |
|--------|--------------|
| `Scaffold` | Estructura base de cada pantalla |
| `AppBar` / `SliverAppBar` | Barra superior con scroll |
| `NavigationBar` | Navegación inferior con badge |
| `GridView.builder` | Grid de productos en inicio |
| `ListView.builder` | Lista del carrito y menú |
| `Card` / `Container` | Tarjetas de productos |
| `Hero` | Animación de emoji entre pantallas |
| `AnimatedContainer` | Botón de carrito animado |
| `AnimatedSwitcher` | Cambio animado de cantidad |
| `SnackBar` | Confirmación al agregar productos |
| `TextField` | Barra de búsqueda |
| `Provider` / `ChangeNotifier` | Gestión de estado del carrito |
| `Consumer` | Widgets reactivos al carrito |
| `Badge` | Contador en ícono del carrito |
| `FilterChip` / `CategoryChip` | Filtros de categoría |
| `ModalBottomSheet` | Confirmación de pedido |
| `AlertDialog` | Confirmación para vaciar carrito |
| `MediaQuery` | Adaptación a tamaño de pantalla |

---

## 🎨 Paleta de colores

| Color | Hex | Uso |
|-------|-----|-----|
| Marrón oscuro | `#4E2D1E` | AppBar, botones primarios |
| Marrón medio | `#6F4E37` | Gradientes |
| Dorado | `#C8943A` | Precios, acentos |
| Crema | `#FAF7F2` | Fondo principal |
| Crema claro | `#F5E6D3` | Fondos de tarjetas |
| Marrón oscuro | `#2C1A0E` | Texto principal |

---

## 📦 Dependencias (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0   # Fuentes Playfair Display y Lato
  provider: ^6.1.1        # Gestión de estado del carrito
  cupertino_icons: ^1.0.6
```

---

## 🔄 Ciclo de vida aplicado

1. **Análisis** → Definición de requerimientos de la cafetería
2. **Diseño** → Wireframes y selección de widgets
3. **Implementación** → Código Dart/Flutter
4. **Pruebas** → `flutter test` y pruebas en emulador
5. **Despliegue** → Generación de APK
6. **Mantenimiento** → Futuras actualizaciones (pagos, notificaciones)
