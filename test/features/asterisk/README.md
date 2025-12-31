# Asterisk Module Tests

This directory contains tests for the Asterisk PBX module.

## Structure

```
test/features/asterisk/
├── data/
│   ├── datasources/          # Tests for data sources (AMI, SSH)
│   └── repositories/         # Tests for repository implementations
│       ├── extension_repository_mock_test.dart
│       ├── monitor_repository_mock_test.dart
│       └── cdr_repository_mock_test.dart
├── domain/
│   └── usecases/             # Tests for use cases
└── presentation/
    └── bloc/                 # Tests for BLoC classes
```

## Mock Repositories

The mock repositories are located in:
```
lib/features/asterisk/data/repositories/mock/
```

These mocks provide:
- **ExtensionRepositoryMock**: Simulates extension/SIP peer data
- **MonitorRepositoryMock**: Simulates active calls and queue statuses
- **CdrRepositoryMock**: Simulates call detail records

### Features:
- ✅ Realistic network delay simulation (300-500ms)
- ✅ Dynamic data changes (random status updates)
- ✅ Complete filtering support (date range, src, dst, disposition)
- ✅ No external dependencies required
- ✅ Perfect for development and testing

## Running Tests

Run all Asterisk module tests:
```bash
flutter test test/features/asterisk/
```

Run specific test file:
```bash
flutter test test/features/asterisk/data/repositories/extension_repository_mock_test.dart
```

Run with coverage:
```bash
flutter test --coverage test/features/asterisk/
```

## Test Categories

### 1. Repository Mock Tests
- **Purpose**: Verify mock repositories return correct data structures
- **Coverage**: Data validation, filtering, network simulation
- **Files**: 
  - `extension_repository_mock_test.dart`
  - `monitor_repository_mock_test.dart`
  - `cdr_repository_mock_test.dart`

### 2. Data Source Tests (TODO)
- Tests for AMI data source
- Tests for SSH data source
- Tests for data parsing and validation

### 3. Use Case Tests (TODO)
- Tests for business logic
- Tests for use case orchestration
- Tests for error handling

### 4. BLoC Tests (TODO)
- Tests for state management
- Tests for event handling
- Tests for side effects

## Writing New Tests

### Example: Testing a Repository

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/asterisk/data/repositories/mock/extension_repository_mock.dart';

void main() {
  late ExtensionRepositoryMock repository;

  setUp(() {
    repository = ExtensionRepositoryMock();
  });

  group('ExtensionRepositoryMock', () {
    test('should return extensions', () async {
      final result = await repository.getExtensions();
      expect(result, isNotEmpty);
    });
  });
}
```

### Example: Using Mockito

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([IExtensionRepository])
import 'my_test.mocks.dart';

void main() {
  late MockIExtensionRepository mockRepository;

  setUp(() {
    mockRepository = MockIExtensionRepository();
  });

  test('should call repository', () async {
    when(mockRepository.getExtensions())
        .thenAnswer((_) async => []);
        
    // Test code here
    
    verify(mockRepository.getExtensions()).called(1);
  });
}
```

## Best Practices

1. **Use descriptive test names**: Test names should clearly describe what is being tested
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **One assertion per test**: Keep tests focused on a single behavior
4. **Use setUp/tearDown**: Initialize and clean up test fixtures properly
5. **Mock external dependencies**: Use mock repositories for isolated testing
6. **Test edge cases**: Include tests for error conditions and boundary values

## Coverage Goals

- **Unit Tests**: 80%+ coverage
- **Integration Tests**: Key user flows
- **Widget Tests**: Critical UI components

## Current Status

### ✅ Completed:
- Mock repositories created
- Mock repository tests created
- Test structure established

### 🔄 In Progress:
- None

### 📋 TODO:
- [ ] Create AMI data source tests
- [ ] Create SSH data source tests
- [ ] Create use case tests
- [ ] Create BLoC tests
- [ ] Create widget tests for Asterisk pages
- [ ] Create integration tests

## Related Documentation

- [Asterisk Module Architecture](../../../docs/modules/asterisk/README.md)
- [Testing Guidelines](../../../docs/TEST_GUIDELINES.md)
- [Module Guidelines](../../../docs/architecture/MODULE_GUIDELINES.md)
