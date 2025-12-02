/// Stub implementation for platforms that don't support FFI (mobile, web)
/// This file is used when dart.library.ffi is not available
library;

void initFfi() {
  // No-op for mobile platforms - sqflite works natively on iOS/Android
}
