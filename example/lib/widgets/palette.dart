import 'package:flutter/widgets.dart';

/// The example's colours. It uses no component library, so this small table
/// (picked by the platform brightness) is the whole theme.
class Palette {
  const Palette._({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.text,
    required this.muted,
    required this.border,
    required this.hover,
    required this.accent,
    required this.accentSurface,
    required this.success,
    required this.danger,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color text;
  final Color muted;
  final Color border;
  final Color hover;
  final Color accent;
  final Color accentSurface;
  final Color success;
  final Color danger;

  static const light = Palette._(
    isDark: false,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F7),
    text: Color(0xFF1D1D1F),
    muted: Color(0xFF6E6E73),
    border: Color(0xFFDCDCE0),
    hover: Color(0x0F000000),
    accent: Color(0xFF1668DC),
    accentSurface: Color(0xFFE3EEFD),
    success: Color(0xFF1E8E3E),
    danger: Color(0xFFD93025),
  );

  static const dark = Palette._(
    isDark: true,
    background: Color(0xFF1E1E20),
    surface: Color(0xFF28282B),
    text: Color(0xFFF2F2F4),
    muted: Color(0xFF9A9AA0),
    border: Color(0xFF3A3A3E),
    hover: Color(0x14FFFFFF),
    accent: Color(0xFF6AA8FF),
    accentSurface: Color(0xFF1D3557),
    success: Color(0xFF5BD07A),
    danger: Color(0xFFFF6B61),
  );

  static Palette of(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? dark
      : light;

  TextStyle get mono => TextStyle(
    fontSize: 11,
    height: 1.35,
    fontFamily: 'Menlo',
    fontFamilyFallback: const ['Consolas', 'DejaVu Sans Mono', 'monospace'],
    color: muted,
  );
}
