#include "include/window_manager/window_manager_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <shobjidl_core.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <dwmapi.h>
#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

#pragma comment(lib, "dwmapi.lib")

#define STATE_NORMAL 0
#define STATE_MAXIMIZED 1
#define STATE_MINIMIZED 2
#define STATE_FULLSCREEN_ENTERED 3

#define DWMWA_USE_IMMERSIVE_DARK_MODE 19

namespace {

const flutter::EncodableValue* ValueOrNull(const flutter::EncodableMap& map,
                                           const char* key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it == map.end()) {
    return nullptr;
  }
  return &(it->second);
}

class WindowManager {
 public:
  WindowManager();

  virtual ~WindowManager();

  HWND native_window;

  int last_state = STATE_NORMAL;

  bool has_shadow_ = false;
  bool is_frameless_ = false;
  bool is_prevent_close_ = false;
  double aspect_ratio_ = 0;
  POINT minimum_size_ = {0, 0};
  POINT maximum_size_ = {-1, -1};
  bool is_resizable_ = true;
  bool is_skip_taskbar_ = true;
  std::string title_bar_style_ = "normal";
  double opacity_ = 1;

  bool is_resizing_ = false;
  bool is_moving_ = false;

  HWND GetMainWindow();
  void WindowManager::ForceRefresh();
  void WindowManager::ForceChildRefresh();
  void WindowManager::SetAsFrameless();
  void WindowManager::WaitUntilReadyToShow();
  void WindowManager::Destroy();
  void WindowManager::Close();
  bool WindowManager::IsPreventClose();
  void WindowManager::SetPreventClose(const flutter::EncodableMap& args);
  void WindowManager::Focus();
  void WindowManager::Blur();
  bool WindowManager::IsFocused();
  void WindowManager::Show();
  void WindowManager::Hide();
  bool WindowManager::IsVisible();
  bool WindowManager::IsMaximized();
  void WindowManager::Maximize(const flutter::EncodableMap& args);
  void WindowManager::Unmaximize();
  bool WindowManager::IsMinimized();
  void WindowManager::Minimize();
  void WindowManager::Restore();
  bool WindowManager::IsFullScreen();
  void WindowManager::SetFullScreen(const flutter::EncodableMap& args);
  void WindowManager::SetAspectRatio(const flutter::EncodableMap& args);
  void WindowManager::SetBackgroundColor(const flutter::EncodableMap& args);
  flutter::EncodableMap WindowManager::GetBounds(
      const flutter::EncodableMap& args);
  void WindowManager::SetBounds(const flutter::EncodableMap& args);
  void WindowManager::SetMinimumSize(const flutter::EncodableMap& args);
  void WindowManager::SetMaximumSize(const flutter::EncodableMap& args);
  bool WindowManager::IsResizable();
  void WindowManager::SetResizable(const flutter::EncodableMap& args);
  bool WindowManager::IsMinimizable();
  void WindowManager::SetMinimizable(const flutter::EncodableMap& args);
  bool WindowManager::IsMaximizable();
  void WindowManager::SetMaximizable(const flutter::EncodableMap& args);
  bool WindowManager::IsClosable();
  void WindowManager::SetClosable(const flutter::EncodableMap& args);
  bool WindowManager::IsAlwaysOnTop();
  void WindowManager::SetAlwaysOnTop(const flutter::EncodableMap& args);
  std::string WindowManager::GetTitle();
  void WindowManager::SetTitle(const flutter::EncodableMap& args);
  void WindowManager::SetTitleBarStyle(const flutter::EncodableMap& args);
  int WindowManager::GetTitleBarHeight();
  bool WindowManager::IsSkipTaskbar();
  void WindowManager::SetSkipTaskbar(const flutter::EncodableMap& args);
  void WindowManager::SetProgressBar(const flutter::EncodableMap& args);
  void WindowManager::SetIcon(const flutter::EncodableMap& args);
  bool WindowManager::HasShadow();
  void WindowManager::SetHasShadow(const flutter::EncodableMap& args);
  double WindowManager::GetOpacity();
  void WindowManager::SetOpacity(const flutter::EncodableMap& args);
  void WindowManager::SetBrightness(const flutter::EncodableMap& args);
  void WindowManager::SetIgnoreMouseEvents(const flutter::EncodableMap& args);
  void WindowManager::PopUpWindowMenu(const flutter::EncodableMap& args);
  void WindowManager::StartDragging();
  void WindowManager::StartResizing(const flutter::EncodableMap& args);

