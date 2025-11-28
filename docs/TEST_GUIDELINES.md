# راهنمای نوشتن تست‌ها برای پروژه MikroTik Manager

## معماری پروژه
این پروژه از **Clean Architecture** استفاده می‌کند با سه لایه اصلی:
- **Domain**: Entities, Use Cases, Repository Interfaces
- **Data**: Models, Data Sources, Repository Implementations
- **Presentation**: Bloc, Pages, Widgets

## وابستگی‌های تست
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## 1. تست‌های Unit برای Domain Layer

### 1.1 Entities
مسیر: `lib/features/hotspot/domain/entities/`
- `HotspotServer`: تست equality و props
- `HotspotUser`: تست equality و props
- `HotspotActiveUser`: تست equality و props
- `HotspotProfile`: تست equality و props

**نیازمندی‌ها:**
- تست برابری دو entity با مقادیر یکسان
- تست نابرابری دو entity با مقادیر متفاوت
- تست copyWith (اگر وجود دارد)

### 1.2 Use Cases
مسیر: `lib/features/hotspot/domain/usecases/`

| Use Case | ورودی | خروجی |
|----------|-------|--------|
| `GetServersUseCase` | بدون پارامتر | `Either<Failure, List<HotspotServer>>` |
| `GetUsersUseCase` | بدون پارامتر | `Either<Failure, List<HotspotUser>>` |
| `GetActiveUsersUseCase` | بدون پارامتر | `Either<Failure, List<HotspotActiveUser>>` |
| `GetProfilesUseCase` | بدون پارامتر | `Either<Failure, List<HotspotProfile>>` |
| `AddUserUseCase` | name, password, profile?, server?, comment? | `Either<Failure, bool>` |
| `ToggleUserUseCase` | id, enable | `Either<Failure, bool>` |
| `DisconnectUserUseCase` | id | `Either<Failure, bool>` |
| `SetupHotspotUseCase` | interface, addressPool?, dnsName? | `Either<Failure, bool>` |

**نیازمندی‌ها:**
- Mock کردن `HotspotRepository`
- تست حالت موفق (Right)
- تست حالت خطا (Left با ServerFailure)

---

## 2. تست‌های Unit برای Data Layer

### 2.1 Models
مسیر: `lib/features/hotspot/data/models/`

| Model | متدهای مورد تست |
|-------|------------------|
| `HotspotServerModel` | `fromMap()` |
| `HotspotUserModel` | `fromMap()`, `toMap()` |
| `HotspotActiveUserModel` | `fromMap()` |
| `HotspotProfileModel` | `fromMap()` |

**نیازمندی‌ها:**
- تست تبدیل Map به Model
- تست تبدیل Model به Map (برای HotspotUserModel)
- تست با مقادیر null/خالی
- تست ارث‌بری از Entity مربوطه

### 2.2 Data Source
مسیر: `lib/features/hotspot/data/datasources/hotspot_remote_data_source.dart`

**متدهای مورد تست:**
- `getServers()` - فیلتر کردن `type != 'done'`
- `getUsers()` - فیلتر کردن `type != 'done'`
- `getActiveUsers()` - فیلتر کردن `type != 'done'`
- `getProfiles()` - فیلتر کردن `type != 'done'`
- `addUser()` - ارسال پارامترها به client
- `enableUser()` / `disableUser()`
- `disconnectUser()`
- `setupHotspot()` - ارسال interface و پارامترهای اختیاری

**نیازمندی‌ها:**
- Mock کردن `AuthRemoteDataSource` و `RouterOSClient`
- تست پرتاب `ServerException` در حالت خطا
- تست فیلتر کردن صحیح پاسخ RouterOS

### 2.3 Repository Implementation
مسیر: `lib/features/hotspot/data/repositories/hotspot_repository_impl.dart`

**نیازمندی‌ها:**
- Mock کردن `HotspotRemoteDataSource`
- تست تبدیل Exception به Failure
- تست برگرداندن Right در حالت موفق
- تست برگرداندن Left با ServerFailure در حالت خطا

---

## 3. تست‌های Bloc

### 3.1 HotspotBloc
مسیر: `lib/features/hotspot/presentation/bloc/`

