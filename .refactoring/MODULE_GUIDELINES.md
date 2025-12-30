# Module Development Guidelines

## Overview
This document provides guidelines for creating new vendor modules in the Network Assistant application.

## When to Create a New Module

Create a new module when:
- Adding support for a new vendor/device type
- The functionality is self-contained and vendor-specific
- It requires independent authentication or connection
- It has its own data models and business logic

## Module Structure

Every module should follow this structure:

```
lib/modules/MODULE_NAME/
├── core/
│   └── MODULE_NAME_module.dart     ← Module definition (implements BaseDeviceModule)
├── data/
│   ├── datasources/                 ← External data sources (API, SNMP, etc.)
│   ├── models/                      ← Data models
│   └── repositories/                ← Repository implementations
├── domain/
│   ├── entities/                    ← Business entities
│   ├── repositories/                ← Repository interfaces
│   └── usecases/                    ← Business logic
└── presentation/
    ├── bloc/                        ← State management
    ├── pages/                       ← UI screens
    └── widgets/                     ← Reusable widgets
```

## Step-by-Step Guide

### Step 1: Create Directory Structure

```bash
# Create module directories
mkdir -p lib/modules/MODULE_NAME/{core,data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}

# Create documentation
mkdir -p docs/modules/MODULE_NAME
touch docs/modules/MODULE_NAME/README.md
touch docs/modules/MODULE_NAME/ARCHITECTURE.md
```

### Step 2: Implement Module Interface

Create `lib/modules/MODULE_NAME/core/MODULE_NAME_module.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../modules/_shared/base_device_module.dart';
import '../presentation/pages/MODULE_NAME_dashboard_page.dart';
import '../../../injection_container.dart' as di;

class ModuleNameModule extends BaseDeviceModule {
  @override
  String get moduleName => 'Module Display Name';
  
  @override
  String get moduleId => 'module_name';
  
  @override
  IconData get moduleIcon => Icons.device_hub;
  
  @override
  Color get moduleColor => Colors.blue;
  
  @override
  String get description => 'Brief description of what this module does';
  
  @override
  bool get isEnabled => true;  // or false to disable
  
  @override
  Widget buildDashboard(BuildContext context) {
    return const ModuleNameDashboardPage();
  }
  
  @override
  Future<void> registerDependencies() async {
    // Register data sources
    di.sl.registerLazySingleton<ModuleNameDataSource>(
      () => ModuleNameDataSourceImpl(),
    );
    
    // Register repositories
    di.sl.registerLazySingleton<ModuleNameRepository>(
      () => ModuleNameRepositoryImpl(dataSource: di.sl()),
    );
    
    // Register use cases
    di.sl.registerLazySingleton<GetModuleDataUseCase>(
      () => GetModuleDataUseCase(repository: di.sl()),
    );
    
    // Register BLoC
    di.sl.registerFactory<ModuleNameBloc>(
      () => ModuleNameBloc(getModuleData: di.sl()),
    );
  }
  
  @override
  Future<void> initialize() async {
    // Perform any initialization tasks
    // e.g., load cached data, check connectivity
  }
  
  @override
  Future<void> dispose() async {
    // Clean up resources
    // e.g., close connections, cancel timers
  }
}
```

### Step 3: Implement Clean Architecture Layers

#### Domain Layer (Business Logic)

**Entity** (`domain/entities/device.dart`):
```dart
import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  
  const Device({
    required this.id,
    required this.name,
    required this.ipAddress,
  });
  
  @override
  List<Object?> get props => [id, name, ipAddress];
}
```

