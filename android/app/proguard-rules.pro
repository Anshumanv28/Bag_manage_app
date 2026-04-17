# Keep ML Kit + Play Services classes referenced via reflection.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# CameraX / camera plugin (defensive; some parts use reflection).
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

