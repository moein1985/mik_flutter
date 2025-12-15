# 🎯 MikroTik Flutter App - Refactoring Guide

## هدف
ریفکتور کردن پروژه برای:
1. **توسعه بدون روتر واقعی** (Fake Repository Pattern)
2. **پیدا شدن خودکار باگ‌ها** (Comprehensive Tests)
3. **پیدا شدن باگ در زمان کامپایل** (Sealed Classes)

---

## 📋 وضعیت فعلی پروژه

### ساختار Feature ها:
- `lib/features/dashboard/` - داشبورد اصلی
- `lib/features/hotspot/` - مدیریت HotSpot
- `lib/features/queues/` - مدیریت Queue
- `lib/features/ping/` - ابزار Ping
- `lib/features/traceroute/` - ابزار Traceroute
- `lib/features/ip_services/` - مدیریت IP Services
- `lib/features/connection/` - اتصال به روتر

### تست‌های موجود:
- `test/features/` - تست‌های فعلی (نیاز به بررسی و تکمیل)
- `test/mocks/` - mock های موجود

### Dependency Injection:
- `lib/injection_container.dart` - تنظیمات GetIt

---

## 🔧 Task 1: Sealed Classes برای State Management

### هدف:
تبدیل همه State های BLoC به Sealed Classes برای Exhaustive Matching

### الگوی مورد نظر:
```dart
// ❌ الگوی قدیمی (nullable fields)
class SomeLoaded extends SomeState {
  final Data? data;
  final String? error;
}

// ✅ الگوی جدید (Sealed + Non-nullable)
sealed class SomeState {}
class SomeInitial extends SomeState {}
class SomeLoading extends SomeState {}
class SomeSuccess extends SomeState {
  final Data data; // Non-nullable!
}
class SomeFailure extends SomeState {
  final String message;
}
```

### فایل‌هایی که باید ریفکتور شوند:

#### اولویت 1 (Dashboard):
- [ ] `lib/features/dashboard/presentation/bloc/dashboard_state.dart`
- [ ] `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart`
- [ ] `lib/features/dashboard/presentation/pages/dashboard_page.dart` (استفاده از switch)

#### اولویت 2 (سایر Feature ها):
- [ ] `lib/features/hotspot/presentation/bloc/` - همه BLoC ها
- [ ] `lib/features/queues/presentation/bloc/queues_state.dart`
- [ ] `lib/features/ping/presentation/bloc/ping_state.dart`
- [ ] `lib/features/traceroute/presentation/bloc/traceroute_state.dart`
- [ ] `lib/features/ip_services/presentation/bloc/ip_service_state.dart`
- [ ] `lib/features/connection/presentation/bloc/connection_state.dart`

### نکات مهم:
1. از `sealed class` استفاده کن (نه `abstract class`)
2. همه فیلدهای Success state باید **non-nullable** باشند
3. در UI از `switch` expression استفاده کن برای exhaustive matching
4. اگر state های اضافی مثل `OperationLoading` یا `OperationSuccess` وجود داره، اون‌ها رو هم در sealed class قرار بده

---

## 🔧 Task 2: Fake Repository Pattern

### هدف:
ایجاد Fake Implementation برای همه Repository ها

### ساختار پیشنهادی:
```
lib/
├── core/
│   └── config/
│       └── app_config.dart          # فلگ useFakeRepositories
├── features/
│   └── [feature]/
│       └── data/
│           └── repositories/
│               ├── [feature]_repository_impl.dart      # واقعی
│               └── fake_[feature]_repository_impl.dart # Fake
```

### فایل‌های جدید که باید ساخته شوند:

```
lib/core/config/app_config.dart
lib/core/fake_data/fake_data_generator.dart
lib/features/dashboard/data/repositories/fake_dashboard_repository_impl.dart
lib/features/hotspot/data/repositories/fake_hotspot_repository_impl.dart
lib/features/queues/data/repositories/fake_queues_repository_impl.dart
lib/features/ping/data/repositories/fake_ping_repository_impl.dart
lib/features/traceroute/data/repositories/fake_traceroute_repository_impl.dart
lib/features/ip_services/data/repositories/fake_ip_service_repository_impl.dart
```

### app_config.dart:
```dart
class AppConfig {
  // در حالت development روی true باشه
  static const bool useFakeRepositories = true;
  
  // تنظیمات Fake
  static const Duration fakeNetworkDelay = Duration(milliseconds: 800);
  static const double fakeErrorRate = 0.1; // 10% خطا
}
```

### الگوی Fake Repository:
1. `Future.delayed` برای شبیه‌سازی تأخیر شبکه
2. داده‌های واقع‌گرایانه (نام‌های MikroTik مثل `ether1`, `wlan1`, `bridge1`)
3. احتمال خطای تصادفی (10%) برای تست error handling
4. سناریوهای مختلف (enum FakeScenario)

### به‌روزرسانی injection_container.dart:
```dart
// در sl.registerLazySingleton<DashboardRepository>
if (AppConfig.useFakeRepositories) {
  sl.registerLazySingleton<DashboardRepository>(
    () => FakeDashboardRepositoryImpl(),
  );
} else {
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
}
```

---

## 🔧 Task 3: تکمیل Unit Tests

### هدف:
پوشش تست حداقل 80% برای BLoC ها و Repository ها

### فایل‌های تست که باید ایجاد/تکمیل شوند:

