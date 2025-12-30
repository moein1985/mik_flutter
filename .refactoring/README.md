# 🔧 Refactoring Implementation Workspace

## ⚠️ IMPORTANT
این پوشه موقت است و فقط برای مرجع در حین پیاده‌سازی refactoring استفاده می‌شود.

**تاریخ ایجاد:** 2025-12-30

---

## 📁 محتویات این پوشه

### 1. فایل اصلی Proposal
- **[REFACTORING_PROPOSAL.md](./REFACTORING_PROPOSAL.md)**
  - پیشنهاد کامل refactoring
  - Architecture جدید
  - Implementation plan (6 فاز)
  - این فایل را به دستیار گوگل (Gemini) بدهید

### 2. مستندات معماری
- **[MODULE_GUIDELINES.md](./MODULE_GUIDELINES.md)**
  - راهنمای step-by-step ایجاد ماژول جدید
  - نمونه کدهای کامل
  - Best practices
  - چک‌لیست

- **[SDK_DEVELOPMENT.md](./SDK_DEVELOPMENT.md)**
  - راهنمای ایجاد SDK
  - مثال: Cisco multi-protocol SDK
  - Decision tree: چه موقع SDK بسازیم

### 3. مستندات ماژول‌ها
- **[MIKROTIK_MODULE.md](./MIKROTIK_MODULE.md)**
  - مستندات ماژول MikroTik
  - 13 feature
  - Protocol: RouterOS API

- **[SNMP_MODULE.md](./SNMP_MODULE.md)**
  - مستندات ماژول SNMP
  - General + Asterisk support
  - Protocol: SNMP v1/v2c

### 4. فایل Index کلی
- **[DOCS_INDEX.md](./DOCS_INDEX.md)**
  - Index همه مستندات پروژه
  - لینک به همه فایل‌ها

---

## 🎯 نحوه استفاده

### برای شروع Refactoring:

1. **بخوانید:**
   ```
   REFACTORING_PROPOSAL.md  ← شروع از اینجا
   ```

2. **Phase 1 را شروع کنید:**
   ```bash
   # ایجاد ساختارهای پایه
   mkdir -p lib/core/protocols/snmp/models
   mkdir -p lib/sdks/cisco/protocols/{snmp,netconf,restconf,ssh}
   mkdir -p lib/modules/_shared/widgets
   ```

3. **از Guidelines استفاده کنید:**
   - برای ماژول جدید: `MODULE_GUIDELINES.md`
   - برای SDK جدید: `SDK_DEVELOPMENT.md`

4. **مستندات ماژول‌ها:**
   - MikroTik: `MIKROTIK_MODULE.md`
   - SNMP: `SNMP_MODULE.md`

### برای دستیار گوگل (Gemini):

فقط این فایل را بدهید:
```
REFACTORING_PROPOSAL.md
```

این فایل شامل:
- ✅ توضیحات کامل
- ✅ Architecture diagram
- ✅ Implementation plan
- ✅ Code examples
- ✅ Testing strategy
- ✅ Checklist‌ها

### برای مرجع سریع:

**سوالات متداول:**

Q: چطور ماژول جدید بسازم؟
→ `MODULE_GUIDELINES.md` → Step 1-6

Q: چه موقع SDK بسازم؟
→ `SDK_DEVELOPMENT.md` → "When to Create"

Q: MikroTik چطور کار می‌کنه؟
→ `MIKROTIK_MODULE.md` → Protocol

Q: SNMP چطور setup کنم؟
→ `SNMP_MODULE.md` → Configuration

---

## 📊 وضعیت Implementation

### Phase 1: Foundation ⏳
- [ ] Create core protocols structure
- [ ] Create SDK structure
- [ ] Create BaseDeviceModule interface
- [ ] Create documentation structure

### Phase 2: SNMP Documentation ⏳
- [ ] Document SNMP architecture
- [ ] No code migration needed

### Phase 3: Module Wrappers ⏳
- [ ] Create MikroTikModule wrapper
- [ ] Create SNMPModule wrapper

### Phase 4: Cisco SDK ⏳
- [ ] Create SDK foundation
- [ ] Document interfaces

### Phase 5: Module Registration ⏳
- [ ] Update injection_container.dart
- [ ] Update home page

### Phase 6: Testing & Cleanup ⏳
- [ ] All tests pass
- [ ] Documentation complete
- [ ] No regressions

---

## 🔗 لینک به مستندات اصلی

بعد از تکمیل refactoring، مستندات اصلی در:
```
docs/
├── architecture/
│   ├── MODULE_GUIDELINES.md
│   └── SDK_DEVELOPMENT.md
└── modules/
    ├── mikrotik/README.md
    ├── snmp/README.md
    └── ...
```

---

## 🗑️ حذف این پوشه

بعد از تکمیل موفق refactoring:
```bash
# حذف پوشه موقت
rm -rf .refactoring
```

یا در git ignore بگذارید:
```bash
echo ".refactoring/" >> .gitignore
```

---

## 📝 یادداشت‌ها

(از این بخش برای یادداشت‌های شخصی استفاده کنید)

```
تاریخ    | کار انجام شده
----------|------------------
2025-12-30 | پوشه ایجاد شد
          |
          |
```

---

**آخرین بروزرسانی:** 2025-12-30  
**وضعیت:** آماده برای شروع
