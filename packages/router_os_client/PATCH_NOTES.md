# RouterOS Client - Patch Notes

## مشکل UTF-8 Encoding (حل شده در ۱۳ آذر ۱۴۰۴)

### مشکل:
پکیج `router_os_client` هنگام دریافت داده از RouterOS با خطای زیر crash می‌کرد:

```
FormatException: Unexpected extension byte (at offset 18)
```

این خطا در متد `_readSentenceFromBuffer` رخ می‌داد، جایی که از `utf8.decode()` بدون گزینه `allowMalformed` استفاده می‌شد.

### علت:
RouterOS API گاهی داده‌هایی با کاراکترهای غیر UTF-8 می‌فرستد (مثلاً binary data، encoding های دیگر، یا داده‌های خراب).
تابع `utf8.decode()` به صورت پیش‌فرض strict است و چنین کاراکترهایی را قبول نمی‌کند.

### راه‌حل:
در فایل `lib/router_os_client.dart`، خط ۴۱۹:

**قبل:**
```dart
var word = utf8.decode(buffer.sublist(0, length));
```

**بعد:**
```dart
var word = utf8.decode(buffer.sublist(0, length), allowMalformed: true);
```

با اضافه کردن `allowMalformed: true`، کاراکترهای invalid به جای throw کردن exception، با کاراکتر جایگزین (�) نمایش داده می‌شوند.

### فایل اصلاح شده:
- `packages/router_os_client/lib/router_os_client.dart` (خط ۴۱۹)

### تاریخ:
۱۳ آذر ۱۴۰۴ (December 13, 2025)
