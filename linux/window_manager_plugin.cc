#include "include/window_manager/window_manager_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cairo/cairo.h>
#include <cstring>

#define WINDOW_MANAGER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), window_manager_plugin_get_type(), \
                              WindowManagerPlugin))

WindowManagerPlugin* plugin_instance;

static double bg_color_r = 0.0;
static double bg_color_g = 0.0;
static double bg_color_b = 0.0;
static double bg_color_a = 0.0;

struct _WindowManagerPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
  GdkGeometry window_geometry;
  bool _is_prevent_close = false;
  bool _is_frameless = false;
  bool _is_maximized = false;
  bool _is_minimized = false;
  bool _is_fullscreen = false;
  bool _is_always_on_top = false;
  bool _is_always_on_bottom = false;
  gchar* title_bar_style_ = strdup("normal");
  GdkEventButton _event_button = GdkEventButton{};
};

G_DEFINE_TYPE(WindowManagerPlugin, window_manager_plugin, g_object_get_type())

// Gets the window being controlled.
GtkWindow* get_window(WindowManagerPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr)
    return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

GdkWindow* get_gdk_window(WindowManagerPlugin* self) {
  return gtk_widget_get_window(GTK_WIDGET(get_window(self)));
}

static FlMethodResponse* set_as_frameless(WindowManagerPlugin* self,
                                          FlValue* args) {
  self->_is_frameless = true;
  bg_color_r = 0;
  bg_color_g = 0;
  bg_color_b = 0;
  bg_color_a = 0;

  gtk_window_set_decorated(get_window(self), false);

  gtk_widget_set_app_paintable(GTK_WIDGET(get_window(self)), TRUE);

  gint width, height;
  gtk_window_get_size(get_window(self), &width, &height);

  // gtk_window_resize(get_window(self), static_cast<gint>(width),
  // static_cast<gint>(height+1));
  gtk_window_resize(get_window(self), static_cast<gint>(width),
                    static_cast<gint>(height));

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* close(WindowManagerPlugin* self) {
  gtk_window_close(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_prevent_close(WindowManagerPlugin* self) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(
      fl_value_new_bool(self->_is_prevent_close)));
}

static FlMethodResponse* set_prevent_close(WindowManagerPlugin* self,
                                           FlValue* args) {
  self->_is_prevent_close =
      fl_value_get_bool(fl_value_lookup_string(args, "isPreventClose"));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* focus(WindowManagerPlugin* self) {
  gtk_window_present(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* blur(WindowManagerPlugin* self) {
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* show(WindowManagerPlugin* self) {
  gtk_widget_show(GTK_WIDGET(get_window(self)));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* hide(WindowManagerPlugin* self) {
  gtk_widget_hide(GTK_WIDGET(get_window(self)));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_visible(WindowManagerPlugin* self) {
  bool is_visible = gtk_widget_is_visible(GTK_WIDGET(get_window(self)));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(is_visible)));
}

static FlMethodResponse* is_maximized(WindowManagerPlugin* self) {
  bool is_maximized = gtk_window_is_maximized(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(is_maximized)));
}

static FlMethodResponse* maximize(WindowManagerPlugin* self) {
  gtk_window_maximize(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* unmaximize(WindowManagerPlugin* self) {
  gtk_window_unmaximize(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_minimized(WindowManagerPlugin* self) {
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(self->_is_minimized)));
}

static FlMethodResponse* minimize(WindowManagerPlugin* self) {
  gtk_window_iconify(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* restore(WindowManagerPlugin* self) {
  gtk_window_deiconify(get_window(self));
  gtk_window_present(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_full_screen(WindowManagerPlugin* self) {
  bool is_full_screen = (bool)(gdk_window_get_state(get_gdk_window(self)) &
                               GDK_WINDOW_STATE_FULLSCREEN);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(is_full_screen)));
}

static FlMethodResponse* set_full_screen(WindowManagerPlugin* self,
                                         FlValue* args) {
  bool is_full_screen =
      fl_value_get_bool(fl_value_lookup_string(args, "isFullScreen"));

  if (is_full_screen)
    gtk_window_fullscreen(get_window(self));
  else
    gtk_window_unfullscreen(get_window(self));

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* set_aspect_ratio(WindowManagerPlugin* self,
                                          FlValue* args) {
  const float aspect_ratio =
      fl_value_get_float(fl_value_lookup_string(args, "aspectRatio"));

  self->window_geometry.min_aspect = aspect_ratio;
  self->window_geometry.max_aspect = aspect_ratio;

  gdk_window_set_geometry_hints(get_gdk_window(self), &self->window_geometry,
                                static_cast<GdkWindowHints>(GDK_HINT_ASPECT));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* set_background_color(WindowManagerPlugin* self,
                                              FlValue* args) {
  bg_color_r = ((double)fl_value_get_int(
                    fl_value_lookup_string(args, "backgroundColorR")) /
                255.0);
  bg_color_g = ((double)fl_value_get_int(
                    fl_value_lookup_string(args, "backgroundColorG")) /
                255.0);
  bg_color_b = ((double)fl_value_get_int(
                    fl_value_lookup_string(args, "backgroundColorB")) /
                255.0);
  bg_color_a = ((double)fl_value_get_int(
                    fl_value_lookup_string(args, "backgroundColorA")) /
                255.0);

  gtk_widget_set_app_paintable(GTK_WIDGET(get_window(self)), TRUE);

  gint width, height;
  gtk_window_get_size(get_window(self), &width, &height);

  // gtk_window_resize(get_window(self), static_cast<gint>(width),
  // static_cast<gint>(height+1));
  gtk_window_resize(get_window(self), static_cast<gint>(width),
                    static_cast<gint>(height));

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* get_position(WindowManagerPlugin* self) {
  gint x, y;
  gtk_window_get_position(get_window(self), &x, &y);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "x", fl_value_new_float(x));
  fl_value_set_string_take(result_data, "y", fl_value_new_float(y));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result_data));
}

static FlMethodResponse* set_position(WindowManagerPlugin* self,
                                      FlValue* args) {
  const float x = fl_value_get_float(fl_value_lookup_string(args, "x"));
  const float y = fl_value_get_float(fl_value_lookup_string(args, "y"));

  gtk_window_move(get_window(self), static_cast<gint>(x), static_cast<gint>(y));

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* get_size(WindowManagerPlugin* self) {
  gint width, height;
  gtk_window_get_size(get_window(self), &width, &height);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "width", fl_value_new_float(width));
  fl_value_set_string_take(result_data, "height", fl_value_new_float(height));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result_data));
}

static FlMethodResponse* set_size(WindowManagerPlugin* self, FlValue* args) {
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height =
      fl_value_get_float(fl_value_lookup_string(args, "height"));

  gtk_window_resize(get_window(self), static_cast<gint>(width),
                    static_cast<gint>(height));

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* set_minimum_size(WindowManagerPlugin* self,
                                          FlValue* args) {
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height =
      fl_value_get_float(fl_value_lookup_string(args, "height"));

  if (width >= 0 && height >= 0) {
    self->window_geometry.min_width = static_cast<gint>(width);
    self->window_geometry.min_height = static_cast<gint>(height);
  }

  gdk_window_set_geometry_hints(
      get_gdk_window(self), &self->window_geometry,
      static_cast<GdkWindowHints>(GDK_HINT_MIN_SIZE | GDK_HINT_MAX_SIZE));

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* set_maximum_size(WindowManagerPlugin* self,
                                          FlValue* args) {
  const float width = fl_value_get_float(fl_value_lookup_string(args, "width"));
  const float height =
      fl_value_get_float(fl_value_lookup_string(args, "height"));

  self->window_geometry.max_width = static_cast<gint>(width);
  self->window_geometry.max_height = static_cast<gint>(height);

  if (self->window_geometry.max_width < 0)
    self->window_geometry.max_width = G_MAXINT;
  if (self->window_geometry.max_height < 0)
    self->window_geometry.max_height = G_MAXINT;

  gdk_window_set_geometry_hints(
      get_gdk_window(self), &self->window_geometry,
      static_cast<GdkWindowHints>(GDK_HINT_MIN_SIZE | GDK_HINT_MAX_SIZE));

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_resizable(WindowManagerPlugin* self) {
  bool is_resizable = gtk_window_get_resizable(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(is_resizable)));
}

static FlMethodResponse* set_resizable(WindowManagerPlugin* self,
                                       FlValue* args) {
  bool is_resizable =
      fl_value_get_bool(fl_value_lookup_string(args, "isResizable"));
  gtk_window_set_resizable(get_window(self), is_resizable);
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_closable(WindowManagerPlugin* self) {
  bool is_closable = gtk_window_get_deletable(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(is_closable)));
}

static FlMethodResponse* set_closable(WindowManagerPlugin* self,
                                      FlValue* args) {
  bool is_closable =
      fl_value_get_bool(fl_value_lookup_string(args, "isClosable"));
  gtk_window_set_deletable(get_window(self), is_closable);
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_always_on_top(WindowManagerPlugin* self) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(
      fl_value_new_bool(self->_is_always_on_top)));
}

static FlMethodResponse* set_always_on_top(WindowManagerPlugin* self,
                                           FlValue* args) {
  bool isAlwaysOnTop =
      fl_value_get_bool(fl_value_lookup_string(args, "isAlwaysOnTop"));

  gtk_window_set_keep_above(get_window(self), isAlwaysOnTop);
  self->_is_always_on_top = isAlwaysOnTop;

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* is_always_on_bottom(WindowManagerPlugin* self) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(
      fl_value_new_bool(self->_is_always_on_bottom)));
}

static FlMethodResponse* set_always_on_bottom(WindowManagerPlugin* self,
                                              FlValue* args) {
  bool isAlwaysOnBottom =
      fl_value_get_bool(fl_value_lookup_string(args, "isAlwaysOnBottom"));

  gtk_window_set_keep_below(get_window(self), isAlwaysOnBottom);
  self->_is_always_on_bottom = isAlwaysOnBottom;

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* get_title(WindowManagerPlugin* self) {
  const gchar* title = gtk_window_get_title(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_string(title)));
}

static FlMethodResponse* set_title(WindowManagerPlugin* self, FlValue* args) {
  const gchar* title =
      fl_value_get_string(fl_value_lookup_string(args, "title"));

  gtk_window_set_title(get_window(self), title);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* set_title_bar_style(WindowManagerPlugin* self,
                                             FlValue* args) {
  const gchar* title_bar_style =
      fl_value_get_string(fl_value_lookup_string(args, "titleBarStyle"));

  gtk_window_set_decorated(get_window(self),
                           strcmp(title_bar_style, "hidden") != 0);

  self->title_bar_style_ = strdup(title_bar_style);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* get_title_bar_height(WindowManagerPlugin* self,
                                              FlValue* args) {
  GtkWidget* widget = gtk_window_get_titlebar(get_window(self));

  int title_bar_height = 0;

  if (strcmp(self->title_bar_style_, "hidden") != 0) {
    title_bar_height = gtk_widget_get_allocated_height(widget);
  }

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_int(title_bar_height)));
}

static FlMethodResponse* is_skip_taskbar(WindowManagerPlugin* self) {
  const gboolean skipping = gtk_window_get_skip_taskbar_hint(get_window(self));
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(skipping)));
}

static FlMethodResponse* set_skip_taskbar(WindowManagerPlugin* self,
                                          FlValue* args) {
  bool isSkipTaskbar =
      fl_value_get_bool(fl_value_lookup_string(args, "isSkipTaskbar"));
  gtk_window_set_skip_taskbar_hint(get_window(self), isSkipTaskbar);
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* get_opacity(WindowManagerPlugin* self) {
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_float(1)));
}

static FlMethodResponse* pop_up_window_menu(WindowManagerPlugin* self) {
  GdkWindow* window = get_gdk_window(self);
  GdkDisplay* display = gdk_display_get_default();
  GdkSeat* seat = gdk_display_get_default_seat(display);
  GdkDevice* pointer = gdk_seat_get_pointer(seat);

  int x, y;
  gdk_device_get_position(pointer, NULL, &x, &y);

  int origin_x, origin_y;
  gdk_window_get_origin(window, &origin_x, &origin_y);

  GdkEvent* event = gdk_event_new(GDK_BUTTON_PRESS);
  event->button.window = window;
  event->button.device = pointer;
  event->button.x_root = x;
  event->button.y_root = y;
  event->button.x = x - origin_x;
  event->button.y = y - origin_y;
  gdk_window_show_window_menu(window, event);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_float(1)));
}

static FlMethodResponse* start_dragging(WindowManagerPlugin* self) {
  auto window = get_window(self);
  auto screen = gtk_window_get_screen(window);
  auto display = gdk_screen_get_display(screen);
  auto seat = gdk_display_get_default_seat(display);
  auto device = gdk_seat_get_pointer(seat);

  gint root_x, root_y;
  gdk_device_get_position(device, nullptr, &root_x, &root_y);
  guint32 timestamp = (guint32)g_get_monotonic_time();

  gtk_window_begin_move_drag(window, 1, root_x, root_y, timestamp);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* start_resizing(WindowManagerPlugin* self,
                                        FlValue* args) {
  const gchar* resize_edge =
      fl_value_get_string(fl_value_lookup_string(args, "resizeEdge"));

  auto window = get_window(self);
  auto screen = gtk_window_get_screen(window);
  auto display = gdk_screen_get_display(screen);
  auto seat = gdk_display_get_default_seat(display);
  auto device = gdk_seat_get_pointer(seat);

  gint root_x, root_y;
  gdk_device_get_position(device, nullptr, &root_x, &root_y);
  guint32 timestamp = (guint32)g_get_monotonic_time();

  GdkWindowEdge gdk_window_edge = GDK_WINDOW_EDGE_NORTH_WEST;

  if (strcmp(resize_edge, "topLeft") == 0) {
    gdk_window_edge = GDK_WINDOW_EDGE_NORTH_WEST;
  } else if (strcmp(resize_edge, "top") == 0) {
    gdk_window_edge = GDK_WINDOW_EDGE_NORTH;
  } else if (strcmp(resize_edge, "topRight") == 0) {
    gdk_window_edge = GDK_WINDOW_EDGE_NORTH_EAST;
  } else if (strcmp(resize_edge, "left") == 0) {
    gdk_window_edge = GDK_WINDOW_EDGE_WEST;
  } else if (strcmp(resize_edge, "right") == 0) {
    gdk_window_edge = GDK_WINDOW_EDGE_EAST;
  } else if (strcmp(resize_edge, "bottomLeft")) {
    gdk_window_edge = GDK_WINDOW_EDGE_SOUTH_WEST;
  } else if (strcmp(resize_edge, "bottom")) {
    gdk_window_edge = GDK_WINDOW_EDGE_SOUTH;
  } else if (strcmp(resize_edge, "bottomRight")) {
    gdk_window_edge = GDK_WINDOW_EDGE_SOUTH_EAST;
  }

  gtk_window_begin_resize_drag(window, gdk_window_edge,
                               self->_event_button.button, root_x, root_y,
                               timestamp);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* get_primary_display(WindowManagerPlugin* self,
                                             FlValue* args) {
  GdkDisplay* display = gdk_display_get_default();
  GdkMonitor* monitor = gdk_display_get_primary_monitor(display);

  GdkRectangle frame;
  gdk_monitor_get_geometry(monitor, &frame);

  auto size = fl_value_new_map();
  fl_value_set_string_take(size, "width", fl_value_new_float(frame.width));
  fl_value_set_string_take(size, "height", fl_value_new_float(frame.height));

  g_autoptr(FlValue) value = fl_value_new_map();
  fl_value_set_take(value, fl_value_new_string("size"), size);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(value));
}

// Called when a method call is received from Flutter.
static void window_manager_plugin_handle_method_call(
    WindowManagerPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "ensureInitialized") == 0) {
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_bool(true)));
  } else if (strcmp(method, "waitUntilReadyToShow") == 0) {
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_bool(true)));
  } else if (strcmp(method, "setAsFrameless") == 0) {
    response = set_as_frameless(self, args);
  } else if (strcmp(method, "close") == 0) {
    response = close(self);
  } else if (strcmp(method, "setPreventClose") == 0) {
    response = set_prevent_close(self, args);
  } else if (strcmp(method, "isPreventClose") == 0) {
    response = is_prevent_close(self);
  } else if (strcmp(method, "focus") == 0) {
    response = focus(self);
  } else if (strcmp(method, "blur") == 0) {
    response = blur(self);
  } else if (strcmp(method, "show") == 0) {
    response = show(self);
  } else if (strcmp(method, "hide") == 0) {
    response = hide(self);
  } else if (strcmp(method, "isVisible") == 0) {
    response = is_visible(self);
  } else if (strcmp(method, "isMaximized") == 0) {
    response = is_maximized(self);
  } else if (strcmp(method, "maximize") == 0) {
    response = maximize(self);
  } else if (strcmp(method, "unmaximize") == 0) {
    response = unmaximize(self);
  } else if (strcmp(method, "isMinimized") == 0) {
    response = is_minimized(self);
  } else if (strcmp(method, "minimize") == 0) {
    response = minimize(self);
  } else if (strcmp(method, "restore") == 0) {
    response = restore(self);
  } else if (strcmp(method, "isFullScreen") == 0) {
    response = is_full_screen(self);
  } else if (strcmp(method, "setFullScreen") == 0) {
    response = set_full_screen(self, args);
  } else if (strcmp(method, "setAspectRatio") == 0) {
    response = set_aspect_ratio(self, args);
  } else if (strcmp(method, "setBackgroundColor") == 0) {
    response = set_background_color(self, args);
  } else if (strcmp(method, "getPosition") == 0) {
    response = get_position(self);
  } else if (strcmp(method, "setPosition") == 0) {
    response = set_position(self, args);
  } else if (strcmp(method, "getSize") == 0) {
    response = get_size(self);
  } else if (strcmp(method, "setSize") == 0) {
    response = set_size(self, args);
  } else if (strcmp(method, "setMinimumSize") == 0) {
    response = set_minimum_size(self, args);
  } else if (strcmp(method, "setMaximumSize") == 0) {
    response = set_maximum_size(self, args);
  } else if (strcmp(method, "isResizable") == 0) {
    response = is_resizable(self);
  } else if (strcmp(method, "setResizable") == 0) {
    response = set_resizable(self, args);
  } else if (strcmp(method, "isClosable") == 0) {
    response = is_closable(self);
  } else if (strcmp(method, "setClosable") == 0) {
    response = set_closable(self, args);
  } else if (strcmp(method, "isAlwaysOnTop") == 0) {
    response = is_always_on_top(self);
  } else if (strcmp(method, "setAlwaysOnTop") == 0) {
    response = set_always_on_top(self, args);
  } else if (strcmp(method, "isAlwaysOnBottom") == 0) {
    response = is_always_on_bottom(self);
  } else if (strcmp(method, "setAlwaysOnBottom") == 0) {
    response = set_always_on_bottom(self, args);
  } else if (strcmp(method, "getTitle") == 0) {
    response = get_title(self);
  } else if (strcmp(method, "setTitle") == 0) {
    response = set_title(self, args);
  } else if (strcmp(method, "setTitleBarStyle") == 0) {
    response = set_title_bar_style(self, args);
  } else if (strcmp(method, "getTitleBarHeight") == 0) {
    response = get_title_bar_height(self, args);
  } else if (strcmp(method, "isSkipTaskbar") == 0) {
    response = is_skip_taskbar(self);
  } else if (strcmp(method, "setSkipTaskbar") == 0) {
    response = set_skip_taskbar(self, args);
  } else if (strcmp(method, "getOpacity") == 0) {
    response = get_opacity(self);
  } else if (strcmp(method, "popUpWindowMenu") == 0) {
    response = pop_up_window_menu(self);
  } else if (strcmp(method, "startDragging") == 0) {
    response = start_dragging(self);
  } else if (strcmp(method, "startResizing") == 0) {
    response = start_resizing(self, args);
  } else if (strcmp(method, "getPrimaryDisplay") == 0) {
    response = get_primary_display(self, args);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void window_manager_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(window_manager_plugin_parent_class)->dispose(object);
}

