# 🌳 Git Branching Strategy

این پروژه از **Git Flow ساده‌شده** استفاده می‌کند.

## 📋 ساختار Branch ها

### 🔴 `main` (Production)
- **هدف**: نسخه‌های منتشر شده در Cafe Bazaar
- **محافظت**: هیچ commit مستقیمی نباید روی این برنچ انجام شود
- **بروزرسانی**: فقط از طریق merge از `develop` یا `hotfix/*`
- **تگ**: هر release باید تگ گذاری شود (مثال: `v1.0.1-build7`)

### 🟢 `develop` (Development)
- **هدف**: برنچ اصلی توسعه
- **استفاده**: تمام feature ها قبل از release اینجا merge می‌شوند
- **کی merge می‌شه به main**: زمانی که آماده release باشد

### 🔵 `feature/*` (Feature Branches)
- **فرمت**: `feature/نام-ویژگی` (مثال: `feature/snmp`)
- **منشعب از**: `develop`
- **merge به**: `develop`
- **حذف**: بعد از merge

#### Feature های در حال توسعه:
- `feature/snmp` - پشتیبانی SNMP
- `feature/cisco` - مدیریت دستگاه‌های Cisco (آینده)
- `feature/voip` - مدیریت سرور تلفنی (آینده)

### 🟠 `hotfix/*` (Hotfix Branches)
- **فرمت**: `hotfix/شماره-issue-یا-توضیح` (مثال: `hotfix/crash-on-login`)
- **منشعب از**: `main`
- **merge به**: `main` و `develop`
- **استفاده**: رفع باگ‌های فوری روی production
- **حذف**: بعد از merge

---

## 🔄 Workflow

### 1️⃣ شروع یک Feature جدید

```bash
# به develop برو
git checkout develop
git pull origin develop

# برنچ feature جدید بساز
git checkout -b feature/نام-ویژگی

# کد بنویس، commit کن
git add .
git commit -m "feat: توضیحات تغییرات"

# push کن
git push origin feature/نام-ویژگی
```

### 2️⃣ تکمیل یک Feature

```bash
# به develop برو و آخرین تغییرات رو بگیر
git checkout develop
git pull origin develop

# feature رو merge کن
git merge --no-ff feature/نام-ویژگی

# push کن
git push origin develop

# برنچ feature رو پاک کن (اختیاری)
git branch -d feature/نام-ویژگی
git push origin --delete feature/نام-ویژگی
```

### 3️⃣ Release جدید (از develop به main)

```bash
# develop رو آماده کن
git checkout develop
git pull origin develop

# به main برو
git checkout main
git pull origin main

# develop رو merge کن
git merge --no-ff develop -m "Release v1.0.2-build8: توضیحات"

# تگ بزن
git tag -a v1.0.2-build8 -m "Release version 1.0.2 build 8"

# push کن
git push origin main
git push origin v1.0.2-build8
```

### 4️⃣ Hotfix فوری

```bash
# از main منشعب شو
git checkout main
git pull origin main
git checkout -b hotfix/توضیح-باگ

# باگ رو رفع کن
git add .
git commit -m "fix: توضیحات رفع باگ"

# به main merge کن
git checkout main
git merge --no-ff hotfix/توضیح-باگ

# تگ بزن
git tag -a v1.0.1-build8 -m "Hotfix: توضیحات"

# به develop هم merge کن
git checkout develop
git merge --no-ff hotfix/توضیح-باگ

# push کن
git push origin main
git push origin develop
git push origin v1.0.1-build8

# برنچ hotfix رو پاک کن
git branch -d hotfix/توضیح-باگ
git push origin --delete hotfix/توضیح-باگ
```

---

## 📝 قوانین Commit Messages

از **Conventional Commits** استفاده کن:

```
feat: اضافه کردن ویژگی جدید
fix: رفع باگ
docs: تغییرات در مستندات
style: فرمت کد (بدون تغییر منطق)
refactor: بازنویسی کد
test: اضافه کردن تست
chore: کارهای نگهداری
```

**مثال:**
```bash
git commit -m "feat(snmp): add SNMP monitoring support"
git commit -m "fix(dashboard): resolve overflow issue in premium widget"
git commit -m "docs: update README with SNMP configuration"
```

---

## 🎯 نکات مهم

### ✅ انجام بده:
- همیشه قبل از شروع کار، آخرین تغییرات رو `pull` کن
- برای هر feature یک برنچ جدید بساز
- commit های کوچک و معنادار بزن
- قبل از merge، کد رو تست کن
- از merge `--no-ff` استفاده کن (تاریخچه واضح‌تر)

### ❌ انجام نده:
- مستقیم روی `main` commit نزن
- feature های نیمه‌کاره رو به `develop` merge نکن
- برنچ‌های قدیمی رو نگه ندار (بعد از merge پاک کن)
- commit های بی‌معنی نزن (مثل "fix", "test", "aaa")

---

## 📊 نمای کلی

```
main (v1.0.1-build7) ──────┬──────────────────── (production)
                           │
                        merge
                           │
develop ────────┬──────────┴─────────────────── (integration)
                │
    ┌───────────┼───────────────┐
    │           │               │
feature/snmp  feature/cisco  feature/voip      (new features)
```

---

## 🔖 Version Tags

فرمت: `v{major}.{minor}.{patch}-build{number}`

- **major**: تغییرات بزرگ و breaking
- **minor**: ویژگی‌های جدید
- **patch**: رفع باگ
- **build**: شماره build برای Cafe Bazaar

**مثال:**
- `v1.0.1-build7` ← نسخه فعلی
- `v1.1.0-build8` ← بعد از اضافه شدن SNMP
- `v1.1.1-build9` ← hotfix روی v1.1.0

---

## 🚀 وضعیت فعلی

**Branches:**
- ✅ `main` - v1.0.1-build7 (Production - Cafe Bazaar)
- ✅ `develop` - Ready for new features
- ✅ `feature/snmp` - در حال توسعه

**تاریخ ایجاد:** 2025-12-28

---

## 📞 سوالات؟

برای هر سوال یا پیشنهادی درباره workflow، یک issue بساز.
