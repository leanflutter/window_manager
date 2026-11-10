// The Windows lookup of a hidden window hosting a Flutter view, against real
// Win32 windows made here: a top-level window with a child of window class
// `FLUTTERVIEW`, as Flutter's runner sets it up.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/src/legacy/flutter_host_window_win32.dart';

final class _WndClass extends Struct {
  @Uint32()
  external int style;
  external Pointer<Void> lpfnWndProc;
  @Int32()
  external int cbClsExtra;
  @Int32()
  external int cbWndExtra;
  @IntPtr()
  external int hInstance;
  @IntPtr()
  external int hIcon;
  @IntPtr()
  external int hCursor;
  @IntPtr()
  external int hbrBackground;
  external Pointer<Utf16> lpszMenuName;
  external Pointer<Utf16> lpszClassName;
}

typedef _CreateWindowExNative = IntPtr Function(
  Uint32,
  Pointer<Utf16>,
  Pointer<Utf16>,
  Uint32,
  Int32,
  Int32,
  Int32,
  Int32,
  IntPtr,
  IntPtr,
  IntPtr,
  Pointer<Void>,
);
typedef _CreateWindowEx = int Function(
  int,
  Pointer<Utf16>,
  Pointer<Utf16>,
  int,
  int,
  int,
  int,
  int,
  int,
  int,
  int,
  Pointer<Void>,
);

const _wsOverlapped = 0x00CF0000; // WS_OVERLAPPEDWINDOW, not WS_VISIBLE.
const _wsChild = 0x40000000;

void main() {
  if (!Platform.isWindows) {
    test('the lookup answers nothing off Windows', () {
      expect(findSoleFlutterHostWindow(), 0);
    });
    return;
  }

  final user32 = DynamicLibrary.open('user32.dll');
  final kernel32 = DynamicLibrary.open('kernel32.dll');
  final registerClass = user32
      .lookupFunction<
        Uint16 Function(Pointer<_WndClass>),
        int Function(Pointer<_WndClass>)
      >('RegisterClassW');
  final createWindowEx = user32
      .lookupFunction<_CreateWindowExNative, _CreateWindowEx>(
        'CreateWindowExW',
      );
  final destroyWindow = user32
      .lookupFunction<Int32 Function(IntPtr), int Function(int)>(
        'DestroyWindow',
      );
  final getModuleHandle = kernel32
      .lookupFunction<
        IntPtr Function(Pointer<Utf16>),
        int Function(Pointer<Utf16>)
      >('GetModuleHandleW');
  final defWindowProc = user32.lookup<Void>('DefWindowProcW');

  final instance = getModuleHandle(nullptr);
  final viewClass = 'FLUTTERVIEW'.toNativeUtf16();
  final hostClass = 'STATIC'.toNativeUtf16();
  final created = <int>[];

  setUpAll(() {
    final wndClass = calloc<_WndClass>();
    wndClass.ref
      ..lpfnWndProc = defWindowProc
      ..hInstance = instance
      ..lpszClassName = viewClass;
    registerClass(wndClass);
    calloc.free(wndClass);
  });

  tearDown(() {
    // Children go with their parents, owned windows with their owners.
    for (final hwnd in created.reversed) {
      destroyWindow(hwnd);
    }
    created.clear();
  });

  tearDownAll(() {
    calloc.free(viewClass);
    calloc.free(hostClass);
  });

  int topLevel({int owner = 0}) {
    final hwnd = createWindowEx(
      0,
      hostClass,
      nullptr,
      _wsOverlapped,
      0,
      0,
      100,
      100,
      owner,
      0,
      instance,
      nullptr,
    );
    expect(hwnd, isNot(0));
    created.add(hwnd);
    return hwnd;
  }

  void hostView(int parent) {
    final hwnd = createWindowEx(
      0,
      viewClass,
      nullptr,
      _wsChild,
      0,
      0,
      10,
      10,
      parent,
      0,
      instance,
      nullptr,
    );
    expect(hwnd, isNot(0));
  }

  test('a test process has no Flutter host window', () {
    expect(findSoleFlutterHostWindow(), 0);
  });

  test('finds the only hidden window hosting a Flutter view', () {
    topLevel(); // No Flutter view.
    final host = topLevel();
    hostView(host);
    expect(findSoleFlutterHostWindow(), host);
  });

  test('skips owned windows', () {
    final host = topLevel();
    hostView(host);
    final owned = topLevel(owner: host);
    hostView(owned);
    expect(findSoleFlutterHostWindow(), host);
  });

  test('answers nothing with several candidates', () {
    final first = topLevel();
    hostView(first);
    final second = topLevel();
    hostView(second);
    expect(findSoleFlutterHostWindow(), 0);
  });
}
