# 🔐 Configuración de Permisos - Geolocalización

Esta guía te ayudará a configurar los permisos necesarios para que la funcionalidad de envío a domicilio funcione correctamente en Android e iOS.

---

## 🤖 Android

### 1. AndroidManifest.xml

**Ubicación**: `android/app/src/main/AndroidManifest.xml`

**Qué agregar**:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.cafe_app">

    <!-- AGREGAR ESTOS PERMISOS -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <application>
        <!-- ... resto de la configuración ... -->
    </application>
</manifest>
```

### 2. Versión mínima de Android

**Ubicación**: `android/app/build.gradle.kts` o `android/app/build.gradle`

**Verificar que tienes**:
```gradle
android {
    compileSdk 34  // O versión compatible
    
    defaultConfig {
        minSdkVersion 21  // Mínimo recomendado para geolocator
        targetSdkVersion 34
    }
}
```

### 3. Permisos en Tiempo de Ejecución

Con Android 6.0 (API 23) en adelante, los permisos de ubicación deben solicitarse en **tiempo de ejecución**.

✅ **Lo bueno**: La librería `geolocator` ya maneja esto automáticamente.

Cuando el usuario toca "Obtener Mi Ubicación", aparecerá un diálogo como este:

```
┌─────────────────────────────────────┐
│ CaféApp quiere acceder a tu ubicación
│                                     │
│ ¿Permitir que CaféApp acceda a tu  │
│ ubicación mientras usas esta app?   │
│                                     │
│ [No permitir]  [Permitir]          │
└─────────────────────────────────────┘
```

### 4. Probar en Android

```bash
flutter run -d android
```

Luego:
1. Abre el carrito
2. Selecciona "Envío a domicilio"
3. Toca "Obtener Mi Ubicación"
4. Acepta el permiso en el diálogo
5. El GPS debería obtener tu ubicación

---

## 🍎 iOS

### 1. Info.plist

**Ubicación**: `ios/Runner/Info.plist`

**Qué agregar**:

Abre el archivo y busca la sección `<dict>`. Dentro de ella, agrega:

```xml
<!-- Ubicación mientras usas la app -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para confirmar el envío de tu pedido</string>

<!-- (Opcional) Ubicación siempre -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para confirmar el envío</string>

<!-- (Opcional) Solo ubicación aproximada -->
<key>NSLocationDefaultAccuracyReduction</key>
<false/>
```

**Ejemplo completo**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- ... otras configuraciones ... -->
	
	<!-- AGREGAR ESTO -->
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Necesitamos tu ubicación para confirmar el envío de tu pedido</string>
	
	<!-- ... más configuraciones ... -->
</dict>
</plist>
```

### 2. Versión mínima de iOS

**Ubicación**: `ios/Podfile`

**Verificar**:
```ruby
platform :ios, '12.0'  # Mínimo recomendado
```

### 3. Probar en iOS

```bash
flutter run -d ios
```

Luego:
1. Abre el carrito
2. Selecciona "Envío a domicilio"
3. Toca "Obtener Mi Ubicación"
4. Acepta el permiso en el diálogo
5. El GPS debería obtener tu ubicación

---

## 🧪 Prueba de Permisos

### Verificar que todo está configurado

```bash
# Analizar la app
flutter analyze

# Compilar (sin ejecutar)
flutter build apk  # Android
flutter build ios  # iOS (necesita Mac)
```

### Simular diferentes escenarios

#### 1. GPS Activado (Caso normal)
```bash
# En el emulador de Android:
# adb emu geo fix -73.9352 40.7306  # Nueva York
```

#### 2. GPS Desactivado
```bash
# Android: Ajustes > Ubicación > Desactivar
# iOS: Ajustes > Privacidad > Ubicación > CaféApp > Nunca
```

#### 3. Permisos Denegados
```bash
# Android: Ajustes > Aplicaciones > CaféApp > Permisos > Ubicación > Denyga
# iOS: Ajustes > Privacidad > Ubicación > CaféApp > Nunca
```

---

## 🐛 Solución de Problemas

### Error: "Permiso de ubicación denegado"

**Síntoma**:
```
Error obteniendo ubicación: Permiso de ubicación denegado
```

**Soluciones**:
1. **Android**:
   - Ve a Ajustes > Aplicaciones > CaféApp > Permisos
   - Asegúrate de que "Ubicación" está activado
   - Si dice "solo cuando uso la app", eso está bien

2. **iOS**:
   - Ve a Ajustes > Privacidad > Ubicación
   - Busca CaféApp
   - Cambia de "Nunca" a "Mientras usas la app"

### Error: "POSITION_UNAVAILABLE"

**Síntoma**:
```
Error obteniendo ubicación: POSITION_UNAVAILABLE
```

**Causas**:
- GPS no está activado
- Estás en un lugar cubierto (dentro de un edificio)
- Mala señal GPS

