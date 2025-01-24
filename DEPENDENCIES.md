# Project Dependencies Reference

## Java & Android Build Tools

- Java Version: OpenJDK 17.0.11
- Android Gradle Plugin (AGP): 8.2.2
- Gradle Version: 8.3
- Kotlin Version: 1.8.22
- Kotlin JVM Target: 17
- Minimum SDK Version: 21
- Target SDK Version: 34
- Compile SDK Version: 34

## Android Dependencies

- AndroidX Multidex: 2.0.1
- AndroidX Window: 1.0.0
- AndroidX Window Java: 1.0.0
- Google Play Core: 1.10.3
- Google Play Core KTX: 1.8.1

## Flutter Dependencies

- Flutter SDK Channel: stable
- Flutter Version: 3.19.x
- Dart Version: 3.6.x

### Main Dependencies

```yaml
dependencies:
  cupertino_icons: ^1.0.8
  google_fonts: ^6.1.0
  flutter_riverpod: ^2.5.1
  shared_preferences: ^2.3.5
  smooth_page_indicator: ^1.1.0
  file_picker: ^8.1.7
  path_provider: ^2.1.5
  crypto: ^3.0.6
  encrypt: ^5.0.3
  share_plus: ^10.1.4
  vibration: ^3.0.0
  package_info_plus: ^8.1.3
  http: ^1.3.0
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_lints: ^5.0.0
```

## Gradle Plugin Versions

```groovy
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.2.2"
    id "org.jetbrains.kotlin.android" version "1.8.22"
}
```

## Notes

- All Android dependencies are configured for Java 17 compatibility
- The project uses AndroidX libraries instead of legacy Android Support libraries
- Multidex is enabled by default for supporting large numbers of methods
- ProGuard/R8 optimization is enabled for release builds