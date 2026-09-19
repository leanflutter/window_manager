/// Runs [body], answering null when the nativeapi library is not loaded.
///
/// The widgets of this package are built in widget tests as well as on a real
/// desktop, and a test runs in a Dart VM that has no native library: looking a
/// symbol up there throws an [ArgumentError]. 0.5.x degraded the same way,
/// because its method channel answered nothing outside a real app.
T? tryNative<T>(T Function() body) {
  try {
    return body();
  } on ArgumentError {
    return null;
  }
}