 private:
  bool g_is_window_fullscreen = false;
  std::string g_title_bar_style_before_fullscreen;
  bool g_is_frameless_before_fullscreen;
  RECT g_frame_before_fullscreen;
  bool g_maximized_before_fullscreen;
  LONG g_style_before_fullscreen;
  LONG g_ex_style_before_fullscreen;
  ITaskbarList3* taskbar_ = nullptr;
};

WindowManager::WindowManager() {}

WindowManager::~WindowManager() {}

HWND WindowManager::GetMainWindow() {
  return native_window;
}

void WindowManager::ForceRefresh() {
  HWND hWnd = GetMainWindow();

  RECT rect;

  GetWindowRect(hWnd, &rect);
  SetWindowPos(
      hWnd, nullptr, rect.left, rect.top, rect.right - rect.left + 1,
      rect.bottom - rect.top,
      SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_FRAMECHANGED);
  SetWindowPos(
      hWnd, nullptr, rect.left, rect.top, rect.right - rect.left,
      rect.bottom - rect.top,
      SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_FRAMECHANGED);
}

void WindowManager::ForceChildRefresh() {
  HWND hWnd = GetWindow(GetMainWindow(), GW_CHILD);

  RECT rect;

  GetWindowRect(hWnd, &rect);
  SetWindowPos(
      hWnd, nullptr, rect.left, rect.top, rect.right - rect.left + 1,
      rect.bottom - rect.top,
      SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_FRAMECHANGED);
  SetWindowPos(
      hWnd, nullptr, rect.left, rect.top, rect.right - rect.left,
      rect.bottom - rect.top,
      SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_FRAMECHANGED);
}

void WindowManager::SetAsFrameless() {
  is_frameless_ = true;
  HWND hWnd = GetMainWindow();

  RECT rect;

  GetWindowRect(hWnd, &rect);
  SetWindowPos(hWnd, nullptr, rect.left, rect.top, rect.right - rect.left,
               rect.bottom - rect.top,
               SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOSIZE |
                   SWP_FRAMECHANGED);
}

void WindowManager::WaitUntilReadyToShow() {
  ::CoCreateInstance(CLSID_TaskbarList, NULL, CLSCTX_INPROC_SERVER,
                     IID_PPV_ARGS(&taskbar_));
}

void WindowManager::Destroy() {
  PostQuitMessage(0);
}

void WindowManager::Close() {
  HWND hWnd = GetMainWindow();
  PostMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
}

void WindowManager::SetPreventClose(const flutter::EncodableMap& args) {
  is_prevent_close_ =
      std::get<bool>(args.at(flutter::EncodableValue("isPreventClose")));
}

bool WindowManager::IsPreventClose() {
  return is_prevent_close_;
}

