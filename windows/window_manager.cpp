#include "include/window_manager/window_manager_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <shobjidl_core.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <dwmapi.h>
#include <map>
#include <memory>
#include <sstream>

#pragma comment(lib, "dwmapi.lib")

#define STATE_NORMAL 0
#define STATE_MAXIMIZED 1
#define STATE_MINIMIZED 2
#define STATE_FULLSCREEN_ENTERED 3

namespace
{
class WindowManager
{
  public:
    WindowManager();

    virtual ~WindowManager();

    HWND native_window;

    int last_state = STATE_NORMAL;

    bool is_frameless = false;
    std::string title_bar_style = "default";
    double opacity = 1;

    // The minimum size set by the platform channel.
    POINT minimum_size = {0, 0};
    // The maximum size set by the platform channel.
    POINT maximum_size = {-1, -1};

    HWND GetMainWindow();
    void WindowManager::SetAsFrameless();
    void WindowManager::WaitUntilReadyToShow();
    void WindowManager::Focus();
    void WindowManager::Blur();
    void WindowManager::Show();
    void WindowManager::Hide();
    bool WindowManager::IsVisible();
    bool WindowManager::IsMaximized();
    void WindowManager::Maximize();
    void WindowManager::Unmaximize();
    bool WindowManager::IsMinimized();
    void WindowManager::Minimize();
    void WindowManager::Restore();
    bool WindowManager::IsFullScreen();
    void WindowManager::SetFullScreen(const flutter::EncodableMap &args);
    void WindowManager::SetBackgroundColor(const flutter::EncodableMap &args);
    flutter::EncodableMap WindowManager::GetPosition(const flutter::EncodableMap &args);
    void WindowManager::SetPosition(const flutter::EncodableMap &args);
    flutter::EncodableMap WindowManager::GetSize(const flutter::EncodableMap &args);
    void WindowManager::SetSize(const flutter::EncodableMap &args);
    void WindowManager::SetMinimumSize(const flutter::EncodableMap &args);
    void WindowManager::SetMaximumSize(const flutter::EncodableMap &args);
    bool WindowManager::IsResizable();
    void WindowManager::SetResizable(const flutter::EncodableMap &args);
    bool WindowManager::IsMinimizable();
    void WindowManager::SetMinimizable(const flutter::EncodableMap &args);
    bool WindowManager::IsClosable();
    void WindowManager::SetClosable(const flutter::EncodableMap &args);
    bool WindowManager::IsAlwaysOnTop();
    void WindowManager::SetAlwaysOnTop(const flutter::EncodableMap &args);
    std::string WindowManager::GetTitle();
    void WindowManager::SetTitle(const flutter::EncodableMap &args);
    void WindowManager::SetTitleBarStyle(const flutter::EncodableMap &args);
    void WindowManager::SetSkipTaskbar(const flutter::EncodableMap &args);
    bool WindowManager::HasShadow();
    void WindowManager::SetHasShadow(const flutter::EncodableMap &args);
    double WindowManager::GetOpacity();
    void WindowManager::SetOpacity(const flutter::EncodableMap &args);
    void WindowManager::StartDragging();

