# 🚀 Implementation Plan: Multi-Module App Architecture

## 📌 Project Overview

Transform the current MikroTik-only app into a multi-module network assistant with:
- **App-level authentication** (separate from router authentication)
- **Main dashboard** with module selection tiles
- **MikroTik Assist** module (current app functionality)
- **SNMP Assist** module (from HSNMP project)
- **Coming Soon** placeholder (Asterisk PBX - future)

---

## 🏗️ Target Architecture

```
App Launch → App Auth (Login/Register/Biometric) → Home Dashboard
                                                         │
                    ┌────────────────────────────────────┼────────────────────────────────────┐
                    ▼                                    ▼                                    ▼
            MikroTik Assist                        SNMP Assist                          Coming Soon
            (current features)                    (from HSNMP)                        (Asterisk PBX)
```

---

## 📦 New Dependencies Required

Add to `pubspec.yaml`:

```yaml
# Biometric Authentication
local_auth: ^2.3.0

# SNMP Protocol
dart_snmp: ^3.0.1

# Local Storage (for app auth)
hive: ^2.2.3
hive_flutter: ^1.1.0
```

---

## 📁 Reference Project: HSNMP

Location: `c:\Users\Moein\Documents\Codes\HSNMP\`

### Key Files to Integrate:

**Data Layer:**
- `lib/data/data_sources/snmp_data_source.dart` - Core SNMP logic with dart_snmp
- `lib/data/data_sources/oid_constants.dart` - SNMP OID definitions
- `lib/data/repositories/snmp_repository_impl.dart` - Repository implementation

**Domain Layer:**
- `lib/domain/entities/device_info.dart` - Device information entity
- `lib/domain/entities/interface_info.dart` - Network interface entity (includes VlanInfo)
- `lib/domain/repositories/snmp_repository.dart` - Abstract repository
- `lib/domain/usecases/get_device_info_usecase.dart`
- `lib/domain/usecases/get_interface_status_usecase.dart`

**Presentation Layer:**
- `lib/presentation/features/snmp_monitor/bloc/router_monitor_bloc.dart`
- `lib/presentation/features/snmp_monitor/bloc/router_monitor_event.dart`
- `lib/presentation/features/snmp_monitor/bloc/router_monitor_state.dart`
- `lib/presentation/features/snmp_monitor/view/home_page.dart`
- `lib/presentation/features/snmp_monitor/view/widgets/` (9 widget files)

### Critical Conversion: fpdart → dartz

HSNMP uses `fpdart`, mik_flutter uses `dartz`. Convert:
- `import 'package:fpdart/fpdart.dart'` → `import 'package:dartz/dartz.dart'`
- Pattern is identical: `Either<Failure, T>`, `Left()`, `Right()`, `.fold()`

---

## 📋 Implementation Phases

### Phase 1: Home Dashboard (Start Here)

**Goal:** Create the main dashboard with 3 module tiles

**New Feature:** `lib/features/home/`

**Structure:**
```
lib/features/home/
├── domain/
│   └── entities/
│       └── app_module.dart          # name, icon, route, isEnabled, description
└── presentation/
    ├── pages/
    │   └── home_page.dart           # Main dashboard with 3 tiles
    └── widgets/
        └── module_tile.dart         # Reusable tile widget