**Events:**
- `LoadHotspotServers`
- `LoadHotspotUsers`
- `LoadHotspotActiveUsers`
- `LoadHotspotProfiles`
- `AddHotspotUser`
- `ToggleHotspotUser`
- `DisconnectHotspotUser`
- `SetupHotspot`

**States:**
- `HotspotInitial`
- `HotspotLoading`
- `HotspotLoaded` (با servers?, users?, activeUsers?, profiles?)
- `HotspotError`
- `HotspotOperationSuccess`

**نیازمندی‌ها:**
- استفاده از `bloc_test` package
- Mock کردن تمام 8 Use Case
- تست هر event به صورت جداگانه
- تست state transitions
- تست حالت خطا برای هر event
- تست copyWith در HotspotLoaded

---

## 4. تست‌های RouterOSClient
مسیر: `lib/core/network/routeros_client.dart`

**متدهای HotSpot مورد تست:**
- `getHotspotServers()` - ارسال دستور `/ip/hotspot/print`
- `getHotspotUsers()` - ارسال دستور `/ip/hotspot/user/print`
- `getHotspotActiveUsers()` - ارسال دستور `/ip/hotspot/active/print`
- `getHotspotProfiles()` - ارسال دستور `/ip/hotspot/user/profile/print`
- `addHotspotUser()` - ارسال دستور `/ip/hotspot/user/add` با پارامترها
- `enableHotspotUser()` / `disableHotspotUser()`
- `disconnectHotspotUser()`
- `setupHotspot()` - اجرای چند دستور متوالی

**نیازمندی‌ها:**
- Mock کردن Socket connection
- تست فرمت صحیح دستورات ارسالی
- تست timeout handling
- تست حالت عدم اتصال

---

## 5. تست‌های Widget (اختیاری)

### 5.1 HotspotPage
- تست نمایش Loading indicator
- تست نمایش پیام "HotSpot is not configured"
- تست نمایش grid cards
- تست navigation به صفحات فرعی

### 5.2 سایر صفحات
- `HotspotUsersPage`
- `HotspotActiveUsersPage`
- `HotspotServersPage`
- `HotspotProfilesPage`

---

## 6. ساختار پوشه تست‌ها
```
test/
├── features/
│   └── hotspot/
│       ├── domain/
│       │   ├── entities/
│       │   └── usecases/
│       ├── data/
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       └── presentation/
│           └── bloc/
├── core/
│   ├── network/
│   │   └── routeros_client_test.dart
│   └── utils/
│       └── logger_test.dart
└── mocks/
    └── mock_classes.dart
```

---

## 7. نکات مهم

1. **Either Pattern**: این پروژه از `dartz` package استفاده می‌کند. `Right` برای موفقیت و `Left` برای خطا.

2. **Equatable**: تمام Entities از Equatable ارث‌بری می‌کنند.

3. **فیلتر RouterOS**: تمام پاسخ‌های RouterOS شامل یک item با `type: 'done'` هستند که باید فیلتر شوند.

4. **ServerException/ServerFailure**: خطاهای شبکه با `ServerException` پرتاب و به `ServerFailure` تبدیل می‌شوند.

5. **Bloc State Management**: از `emit.isDone` برای جلوگیری از emit بعد از بسته شدن استفاده می‌شود.

---

## 8. اولویت تست‌ها

1. **بالا**: Use Cases, Repository, Data Source
2. **متوسط**: Bloc, Models
3. **پایین**: Entities, Widget Tests

---

## 9. مثال Mock Data

### RouterOS Response برای Servers:
```
[
  {'.id': '*1', 'name': 'hotspot1', 'interface': 'ether1', 'address-pool': 'hs-pool', 'disabled': 'false'},
  {'type': 'done'}
]
```

### RouterOS Response برای Users:
```
[
  {'.id': '*1', 'name': 'user1', 'password': '123', 'profile': 'default', 'disabled': 'false'},
  {'type': 'done'}
]
```

---

## 10. دستورات اجرای تست

```bash
# اجرای همه تست‌ها
flutter test

# اجرای تست‌های یک فایل
flutter test test/features/hotspot/domain/usecases/get_servers_usecase_test.dart

# اجرای تست با coverage
flutter test --coverage
```