  private:
    bool g_is_window_fullscreen = false;
    RECT g_frame_before_fullscreen;
    bool g_maximized_before_fullscreen;
    LONG g_style_before_fullscreen;
    LONG g_ex_style_before_fullscreen;
};

WindowManager::WindowManager()
{
}

WindowManager::~WindowManager()
{
}

HWND WindowManager::GetMainWindow()
{
    return native_window;
}

void WindowManager::SetAsFrameless()
{
    is_frameless = true;
    HWND hWnd = GetMainWindow();

    RECT rect;
    MARGINS margins = {0, 0, 0, 0};

    GetWindowRect(hWnd, &rect);
    SetWindowLong(hWnd, GWL_STYLE, WS_POPUP | WS_CAPTION | WS_VISIBLE);
    DwmExtendFrameIntoClientArea(hWnd, &margins);
    SetWindowPos(hWnd, nullptr, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top,
                 SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED);

    flutter::EncodableMap args = flutter::EncodableMap();
    args[flutter::EncodableValue("backgroundColorA")] = flutter::EncodableValue(0);
    args[flutter::EncodableValue("backgroundColorR")] = flutter::EncodableValue(0);
    args[flutter::EncodableValue("backgroundColorG")] = flutter::EncodableValue(0);
    args[flutter::EncodableValue("backgroundColorB")] = flutter::EncodableValue(0);
    SetBackgroundColor(args);
}

void WindowManager::WaitUntilReadyToShow()
{
}

void WindowManager::Focus()
{
    HWND hWnd = GetMainWindow();
    if (IsMinimized())
    {
        Restore();
    }

    ::SetWindowPos(hWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
    SetForegroundWindow(hWnd);
}

void WindowManager::Blur()
{
    HWND hWnd = GetMainWindow();
    HWND next_hwnd = ::GetNextWindow(hWnd, GW_HWNDNEXT);
    while (next_hwnd)
    {
        if (::IsWindowVisible(next_hwnd))
        {
            ::SetForegroundWindow(next_hwnd);
            return;
        }
        next_hwnd = ::GetNextWindow(next_hwnd, GW_HWNDNEXT);
    }
}

void WindowManager::Show()
{
    ShowWindowAsync(GetMainWindow(), SW_SHOW);
    SetForegroundWindow(GetMainWindow());
}

void WindowManager::Hide()
{
    ShowWindow(GetMainWindow(), SW_HIDE);
}

bool WindowManager::IsVisible()
{
    bool isVisible = IsWindowVisible(GetMainWindow());
    return isVisible;
}

bool WindowManager::IsMaximized()
{
    HWND mainWindow = GetMainWindow();
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(mainWindow, &windowPlacement);

    return windowPlacement.showCmd == SW_MAXIMIZE;
}

void WindowManager::Maximize()
{
    HWND mainWindow = GetMainWindow();
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(mainWindow, &windowPlacement);

    if (windowPlacement.showCmd != SW_MAXIMIZE)
    {
        PostMessage(mainWindow, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    }
}

void WindowManager::Unmaximize()
{
    HWND mainWindow = GetMainWindow();
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(mainWindow, &windowPlacement);

    if (windowPlacement.showCmd != SW_NORMAL)
    {
        PostMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
    }
}

bool WindowManager::IsMinimized()
{
    HWND mainWindow = GetMainWindow();
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(mainWindow, &windowPlacement);

    return windowPlacement.showCmd == SW_SHOWMINIMIZED;
}

void WindowManager::Minimize()
{
    HWND mainWindow = GetMainWindow();
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(mainWindow, &windowPlacement);

    if (windowPlacement.showCmd != SW_SHOWMINIMIZED)
    {
        PostMessage(mainWindow, WM_SYSCOMMAND, SC_MINIMIZE, 0);
    }
}

void WindowManager::Restore()
{
    HWND mainWindow = GetMainWindow();
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(mainWindow, &windowPlacement);

    if (windowPlacement.showCmd != SW_NORMAL)
    {
        PostMessage(mainWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
    }
}

bool WindowManager::IsFullScreen()
{
    return g_is_window_fullscreen;
}

void WindowManager::SetFullScreen(const flutter::EncodableMap &args)
{
    bool isFullScreen = std::get<bool>(args.at(flutter::EncodableValue("isFullScreen")));

    HWND mainWindow = GetMainWindow();

    // Inspired by how Chromium does this
    // https://src.chromium.org/viewvc/chrome/trunk/src/ui/views/win/fullscreen_handler.cc?revision=247204&view=markup

    // Save current window state if not already fullscreen.
    if (!g_is_window_fullscreen)
    {
        // Save current window information.
        g_maximized_before_fullscreen = !!::IsZoomed(mainWindow);
        g_style_before_fullscreen = GetWindowLong(mainWindow, GWL_STYLE);
        g_ex_style_before_fullscreen = GetWindowLong(mainWindow, GWL_EXSTYLE);
        ::GetWindowRect(mainWindow, &g_frame_before_fullscreen);
    }

    if (isFullScreen)
    {
        // Set new window style and size.
        ::SetWindowLong(mainWindow, GWL_STYLE, g_style_before_fullscreen & ~(WS_CAPTION | WS_THICKFRAME));
        ::SetWindowLong(mainWindow, GWL_EXSTYLE,
                        g_ex_style_before_fullscreen &
                            ~(WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE));

        MONITORINFO monitor_info;
        monitor_info.cbSize = sizeof(monitor_info);
        ::GetMonitorInfo(::MonitorFromWindow(mainWindow, MONITOR_DEFAULTTONEAREST), &monitor_info);
        ::SetWindowPos(mainWindow, NULL, monitor_info.rcMonitor.left, monitor_info.rcMonitor.top,
                       monitor_info.rcMonitor.right - monitor_info.rcMonitor.left,
                       monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top,
                       SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED);
        ::SendMessage(mainWindow, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    }
    else
    {
        ::SetWindowLong(mainWindow, GWL_STYLE, g_style_before_fullscreen);
        ::SetWindowLong(mainWindow, GWL_EXSTYLE, g_ex_style_before_fullscreen);

        ::SetWindowPos(mainWindow, NULL, g_frame_before_fullscreen.left, g_frame_before_fullscreen.top,
                       g_frame_before_fullscreen.right - g_frame_before_fullscreen.left,
                       g_frame_before_fullscreen.bottom - g_frame_before_fullscreen.top,
                       SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED);
        if (g_maximized_before_fullscreen)
            ::SendMessage(mainWindow, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    }

    g_is_window_fullscreen = isFullScreen;
}

void WindowManager::SetBackgroundColor(const flutter::EncodableMap &args)
{
    int backgroundColorA = std::get<int>(args.at(flutter::EncodableValue("backgroundColorA")));
    int backgroundColorR = std::get<int>(args.at(flutter::EncodableValue("backgroundColorR")));
    int backgroundColorG = std::get<int>(args.at(flutter::EncodableValue("backgroundColorG")));
    int backgroundColorB = std::get<int>(args.at(flutter::EncodableValue("backgroundColorB")));

    bool isTransparent =
        backgroundColorA == 0 && backgroundColorR == 0 && backgroundColorG == 0 && backgroundColorB == 0;

    HWND hWnd = GetMainWindow();
    const HINSTANCE hModule = LoadLibrary(TEXT("user32.dll"));
    if (hModule)
    {
        typedef enum _ACCENT_STATE
        {
            ACCENT_DISABLED = 0,
            ACCENT_ENABLE_GRADIENT = 1,
            ACCENT_ENABLE_TRANSPARENTGRADIENT = 2,
            ACCENT_ENABLE_BLURBEHIND = 3,
            ACCENT_ENABLE_ACRYLICBLURBEHIND = 4,
            ACCENT_ENABLE_HOSTBACKDROP = 5,
            ACCENT_INVALID_STATE = 6
        } ACCENT_STATE;
        struct ACCENTPOLICY
        {
            int nAccentState;
            int nFlags;
            int nColor;
            int nAnimationId;
        };
        struct WINCOMPATTRDATA
        {
            int nAttribute;
            PVOID pData;
            ULONG ulDataSize;
        };
        typedef BOOL(WINAPI * pSetWindowCompositionAttribute)(HWND, WINCOMPATTRDATA *);
        const pSetWindowCompositionAttribute SetWindowCompositionAttribute =
            (pSetWindowCompositionAttribute)GetProcAddress(hModule, "SetWindowCompositionAttribute");
        if (SetWindowCompositionAttribute)
        {
            int32_t accent_state = isTransparent ? ACCENT_ENABLE_TRANSPARENTGRADIENT : ACCENT_ENABLE_GRADIENT;
            ACCENTPOLICY policy = {
                accent_state, 2,
                ((backgroundColorA << 24) + (backgroundColorB << 16) + (backgroundColorG << 8) + (backgroundColorR)),
                0};
            WINCOMPATTRDATA data = {19, &policy, sizeof(policy)};
            SetWindowCompositionAttribute(hWnd, &data);
        }
        FreeLibrary(hModule);
    }
}

flutter::EncodableMap WindowManager::GetPosition(const flutter::EncodableMap &args)
{
    double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

    flutter::EncodableMap resultMap = flutter::EncodableMap();
    RECT rect;
    if (GetWindowRect(GetMainWindow(), &rect))
    {
        double x = rect.left / devicePixelRatio * 1.0f;
        double y = rect.top / devicePixelRatio * 1.0f;

        resultMap[flutter::EncodableValue("x")] = flutter::EncodableValue(x);
        resultMap[flutter::EncodableValue("y")] = flutter::EncodableValue(y);
    }
    return resultMap;
}

void WindowManager::SetPosition(const flutter::EncodableMap &args)
{
    double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
    double x = std::get<double>(args.at(flutter::EncodableValue("x")));
    double y = std::get<double>(args.at(flutter::EncodableValue("y")));

    SetWindowPos(GetMainWindow(), HWND_TOP, int(x * devicePixelRatio), int(y * devicePixelRatio), 0, 0, SWP_NOSIZE);
}

flutter::EncodableMap WindowManager::GetSize(const flutter::EncodableMap &args)
{
    double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

    flutter::EncodableMap resultMap = flutter::EncodableMap();
    RECT rect;
    if (GetWindowRect(GetMainWindow(), &rect))
    {
        double width = (rect.right - rect.left) / devicePixelRatio * 1.0f;
        double height = (rect.bottom - rect.top) / devicePixelRatio * 1.0f;

        resultMap[flutter::EncodableValue("width")] = flutter::EncodableValue(width);
        resultMap[flutter::EncodableValue("height")] = flutter::EncodableValue(height);
    }
    return resultMap;
}

void WindowManager::SetSize(const flutter::EncodableMap &args)
{
    double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
    double width = std::get<double>(args.at(flutter::EncodableValue("width")));
    double height = std::get<double>(args.at(flutter::EncodableValue("height")));

    SetWindowPos(GetMainWindow(), HWND_TOP, 0, 0, int(width * devicePixelRatio), int(height * devicePixelRatio),
                 SWP_NOMOVE);
}

void WindowManager::SetMinimumSize(const flutter::EncodableMap &args)
{
    double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
    double width = std::get<double>(args.at(flutter::EncodableValue("width")));
    double height = std::get<double>(args.at(flutter::EncodableValue("height")));

    if (width >= 0 && height >= 0)
    {
        POINT point = {};
        point.x = static_cast<LONG>(width * devicePixelRatio);
        point.y = static_cast<LONG>(height * devicePixelRatio);
        minimum_size = point;
    }
}

void WindowManager::SetMaximumSize(const flutter::EncodableMap &args)
{
    double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
    double width = std::get<double>(args.at(flutter::EncodableValue("width")));
    double height = std::get<double>(args.at(flutter::EncodableValue("height")));

    if (width >= 0 && height >= 0)
    {
        POINT point = {};
        point.x = static_cast<LONG>(width * devicePixelRatio);
        point.y = static_cast<LONG>(height * devicePixelRatio);
        maximum_size = point;
    }
}

bool WindowManager::IsResizable()
{
    HWND hWnd = GetMainWindow();
    DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
    return (gwlStyle & WS_THICKFRAME) != 0;
}

void WindowManager::SetResizable(const flutter::EncodableMap &args)
{
    HWND hWnd = GetMainWindow();
    bool isResizable = std::get<bool>(args.at(flutter::EncodableValue("isResizable")));
    DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
    gwlStyle = isResizable ? gwlStyle | WS_THICKFRAME : gwlStyle & ~WS_THICKFRAME;
    SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
}

bool WindowManager::IsMinimizable()
{
    HWND hWnd = GetMainWindow();
    DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
    return (gwlStyle & WS_MINIMIZEBOX) != 0;
}

void WindowManager::SetMinimizable(const flutter::EncodableMap &args)
{
    HWND hWnd = GetMainWindow();
    bool isMinimizable = std::get<bool>(args.at(flutter::EncodableValue("isMinimizable")));
    DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
    gwlStyle = isMinimizable ? gwlStyle | WS_MINIMIZEBOX : gwlStyle & ~WS_MINIMIZEBOX;
    SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
}

bool WindowManager::IsClosable()
{
    HWND hWnd = GetMainWindow();
    DWORD gclStyle = GetClassLong(hWnd, GCL_STYLE);
    return !((gclStyle & CS_NOCLOSE) != 0);
}

void WindowManager::SetClosable(const flutter::EncodableMap &args)
{
    HWND hWnd = GetMainWindow();
    bool isClosable = std::get<bool>(args.at(flutter::EncodableValue("isClosable")));
    DWORD gclStyle = GetClassLong(hWnd, GCL_STYLE);
    gclStyle = isClosable ? gclStyle & ~CS_NOCLOSE : gclStyle | CS_NOCLOSE;
    SetClassLong(hWnd, GCL_STYLE, gclStyle);
}

bool WindowManager::IsAlwaysOnTop()
{
    DWORD dwExStyle = GetWindowLong(GetMainWindow(), GWL_EXSTYLE);
    return (dwExStyle & WS_EX_TOPMOST) != 0;
}

void WindowManager::SetAlwaysOnTop(const flutter::EncodableMap &args)
{
    bool isAlwaysOnTop = std::get<bool>(args.at(flutter::EncodableValue("isAlwaysOnTop")));
    SetWindowPos(GetMainWindow(), isAlwaysOnTop ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

std::string WindowManager::GetTitle()
{
    int const bufferSize = 1 + GetWindowTextLength(GetMainWindow());
    std::wstring title(bufferSize, L'\0');
    GetWindowText(GetMainWindow(), &title[0], bufferSize);

    std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
    return (converter.to_bytes(title)).c_str();
}

void WindowManager::SetTitle(const flutter::EncodableMap &args)
{
    std::string title = std::get<std::string>(args.at(flutter::EncodableValue("title")));

    std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
    SetWindowText(GetMainWindow(), converter.from_bytes(title).c_str());
}

void WindowManager::SetTitleBarStyle(const flutter::EncodableMap &args)
{
    std::string titleBarStyle = std::get<std::string>(args.at(flutter::EncodableValue("titleBarStyle")));

    this->title_bar_style = titleBarStyle;

    HWND hWnd = GetMainWindow();
    DWORD gwlStyle = GetWindowLong(hWnd, GWL_STYLE);
    if (titleBarStyle == "hidden")
    {
        gwlStyle = gwlStyle & ~WS_CAPTION;
        SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
    }
    else
    {
        gwlStyle = gwlStyle | WS_CAPTION;
        SetWindowLong(hWnd, GWL_STYLE, gwlStyle);
    }

    RECT rect;
    GetWindowRect(hWnd, &rect);
    SetWindowPos(hWnd, nullptr, rect.left, rect.top, 0, 0,
                 SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED);
}

void WindowManager::SetSkipTaskbar(const flutter::EncodableMap &args)
{
    bool is_skip_taskbar = std::get<bool>(args.at(flutter::EncodableValue("isSkipTaskbar")));

    HWND hWnd = GetMainWindow();

    LPVOID lp = NULL;
    CoInitialize(lp);

    HRESULT hr;
    ITaskbarList *pTaskbarList;
    hr = CoCreateInstance(CLSID_TaskbarList, NULL, CLSCTX_INPROC_SERVER, IID_ITaskbarList, (void **)&pTaskbarList);
    if (SUCCEEDED(hr))
    {
        pTaskbarList->HrInit();
        if (!is_skip_taskbar)
            pTaskbarList->AddTab(hWnd);
        else
            pTaskbarList->DeleteTab(hWnd);
        pTaskbarList->Release();
    }
}

double WindowManager::GetOpacity()
{
    return this->opacity;
}

void WindowManager::SetOpacity(const flutter::EncodableMap &args)
{
    this->opacity = std::get<double>(args.at(flutter::EncodableValue("opacity")));
    HWND hWnd = GetMainWindow();
    long gwlExStyle = GetWindowLong(hWnd, GWL_EXSTYLE);
    SetWindowLong(hWnd, GWL_EXSTYLE, gwlExStyle | WS_EX_LAYERED);
    SetLayeredWindowAttributes(hWnd, 0, static_cast<int8_t>(255 * this->opacity), 0x02);
}

void WindowManager::StartDragging()
{
    ReleaseCapture();
    SendMessage(GetMainWindow(), WM_SYSCOMMAND, SC_MOVE | HTCAPTION, 0);
}

} // namespace
