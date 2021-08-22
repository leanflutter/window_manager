#include "include/window_manager/window_manager_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define WINDOW_MANAGER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), window_manager_plugin_get_type(), \
                              WindowManagerPlugin))

struct _WindowManagerPlugin
{
  GObject parent_instance;
  FlPluginRegistrar *registrar;
  bool _is_use_animator = false;
  bool _is_always_on_top = false;
};

G_DEFINE_TYPE(WindowManagerPlugin, window_manager_plugin, g_object_get_type())

// Gets the window being controlled.
GtkWindow *get_window(WindowManagerPlugin *self)
{
  FlView *view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr)
    return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

static FlMethodResponse *focus(WindowManagerPlugin *self)
{
  gtk_window_present(get_window(self));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *is_full_screen(WindowManagerPlugin *self)
{
  GdkWindow *gdk_window = gtk_widget_get_window(GTK_WIDGET(get_window(self)));
  bool is_full_screen = (bool)(gdk_window_get_state(gdk_window) & GDK_WINDOW_STATE_FULLSCREEN);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "isFullScreen", fl_value_new_bool(is_full_screen));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result_data));
}

static FlMethodResponse *set_full_screen(WindowManagerPlugin *self,
                                         FlValue *args)
{
  bool is_full_screen = fl_value_get_bool(fl_value_lookup_string(args, "isFullScreen"));

  if (is_full_screen)
    gtk_window_fullscreen(get_window(self));
  else
    gtk_window_unfullscreen(get_window(self));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *get_bounds(WindowManagerPlugin *self)
{
  gint width, height;
  gtk_window_get_size(get_window(self), &width, &height);
  gint x, y;
  gtk_window_get_position(get_window(self), &x, &y);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "x", fl_value_new_float(x));
  fl_value_set_string_take(result_data, "y", fl_value_new_float(y));
  fl_value_set_string_take(result_data, "width", fl_value_new_float(width));
  fl_value_set_string_take(result_data, "height", fl_value_new_float(height));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result_data));
}

static FlMethodResponse *set_bounds(WindowManagerPlugin *self,
                                    FlValue *args)
{
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height = fl_value_get_float(fl_value_lookup_string(args, "height"));

  gtk_window_resize(get_window(self), static_cast<gint>(width), static_cast<gint>(height));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *set_minimum_size(WindowManagerPlugin *self,
                                          FlValue *args)
{
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height = fl_value_get_float(fl_value_lookup_string(args, "height"));

  GdkGeometry geometry;
  geometry.max_width = static_cast<gint>(width);
  geometry.max_height = static_cast<gint>(height);

  // gdk_window_set_geometry_hints(get_window(self), &geometry, static_cast<GdkWindowHints>(GDK_HINT_MIN_SIZE));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *is_always_on_top(WindowManagerPlugin *self)
{
  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "isAlwaysOnTop", fl_value_new_bool(self->_is_always_on_top));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result_data));
}

static FlMethodResponse *set_always_on_top(WindowManagerPlugin *self,
                                           FlValue *args)
{
  bool isAlwaysOnTop = fl_value_get_bool(fl_value_lookup_string(args, "isAlwaysOnTop"));

  gtk_window_set_keep_above(get_window(self), isAlwaysOnTop);
  self->_is_always_on_top = isAlwaysOnTop;

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *terminate(WindowManagerPlugin *self)
{
  gtk_window_close(get_window(self));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

// Called when a method call is received from Flutter.
static void window_manager_plugin_handle_method_call(
    WindowManagerPlugin *self,
    FlMethodCall *method_call)
{
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);
  FlValue *args = fl_method_call_get_args(method_call);
  if (strcmp(method, "focus") == 0)
  {
    response = focus(self);
  }
  else if (strcmp(method, "isFullScreen") == 0)
  {
    response = is_full_screen(self);
  }
  else if (strcmp(method, "setFullScreen") == 0)
  {
    response = set_full_screen(self, args);
  }
  else if (strcmp(method, "getBounds") == 0)
  {
    response = get_bounds(self);
  }
  else if (strcmp(method, "setBounds") == 0)
  {
    response = set_bounds(self, args);
  }
  else if (strcmp(method, "setMinimumSize") == 0)
  {
    response = set_minimum_size(self, args);
  }
  // else if (strcmp(method, "setMaximumSize") == 0)
  // {
  //   response = set_maximum_size(self, args);
  // }
  else if (strcmp(method, "isAlwaysOnTop") == 0)
  {
    response = is_always_on_top(self);
  }
  else if (strcmp(method, "setAlwaysOnTop") == 0)
  {
    response = set_always_on_top(self, args);
  }
  else if (strcmp(method, "terminate") == 0)
  {
    response = terminate(self);
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void window_manager_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(window_manager_plugin_parent_class)->dispose(object);
}

static void window_manager_plugin_class_init(WindowManagerPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = window_manager_plugin_dispose;
}

static void window_manager_plugin_init(WindowManagerPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  WindowManagerPlugin *plugin = WINDOW_MANAGER_PLUGIN(user_data);
  window_manager_plugin_handle_method_call(plugin, method_call);
}

void window_manager_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  WindowManagerPlugin *plugin = WINDOW_MANAGER_PLUGIN(
      g_object_new(window_manager_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "window_manager",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