void WindowManager::Focus() {
  HWND hWnd = GetMainWindow();
  if (IsMinimized()) {
    Restore();
  }

  ::SetWindowPos(hWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
  SetForegroundWindow(hWnd);
}

void WindowManager::Blur() {
  HWND hWnd = GetMainWindow();
  HWND next_hwnd = ::GetNextWindow(hWnd, GW_HWNDNEXT);
  while (next_hwnd) {
    if (::IsWindowVisible(next_hwnd)) {
      ::SetForegroundWindow(next_hwnd);
      return;
    }
    next_hwnd = ::GetNextWindow(next_hwnd, GW_HWNDNEXT);
  }
}

bool WindowManager::IsFocused() {
  return GetMainWindow() == GetActiveWindow();
}

void WindowManager::Show() {
  HWND hWnd = GetMainWindow();
  DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
  gwlStyle = gwlStyle | WS_VISIBLE;
  if ((gwlStyle & WS_VISIBLE) == 0) {
    SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
    ::SetWindowPos(hWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
  }

  ShowWindowAsync(GetMainWindow(), SW_SHOW);
  SetForegroundWindow(GetMainWindow());
}

void WindowManager::Hide() {
  ShowWindow(GetMainWindow(), SW_HIDE);
}

bool WindowManager::IsVisible() {
  bool isVisible = IsWindowVisible(GetMainWindow());
  return isVisible;
}

bool WindowManager::IsMaximized() {
  HWND mainWindow = GetMainWindow();
  WINDOWPLACEMENT windowPlacement;
  GetWindowPlacement(mainWindow, &windowPlacement);

  return windowPlacement.showCmd == SW_MAXIMIZE;
}

void WindowManager::Maximize(const flutter::EncodableMap& args) {
  bool vertically =
      std::get<bool>(args.at(flutter::EncodableValue("vertically")));

  HWND hwnd = GetMainWindow();
  WINDOWPLACEMENT windowPlacement;
  GetWindowPlacement(hwnd, &windowPlacement);

  if (vertically) {
    POINT cursorPos;
    GetCursorPos(&cursorPos);
    PostMessage(hwnd, WM_NCLBUTTONDBLCLK, HTTOP,
                MAKELPARAM(cursorPos.x, cursorPos.y));
  } else {
    if (windowPlacement.showCmd != SW_MAXIMIZE) {
      PostMessage(hwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    }
  }
}

void WindowManager::Unmaximize() {
  HWND mainWindow = GetMainWindow();
  WINDOWPLACEMENT windowPlacement;
  GetWindowPlacement(mainWindow, &windowPlacement);

  if (windowPlacement.showCmd != SW_NORMAL) {
    PostMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
  }
}

bool WindowManager::IsMinimized() {
  HWND mainWindow = GetMainWindow();
  WINDOWPLACEMENT windowPlacement;
  GetWindowPlacement(mainWindow, &windowPlacement);

  return windowPlacement.showCmd == SW_SHOWMINIMIZED;
}

void WindowManager::Minimize() {
  HWND mainWindow = GetMainWindow();
  WINDOWPLACEMENT windowPlacement;
  GetWindowPlacement(mainWindow, &windowPlacement);

  if (windowPlacement.showCmd != SW_SHOWMINIMIZED) {
    PostMessage(mainWindow, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  }
}

void WindowManager::Restore() {
  HWND mainWindow = GetMainWindow();
  WINDOWPLACEMENT windowPlacement;
  GetWindowPlacement(mainWindow, &windowPlacement);

  if (windowPlacement.showCmd != SW_NORMAL) {
    PostMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
  }
}

bool WindowManager::IsFullScreen() {
  return g_is_window_fullscreen;
}

void WindowManager::SetFullScreen(const flutter::EncodableMap& args) {
  bool isFullScreen =
      std::get<bool>(args.at(flutter::EncodableValue("isFullScreen")));

  HWND mainWindow = GetMainWindow();

  // Inspired by how Chromium does this
  // https://src.chromium.org/viewvc/chrome/trunk/src/ui/views/win/fullscreen_handler.cc?revision=247204&view=markup

  // Save current window state if not already fullscreen.
  if (!g_is_window_fullscreen) {
    // Save current window information.
    g_maximized_before_fullscreen = !!::IsZoomed(mainWindow);
    g_style_before_fullscreen = GetWindowLong(mainWindow, GWL_STYLE);
    g_ex_style_before_fullscreen = GetWindowLong(mainWindow, GWL_EXSTYLE);
    if (g_maximized_before_fullscreen) {
      SendMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
    }
    ::GetWindowRect(mainWindow, &g_frame_before_fullscreen);
    g_title_bar_style_before_fullscreen = title_bar_style_;
    g_is_frameless_before_fullscreen = is_frameless_;
  }

  if (isFullScreen) {
    flutter::EncodableMap args2 = flutter::EncodableMap();
    args2[flutter::EncodableValue("titleBarStyle")] =
        flutter::EncodableValue("normal");
    SetTitleBarStyle(args2);

    // Set new window style and size.
    ::SetWindowLong(mainWindow, GWL_STYLE,
                    g_style_before_fullscreen & ~(WS_CAPTION | WS_THICKFRAME));
    ::SetWindowLong(mainWindow, GWL_EXSTYLE,
                    g_ex_style_before_fullscreen &
                        ~(WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE |
                          WS_EX_CLIENTEDGE | WS_EX_STATICEDGE));

    MONITORINFO monitor_info;
    monitor_info.cbSize = sizeof(monitor_info);
    ::GetMonitorInfo(::MonitorFromWindow(mainWindow, MONITOR_DEFAULTTONEAREST),
                     &monitor_info);
    ::SetWindowPos(mainWindow, NULL, monitor_info.rcMonitor.left,
                   monitor_info.rcMonitor.top,
                   monitor_info.rcMonitor.right - monitor_info.rcMonitor.left,
                   monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top,
                   SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED);
    ::SendMessage(mainWindow, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  } else {
    ::SetWindowLong(mainWindow, GWL_STYLE, g_style_before_fullscreen);
    ::SetWindowLong(mainWindow, GWL_EXSTYLE, g_ex_style_before_fullscreen);

    SendMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);

    if (title_bar_style_ != g_title_bar_style_before_fullscreen) {
      flutter::EncodableMap args2 = flutter::EncodableMap();
      args2[flutter::EncodableValue("titleBarStyle")] =
          flutter::EncodableValue(g_title_bar_style_before_fullscreen);
      SetTitleBarStyle(args2);
    }

    if (g_is_frameless_before_fullscreen)
      SetAsFrameless();

    if (g_maximized_before_fullscreen) {
      flutter::EncodableMap args2 = flutter::EncodableMap();
      args2[flutter::EncodableValue("vertically")] =
          flutter::EncodableValue(false);
      Maximize(args2);
    } else {
      ::SetWindowPos(
          mainWindow, NULL, g_frame_before_fullscreen.left,
          g_frame_before_fullscreen.top,
          g_frame_before_fullscreen.right - g_frame_before_fullscreen.left,
          g_frame_before_fullscreen.bottom - g_frame_before_fullscreen.top,
          SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED);
    }
  }

  g_is_window_fullscreen = isFullScreen;
}

void WindowManager::SetAspectRatio(const flutter::EncodableMap& args) {
  aspect_ratio_ =
      std::get<double>(args.at(flutter::EncodableValue("aspectRatio")));
}

void WindowManager::SetBackgroundColor(const flutter::EncodableMap& args) {
  int backgroundColorA =
      std::get<int>(args.at(flutter::EncodableValue("backgroundColorA")));
  int backgroundColorR =
      std::get<int>(args.at(flutter::EncodableValue("backgroundColorR")));
  int backgroundColorG =
      std::get<int>(args.at(flutter::EncodableValue("backgroundColorG")));
  int backgroundColorB =
      std::get<int>(args.at(flutter::EncodableValue("backgroundColorB")));

  bool isTransparent = backgroundColorA == 0 && backgroundColorR == 0 &&
                       backgroundColorG == 0 && backgroundColorB == 0;

  HWND hWnd = GetMainWindow();
  const HINSTANCE hModule = LoadLibrary(TEXT("user32.dll"));
  if (hModule) {
    typedef enum _ACCENT_STATE {
      ACCENT_DISABLED = 0,
      ACCENT_ENABLE_GRADIENT = 1,
      ACCENT_ENABLE_TRANSPARENTGRADIENT = 2,
      ACCENT_ENABLE_BLURBEHIND = 3,
      ACCENT_ENABLE_ACRYLICBLURBEHIND = 4,
      ACCENT_ENABLE_HOSTBACKDROP = 5,
      ACCENT_INVALID_STATE = 6
    } ACCENT_STATE;
    struct ACCENTPOLICY {
      int nAccentState;
      int nFlags;
      int nColor;
      int nAnimationId;
    };
    struct WINCOMPATTRDATA {
      int nAttribute;
      PVOID pData;
      ULONG ulDataSize;
    };
    typedef BOOL(WINAPI * pSetWindowCompositionAttribute)(HWND,
                                                          WINCOMPATTRDATA*);
    const pSetWindowCompositionAttribute SetWindowCompositionAttribute =
        (pSetWindowCompositionAttribute)GetProcAddress(
            hModule, "SetWindowCompositionAttribute");
    if (SetWindowCompositionAttribute) {
      int32_t accent_state = isTransparent ? ACCENT_ENABLE_TRANSPARENTGRADIENT
                                           : ACCENT_ENABLE_GRADIENT;
      ACCENTPOLICY policy = {
          accent_state, 2,
          ((backgroundColorA << 24) + (backgroundColorB << 16) +
           (backgroundColorG << 8) + (backgroundColorR)),
          0};
      WINCOMPATTRDATA data = {19, &policy, sizeof(policy)};
      SetWindowCompositionAttribute(hWnd, &data);
    }
    FreeLibrary(hModule);
  }
}

flutter::EncodableMap WindowManager::GetBounds(
    const flutter::EncodableMap& args) {
  HWND hwnd = GetMainWindow();
  double devicePixelRatio =
      std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

  flutter::EncodableMap resultMap = flutter::EncodableMap();
  RECT rect;
  if (GetWindowRect(hwnd, &rect)) {
    double x = rect.left / devicePixelRatio * 1.0f;
    double y = rect.top / devicePixelRatio * 1.0f;
    double width = (rect.right - rect.left) / devicePixelRatio * 1.0f;
    double height = (rect.bottom - rect.top) / devicePixelRatio * 1.0f;

    resultMap[flutter::EncodableValue("x")] = flutter::EncodableValue(x);
    resultMap[flutter::EncodableValue("y")] = flutter::EncodableValue(y);
    resultMap[flutter::EncodableValue("width")] =
        flutter::EncodableValue(width);
    resultMap[flutter::EncodableValue("height")] =
        flutter::EncodableValue(height);
  }
  return resultMap;
}

void WindowManager::SetBounds(const flutter::EncodableMap& args) {
  HWND hwnd = GetMainWindow();

  double devicePixelRatio =
      std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

  auto* null_or_x = std::get_if<double>(ValueOrNull(args, "x"));
  auto* null_or_y = std::get_if<double>(ValueOrNull(args, "y"));
  auto* null_or_width = std::get_if<double>(ValueOrNull(args, "width"));
  auto* null_or_height = std::get_if<double>(ValueOrNull(args, "height"));

  int x = 0;
  int y = 0;
  int width = 0;
  int height = 0;
  UINT uFlags = NULL;

  if (null_or_x != nullptr && null_or_y != nullptr) {
    x = static_cast<int>(*null_or_x * devicePixelRatio);
    y = static_cast<int>(*null_or_y * devicePixelRatio);
  }
  if (null_or_width != nullptr && null_or_height != nullptr) {
    width = static_cast<int>(*null_or_width * devicePixelRatio);
    height = static_cast<int>(*null_or_height * devicePixelRatio);
  }

  if (null_or_x == nullptr || null_or_y == nullptr) {
    uFlags = SWP_NOMOVE;
  }
  if (null_or_width == nullptr || null_or_height == nullptr) {
    uFlags = SWP_NOSIZE;
  }

  SetWindowPos(hwnd, HWND_TOP, x, y, width, height, uFlags);
}

void WindowManager::SetMinimumSize(const flutter::EncodableMap& args) {
  double devicePixelRatio =
      std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
  double width = std::get<double>(args.at(flutter::EncodableValue("width")));
  double height = std::get<double>(args.at(flutter::EncodableValue("height")));

  if (width >= 0 && height >= 0) {
    POINT point = {};
    point.x = static_cast<LONG>(width * devicePixelRatio);
    point.y = static_cast<LONG>(height * devicePixelRatio);
    minimum_size_ = point;
  }
}

void WindowManager::SetMaximumSize(const flutter::EncodableMap& args) {
  double devicePixelRatio =
      std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
  double width = std::get<double>(args.at(flutter::EncodableValue("width")));
  double height = std::get<double>(args.at(flutter::EncodableValue("height")));

  if (width >= 0 && height >= 0) {
    POINT point = {};
    point.x = static_cast<LONG>(width * devicePixelRatio);
    point.y = static_cast<LONG>(height * devicePixelRatio);
    maximum_size_ = point;
  }
}

bool WindowManager::IsResizable() {
  return is_resizable_;
}

void WindowManager::SetResizable(const flutter::EncodableMap& args) {
  HWND hWnd = GetMainWindow();
  is_resizable_ =
      std::get<bool>(args.at(flutter::EncodableValue("isResizable")));
  DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
  if (is_resizable_) {
    gwlStyle |= WS_THICKFRAME;
  } else {
    gwlStyle &= ~WS_THICKFRAME;
  }
  ::SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
}

bool WindowManager::IsMinimizable() {
  HWND hWnd = GetMainWindow();
  DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
  return (gwlStyle & WS_MINIMIZEBOX) != 0;
}

void WindowManager::SetMinimizable(const flutter::EncodableMap& args) {
  HWND hWnd = GetMainWindow();
  bool isMinimizable =
      std::get<bool>(args.at(flutter::EncodableValue("isMinimizable")));
  DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
  gwlStyle =
      isMinimizable ? gwlStyle | WS_MINIMIZEBOX : gwlStyle & ~WS_MINIMIZEBOX;
  SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
}

bool WindowManager::IsMaximizable() {
  HWND hWnd = GetMainWindow();
  DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
  return (gwlStyle & WS_MAXIMIZEBOX) != 0;
}

void WindowManager::SetMaximizable(const flutter::EncodableMap& args) {
  HWND hWnd = GetMainWindow();
  bool isMaximizable =
      std::get<bool>(args.at(flutter::EncodableValue("isMaximizable")));
  DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
  gwlStyle =
      isMaximizable ? gwlStyle | WS_MAXIMIZEBOX : gwlStyle & ~WS_MAXIMIZEBOX;
  SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
}

bool WindowManager::IsClosable() {
  HWND hWnd = GetMainWindow();
  DWORD gclStyle = GetClassLong(hWnd, GCL_STYLE);
  return !((gclStyle & CS_NOCLOSE) != 0);
}

void WindowManager::SetClosable(const flutter::EncodableMap& args) {
  HWND hWnd = GetMainWindow();
  bool isClosable =
      std::get<bool>(args.at(flutter::EncodableValue("isClosable")));
  DWORD gclStyle = GetClassLong(hWnd, GCL_STYLE);
  gclStyle = isClosable ? gclStyle & ~CS_NOCLOSE : gclStyle | CS_NOCLOSE;
  SetClassLong(hWnd, GCL_STYLE, gclStyle);
}

bool WindowManager::IsAlwaysOnTop() {
  DWORD dwExStyle = GetWindowLong(GetMainWindow(), GWL_EXSTYLE);
  return (dwExStyle & WS_EX_TOPMOST) != 0;
}

void WindowManager::SetAlwaysOnTop(const flutter::EncodableMap& args) {
  bool isAlwaysOnTop =
      std::get<bool>(args.at(flutter::EncodableValue("isAlwaysOnTop")));
  SetWindowPos(GetMainWindow(), isAlwaysOnTop ? HWND_TOPMOST : HWND_NOTOPMOST,
               0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

std::string WindowManager::GetTitle() {
  int const bufferSize = 1 + GetWindowTextLength(GetMainWindow());
  std::wstring title(bufferSize, L'\0');
  GetWindowText(GetMainWindow(), &title[0], bufferSize);

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
  return (converter.to_bytes(title)).c_str();
}

void WindowManager::SetTitle(const flutter::EncodableMap& args) {
  std::string title =
      std::get<std::string>(args.at(flutter::EncodableValue("title")));

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
  SetWindowText(GetMainWindow(), converter.from_bytes(title).c_str());
}

void WindowManager::SetTitleBarStyle(const flutter::EncodableMap& args) {
  title_bar_style_ =
      std::get<std::string>(args.at(flutter::EncodableValue("titleBarStyle")));
  // Enables the ability to go from setAsFrameless() to
  // TitleBarStyle.normal/hidden
  is_frameless_ = false;

  MARGINS margins = {0, 0, 0, 0};
  HWND hWnd = GetMainWindow();
  RECT rect;
  GetWindowRect(hWnd, &rect);
  DwmExtendFrameIntoClientArea(hWnd, &margins);
  SetWindowPos(hWnd, nullptr, rect.left, rect.top, 0, 0,
               SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOSIZE |
                   SWP_FRAMECHANGED);
}

int WindowManager::GetTitleBarHeight() {
  HWND hWnd = GetMainWindow();

  TITLEBARINFOEX* ptinfo = (TITLEBARINFOEX*)malloc(sizeof(TITLEBARINFOEX));
  ptinfo->cbSize = sizeof(TITLEBARINFOEX);
  SendMessage(hWnd, WM_GETTITLEBARINFOEX, 0, (LPARAM)ptinfo);
  int height = ptinfo->rcTitleBar.bottom == 0
                   ? 0
                   : ptinfo->rcTitleBar.bottom - ptinfo->rcTitleBar.top;
  free(ptinfo);

  return height;
}

bool WindowManager::IsSkipTaskbar() {
  return is_skip_taskbar_;
}

void WindowManager::SetSkipTaskbar(const flutter::EncodableMap& args) {
  is_skip_taskbar_ =
      std::get<bool>(args.at(flutter::EncodableValue("isSkipTaskbar")));

  HWND hWnd = GetMainWindow();

  LPVOID lp = NULL;
  CoInitialize(lp);

  taskbar_->HrInit();
  if (!is_skip_taskbar_)
    taskbar_->AddTab(hWnd);
  else
    taskbar_->DeleteTab(hWnd);
}

void WindowManager::SetProgressBar(const flutter::EncodableMap& args) {
  double progress =
      std::get<double>(args.at(flutter::EncodableValue("progress")));

  HWND hWnd = GetMainWindow();
  taskbar_->SetProgressState(hWnd, TBPF_INDETERMINATE);
  taskbar_->SetProgressValue(hWnd, static_cast<int32_t>(progress * 100),
                             static_cast<int32_t>(100));

  if (progress < 0) {
    taskbar_->SetProgressState(hWnd, TBPF_NOPROGRESS);
    taskbar_->SetProgressValue(hWnd, static_cast<int32_t>(0),
                               static_cast<int32_t>(0));
  } else if (progress > 1) {
    taskbar_->SetProgressState(hWnd, TBPF_INDETERMINATE);
    taskbar_->SetProgressValue(hWnd, static_cast<int32_t>(100),
                               static_cast<int32_t>(100));
  } else {
    taskbar_->SetProgressState(hWnd, TBPF_INDETERMINATE);
    taskbar_->SetProgressValue(hWnd, static_cast<int32_t>(progress * 100),
                               static_cast<int32_t>(100));
  }
}

void WindowManager::SetIcon(const flutter::EncodableMap& args) {
  std::string iconPath =
      std::get<std::string>(args.at(flutter::EncodableValue("iconPath")));

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;

  HICON hIconSmall =
      (HICON)(LoadImage(NULL, (LPCWSTR)(converter.from_bytes(iconPath).c_str()),
                        IMAGE_ICON, 16, 16, LR_LOADFROMFILE));

  HICON hIconLarge =
      (HICON)(LoadImage(NULL, (LPCWSTR)(converter.from_bytes(iconPath).c_str()),
                        IMAGE_ICON, 32, 32, LR_LOADFROMFILE));

  HWND hWnd = GetMainWindow();

  SendMessage(hWnd, WM_SETICON, ICON_SMALL, (LPARAM)hIconSmall);
  SendMessage(hWnd, WM_SETICON, ICON_BIG, (LPARAM)hIconLarge);
}

bool WindowManager::HasShadow() {
  if (is_frameless_)
    return has_shadow_;
  return true;
}

void WindowManager::SetHasShadow(const flutter::EncodableMap& args) {
  if (is_frameless_) {
    has_shadow_ = std::get<bool>(args.at(flutter::EncodableValue("hasShadow")));

    HWND hWnd = GetMainWindow();

    MARGINS margins[2]{{0, 0, 0, 0}, {0, 0, 1, 0}};

    DwmExtendFrameIntoClientArea(hWnd, &margins[has_shadow_]);
  }
}

double WindowManager::GetOpacity() {
  return opacity_;
}

void WindowManager::SetOpacity(const flutter::EncodableMap& args) {
  opacity_ = std::get<double>(args.at(flutter::EncodableValue("opacity")));
  HWND hWnd = GetMainWindow();
  long gwlExStyle = GetWindowLong(hWnd, GWL_EXSTYLE);
  SetWindowLong(hWnd, GWL_EXSTYLE, gwlExStyle | WS_EX_LAYERED);
  SetLayeredWindowAttributes(hWnd, 0, static_cast<int8_t>(255 * opacity_),
                             0x02);
}

void WindowManager::SetBrightness(const flutter::EncodableMap& args) {
  std::string brightness =
      std::get<std::string>(args.at(flutter::EncodableValue("brightness")));

  const BOOL is_dark_mode = brightness == "dark";

  HWND hWnd = GetMainWindow();
  DwmSetWindowAttribute(hWnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &is_dark_mode,
                        sizeof(is_dark_mode));
}

void WindowManager::SetIgnoreMouseEvents(const flutter::EncodableMap& args) {
  bool ignore = std::get<bool>(args.at(flutter::EncodableValue("ignore")));

  HWND hwnd = GetMainWindow();
  LONG ex_style = ::GetWindowLong(hwnd, GWL_EXSTYLE);
  if (ignore)
    ex_style |= (WS_EX_TRANSPARENT | WS_EX_LAYERED);
  else
    ex_style &= ~(WS_EX_TRANSPARENT | WS_EX_LAYERED);

  ::SetWindowLong(hwnd, GWL_EXSTYLE, ex_style);
}

void WindowManager::PopUpWindowMenu(const flutter::EncodableMap& args) {
  HWND hWnd = GetMainWindow();
  HMENU hMenu = GetSystemMenu(hWnd, false);

  double x, y;

  POINT cursorPos;
  GetCursorPos(&cursorPos);
  x = cursorPos.x;
  y = cursorPos.y;

  int cmd =
      TrackPopupMenu(hMenu, TPM_LEFTBUTTON | TPM_RIGHTBUTTON | TPM_RETURNCMD,
                     static_cast<int>(x), static_cast<int>(y), 0, hWnd, NULL);

  if (cmd) {
    PostMessage(hWnd, WM_SYSCOMMAND, cmd, 0);
  }
}

void WindowManager::StartDragging() {
  ReleaseCapture();
  SendMessage(GetMainWindow(), WM_SYSCOMMAND, SC_MOVE | HTCAPTION, 0);
}

void WindowManager::StartResizing(const flutter::EncodableMap& args) {
  bool top = std::get<bool>(args.at(flutter::EncodableValue("top")));
  bool bottom = std::get<bool>(args.at(flutter::EncodableValue("bottom")));
  bool left = std::get<bool>(args.at(flutter::EncodableValue("left")));
  bool right = std::get<bool>(args.at(flutter::EncodableValue("right")));

  HWND hWnd = GetMainWindow();
  ReleaseCapture();
  LONG command;
  if (top && !bottom && !right && !left) {
    command = HTTOP;
  } else if (top && left && !bottom && !right) {
    command = HTTOPLEFT;
  } else if (left && !top && !bottom && !right) {
    command = HTLEFT;
  } else if (right && !top && !left && !bottom) {
    command = HTRIGHT;
  } else if (top && right && !left && !bottom) {
    command = HTTOPRIGHT;
  } else if (bottom && !top && !right && !left) {
    command = HTBOTTOM;
  } else if (bottom && left && !top && !right) {
    command = HTBOTTOMLEFT;
  } else
    command = HTBOTTOMRIGHT;
  POINT cursorPos;
  GetCursorPos(&cursorPos);
  PostMessage(hWnd, WM_NCLBUTTONDOWN, command,
              MAKELPARAM(cursorPos.x, cursorPos.y));
}

}  // namespace
