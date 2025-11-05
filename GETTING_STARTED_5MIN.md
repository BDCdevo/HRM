# 🎯 دليل البدء السريع - 5 دقائق

## ⚡ ابدأ الآن في 5 خطوات

### الخطوة 1️⃣: تشغيل Backend (2 دقيقة)

```bash
# افتح Terminal في مجلد Backend
cd C:\Users\B-SMART\Documents\GitHub\flowERP

# شغل الخادم
php artisan serve
```

✅ يجب أن ترى: `Starting Laravel development server: http://127.0.0.1:8000`

---

### الخطوة 2️⃣: تحديث API URL في Flutter (30 ثانية)

افتح الملف: `lib/core/config/api_config.dart`

```dart
// غيّر هذا السطر:
static const String baseUrl = baseUrlEmulator; 
// ✅ للإيميوليتر (Android Emulator)

// أو
static const String baseUrl = baseUrlSimulator;
// ✅ للمحاكي (iOS Simulator / Web)

// أو
static const String baseUrl = baseUrlRealDevice;
// ✅ للجهاز الحقيقي (غيّر IP)
```

---

### الخطوة 3️⃣: تثبيت Dependencies (1 دقيقة)

```bash
# في مجلد Flutter
cd C:\Users\B-SMART\AndroidStudioProjects\hrm

# تثبيت المكتبات
flutter pub get

# توليد الـ Models (إذا لزم الأمر)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### الخطوة 4️⃣: تشغيل التطبيق (1 دقيقة)

```bash
# للأندرويد
flutter run

# أو للويندوز
flutter run -d windows

# أو للويب
flutter run -d chrome
```

---

### الخطوة 5️⃣: اختبر تسجيل الدخول (30 ثانية)

افتح التطبيق وسجل دخول باستخدام:

```
Email:    employee@example.com
Password: password

# أو إذا لم يعمل، أنشئ حساب جديد من Admin Panel
```

---

## 🔧 إذا واجهت مشكلة

### مشكلة: Backend لا يعمل
```bash
# تأكد من تثبيت Composer
composer install

# تأكد من إعداد البيئة
cp .env.example .env
php artisan key:generate

# تأكد من إعداد Database
php artisan migrate
php artisan db:seed
```

### مشكلة: Connection Refused
```dart
// تأكد من Base URL الصحيح:

// للإيميوليتر
baseUrl = 'http://10.0.2.2:8000/api/v1'

// للمحاكي
baseUrl = 'http://localhost:8000/api/v1'

// للجهاز الحقيقي (غيّر IP)
baseUrl = 'http://192.168.1.X:8000/api/v1'
```

### مشكلة: 401 Unauthorized
```dart
// امسح الـ token القديم
// سجل خروج وسجل دخول من جديد
```

---

## 📱 اختبار سريع للميزات

### 1. Authentication ✅
- سجل دخول
- سجل خروج

### 2. Attendance ✅
- اضغط Check-in
- شاهد المدة في الوقت الفعلي
- اضغط Check-out

### 3. Leave ✅
- اذهب لشاشة الإجازات
- اضغط "طلب إجازة جديدة"
- اختر النوع والتواريخ
- أرسل الطلب

### 4. Profile ✅
- اذهب للملف الشخصي
- عدّل بياناتك
- غيّر كلمة المرور

### 5. Dashboard ✅
- شاهد الإحصائيات
- شاهد الرسوم البيانية

---

## 🎨 الواجهات الرئيسية

```
📱 App Structure
│
├── 🏠 Home/Dashboard
│   ├── إحصائيات الحضور
│   ├── رصيد الإجازات
│   └── ساعات العمل
│
├── ⏰ Attendance
│   ├── Check-in/Check-out
│   ├── المدة الحالية
│   └── السجل
│
├── 🏖️ Leave
│   ├── طلب إجازة
│   ├── سجل الطلبات
│   └── الرصيد
│
├── 👤 Profile
│   ├── البيانات الشخصية
│   ├── تعديل الملف
│   └── تغيير كلمة المرور
│
├── 🔔 Notifications
│   └── قائمة الإشعارات
│
└── ⚙️ Settings
    └── إعدادات التطبيق
