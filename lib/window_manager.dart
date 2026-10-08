/// Windows on nativeapi: the `Window` and `WindowManager` API, the window
/// events, the drag and resize areas, and this package's own title bar
/// widgets.
///
/// Code written for window_manager 0.5.x imports
/// `package:window_manager/legacy.dart` instead.
///
/// nativeapi's `Point`, `Size`, `Rectangle` and `Color` are not exported, as
/// Flutter has its own; convert with `toOffset()`, `toSize()`, `toRect()`,
/// `toColor()` and `toNative()`.
library;

export 'package:nativeapi/nativeapi.dart'
    show
        EventDecision,
        EventRequest,
        ListenerId,
        ResizeEdge,
        TitleBarStyle,
        VisualEffect,
        Window,
        WindowBlurredEvent,
        WindowClosedEvent,
        WindowCloseRequestedEvent,
        WindowCornerPreference,
        WindowCreatedEvent,
        WindowEnteredFullScreenEvent,
        WindowEvent,
        WindowExitedFullScreenEvent,
        WindowFocusedEvent,
        WindowId,
        WindowManager,
        WindowMaximizedEvent,
        WindowMinimizedEvent,
        WindowMovedEvent,
        WindowOcclusionChangedEvent,
        WindowOcclusionState,
        WindowProperty,
        WindowPropertyChangedEvent,
        WindowResizedEvent,
        WindowRestoredEvent;
export 'package:nativeapi_flutter/nativeapi_flutter.dart'
    show
        ColorToNative,
        DragToMoveArea,
        DragToResizeArea,
        MaximizeButtonArea,
        NativeColorToColor,
        NativeSizeToSize,
        OffsetToNative,
        PointToOffset,
        RectToNative,
        RectangleToRect,
        SizeToNative;

export 'src/widgets/virtual_window_frame.dart';
export 'src/widgets/window_caption.dart';
export 'src/widgets/window_caption_button.dart';
