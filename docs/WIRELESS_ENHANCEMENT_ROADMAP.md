# 🛠️ Wireless Enhancement Roadmap

## 📋 Overview

This document outlines the enhancements needed for the Wireless feature in the MikroTik Flutter app. The goal is to add new functionality and improve the UI to match the style of the DNS Lookup page.

---

## 📁 Current Project Structure

### Wireless Feature Location
```
lib/features/wireless/
├── data/
│   ├── datasources/wireless_remote_data_source.dart
│   ├── models/
│   │   ├── wireless_interface_model.dart
│   │   ├── wireless_registration_model.dart
│   │   └── security_profile_model.dart
│   └── repositories/wireless_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── wireless_interface.dart
│   │   ├── wireless_registration.dart
│   │   └── security_profile.dart
│   ├── repositories/wireless_repository.dart
│   └── usecases/
│       ├── get_wireless_interfaces_usecase.dart
│       ├── get_wireless_registrations_usecase.dart
│       └── get_security_profiles_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── wireless_bloc.dart
    │   ├── wireless_event.dart
    │   └── wireless_state.dart
    ├── pages/wireless_page.dart
    └── widgets/
        ├── wireless_interfaces_list.dart
        ├── wireless_clients_list.dart
        └── security_profiles_list.dart
```

### API Client Location
- `lib/core/network/routeros_client_v2.dart` - Main API client (already has dual WiFi/Wireless support)

### Reference UI (DNS Lookup Page)
- `lib/features/tools/presentation/pages/dns_lookup_page.dart` - Use this as UI reference

---

## 🎯 Phase 1: WiFi Scanner Feature

### Description
Add ability to scan for nearby WiFi networks and display them with signal strength.

### MikroTik API
```
Command: /interface/wireless/scan
Parameters: 
  - .id=<interface-id> (the wireless interface to scan with)
  - duration=<seconds> (optional, how long to scan)
  
Response fields:
  - address (MAC address of AP)
  - ssid (network name)
  - channel (frequency channel)
  - signal-strength (in dBm)
  - band (2ghz-b/g/n, 5ghz-a/n/ac, etc.)
  - security (security type)
  - routeros-version (if MikroTik AP)
```

### Tasks

#### 1.1 Add API Method in RouterOSClientV2
- Add method `scanWirelessNetworks(String interfaceId, {int? duration})`
- Method should start scan and return list of found networks
- Handle both WiFi package (`/interface/wifi/scan`) and Wireless package (`/interface/wireless/scan`)

#### 1.2 Create Scanner Entity & Model
- Create `WirelessScanResult` entity with fields: ssid, macAddress, channel, signalStrength, band, security
- Create `WirelessScanResultModel` with `fromMap()` method

#### 1.3 Add UseCase
- Create `ScanWirelessNetworksUseCase`
- Add to dependency injection (`injection_container.dart`)

#### 1.4 Update BLoC
- Add `ScanWirelessNetworks` event
- Add `WirelessScanLoading`, `WirelessScanLoaded`, `WirelessScanError` states
- Add handler in `wireless_bloc.dart`

#### 1.5 Create Scanner UI Widget
- Create `wireless_scanner_widget.dart`
- Include:
  - Interface selector dropdown (to choose which interface to scan with)
  - Scan button with loading indicator
  - List of found networks with:
    - Signal strength indicator (visual bar or icon)
    - SSID name
    - Security type icon (locked/open)
    - Channel/Band info
    - Connect button (optional)

#### 1.6 Add Tab to Wireless Page
- Add "Scanner" tab to the TabBar in `wireless_page.dart`

---

## 🎯 Phase 2: Access List Management

### Description
Allow users to manage Access List (allow/deny specific MAC addresses).

### MikroTik API
```
List: /interface/wireless/access-list/print
Add: /interface/wireless/access-list/add
Remove: /interface/wireless/access-list/remove
Edit: /interface/wireless/access-list/set

Key fields:
  - mac-address
  - interface (which wireless interface)
  - authentication (yes/no - allow or deny)
  - forwarding (yes/no)
  - ap-tx-limit (bandwidth limit to client)
  - client-tx-limit (bandwidth limit from client)
  - signal-range (e.g., -80..120)
  - time (time-based access)
  - comment
```

### Tasks

#### 2.1 Add API Methods in RouterOSClientV2
- `getAccessList()` - Get all access list entries
- `addAccessListEntry(mac, interface, authentication, ...)` - Add new entry
- `removeAccessListEntry(id)` - Remove entry
- `updateAccessListEntry(id, ...)` - Update entry

#### 2.2 Create Entity & Model
- Create `AccessListEntry` entity
- Create `AccessListEntryModel` with fromMap/toMap

#### 2.3 Add UseCases
- `GetAccessListUseCase`
- `AddAccessListEntryUseCase`
- `RemoveAccessListEntryUseCase`
- `UpdateAccessListEntryUseCase`

#### 2.4 Update BLoC
- Add events: `LoadAccessList`, `AddAccessListEntry`, `RemoveAccessListEntry`, `UpdateAccessListEntry`
- Add states: `AccessListLoading`, `AccessListLoaded`, `AccessListError`

#### 2.5 Create Access List UI
- Create `access_list_widget.dart`
- Include:
  - List of current entries with MAC, interface, status (Allow/Deny)
  - Add button with dialog form
  - Edit/Delete options for each entry
  - Quick toggle for authentication (allow/deny)

#### 2.6 Add Tab to Wireless Page
- Add "Access List" tab

---

## 🎯 Phase 3: Signal Monitoring with Graph

### Description
Show real-time signal strength graph for connected clients.