**Repository Interface** (`domain/repositories/MODULE_NAME_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/device.dart';

abstract class ModuleNameRepository {
  Future<Either<Failure, Device>> getDeviceInfo(String ip);
  Future<Either<Failure, List<Device>>> getAllDevices();
}
```

**Use Case** (`domain/usecases/get_device_info.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device.dart';
import '../repositories/MODULE_NAME_repository.dart';

class GetDeviceInfoUseCase implements UseCase<Device, String> {
  final ModuleNameRepository repository;
  
  GetDeviceInfoUseCase({required this.repository});
  
  @override
  Future<Either<Failure, Device>> call(String ip) async {
    return await repository.getDeviceInfo(ip);
  }
}
```

#### Data Layer

**Model** (`data/models/device_model.dart`):
```dart
import '../../domain/entities/device.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.ipAddress,
  });
  
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
    };
  }
}
```

**Data Source** (`data/datasources/MODULE_NAME_datasource.dart`):
```dart
import '../models/device_model.dart';

abstract class ModuleNameDataSource {
  Future<DeviceModel> getDeviceInfo(String ip);
}

class ModuleNameDataSourceImpl implements ModuleNameDataSource {
  @override
  Future<DeviceModel> getDeviceInfo(String ip) async {
    // Implement actual data fetching
    // e.g., HTTP request, SNMP query, socket connection
  }
}
```

**Repository Implementation** (`data/repositories/MODULE_NAME_repository_impl.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/MODULE_NAME_repository.dart';
import '../datasources/MODULE_NAME_datasource.dart';

class ModuleNameRepositoryImpl implements ModuleNameRepository {
  final ModuleNameDataSource dataSource;
  
  ModuleNameRepositoryImpl({required this.dataSource});
  
  @override
  Future<Either<Failure, Device>> getDeviceInfo(String ip) async {
    try {
      final device = await dataSource.getDeviceInfo(ip);
      return Right(device);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
  
  @override
  Future<Either<Failure, List<Device>>> getAllDevices() async {
    // Implementation
  }
}
```

#### Presentation Layer

**BLoC Events** (`presentation/bloc/MODULE_NAME_event.dart`):
```dart
import 'package:equatable/equatable.dart';

abstract class ModuleNameEvent extends Equatable {
  const ModuleNameEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadDeviceRequested extends ModuleNameEvent {
  final String ip;
  
  const LoadDeviceRequested(this.ip);
  
  @override
  List<Object?> get props => [ip];
}
```

**BLoC States** (`presentation/bloc/MODULE_NAME_state.dart`):
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/device.dart';

abstract class ModuleNameState extends Equatable {
  const ModuleNameState();
  
  @override
  List<Object?> get props => [];
}

class ModuleNameInitial extends ModuleNameState {}

class ModuleNameLoading extends ModuleNameState {}

class ModuleNameLoaded extends ModuleNameState {
  final Device device;
  
  const ModuleNameLoaded(this.device);
  
  @override
  List<Object?> get props => [device];
}

class ModuleNameError extends ModuleNameState {
  final String message;
  
  const ModuleNameError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**BLoC** (`presentation/bloc/MODULE_NAME_bloc.dart`):
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_device_info.dart';
import 'MODULE_NAME_event.dart';
import 'MODULE_NAME_state.dart';

class ModuleNameBloc extends Bloc<ModuleNameEvent, ModuleNameState> {
  final GetDeviceInfoUseCase getDeviceInfo;
  
  ModuleNameBloc({required this.getDeviceInfo}) : super(ModuleNameInitial()) {
    on<LoadDeviceRequested>(_onLoadDevice);
  }
  
  Future<void> _onLoadDevice(
    LoadDeviceRequested event,
    Emitter<ModuleNameState> emit,
  ) async {
    emit(ModuleNameLoading());
    
    final result = await getDeviceInfo(event.ip);
    
    result.fold(
      (failure) => emit(ModuleNameError(failure.toString())),
      (device) => emit(ModuleNameLoaded(device)),
    );
  }
}
```

**Dashboard Page** (`presentation/pages/MODULE_NAME_dashboard_page.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/MODULE_NAME_bloc.dart';
import '../bloc/MODULE_NAME_state.dart';
import '../bloc/MODULE_NAME_event.dart';

class ModuleNameDashboardPage extends StatelessWidget {
  const ModuleNameDashboardPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module Name'),
      ),
      body: BlocBuilder<ModuleNameBloc, ModuleNameState>(
        builder: (context, state) {
          if (state is ModuleNameLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ModuleNameError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is ModuleNameLoaded) {
            return _buildDeviceInfo(state.device);
          }
          
          return const Center(child: Text('No data'));
        },
      ),
    );
  }
  
  Widget _buildDeviceInfo(Device device) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Name'),
          subtitle: Text(device.name),
        ),
        ListTile(
          title: const Text('IP Address'),
          subtitle: Text(device.ipAddress),
        ),
      ],
    );
  }
}
```

### Step 4: Register Module

Update `lib/injection_container.dart`:

```dart
Future<void> initModules() async {
  final modules = <BaseDeviceModule>[
    MikroTikModule(),
    SNMPModule(),
    ModuleNameModule(),  // ← Add your module
  ];
  
  for (var module in modules) {
    await module.registerDependencies();
    await module.initialize();
  }
  
  sl.registerSingleton<List<BaseDeviceModule>>(
    modules.where((m) => m.isEnabled).toList(),
  );
}
```

### Step 5: Create Documentation

Create `docs/modules/MODULE_NAME/README.md`:

```markdown
# Module Name

## Overview
Brief description of the module.

## Features
- Feature 1
- Feature 2

## Protocol
Describe the communication protocol used.

## Usage
Code examples showing how to use the module.

## Configuration
Any configuration requirements.

## Troubleshooting
Common issues and solutions.
```

### Step 6: Write Tests

Create `test/modules/MODULE_NAME/`:

```dart
// test/modules/MODULE_NAME/MODULE_NAME_module_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mik_flutter/modules/MODULE_NAME/core/MODULE_NAME_module.dart';

void main() {
  group('ModuleNameModule', () {
    test('should have correct properties', () {
      final module = ModuleNameModule();
      
      expect(module.moduleId, 'module_name');
      expect(module.moduleName, 'Module Display Name');
      expect(module.isEnabled, true);
    });
  });
}
```

## Best Practices

### DO:
- ✅ Follow Clean Architecture principles
- ✅ Use dependency injection
- ✅ Write unit tests for use cases
- ✅ Write integration tests for UI
- ✅ Document public APIs
- ✅ Use proper error handling
- ✅ Implement proper logging
- ✅ Follow Flutter/Dart style guide

### DON'T:
- ❌ Mix business logic with UI
- ❌ Use global state
- ❌ Hardcode configuration values
- ❌ Skip error handling
- ❌ Forget to document
- ❌ Ignore test coverage

## Module Checklist

Before marking module as complete:

- [ ] Module implements `BaseDeviceModule`
- [ ] All dependencies registered in `injection_container.dart`
- [ ] Module added to modules list
- [ ] Documentation created in `docs/modules/`
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests written
- [ ] UI follows app theme
- [ ] Error handling implemented
- [ ] Loading states implemented
- [ ] Empty states implemented
- [ ] Logging added
- [ ] Code reviewed
- [ ] Manual testing completed

## Example Modules

Study these existing modules:
- **MikroTik**: Complex module with 13+ features
- **SNMP**: General-purpose with vendor extensions

## Getting Help

- Check existing modules for patterns
- Read `docs/architecture/` for guidelines
- Ask in team chat/code review
- Refer to Flutter/Dart documentation

## References
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Pattern](https://bloclibrary.dev/)
- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