static void window_manager_plugin_class_init(WindowManagerPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = window_manager_plugin_dispose;
}

static void window_manager_plugin_init(WindowManagerPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  WindowManagerPlugin* plugin = WINDOW_MANAGER_PLUGIN(user_data);
  window_manager_plugin_handle_method_call(plugin, method_call);
}

void _emit_event(const char* event_name) {
  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "eventName",
                           fl_value_new_string(event_name));
  fl_method_channel_invoke_method(plugin_instance->channel, "onEvent",
                                  result_data, nullptr, nullptr, nullptr);
}

gboolean on_window_close(GtkWidget* widget, GdkEvent* event, gpointer data) {
  _emit_event("close");
  return plugin_instance->_is_prevent_close;
}

gboolean on_window_focus(GtkWidget* widget, GdkEvent* event, gpointer data) {
  _emit_event("focus");
  return false;
}

gboolean on_window_blur(GtkWidget* widget, GdkEvent* event, gpointer data) {
  _emit_event("blur");
  return false;
}

gboolean on_window_show(GtkWidget* widget, GdkEvent* event, gpointer data) {
  _emit_event("show");
  return false;
}

gboolean on_window_hide(GtkWidget* widget, GdkEvent* event, gpointer data) {
  _emit_event("hide");
  return false;
}

