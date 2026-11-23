import 'dart:ui' show Color;

// Internal color constants for the package's widgets. Not exported, so the
// package stays free of any design-system dependency.

const kBlack = Color(0xFF000000);
const kWhite = Color(0xFFFFFFFF);
const kTransparent = Color(0x00000000);

/// Default [VirtualWindowFrame] border on a light platform (12% black).
const kFrameBorderLight = Color(0x1F000000);

/// Default [VirtualWindowFrame] border on a dark platform (12% white).
const kFrameBorderDark = Color(0x1FFFFFFF);
