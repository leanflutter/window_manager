#include "include/window_manager/window_manager_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define WINDOW_MANAGER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), window_manager_plugin_get_type(), \
                              WindowManagerPlugin))

WindowManagerPlugin *plugin_instance;

struct _WindowManagerPlugin
{
  GObject parent_instance;
  FlPluginRegistrar *registrar;
  FlMethodChannel *channel;
  GdkGeometry window_geometry;
  bool _is_minimized = false;
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

GdkWindow *get_gdk_window(WindowManagerPlugin *self)
{
  return gtk_widget_get_window(GTK_WIDGET(get_window(self)));
}

static FlMethodResponse *focus(WindowManagerPlugin *self)
{
  gtk_window_present(get_window(self));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *blur(WindowManagerPlugin *self)
{
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *show(WindowManagerPlugin *self)
{
  gtk_widget_show(GTK_WIDGET(get_window(self)));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *hide(WindowManagerPlugin *self)
{
  gtk_widget_hide(GTK_WIDGET(get_window(self)));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *is_visible(WindowManagerPlugin *self)
{
  bool is_visible = gtk_widget_is_visible(GTK_WIDGET(get_window(self)));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(is_visible)));
}

static FlMethodResponse *is_maximized(WindowManagerPlugin *self)
{
  bool is_maximized = gtk_window_is_maximized(get_window(self));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(is_maximized)));
}

static FlMethodResponse *maximize(WindowManagerPlugin *self)
{
  gtk_window_maximize(get_window(self));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *unmaximize(WindowManagerPlugin *self)
{
  gtk_window_unmaximize(get_window(self));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *is_minimized(WindowManagerPlugin *self)
{
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(self->_is_minimized)));
}

static FlMethodResponse *minimize(WindowManagerPlugin *self)
{
  gtk_window_iconify(get_window(self));
  self->_is_minimized = true;
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *restore(WindowManagerPlugin *self)
{
  gtk_window_deiconify(get_window(self));
  gtk_window_present(get_window(self));
  self->_is_minimized = false;
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *is_full_screen(WindowManagerPlugin *self)
{
  bool is_full_screen = (bool)(gdk_window_get_state(get_gdk_window(self)) & GDK_WINDOW_STATE_FULLSCREEN);

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
  const float x = fl_value_get_float(fl_value_lookup_string(args, "x"));
  const float y = fl_value_get_float(fl_value_lookup_string(args, "y"));
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height = fl_value_get_float(fl_value_lookup_string(args, "height"));

  gtk_window_resize(get_window(self), static_cast<gint>(width), static_cast<gint>(height));
  gtk_window_move(get_window(self), static_cast<gint>(x), static_cast<gint>(y));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *set_minimum_size(WindowManagerPlugin *self,
                                          FlValue *args)
{
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height = fl_value_get_float(fl_value_lookup_string(args, "height"));

  if (width >= 0 && height >= 0)
  {
    self->window_geometry.min_width = static_cast<gint>(width);
    self->window_geometry.min_height = static_cast<gint>(height);
  }

  gdk_window_set_geometry_hints(
      get_gdk_window(self),
      &self->window_geometry,
      static_cast<GdkWindowHints>(GDK_HINT_MIN_SIZE | GDK_HINT_MAX_SIZE));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *set_maximum_size(WindowManagerPlugin *self,
                                          FlValue *args)
{
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height = fl_value_get_float(fl_value_lookup_string(args, "height"));

  self->window_geometry.max_width = static_cast<gint>(width);
  self->window_geometry.max_height = static_cast<gint>(height);

  if (self->window_geometry.max_width < 0)
    self->window_geometry.max_width = G_MAXINT;
  if (self->window_geometry.max_height < 0)
    self->window_geometry.max_height = G_MAXINT;

  gdk_window_set_geometry_hints(
      get_gdk_window(self),
      &self->window_geometry,
      static_cast<GdkWindowHints>(GDK_HINT_MIN_SIZE | GDK_HINT_MAX_SIZE));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *is_always_on_top(WindowManagerPlugin *self)
{
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(self->_is_always_on_top)));
}

static FlMethodResponse *set_always_on_top(WindowManagerPlugin *self,
                                           FlValue *args)
{
  bool isAlwaysOnTop = fl_value_get_bool(fl_value_lookup_string(args, "isAlwaysOnTop"));

  gtk_window_set_keep_above(get_window(self), isAlwaysOnTop);
  self->_is_always_on_top = isAlwaysOnTop;

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *get_title(WindowManagerPlugin *self)
{
  const gchar *title = gtk_window_get_title(get_window(self));
  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(title)));
}

static FlMethodResponse *set_title(WindowManagerPlugin *self,
                                   FlValue *args)
{
  const gchar *title = fl_value_get_string(fl_value_lookup_string(args, "title"));

  gtk_window_set_title(get_window(self), title);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse *start_dragging(WindowManagerPlugin *self)
{
  auto window = get_window(self);
  auto screen = gtk_window_get_screen(window);
  auto display = gdk_screen_get_display(screen);
  auto seat = gdk_display_get_default_seat(display);
  auto device = gdk_seat_get_pointer(seat);

  gint root_x, root_y;
  gdk_device_get_position(device, nullptr, &root_x, &root_y);
  guint32 timestamp = (guint32)g_get_monotonic_time();

  gtk_window_begin_move_drag(window,
                             1,
                             root_x,
                             root_y,
                             timestamp);

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
  else if (strcmp(method, "blur") == 0)
  {
    response = blur(self);
  }
  else if (strcmp(method, "show") == 0)
  {
    response = show(self);
  }
  else if (strcmp(method, "hide") == 0)
  {
    response = hide(self);
  }
  else if (strcmp(method, "isVisible") == 0)
  {
    response = is_visible(self);
  }
  else if (strcmp(method, "isMaximized") == 0)
  {
    response = is_maximized(self);
  }
  else if (strcmp(method, "maximize") == 0)
  {
    response = maximize(self);
  }
  else if (strcmp(method, "unmaximize") == 0)
  {
    response = unmaximize(self);
  }
  else if (strcmp(method, "isMinimized") == 0)
  {
    response = is_minimized(self);
  }
  else if (strcmp(method, "minimize") == 0)
  {
    response = minimize(self);
  }
  else if (strcmp(method, "restore") == 0)
  {
    response = restore(self);
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
  else if (strcmp(method, "setMaximumSize") == 0)
  {
    response = set_maximum_size(self, args);
  }
  else if (strcmp(method, "isAlwaysOnTop") == 0)
  {
    response = is_always_on_top(self);
  }
  else if (strcmp(method, "setAlwaysOnTop") == 0)
  {
    response = set_always_on_top(self, args);
  }
  else if (strcmp(method, "getTitle") == 0)
  {
    response = get_title(self);
  }
  else if (strcmp(method, "setTitle") == 0)
  {
    response = set_title(self, args);
  }
  else if (strcmp(method, "startDragging") == 0)
  {
    response = start_dragging(self);
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

void _emit_event(const char *event_name)
{
  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "eventName", fl_value_new_string(event_name));
  fl_method_channel_invoke_method(plugin_instance->channel,
                                  "onEvent", result_data,
                                  nullptr, nullptr, nullptr);
}

void on_window_focus(GtkWidget *widget, GdkEvent *event, gpointer data)
{
  _emit_event("focus");
}

void on_window_blur(GtkWidget *widget, GdkEvent *event, gpointer data)
{
  _emit_event("blur");
}
void on_window_show(GtkWidget *widget, GdkEvent *event, gpointer data)
{
  _emit_event("show");
}

void on_window_hide(GtkWidget *widget, GdkEvent *event, gpointer data)
{
  _emit_event("hide");
}

void on_window_state_change(GtkWidget *widget, GdkEventWindowState *event, gpointer data)
{
  if (event->new_window_state & GDK_WINDOW_STATE_MAXIMIZED)
  {
    _emit_event("maximize");
  }
  else if (event->new_window_state & GDK_WINDOW_STATE_ICONIFIED)
  {
    _emit_event("minimize");
  }
  else if (event->new_window_state & GDK_WINDOW_STATE_FULLSCREEN)
  {
    _emit_event("enter-full-screen");
  }
}

void window_manager_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  WindowManagerPlugin *plugin = WINDOW_MANAGER_PLUGIN(
      g_object_new(window_manager_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  plugin->window_geometry.min_width = -1;
  plugin->window_geometry.min_height = -1;
  plugin->window_geometry.max_width = G_MAXINT;
  plugin->window_geometry.max_height = G_MAXINT;

  g_signal_connect(get_window(plugin), "focus-in-event", G_CALLBACK(on_window_focus), NULL);
  g_signal_connect(get_window(plugin), "focus-out-event", G_CALLBACK(on_window_blur), NULL);
  g_signal_connect(get_window(plugin), "show", G_CALLBACK(on_window_show), NULL);
  g_signal_connect(get_window(plugin), "hide", G_CALLBACK(on_window_hide), NULL);
  g_signal_connect(get_window(plugin), "window-state-event", G_CALLBACK(on_window_state_change), NULL);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "window_manager",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(plugin->channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  plugin_instance = plugin;

  g_object_unref(plugin);
}
