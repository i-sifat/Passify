# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Riverpod
-keep class ** extends androidx.lifecycle.ViewModel { *; }
-keepclassmembers class ** extends androidx.lifecycle.ViewModel { *; }

# SharedPreferences
-keep class android.app.SharedPreferencesImpl { *; }