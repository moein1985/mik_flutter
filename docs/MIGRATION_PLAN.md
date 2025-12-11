# Migration Plan: RouterOS Client with Tag Support

## مشکل فعلی

### علت اصلی
در پیاده‌سازی فعلی `routeros_client.dart`، یک متغیر **global** به نام `_activeStreamingTag` برای مدیریت همه streaming ها استفاده می‌شود:

```
_activeStreamingTag = null  →  فقط یک streaming فعال در هر لحظه!
```

### پیامدها
1. شروع streaming جدید → tag قبلی overwrite می‌شود → داده‌ها گم می‌شوند
2. `/cancel` بدون tag → همه streaming ها متوقف می‌شوند
3. پاسخ RouterOS tag ندارد → نمی‌دانیم پاسخ برای کدام stream است

---

## راه‌حل: مهاجرت به `router_os_client: ^2.0.0`

### چرا این کتابخانه؟
- ✅ Tag Support داخلی
- ✅ `cancelTagged(tag)` - لغو stream خاص
- ✅ `streamData()` - برای streaming با tag
- ✅ Concurrent Operations - چند stream همزمان
- ✅ تست شده و نگهداری می‌شود

---

## فایل‌های درگیر

### لایه Core (تغییر اساسی)
| فایل | وضعیت |
|------|-------|
| `lib/core/network/routeros_client.dart` | **حذف یا Refactor کامل** |
| `lib/core/network/routeros_protocol.dart` | احتمالاً حذف (کتابخانه جدید دارد) |

### لایه Logs
| فایل | تغییر |
|------|-------|
| `lib/features/logs/data/datasources/logs_remote_data_source.dart` | استفاده از API جدید |
| `lib/features/logs/data/repositories/logs_repository_impl.dart` | بدون تغییر یا کمینه |
| `lib/features/logs/domain/usecases/follow_logs_usecase.dart` | بدون تغییر |
| `lib/features/logs/presentation/bloc/logs_bloc.dart` | بدون تغییر |

### لایه Network Tools (Ping/Traceroute)
| فایل | تغییر |
|------|-------|
| `lib/features/tools/data/repositories/tools_repository_impl.dart` | استفاده از API جدید |
| `lib/features/tools/domain/usecases/ping_usecase.dart` | بدون تغییر |
| `lib/features/tools/domain/usecases/traceroute_usecase.dart` | بدون تغییر |
| `lib/features/tools/presentation/bloc/tools_bloc.dart` | بدون تغییر |

### Dependency Injection
| فایل | تغییر |
|------|-------|
| `lib/injection_container.dart` | تغییر نحوه register کردن client |

---

## مراحل مهاجرت

### فاز ۱: آماده‌سازی
- [ ] **1.1** اضافه کردن `router_os_client: ^2.0.0` به `pubspec.yaml`
- [ ] **1.2** ایجاد `RouterOSClientWrapper` جدید که از کتابخانه استفاده می‌کند
- [ ] **1.3** نوشتن تست‌های unit برای wrapper جدید

### فاز ۲: ایجاد Wrapper سازگار
- [ ] **2.1** ایجاد `lib/core/network/routeros_client_v2.dart`
- [ ] **2.2** پیاده‌سازی همان interface قبلی با کتابخانه جدید
- [ ] **2.3** پیاده‌سازی متدهای streaming با tag support:
  - `followLogs()` → `streamData()` + tag
  - `pingStream()` → `streamData()` + tag  
  - `tracerouteStream()` → `streamData()` + tag
- [ ] **2.4** پیاده‌سازی `stopStreaming(String tag)` با پارامتر tag

### فاز ۳: به‌روزرسانی Data Sources
- [ ] **3.1** به‌روزرسانی `LogsRemoteDataSource`:
  - نگهداری tag فعلی
  - استفاده از `stopStreaming(tag)` بجای `stopStreaming()`
- [ ] **3.2** به‌روزرسانی `ToolsRepositoryImpl`:
  - نگهداری tag برای ping
  - نگهداری tag برای traceroute
  - توقف انتخابی هر کدام

### فاز ۴: به‌روزرسانی Injection Container
- [ ] **4.1** تغییر registration از client قدیم به جدید
- [ ] **4.2** اطمینان از singleton بودن client

### فاز ۵: تست و پاکسازی
- [ ] **5.1** تست کامل logs با tab switching
- [ ] **5.2** تست ping و traceroute همزمان
- [ ] **5.3** تست توقف انتخابی هر streaming
- [ ] **5.4** حذف فایل‌های قدیمی بعد از اطمینان
- [ ] **5.5** حذف debug print statements

---

## تغییرات کلیدی در Architecture

### قبل (مشکل‌دار)
```
RouterOSClient
├── _activeStreamingTag: String?  ← فقط یکی!
├── followLogs() → sets _activeStreamingTag
├── pingStream() → overwrites _activeStreamingTag
└── stopStreaming() → clears _activeStreamingTag, sends /cancel
```

### بعد (درست)
```
RouterOSClientV2 (uses router_os_client package)
├── _activeStreams: Map<String, StreamController>  ← چندتایی!
├── followLogs() → returns (Stream, tag)
├── pingStream() → returns (Stream, tag)
├── stopStreaming(tag) → cancels specific stream
└── cancelTagged(tag) → package handles it
```

---

## نکات مهم پیاده‌سازی

### ۱. Interface یکسان نگه داشته شود
برای کم کردن تغییرات در لایه‌های بالاتر، interface wrapper باید تا حد امکان شبیه قبل باشد.

### ۲. Tag Management
هر data source باید tag خود را نگه دارد:
```
LogsRemoteDataSource._currentTag
ToolsRepository._pingTag
ToolsRepository._tracerouteTag
```

### ۳. Graceful Shutdown
در `dispose()` هر bloc، باید stream مربوطه stop شود با tag صحیح.

### ۴. Error Handling
کتابخانه جدید exception های خاص دارد که باید handle شوند:
- `LoginError`
- `RouterOSTrapError`
- `CreateSocketError`

---

## تخمین زمان
| فاز | زمان تقریبی |
|-----|-------------|
| فاز ۱ | ۳۰ دقیقه |
| فاز ۲ | ۲-۳ ساعت |
| فاز ۳ | ۱-۲ ساعت |
| فاز ۴ | ۳۰ دقیقه |
| فاز ۵ | ۱ ساعت |
| **مجموع** | **۵-۷ ساعت** |

---

## ریسک‌ها
1. **Breaking Changes**: کتابخانه جدید ممکن است API متفاوتی داشته باشد
2. **SSL Support**: باید بررسی شود که SSL به درستی کار کند
3. **Concurrent Connections**: برخی متدهای قدیمی ممکن است در کتابخانه نباشند

---

## چک‌لیست نهایی قبل از شروع
- [ ] مطالعه کامل documentation کتابخانه `router_os_client`
- [ ] بررسی source code کتابخانه در GitHub
- [ ] تست اتصال ساده با کتابخانه جدید
- [ ] لیست کردن همه متدهای `routeros_client.dart` که استفاده می‌شوند