gboolean on_window_resize(GtkWidget* widget, GdkEvent* event, gpointer data) {
  _emit_event("resize");
  return false;
}

gboolean on_window_move(GtkWidget* widget, GdkEvent* event, gpointer data) {
  _emit_event("move");
  return false;
}

gboolean on_window_state_change(GtkWidget* widget,
                                GdkEventWindowState* event,
                                gpointer data) {
  if (event->new_window_state & GDK_WINDOW_STATE_MAXIMIZED) {
    if (!plugin_instance->_is_maximized) {
      plugin_instance->_is_maximized = true;
      _emit_event("maximize");
    }
  }
  if (event->new_window_state & GDK_WINDOW_STATE_ICONIFIED) {
    if (!plugin_instance->_is_minimized) {
      plugin_instance->_is_minimized = true;
      _emit_event("minimize");
    }
  }
  if (event->new_window_state & GDK_WINDOW_STATE_FULLSCREEN) {
    if (!plugin_instance->_is_fullscreen) {
      plugin_instance->_is_fullscreen = true;
      _emit_event("enter-full-screen");
    }
  }
  if (plugin_instance->_is_maximized &&
      !(event->new_window_state & GDK_WINDOW_STATE_MAXIMIZED)) {
    plugin_instance->_is_maximized = false;
    _emit_event("unmaximize");
  }
  if (plugin_instance->_is_minimized &&
      !(event->new_window_state & GDK_WINDOW_STATE_ICONIFIED)) {
    plugin_instance->_is_minimized = false;
    _emit_event("restore");
  }
  if (plugin_instance->_is_fullscreen &&
      !(event->new_window_state & GDK_WINDOW_STATE_FULLSCREEN)) {
    plugin_instance->_is_fullscreen = false;
    _emit_event("leave-full-screen");
  }
  return false;
}