### MikroTik API
```
Registration table already available at:
/interface/wireless/registration-table/print

Key fields for monitoring:
  - signal-strength
  - signal-strength-ch0, ch1, ch2 (per chain)
  - tx-ccq, rx-ccq (Connection Quality)
  - tx-rate, rx-rate
  - uptime
```

### Tasks

#### 3.1 Create Signal Monitor Widget
- Create `signal_monitor_widget.dart`
- Use `fl_chart` package for graphs (already in pubspec.yaml)
- Show line chart of signal strength over time
- Auto-refresh every 2-3 seconds

#### 3.2 Add to Client Details
- When user taps on a client in `wireless_clients_list.dart`
- Show bottom sheet or dialog with:
  - Real-time signal graph
  - CCQ (Connection Quality) indicator
  - TX/RX rates
  - Uptime
  - Disconnect button

---

## 🎯 Phase 4: UI Enhancement (Match DNS Lookup Style)

### Description
Improve the overall Wireless page UI to match the DNS Lookup page style.

### Reference
Look at `dns_lookup_page.dart` for:
- Header card with icon and description
- Input fields with help icons
- Advanced options expandable section
- Result display cards
- Loading indicators

### Tasks

#### 4.1 Create Wireless Header Widget
- Create `wireless_header_widget.dart`
- Include:
  - WiFi icon
  - Title: "Wireless Management"
  - Subtitle with brief description
  - Quick stats row (interfaces count, clients count, profiles count)

#### 4.2 Enhance Interface Cards
- Update `wireless_interfaces_list.dart`
- Better card design with:
  - Large WiFi icon with signal strength indicator
  - SSID prominently displayed
  - Band/Channel info
  - Client count badge
  - Enable/Disable toggle switch
  - Settings/Edit icon button

#### 4.3 Enhance Client Cards
- Update `wireless_clients_list.dart`
- Better card design with:
  - Device icon
  - MAC address with copy button
  - Signal strength visual bar (colored: green/yellow/red)
  - TX/RX rates
  - Uptime
  - Disconnect button

#### 4.4 Add Help Tooltips
- Add help icons with explanations for:
  - What is Signal Strength
  - What is CCQ
  - What is TX/RX rate
  - etc.

---

## 📦 Dependencies

The following packages are already in pubspec.yaml and can be used:
- `fl_chart` - For signal graphs
- `flutter_bloc` - State management
- `equatable` - For entity comparison
- `dartz` - For Either type (error handling)

---

## 🔄 Implementation Order

1. **Phase 4** (UI Enhancement) - Can be done first as it improves existing features
2. **Phase 1** (WiFi Scanner) - Most requested feature
3. **Phase 3** (Signal Monitor) - Builds on existing client list
4. **Phase 2** (Access List) - More advanced feature

---

## ⚠️ Important Notes

1. **Dual Package Support**: The app already supports both WiFi (`/interface/wifi`) and Wireless (`/interface/wireless`) packages. Use `client.wirelessType` to check which is available.

2. **Auto-Detection**: `RouterOSClientV2` has `detectWirelessType()` method that auto-detects which package is installed.

3. **Error Handling**: All API calls should handle the case where no wireless package is installed (return empty list or show appropriate message).

4. **Localization**: Add new strings to `lib/l10n/app_*.arb` files for all new UI text.

5. **Testing**: After implementation, test with:
   - Router with WiFi package (RouterOS 7.13+)
   - Router with legacy Wireless package
   - Router without any wireless package

---

## 📝 Files to Modify

### Core Files:
- `lib/core/network/routeros_client_v2.dart` - Add new API methods

### Feature Files:
- `lib/features/wireless/presentation/pages/wireless_page.dart` - Add new tabs
- `lib/features/wireless/presentation/bloc/wireless_bloc.dart` - Add new events/states
- `lib/features/wireless/presentation/bloc/wireless_event.dart` - New events
- `lib/features/wireless/presentation/bloc/wireless_state.dart` - New states
- `lib/features/wireless/data/datasources/wireless_remote_data_source.dart` - New methods
- `lib/features/wireless/domain/repositories/wireless_repository.dart` - New methods

### New Files to Create:
- `lib/features/wireless/domain/entities/wireless_scan_result.dart`
- `lib/features/wireless/domain/entities/access_list_entry.dart`
- `lib/features/wireless/data/models/wireless_scan_result_model.dart`
- `lib/features/wireless/data/models/access_list_entry_model.dart`
- `lib/features/wireless/presentation/widgets/wireless_scanner_widget.dart`
- `lib/features/wireless/presentation/widgets/access_list_widget.dart`
- `lib/features/wireless/presentation/widgets/signal_monitor_widget.dart`
- `lib/features/wireless/presentation/widgets/wireless_header_widget.dart`

### DI File:
- `lib/injection_container.dart` - Register new usecases

---

## ✅ Acceptance Criteria

### Phase 1 (Scanner):
- [ ] Can select wireless interface for scanning
- [ ] Scan shows all nearby networks
- [ ] Each network shows: SSID, signal strength, security type, channel
- [ ] Signal strength has visual indicator

### Phase 2 (Access List):
- [ ] Can view all access list entries
- [ ] Can add new entry with MAC address
- [ ] Can delete entry
- [ ] Can toggle allow/deny

### Phase 3 (Signal Monitor):
- [ ] Shows live signal graph for selected client
- [ ] Updates every 2-3 seconds
- [ ] Shows CCQ and TX/RX rates

### Phase 4 (UI):
- [ ] Header card with stats
- [ ] Improved interface cards
- [ ] Improved client cards
- [ ] Help tooltips

---

*Document created: December 12, 2025*