```

**Tile Data:**
1. **MikroTik Assist** - Icon: router/network, Route: `/mikrotik`, Enabled: true
2. **SNMP Assist** - Icon: monitoring/chart, Route: `/snmp`, Enabled: true  
3. **Coming Soon** - Icon: phone/pbx, Route: null, Enabled: false, Description: "Asterisk PBX"

**UI Style:** Match current dashboard card style (see `dashboard_page.dart` GridView)

---

### Phase 2: MikroTik Section Refactor

**Goal:** Move current dashboard under `/mikrotik` route

**Changes:**

1. **Rename/Move:**
   - Current `lib/features/dashboard/` stays but becomes MikroTik's dashboard
   - Route changes from `/` to `/mikrotik`

2. **Router Updates (`lib/core/router/app_router.dart`):**
   - Add new home route `/` → HomePage (from Phase 1)
   - Change dashboard route to `/mikrotik`
   - Keep all existing sub-routes under `/mikrotik/*`

3. **Navigation:**
   - MikroTik tile → navigates to `/mikrotik`
   - Back from MikroTik dashboard → returns to home

---

### Phase 3: SNMP Integration

**Goal:** Integrate SNMP monitoring from HSNMP project

**New Feature:** `lib/features/snmp/`

**Structure:**
```
lib/features/snmp/
├── data/
│   ├── datasources/
│   │   ├── snmp_data_source.dart    # Copy from HSNMP, no changes needed
│   │   └── oid_constants.dart       # Copy from HSNMP
│   └── repositories/
│       └── snmp_repository_impl.dart # Copy, convert fpdart→dartz
├── domain/
│   ├── entities/
│   │   ├── device_info.dart         # Copy from HSNMP
│   │   └── interface_info.dart      # Copy from HSNMP
│   ├── repositories/
│   │   └── snmp_repository.dart     # Copy, convert fpdart→dartz
│   └── usecases/
│       ├── get_device_info_usecase.dart      # Copy, convert fpdart→dartz
│       └── get_interface_status_usecase.dart # Copy, convert fpdart→dartz
└── presentation/
    ├── bloc/
    │   ├── snmp_monitor_bloc.dart   # Copy, convert fpdart→dartz, remove injectable
    │   ├── snmp_monitor_event.dart  # Copy from HSNMP
    │   └── snmp_monitor_state.dart  # Copy from HSNMP
    ├── pages/
    │   └── snmp_dashboard_page.dart # Adapt home_page.dart to match app style
    └── widgets/
        ├── device_info_card.dart
        ├── interface_card.dart
        ├── traffic_stats_section.dart
        └── ... (other widgets from HSNMP)
```

**DI Registration (`lib/injection_container.dart`):**
- Register SnmpDataSource
- Register SnmpRepository
- Register Use Cases
- Register SnmpMonitorBloc

**Routing:**
- Add `/snmp` route → SnmpDashboardPage

**UI Adaptation:**
- Match theme colors with main app
- Use same card styles, fonts, spacing
- Integrate with AppLocalizations for Persian text

---

### Phase 4: App Authentication

**Goal:** Add app-level login with Hive storage and biometric support

**New Feature:** `lib/features/app_auth/`

**Structure:**
```
lib/features/app_auth/
├── data/
│   ├── datasources/
│   │   └── app_auth_local_datasource.dart   # Hive operations
│   ├── models/
│   │   └── app_user_model.dart              # Hive TypeAdapter
│   └── repositories/
│       └── app_auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── app_user.dart                    # id, username, passwordHash, biometricEnabled, createdAt
│   ├── repositories/
│   │   └── app_auth_repository.dart
│   └── usecases/
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       ├── biometric_auth_usecase.dart
│       ├── get_current_user_usecase.dart
│       └── logout_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── app_auth_bloc.dart
    │   ├── app_auth_event.dart
    │   └── app_auth_state.dart
    └── pages/
        └── app_login_page.dart              # Login + Register + Biometric
```

**Default Admin User:**
- Username: `admin`
- Password: empty string (no password)
- Cannot be deleted
- Created on first app launch if not exists

**Biometric Features:**
- Use `local_auth` package
- Support both fingerprint and Face ID
- User can enable/disable in settings
- Biometric only works after first manual login

**Hive Setup:**
- Box name: `app_users`
- TypeAdapter for AppUserModel
- Initialize in `main.dart` before runApp

**Auth Flow:**
1. App starts → Check if any user logged in (stored session)
2. If no session → Show LoginPage
3. If session exists AND biometric enabled → Prompt biometric
4. If biometric fails OR not enabled → Show LoginPage
5. On successful auth → Navigate to HomePage

**Router Guard:**
- Add redirect logic in `app_router.dart`
- If not authenticated → redirect to `/login`
- If authenticated → allow access

---

### Phase 5: Navigation & Final Integration

**Goal:** Wire everything together with proper navigation

**Router Structure (`lib/core/router/app_router.dart`):**

```
Routes:
/login          → AppLoginPage (unprotected)
/               → HomePage (protected - main dashboard)
/mikrotik       → Current Dashboard (protected)
/mikrotik/*     → All existing MikroTik routes (protected)
/snmp           → SnmpDashboardPage (protected)
```

**Auth Guard Logic:**
- Check authentication state from AppAuthBloc
- Redirect unauthenticated users to /login
- After login success → redirect to /

**Back Navigation:**
- From MikroTik/SNMP sections → Back to HomePage
- AppBar in module dashboards should have back button or drawer option

---

## 🔧 Existing Files to Modify

### `pubspec.yaml`
- Add: local_auth, dart_snmp, hive, hive_flutter

### `lib/main.dart`
- Initialize Hive before runApp
- Register Hive TypeAdapters

### `lib/injection_container.dart`
- Register all new dependencies (app_auth, snmp features)

### `lib/core/router/app_router.dart`
- Add new routes (/, /login, /snmp)
- Add auth redirect logic
- Restructure existing routes under /mikrotik

### `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Add back navigation to home
- Update AppBar if needed

---

## ⚠️ Important Notes

### Error Handling
- HSNMP uses custom Failure classes in `lib/core/error/failures.dart`
- Copy these or adapt to existing failure classes in mik_flutter

### Localization
- Add Persian strings for new features to `lib/l10n/app_fa.arb`
- Keys needed: login, register, biometric prompts, SNMP labels

### Theme Consistency
- SNMP widgets should use Theme.of(context) colors
- Match card styles with existing dashboard cards
- Use same spacing/padding patterns

### Session Management
- Store logged-in user ID in Hive or SharedPreferences
- Clear on logout

### Testing
- HSNMP has tests in `test/` folder - can reference for patterns

---

## 📊 Implementation Order

```
1. Phase 1: Home Dashboard          ← Foundation
2. Phase 2: MikroTik Refactor       ← Restructure routes  
3. Phase 5: Basic Navigation        ← Connect phases 1&2
4. Phase 3: SNMP Integration        ← Add SNMP feature
5. Phase 4: App Authentication      ← Add security layer
6. Phase 5: Final Integration       ← Auth guards, polish
```

---

## ✅ Success Criteria

- [ ] App launches to login screen (or biometric prompt if enabled)
- [ ] Default admin user can login with empty password
- [ ] New users can register
- [ ] Biometric authentication works (fingerprint + Face ID)
- [ ] Home dashboard shows 3 tiles
- [ ] MikroTik Assist opens current app functionality
- [ ] SNMP Assist opens SNMP monitoring
- [ ] Coming Soon tile is disabled with "Asterisk PBX" label
- [ ] Navigation flows correctly between all sections
- [ ] Back buttons return to appropriate screens
- [ ] Persian localization works throughout

---

## 🎯 Start Command

Begin with **Phase 1: Home Dashboard** - Create the home feature with module tiles.

