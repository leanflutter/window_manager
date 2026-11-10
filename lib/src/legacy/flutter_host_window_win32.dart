import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

const _gwOwner = 4;

typedef _EnumWindowsProcNative = Int32 Function(IntPtr hwnd, IntPtr lParam);

/// The `HWND` of this process's only top-level window that hosts a Flutter
/// view, or 0 when there is none, more than one, or the platform is not
/// Windows.
///
/// nativeapi finds the current window on Windows through `GetActiveWindow()`,
/// which knows nothing of a window that is still hidden. A Flutter runner
/// parents the engine's view (window class `FLUTTERVIEW`) to its top-level
/// window, visible or not; when that identifies a single window of this
/// process, it is the app's window. With several such windows the answer
/// would be a guess, so there is none.
int findSoleFlutterHostWindow() {
  if (!Platform.isWindows) return 0;
  final api = _Win32.instance;
  final self = api.getCurrentProcessId();
  return using((arena) {
    final viewClass = 'FLUTTERVIEW'.toNativeUtf16(allocator: arena);
    final processId = arena<Uint32>();
    var found = 0;
    // EnumWindows walks a snapshot of the desktop's top-level windows, hidden
    // ones included, so windows that move in the z-order meanwhile are seen
    // once.
    for (final hwnd in _topLevelWindows(api)) {
      api.getWindowThreadProcessId(hwnd, processId);
      if (processId.value != self) continue;
      if (api.getWindow(hwnd, _gwOwner) != 0) continue;
      if (api.findWindowEx(hwnd, 0, viewClass, nullptr) == 0) continue;
      if (found != 0) return 0;
      found = hwnd;
    }
    return found;
  });
}

// Filled by [_collectWindow] during one synchronous EnumWindows call.
List<int>? _collected;

int _collectWindow(int hwnd, int lParam) {
  _collected?.add(hwnd);
  return 1;
}

List<int> _topLevelWindows(_Win32 api) {
  final windows = _collected = <int>[];
  try {
    api.enumWindows(
      Pointer.fromFunction<_EnumWindowsProcNative>(_collectWindow, 0),
      0,
    );
    return windows;
  } finally {
    _collected = null;
  }
}

class _Win32 {
  _Win32._() {
    final user32 = DynamicLibrary.open('user32.dll');
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    enumWindows = user32
        .lookupFunction<
          Int32 Function(
            Pointer<NativeFunction<_EnumWindowsProcNative>>,
            IntPtr,
          ),
          int Function(Pointer<NativeFunction<_EnumWindowsProcNative>>, int)
        >('EnumWindows');
    findWindowEx = user32
        .lookupFunction<
          IntPtr Function(IntPtr, IntPtr, Pointer<Utf16>, Pointer<Utf16>),
          int Function(int, int, Pointer<Utf16>, Pointer<Utf16>)
        >('FindWindowExW');
    getWindowThreadProcessId = user32
        .lookupFunction<
          Uint32 Function(IntPtr, Pointer<Uint32>),
          int Function(int, Pointer<Uint32>)
        >('GetWindowThreadProcessId');
    getWindow = user32
        .lookupFunction<
          IntPtr Function(IntPtr, Uint32),
          int Function(int, int)
        >('GetWindow');
    getCurrentProcessId = kernel32
        .lookupFunction<Uint32 Function(), int Function()>(
          'GetCurrentProcessId',
        );
  }

  static final _Win32 instance = _Win32._();

  late final int Function(Pointer<NativeFunction<_EnumWindowsProcNative>>, int)
  enumWindows;
  late final int Function(int, int, Pointer<Utf16>, Pointer<Utf16>)
  findWindowEx;
  late final int Function(int, Pointer<Uint32>) getWindowThreadProcessId;
  late final int Function(int, int) getWindow;
  late final int Function() getCurrentProcessId;
}
