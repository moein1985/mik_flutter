/// FFI implementation for desktop platforms (Windows, Linux)
/// This file is used when dart.library.ffi is available
/// 
/// NOTE: To enable desktop support, add sqflite_common_ffi to pubspec.yaml:
/// sqflite_common_ffi: ^2.4.0

// Uncomment the following when you want to build for Windows/Linux:
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initFfi() {
  // Uncomment the following when you want to build for Windows/Linux:
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;
  
  // For now, throw an error if this is called on desktop
  throw UnsupportedError(
    'Desktop database support is not enabled. '
    'Add sqflite_common_ffi to pubspec.yaml and uncomment the FFI code.'
  );
}
