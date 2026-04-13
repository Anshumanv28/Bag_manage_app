import 'package:flutter/material.dart';

class AppPalette {
  // Primary / Secondary
  static const primary = Color(0xFF1E3A8A); // Deep Blue
  static const secondary = Color(0xFF3B82F6); // Secondary Blue

  // Accent / Status
  static const amber = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);

  // Neutrals
  static const background = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);

  // Soft fills
  static const navSelectedPill = Color(0xFFDBEAFE);
  static const successSoft = Color(0xFFECFDF5);
  static const amberSoft = Color(0xFFFEF3C7);
}

ThemeData appTheme() {
  final cs = ColorScheme.light(
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.navSelectedPill,
    onPrimaryContainer: AppPalette.primary,
    secondary: AppPalette.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppPalette.navSelectedPill,
    onSecondaryContainer: AppPalette.primary,
    error: AppPalette.danger,
    onError: Colors.white,
    surface: AppPalette.card,
    onSurface: AppPalette.textPrimary,
    surfaceContainerHighest: AppPalette.card,
    outline: AppPalette.border,
    outlineVariant: AppPalette.border,
    onSurfaceVariant: AppPalette.textSecondary,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: cs);

  return base.copyWith(
    scaffoldBackgroundColor: AppPalette.background,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: AppPalette.background,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 1.5,
      color: AppPalette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppPalette.card,
      indicatorColor: AppPalette.navSelectedPill,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? AppPalette.primary : AppPalette.textSecondary,
          fontWeight: FontWeight.w700,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppPalette.primary : AppPalette.textSecondary,
        );
      }),
    ),
    // SnackBars are intentionally not used in this app; alerts are modal pop-ups and logged to Notifications.
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppPalette.border;
          }
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFF162E6E); // darker primary
          }
          return AppPalette.primary;
        }),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        side: const WidgetStatePropertyAll(BorderSide(color: AppPalette.border)),
        foregroundColor: const WidgetStatePropertyAll(AppPalette.textPrimary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppPalette.primary),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.card,
      labelStyle: const TextStyle(color: AppPalette.textSecondary),
      hintStyle: const TextStyle(color: AppPalette.textSecondary),
      prefixIconColor: AppPalette.textSecondary,
      suffixIconColor: AppPalette.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.secondary, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppPalette.border),
  );
}

