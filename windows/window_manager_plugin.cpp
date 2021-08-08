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
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
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

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }

    WindowManagerPlugin::WindowManagerPlugin() {}

    WindowManagerPlugin::~WindowManagerPlugin() {}

    void SetTitle(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        std::string title = std::get<std::string>(args.at(flutter::EncodableValue("title")));

        std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
        HWND mainWindow = GetActiveWindow();
        SetWindowText(mainWindow, converter.from_bytes(title).c_str());

        result->Success(flutter::EncodableValue(true));
    }

    void GetFrame(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));

        flutter::EncodableMap resultMap = flutter::EncodableMap();
        HWND mainWindow = GetActiveWindow();
        RECT rect;
        if (GetWindowRect(mainWindow, &rect))
        {
            double x = rect.left / devicePixelRatio * 1.0f;
            double y = rect.top / devicePixelRatio * 1.0f;
            double width = (rect.right - rect.left) / devicePixelRatio * 1.0f;
            double height = (rect.bottom - rect.top) / devicePixelRatio * 1.0f;

            resultMap[flutter::EncodableValue("origin_x")] = flutter::EncodableValue(x);
            resultMap[flutter::EncodableValue("origin_y")] = flutter::EncodableValue(y);
            resultMap[flutter::EncodableValue("size_width")] = flutter::EncodableValue(width);
            resultMap[flutter::EncodableValue("size_height")] = flutter::EncodableValue(height);
        }
        result->Success(flutter::EncodableValue(resultMap));
    }

    void SetFrame(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        double devicePixelRatio = std::get<double>(args.at(flutter::EncodableValue("devicePixelRatio")));
        // double x = std::get<double>(args.at(flutter::EncodableValue("origin_x")));
        // double y = std::get<double>(args.at(flutter::EncodableValue("origin_y")));
        double width = std::get<double>(args.at(flutter::EncodableValue("size_width")));
        double height = std::get<double>(args.at(flutter::EncodableValue("size_height")));

        HWND mainWindow = GetActiveWindow();
        SetWindowPos(mainWindow, HWND_TOP, 0, 0, int(width * devicePixelRatio), int(height * devicePixelRatio), SWP_NOMOVE);

        result->Success(flutter::EncodableValue(true));
    }

    void SetMinSize(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        result->NotImplemented();
    }

    void SetMaxSize(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        result->NotImplemented();
    }

    void IsUseAnimator(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        result->NotImplemented();
    }

    void SetUseAnimator(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        result->NotImplemented();
    }

    void IsAlwaysOnTop(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        
        HWND mainWindow = GetActiveWindow();
        DWORD dwExStyle = GetWindowLong(mainWindow, GWL_EXSTYLE);

        flutter::EncodableMap resultMap = flutter::EncodableMap();
        if ((dwExStyle & WS_EX_TOPMOST) != 0) {
            resultMap[flutter::EncodableValue("isAlwaysOnTop")] = flutter::EncodableValue(true);
        } else {
            resultMap[flutter::EncodableValue("isAlwaysOnTop")] = flutter::EncodableValue(false);
        }
        result->Success(flutter::EncodableValue(resultMap));
    }

    void SetAlwaysOnTop(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        bool isAlwaysOnTop = std::get<bool>(args.at(flutter::EncodableValue("isAlwaysOnTop")));

        HWND mainWindow = GetActiveWindow();
        SetWindowPos(mainWindow, isAlwaysOnTop ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);

        result->Success(flutter::EncodableValue(true));
    }

    void WindowManagerPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (method_call.method_name().compare("setTitle") == 0) {
            SetTitle(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("getFrame") == 0) {
            GetFrame(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setFrame") == 0) {
            SetFrame(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setMinSize") == 0) {
            SetMinSize(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setMaxSize") == 0) {
            SetMaxSize(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("isUseAnimator") == 0) {
            IsUseAnimator(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setUseAnimator") == 0) {
            SetUseAnimator(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("isAlwaysOnTop") == 0) {
            IsAlwaysOnTop(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("setAlwaysOnTop") == 0) {
            SetAlwaysOnTop(method_call, std::move(result));
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