```
test/features/dashboard/
├── presentation/bloc/dashboard_bloc_test.dart
├── domain/usecases/
│   ├── get_system_resources_test.dart
│   ├── get_interfaces_test.dart
│   └── ...

test/features/hotspot/
├── presentation/bloc/
│   ├── hotspot_users_bloc_test.dart
│   ├── hotspot_profiles_bloc_test.dart
│   └── ...

test/features/queues/
├── presentation/bloc/queues_bloc_test.dart

test/features/ping/
├── presentation/bloc/ping_bloc_test.dart

test/features/traceroute/
├── presentation/bloc/traceroute_bloc_test.dart
```

### الگوی تست BLoC:
```dart
void main() {
  late SomeBloc bloc;
  late MockSomeRepository mockRepository;

  setUp(() {
    mockRepository = MockSomeRepository();
    bloc = SomeBloc(repository: mockRepository);
  });

  tearDown(() => bloc.close());

  group('SomeEvent', () {
    test('emits [Loading, Success] when repository returns data', () async {
      when(mockRepository.getData())
          .thenAnswer((_) async => Right(testData));

      bloc.add(LoadData());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SomeLoading>(),
          isA<SomeSuccess>(),
        ]),
      );
    });

    test('emits [Loading, Failure] when repository returns failure', () async {
      when(mockRepository.getData())
          .thenAnswer((_) async => Left(ServerFailure('error')));

      bloc.add(LoadData());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SomeLoading>(),
          isA<SomeFailure>(),
        ]),
      );
    });
  });
}
```

### نکات:
- از `bloc_test` package استفاده کن
- برای mock از `mocktail` یا `mockito` استفاده کن (بررسی کن پروژه از کدوم استفاده می‌کنه)
- همه state ها رو تست کن (Initial, Loading, Success, Failure)
- edge cases رو فراموش نکن (empty list, null values, etc.)

---

## 🔧 Task 4: Widget Tests

### هدف:
تست UI برای اطمینان از نمایش صحیح همه state ها

### فایل‌های تست:
```
test/features/dashboard/presentation/pages/dashboard_page_test.dart
test/features/dashboard/presentation/widgets/
├── system_resource_card_test.dart
├── interface_list_item_test.dart
└── ...
```

### الگوی Widget Test:
```dart
void main() {
  late MockSomeBloc mockBloc;

  setUp(() {
    mockBloc = MockSomeBloc();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<SomeBloc>.value(
        value: mockBloc,
        child: const SomePage(),
      ),
    );
  }

  testWidgets('shows loading indicator when state is Loading', (tester) async {
    when(() => mockBloc.state).thenReturn(SomeLoading());
    whenListen(mockBloc, Stream<SomeState>.empty());

    await tester.pumpWidget(buildWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when state is Failure', (tester) async {
    when(() => mockBloc.state).thenReturn(SomeFailure('Network error'));
    whenListen(mockBloc, Stream<SomeState>.empty());

    await tester.pumpWidget(buildWidget());

    expect(find.text('Network error'), findsOneWidget);
  });

  testWidgets('shows data when state is Success', (tester) async {
    when(() => mockBloc.state).thenReturn(SomeSuccess(data: testData));
    whenListen(mockBloc, Stream<SomeState>.empty());

    await tester.pumpWidget(buildWidget());

    expect(find.text(testData.name), findsOneWidget);
  });
}
```

---

## 📝 ترتیب اجرا

### Phase 1: Foundation
1. ایجاد `app_config.dart`
2. ایجاد `fake_data_generator.dart` با داده‌های واقع‌گرایانه MikroTik

### Phase 2: Dashboard Feature (Pilot)
1. ریفکتور `dashboard_state.dart` به Sealed Class
2. ریفکتور `dashboard_bloc.dart`
3. ایجاد `fake_dashboard_repository_impl.dart`
4. به‌روزرسانی `injection_container.dart`
5. ریفکتور `dashboard_page.dart` برای استفاده از switch
6. نوشتن/تکمیل تست‌های Dashboard

### Phase 3: سایر Feature ها
به ترتیب اولویت:
1. Connection
2. HotSpot (همه BLoC ها)
3. Queues
4. Ping
5. Traceroute
6. IP Services

### Phase 4: تکمیل تست‌ها
1. Unit Tests برای همه BLoC ها
2. Widget Tests برای صفحات اصلی
3. Integration Tests (اختیاری)

---

## ⚠️ نکات مهم

1. **قبل از هر تغییر**، فایل‌های مرتبط رو بخون و ساختار فعلی رو درک کن
2. **تست‌های موجود** رو اجرا کن و مطمئن شو پاس میشن
3. **بعد از هر ریفکتور**، تست‌ها رو اجرا کن
4. **Backward Compatibility**: UI فعلی باید کار کنه
5. **داده‌های Fake** باید واقع‌گرایانه باشن (نام‌های MikroTik، IP های معتبر، و غیره)

---

## 🧪 اجرای تست‌ها

```bash
# همه تست‌ها
flutter test

# تست یک فایل خاص
flutter test test/features/dashboard/presentation/bloc/dashboard_bloc_test.dart

# با coverage
flutter test --coverage

# دیدن coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## 📊 معیار موفقیت

- [ ] همه State ها Sealed Class هستند
- [ ] همه UI ها از switch expression استفاده می‌کنند
- [ ] Fake Repository برای همه feature ها وجود داره
- [ ] با `useFakeRepositories = true` برنامه بدون روتر کار می‌کنه
- [ ] پوشش تست BLoC ها >= 80%
- [ ] همه تست‌ها پاس میشن
- [ ] هیچ warning در compile time وجود نداره
