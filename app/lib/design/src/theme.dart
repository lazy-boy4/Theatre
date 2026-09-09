import 'package:flutter/material.dart';

// Theatre design token layer — PRD F4, architecture §14, docs/design.md.
//
// ALL Material color/type/spacing decisions live here. Screens read
// Theme.of(context) — never hardcode Colors.* for chrome or text.
// Swap path: when official Flutter M3E ships, only this directory changes.

/// Projector amber — Theatre's single saturated voice (docs/design.md:
/// The One Voice Rule). Play, progress, selection. Never errors.
const kTheatreSeed = Color(0xFFE8B44A);

/// 4-unit spacing scale (docs/design.md). Prefer these over one-off values.
abstract final class TSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

ThemeData theatreTheme({Brightness brightness = Brightness.dark}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kTheatreSeed,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
      selectedLabelTextStyle: TextStyle(color: scheme.onSurface),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: scheme.surfaceContainer),
    listTileTheme: const ListTileThemeData(tileColor: Colors.transparent),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.primary,
      thumbColor: scheme.primary,
      inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.3),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? scheme.primary : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary.withValues(alpha: 0.5)
            : null,
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: scheme.surfaceContainerHigh),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      actionTextColor: scheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
  );
}
