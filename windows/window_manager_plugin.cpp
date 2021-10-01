#include "include/window_manager/window_manager_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

#include "window_manager.cpp"

namespace
{
bool is_hidden_window_at_launch = false;
std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>,
                std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>>
    channel = nullptr;

class WindowManagerPlugin : public flutter::Plugin
{
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    WindowManagerPlugin(flutter::PluginRegistrarWindows *registrar);

    virtual ~WindowManagerPlugin();

  private:
    WindowManager *window_manager;
    flutter::PluginRegistrarWindows *registrar;

    // The ID of the WindowProc delegate registration.
    int window_proc_id = -1;

    void WindowManagerPlugin::_EmitEvent(std::string eventName);
    // Called for top-level WindowProc delegation.
    std::optional<LRESULT> WindowManagerPlugin::HandleWindowProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam);
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void WindowManagerPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
{
    channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "window_manager", &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<WindowManagerPlugin>(registrar);

    channel->SetMethodCallHandler([plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
    });

    registrar->AddPlugin(std::move(plugin));
}

WindowManagerPlugin::WindowManagerPlugin(flutter::PluginRegistrarWindows *registrar) : registrar(registrar)
{
    window_manager = new WindowManager();
    window_proc_id =
        registrar->RegisterTopLevelWindowProcDelegate([this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
            return HandleWindowProc(hwnd, message, wparam, lparam);
        });
}

WindowManagerPlugin::~WindowManagerPlugin()
{
    registrar->UnregisterTopLevelWindowProcDelegate(window_proc_id);
}

void WindowManagerPlugin::_EmitEvent(std::string eventName)
{
    flutter::EncodableMap args = flutter::EncodableMap();
    args[flutter::EncodableValue("eventName")] = flutter::EncodableValue(eventName);
    channel->InvokeMethod("onEvent", std::make_unique<flutter::EncodableValue>(args));
}

std::optional<LRESULT> WindowManagerPlugin::HandleWindowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    std::optional<LRESULT> result;

    if (message == WM_NCCALCSIZE)
    {
        if (wParam && window_manager->is_frameless)
        {
            SetWindowLong(hWnd, 0, 0);
            return 1;
        }
    }
    else if (message == WM_NCHITTEST)
    {
        LONG width = 10;
        POINT mouse = {LOWORD(lParam), HIWORD(lParam)};
        RECT window;
        GetWindowRect(hWnd, &window);
        RECT rcFrame = {0};
        // AdjustWindowRectEx(&rcFrame, WS_OVERLAPPEDWINDOW & ~WS_CAPTION, FALSE, NULL);
        USHORT x = 1;
        USHORT y = 1;
        bool fOnResizeBorder = false;
        if (mouse.y >= window.top && mouse.y < window.top + width)
            x = 0;
        else if (mouse.y < window.bottom && mouse.y >= window.bottom - width)
            x = 2;
        if (mouse.x >= window.left && mouse.x < window.left + width)
            y = 0;
        else if (mouse.x < window.right && mouse.x >= window.right - width)
            y = 2;
        LRESULT hitTests[3][3] = {
            {HTTOPLEFT, fOnResizeBorder ? HTTOP : HTCAPTION, HTTOPRIGHT},
            {HTLEFT, HTNOWHERE, HTRIGHT},
            {HTBOTTOMLEFT, HTBOTTOM, HTBOTTOMRIGHT},
        };
        return hitTests[x][y];
    }
    else if (message == WM_GETMINMAXINFO)
    {
        MINMAXINFO *info = reinterpret_cast<MINMAXINFO *>(lParam);
        // For the special "unconstrained" values, leave the defaults.
        if (window_manager->minimum_size.x != 0)
            info->ptMinTrackSize.x = window_manager->minimum_size.x;
        if (window_manager->minimum_size.y != 0)
            info->ptMinTrackSize.y = window_manager->minimum_size.y;
        if (window_manager->maximum_size.x != -1)
            info->ptMaxTrackSize.x = window_manager->maximum_size.x;
        if (window_manager->maximum_size.y != -1)
            info->ptMaxTrackSize.y = window_manager->maximum_size.y;
        result = 0;
    }
    else if (message == WM_NCACTIVATE)
    {
        if (wParam == TRUE)
        {
            _EmitEvent("focus");
        }
        else
        {
            _EmitEvent("blur");
        }
    }
    else if (message == WM_MOVING)
    {
        _EmitEvent("move");
    }
    else if (message == WM_SIZING)
    {
        _EmitEvent("resize");
    }
    else if (message == WM_SIZE)
    {
        LONG_PTR gwlStyle = GetWindowLongPtr(window_manager->GetMainWindow(), GWL_STYLE);
        if ((gwlStyle & WS_POPUP) != 0 && wParam == SIZE_MAXIMIZED)
        {
            _EmitEvent("enter-full-screen");
            window_manager->last_state = STATE_FULLSCREEN_ENTERED;
        }
        else if (window_manager->last_state == STATE_FULLSCREEN_ENTERED && wParam == SIZE_RESTORED)
        {
            _EmitEvent("leave-full-screen");
            window_manager->last_state = STATE_NORMAL;
        }
        else if (wParam == SIZE_MAXIMIZED)
        {
            _EmitEvent("maximize");
            window_manager->last_state = STATE_MAXIMIZED;
        }
        else if (wParam == SIZE_MINIMIZED)
        {
            _EmitEvent("minimize");
            window_manager->last_state = STATE_MINIMIZED;
        }
        else if (wParam == SIZE_RESTORED)
        {
            if (window_manager->last_state == STATE_MAXIMIZED)
            {
                _EmitEvent("unmaximize");
                window_manager->last_state = STATE_NORMAL;
            }
            else if (window_manager->last_state == STATE_MINIMIZED)
            {
                _EmitEvent("restore");
                window_manager->last_state = STATE_NORMAL;
            }
        }
    }
    return result;
}

void WindowManagerPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                           std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
    std::string method_name = method_call.method_name();

    if (method_name.compare("ensureInitialized") == 0)
    {
        window_manager->native_window = ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("waitUntilReadyToShow") == 0)
    {
        window_manager->WaitUntilReadyToShow();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("setAsFrameless") == 0)
    {
        window_manager->SetAsFrameless();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("focus") == 0)
    {
        window_manager->Focus();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("show") == 0)
    {
        window_manager->Show();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("hide") == 0)
    {
        window_manager->Hide();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("isVisible") == 0)
    {
        bool value = window_manager->IsVisible();
        result->Success(flutter::EncodableValue(value));
    }
    else if (method_name.compare("isMaximized") == 0)
    {
        bool value = window_manager->IsMaximized();
        result->Success(flutter::EncodableValue(value));
    }
    else if (method_name.compare("maximize") == 0)
    {
        window_manager->Maximize();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("unmaximize") == 0)
    {
        window_manager->Unmaximize();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("isMinimized") == 0)
    {
        bool value = window_manager->IsMinimized();
        result->Success(flutter::EncodableValue(value));
    }
    else if (method_name.compare("minimize") == 0)
    {
        window_manager->Minimize();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("restore") == 0)
    {
        window_manager->Restore();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("isFullScreen") == 0)
    {
        bool value = window_manager->IsFullScreen();
        result->Success(flutter::EncodableValue(value));
    }
    else if (method_name.compare("setFullScreen") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetFullScreen(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("setBackgroundColor") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetBackgroundColor(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("getBounds") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        flutter::EncodableMap value = window_manager->GetBounds(args);
        result->Success(flutter::EncodableValue(value));
    }
    else if (method_name.compare("setBounds") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetBounds(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("setMinimumSize") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetMinimumSize(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("setMaximumSize") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetMaximumSize(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("isAlwaysOnTop") == 0)
    {
        bool value = window_manager->IsAlwaysOnTop();
        result->Success(flutter::EncodableValue(value));
    }
    else if (method_name.compare("setAlwaysOnTop") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetAlwaysOnTop(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("getTitle") == 0)
    {
        std::string value = window_manager->GetTitle();
        result->Success(flutter::EncodableValue(value));
    }
    else if (method_name.compare("setTitle") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetTitle(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("setSkipTaskbar") == 0)
    {
        const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        window_manager->SetSkipTaskbar(args);
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("startDragging") == 0)
    {
        window_manager->StartDragging();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_name.compare("terminate") == 0)
    {
        window_manager->Terminate();
        result->Success(flutter::EncodableValue(true));
    }
    else
    {
        result->NotImplemented();
    }
}

} // namespace

void WindowManagerPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar)
{
    WindowManagerPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

void HiddenWindowAtLaunch()
{
    is_hidden_window_at_launch = true;
}