```

---

## 🔑 بيانات الاختبار

### Admin Panel
```
URL:      http://localhost:8000/admin
Email:    admin@erpsaas.com
Password: password
```

### Employee Login
```
Email:    employee@example.com
Password: password
```

### أو أنشئ موظف جديد من Admin Panel:
1. اذهب لـ http://localhost:8000/admin
2. سجل دخول كـ Admin
3. اذهب لـ HRM → Employees
4. أضف موظف جديد

---

## 📋 Checklist سريع

### قبل البدء
- [ ] PHP 8.2+ مثبت
- [ ] Composer مثبت
- [ ] MySQL يعمل
- [ ] Flutter SDK مثبت
- [ ] Android Studio/VS Code جاهز

### خطوات التشغيل
- [ ] Backend يعمل على localhost:8000
- [ ] Database مهيأة
- [ ] Flutter dependencies مثبتة
- [ ] API URL محدث
- [ ] التطبيق يعمل

### اختبار الميزات
- [ ] Login يعمل
- [ ] Check-in/out يعمل
- [ ] طلب إجازة يعمل
- [ ] Profile يعمل
- [ ] Dashboard يعمل

---

## 🚀 الخطوات التالية

### للتطوير
1. راجع `PROJECT_ANALYSIS.md` لفهم البنية
2. راجع `API_DOCUMENTATION.md` للـ API
3. راجع `BACKEND_INTEGRATION_GUIDE.md` للتكامل

### لإضافة ميزات
1. راجع `BACKEND_COMPARISON.md` للميزات الجديدة
2. اتبع Clean Architecture
3. استخدم BLoC pattern

### للنشر
1. راجع إعدادات Production
2. غيّر API URL للسيرفر الحقيقي
3. فعّل HTTPS
4. بناء الـ APK/IPA

---

## 💡 نصائح سريعة

### Flutter Development
```bash
# Hot Reload: r
# Hot Restart: R
# Clear build: flutter clean
# Update packages: flutter pub upgrade
```

### Laravel Development
```bash
# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# View routes
php artisan route:list

# Database reset
php artisan migrate:fresh --seed
```

### Debugging
```dart
// في Flutter
print('🔍 Debug: $variable');
debugPrint('📝 Info: $message');

// في Laravel
Log::info('Debug', ['data' => $data]);
dd($variable); // Dump and die
```

---

## 📞 مساعدة سريعة

### الأخطاء الشائعة

**`Connection refused`**
```
✅ الحل: تأكد من تشغيل Backend
php artisan serve
```

**`401 Unauthorized`**
```
✅ الحل: سجل دخول من جديد
```

**`CORS Error`**
```
✅ الحل: تأكد من إعدادات CORS في Laravel
config/cors.php
```

**`Table doesn't exist`**
```
✅ الحل: شغل migrations
php artisan migrate
```

---

## 🎓 التعلم أكثر

### للمبتدئين
1. ابدأ بـ `QUICK_START_AR.md`
2. راجع `README.md`
3. جرب الميزات الأساسية

### للمطورين
1. راجع `PROJECT_ANALYSIS.md`
2. راجع `BACKEND_INTEGRATION_GUIDE.md`
3. راجع `API_DOCUMENTATION.md`

### للخبراء
1. راجع الكود مباشرة
2. راجع `BACKEND_COMPARISON.md`
3. ساهم في التطوير

---

## ✅ النجاح!

إذا وصلت هنا وكل شيء يعمل:
- ✅ Backend يعمل
- ✅ Flutter App يعمل
- ✅ API متصل
- ✅ Login يعمل

**مبروك! 🎉 المشروع جاهز للاستخدام**

---

**وقت القراءة:** 5 دقائق
**وقت التنفيذ:** 5 دقائق
**إجمالي الوقت:** ⏱️ 10 دقائق فقط!

**آخر تحديث:** 2025-11-05
**الحالة:** ✅ جاهز للبدء
