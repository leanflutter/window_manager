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

namespace {

    class WindowManagerPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

        WindowManagerPlugin();

        virtual ~WindowManagerPlugin();

    private:
        flutter::PluginRegistrarWindows* registrar;

        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        HWND GetMainWindow();
        void Show(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void Hide(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::IsVisible(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::IsMaximized(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::Maximize(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::Unmaximize(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::IsMinimized(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::Minimize(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::Restore(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::IsFullScreen(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::SetFullScreen(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::GetBounds(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::SetBounds(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::SetMinimumSize(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::SetMaximumSize(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::IsAlwaysOnTop(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::SetAlwaysOnTop(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void WindowManagerPlugin::Terminate(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

    // static
    void WindowManagerPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows* registrar) {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "window_manager",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<WindowManagerPlugin>();
        plugin->registrar = registrar;

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }

    WindowManagerPlugin::WindowManagerPlugin() {}

    WindowManagerPlugin::~WindowManagerPlugin() {}

    HWND WindowManagerPlugin::GetMainWindow() {
        return ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
    }

    void WindowManagerPlugin::Show(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        ShowWindow(GetMainWindow(), SW_SHOW);

        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::Hide(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        ShowWindow(GetMainWindow(), SW_HIDE);

        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::IsVisible(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        bool isVisible = IsWindowVisible(GetMainWindow());

        result->Success(flutter::EncodableValue(isVisible));
    }

    void WindowManagerPlugin::IsMaximized(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        result->Success(flutter::EncodableValue(windowPlacement.showCmd == SW_MAXIMIZE));
    }

    void WindowManagerPlugin::Maximize(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        if (windowPlacement.showCmd != SW_MAXIMIZE) {
            windowPlacement.showCmd = SW_MAXIMIZE;
            SetWindowPlacement(mainWindow, &windowPlacement);
        }
        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::Unmaximize(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        if (windowPlacement.showCmd != SW_NORMAL) {
            windowPlacement.showCmd = SW_NORMAL;
            SetWindowPlacement(mainWindow, &windowPlacement);
        }
        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::IsMinimized(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        result->Success(flutter::EncodableValue(windowPlacement.showCmd == SW_SHOWMINIMIZED));
    }

    void WindowManagerPlugin::Minimize(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        if (windowPlacement.showCmd != SW_SHOWMINIMIZED) {
            windowPlacement.showCmd = SW_SHOWMINIMIZED;
            SetWindowPlacement(mainWindow, &windowPlacement);
        }
        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::Restore(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        if (windowPlacement.showCmd != SW_NORMAL) {
            windowPlacement.showCmd = SW_NORMAL;
            SetWindowPlacement(mainWindow, &windowPlacement);
        }
        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::IsFullScreen(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        flutter::EncodableMap resultMap = flutter::EncodableMap();
        resultMap[flutter::EncodableValue("isFullScreen")] = flutter::EncodableValue(windowPlacement.showCmd == SW_MAXIMIZE);
        
        result->Success(flutter::EncodableValue(resultMap));
    }

    void WindowManagerPlugin::SetFullScreen(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        bool isFullScreen = std::get<bool>(args.at(flutter::EncodableValue("isFullScreen")));

        HWND mainWindow = GetMainWindow();
        WINDOWPLACEMENT windowPlacement;
        GetWindowPlacement(mainWindow, &windowPlacement);

        if (isFullScreen) {
            windowPlacement.showCmd = SW_MAXIMIZE;
            SetWindowPlacement(mainWindow, &windowPlacement);
        }
        else {
            windowPlacement.showCmd = SW_NORMAL;
            SetWindowPlacement(mainWindow, &windowPlacement);
        }

        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::GetBounds(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

        flutter::EncodableMap resultMap = flutter::EncodableMap();
        RECT rect;
        if (GetWindowRect(GetMainWindow(), &rect))
        {
            double x = rect.left / devicePixelRatio * 1.0f;
            double y = rect.top / devicePixelRatio * 1.0f;
            double width = (rect.right - rect.left) / devicePixelRatio * 1.0f;
            double height = (rect.bottom - rect.top) / devicePixelRatio * 1.0f;

            resultMap[flutter::EncodableValue("x")] = flutter::EncodableValue(x);
            resultMap[flutter::EncodableValue("y")] = flutter::EncodableValue(y);
            resultMap[flutter::EncodableValue("width")] = flutter::EncodableValue(width);
            resultMap[flutter::EncodableValue("height")] = flutter::EncodableValue(height);
        }
        result->Success(flutter::EncodableValue(resultMap));
    }

    void WindowManagerPlugin::SetBounds(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
        double x = std::get<double>(args.at(flutter::EncodableValue("x")));
        double y = std::get<double>(args.at(flutter::EncodableValue("y")));
        double width = std::get<double>(args.at(flutter::EncodableValue("width")));
        double height = std::get<double>(args.at(flutter::EncodableValue("height")));

        SetWindowPos(
            GetMainWindow(), 
            HWND_TOP, 
            int(x * devicePixelRatio), 
            int(y * devicePixelRatio), 
            int(width * devicePixelRatio), 
            int(height * devicePixelRatio), 
            SWP_SHOWWINDOW
        );

        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::SetMinimumSize(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        result->NotImplemented();
    }

    void WindowManagerPlugin::SetMaximumSize(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        result->NotImplemented();
    }

    void WindowManagerPlugin::IsAlwaysOnTop(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        DWORD dwExStyle = GetWindowLong(GetMainWindow(), GWL_EXSTYLE);

        flutter::EncodableMap resultMap = flutter::EncodableMap();
        resultMap[flutter::EncodableValue("isAlwaysOnTop")] = flutter::EncodableValue((dwExStyle & WS_EX_TOPMOST) != 0);
        
        result->Success(flutter::EncodableValue(resultMap));
    }

    void WindowManagerPlugin::SetAlwaysOnTop(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        bool isAlwaysOnTop = std::get<bool>(args.at(flutter::EncodableValue("isAlwaysOnTop")));

        SetWindowPos(GetMainWindow(), isAlwaysOnTop ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);

        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::Terminate(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        ExitProcess(1);
    }

    void WindowManagerPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (method_call.method_name().compare("show") == 0) {
            Show(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("hide") == 0) {
            Hide(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("isVisible") == 0) {
            IsVisible(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("isMaximized") == 0) {
            IsMaximized(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("maximize") == 0) {
            Maximize(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("unmaximize") == 0) {
            Unmaximize(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("isMinimized") == 0) {
            IsMinimized(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("minimize") == 0) {
            Minimize(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("restore") == 0) {
            Restore(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("isFullScreen") == 0) {
            IsFullScreen(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setFullScreen") == 0) {
            SetFullScreen(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("getBounds") == 0) {
            GetBounds(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setBounds") == 0) {
            SetBounds(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setMinimumSize") == 0) {
            SetMinimumSize(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setMaximumSize") == 0) {
            SetMaximumSize(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("isAlwaysOnTop") == 0) {
            IsAlwaysOnTop(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setAlwaysOnTop") == 0) {
            SetAlwaysOnTop(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("terminate") == 0) {
            Terminate(method_call, std::move(result));
        }
        else {
            result->NotImplemented();
        }
    }

}  // namespace

void WindowManagerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
    WindowManagerPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
        ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