gboolean on_window_draw(GtkWidget* widget, cairo_t* cr, gpointer data) {
  if (plugin_instance->_is_frameless) {
    cairo_set_source_rgba(cr, bg_color_r, bg_color_g, bg_color_b, bg_color_a);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_paint(cr);
  }
  return false;
}

gboolean on_mouse_press(GSignalInvocationHint* ihint,
                        guint n_param_values,
                        const GValue* param_values,
                        gpointer data) {
  GdkEventButton* event_button =
      (GdkEventButton*)(g_value_get_boxed(param_values + 1));

  // plugin_instance->_event_button = event_button;

  memset(&plugin_instance->_event_button, 0,
         sizeof(plugin_instance->_event_button));
  memcpy(&plugin_instance->_event_button, event_button,
         sizeof(plugin_instance->_event_button));
  return TRUE;
}

void window_manager_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  WindowManagerPlugin* plugin = WINDOW_MANAGER_PLUGIN(
      g_object_new(window_manager_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  plugin->window_geometry.min_width = -1;
  plugin->window_geometry.min_height = -1;
  plugin->window_geometry.max_width = G_MAXINT;
  plugin->window_geometry.max_height = G_MAXINT;
  g_signal_connect(get_window(plugin), "delete_event",
                   G_CALLBACK(on_window_close), NULL);
  g_signal_connect(get_window(plugin), "focus-in-event",
                   G_CALLBACK(on_window_focus), NULL);
  g_signal_connect(get_window(plugin), "focus-out-event",
                   G_CALLBACK(on_window_blur), NULL);
  g_signal_connect(get_window(plugin), "show", G_CALLBACK(on_window_show),
                   NULL);
  g_signal_connect(get_window(plugin), "hide", G_CALLBACK(on_window_hide),
                   NULL);
  g_signal_connect(get_window(plugin), "check-resize",
                   G_CALLBACK(on_window_resize), NULL);
  g_signal_connect(get_window(plugin), "configure-event",
                   G_CALLBACK(on_window_move), NULL);
  g_signal_connect(get_window(plugin), "window-state-event",
                   G_CALLBACK(on_window_state_change), NULL);
  g_signal_connect(get_window(plugin), "draw", G_CALLBACK(on_window_draw),
                   NULL);

  g_signal_add_emission_hook(
      g_signal_lookup("button-press-event", GTK_TYPE_WIDGET), 0, on_mouse_press,
      plugin, NULL);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "window_manager", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  plugin_instance = plugin;

  g_object_unref(plugin);
}