**Soluciones**:
1. Activa el GPS en los ajustes del dispositivo
2. Acércate a una ventana o sal al aire libre
3. Espera un poco más (hasta 30 segundos)
4. Reinicia el GPS

### Error: TIMEOUT (después de 30 segundos)

**Síntoma**:
```
No se pudo obtener la posición. Intenta en un lugar abierto...
```

**Causas**:
- El GPS tardó más de 30 segundos
- Poca señal satelital
- Edificio alto que bloquea señal

**Soluciones**:
1. Intenta de nuevo en un lugar con mejor visibilidad del cielo
2. Activa el WiFi (el GPS puede auxiliarse de datos WiFi)
3. Aumenta el timeout en `delivery_provider.dart`:
```dart
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  timeLimit: const Duration(seconds: 60),  // Aumenta a 60s
);
```

### Error: "Servicios de ubicación desactivados"

**Síntoma**:
```
Servicios de ubicación desactivados
```

**Android**:
- Ajustes > Ubicación > Activar

**iOS**:
- Ajustes > Privacidad > Servicios de Ubicación > Activar

---

## 📱 Prueba en Dispositivo Real vs Emulador

### Android Emulador

**Ventajas**:
- Puedes simular ubicación fácilmente
- No necesitas dispositivo físico

**Desventajas**:
- GPS puede ser lento o impreciso
- Necesita más recursos de la computadora

**Cómo simular ubicación**:
```bash
# Desde Android Studio Extended Controls
# O via command line:
adb emu geo fix -73.9352 40.7306  # Nueva York
```

### iPhone Simulator

**Ventajas**:
- Rápido para testing
- Puedes simular ubicación

**Desventajas**:
- Solo en Mac
- Algunos features pueden no funcionar igual

**Cómo simular ubicación**:
- Xcode > Scheme > Run > Options > Location > Custom Location
- O: Debug > Location > Custom Location

### Dispositivo Real

**Ventajas**:
- GPS real y preciso
- Comportamiento real

**Desventajas**:
- Requiere dispositivo físico
- Más lento de iterar

**Cómo**:
1. Conecta tu dispositivo USB
2. Activa el "Depuración de USB" (Android) o confía en XCODE (iOS)
3. `flutter devices` para verificar
4. `flutter run -d <device_id>`

---

## 🔍 Verificación de Permisos (Código)

Si necesitas verificar manualmente que los permisos están correctos:

```dart
import 'package:geolocator/geolocator.dart';

Future<void> checkPermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  
  print('Estado actual: $permission');
  // Posibles valores:
  // LocationPermission.granted     ✅ Permitido
  // LocationPermission.denied      ❌ Denegado (puede solicitar de nuevo)
  // LocationPermission.deniedForever ❌ Denegado permanentemente
  
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
}
```

---

## 📋 Checklist de Configuración

### Android
- [ ] Agregué `ACCESS_FINE_LOCATION` a AndroidManifest.xml
- [ ] Agregué `ACCESS_COARSE_LOCATION` a AndroidManifest.xml
- [ ] `minSdkVersion` es 21 o mayor
- [ ] Probé en emulador o dispositivo real
- [ ] Acepté el permiso cuando lo solicitó

### iOS
- [ ] Agregué `NSLocationWhenInUseUsageDescription` a Info.plist
- [ ] El mensaje de descripción es claro y apropiado
- [ ] `platform :ios` es 12.0 o mayor en Podfile
- [ ] Probé en simulator o dispositivo real
- [ ] Cambié el permiso de "Nunca" a "Mientras usas la app"

### General
- [ ] Ejecuté `flutter pub get`
- [ ] Ejecuté `flutter analyze` sin errores críticos
- [ ] Probé "Recogida en tienda" (sin ubicación)
- [ ] Probé "Envío a domicilio" (con ubicación)
- [ ] Verifiqué que se obtiene la ubicación correcta
- [ ] Verifiqué que se calcula el costo de envío correctamente

---

## 📚 Referencias Oficiales

- **Geolocator**: https://pub.dev/packages/geolocator
- **Geocoding**: https://pub.dev/packages/geocoding
- **Android Permissions**: https://developer.android.com/training/location
- **iOS Location**: https://developer.apple.com/documentation/corelocation

---

## 🆘 Si No Funciona

1. Limpia todo:
```bash
flutter clean
flutter pub get
```

2. Reconstruye:
```bash
flutter clean && flutter pub get && flutter run
```

3. Revisa que:
   - Los archivos de configuración se guardaron correctamente
   - No hay caracteres especiales en la descripción del permiso
   - La indentación en XML está correcta

4. Contacta al soporte de `geolocator` si persiste:
   - https://github.com/Baseflow/flutter-geolocator/issues

---

**Última actualización**: 21 de abril de 2026
