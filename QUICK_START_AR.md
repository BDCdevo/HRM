# 📋 ملخص سريع - مشروع HRM

## 🎯 نظرة عامة

نظام إدارة موارد بشرية متكامل مكون من جزأين:
- **تطبيق Flutter**: واجهة المستخدم (موبايل/ويب/ديسكتوب)
- **Backend Laravel**: الخادم والـ API

---

## 📁 المسارات

```
Flutter:  C:\Users\B-SMART\AndroidStudioProjects\hrm
Backend:  C:\Users\B-SMART\Documents\GitHub\flowERP
```

---

## 🔑 المعلومات الأساسية

### API Configuration
```dart
// في: lib/core/config/api_config.dart

// للإيميوليتر (Android)
baseUrlEmulator = 'http://10.0.2.2:8000/api/v1'

// للمحاكي (iOS/Web)
baseUrlSimulator = 'http://localhost:8000/api/v1'

// للجهاز الحقيقي
baseUrlRealDevice = 'http://192.168.1.X:8000/api/v1'
```

### Database
```
Database Name: erpsaas
Default User:  admin@erpsaas.com
Default Pass:  password
```

---

## 🚀 أوامر التشغيل السريع

### Flutter App
```bash
# التثبيت
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# التشغيل
flutter run              # Android
flutter run -d windows   # Windows
flutter run -d chrome    # Web
```

### Laravel Backend
```bash
# التثبيت
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed

# التشغيل
php artisan serve        # يبدأ على localhost:8000
```

---

## 📊 الميزات المتاحة

### ✅ مطبقة
- 🔐 المصادقة (موظف + مسؤول)
- ⏰ الحضور والانصراف (مع GPS)
- 🏖️ إدارة الإجازات
- 👤 الملف الشخصي
- 📊 لوحة التحكم
- 🔔 الإشعارات
- 📋 المهام

### ⏳ قيد التطوير
- 📈 التقارير التفصيلية
- 📅 جدول المناوبات
- 📝 إدارة المستندات
- 💰 الرواتب

---

## 🏗️ البنية المعمارية

### Flutter (Clean Architecture)
```
lib/
├── core/               # الأساسيات
│   ├── config/        # API endpoints
│   ├── networking/    # DioClient
│   ├── styles/        # Theme
│   └── widgets/       # مكونات مشتركة
│
└── features/          # الميزات
    ├── auth/
    ├── attendance/
    ├── leave/
    └── profile/
```

### كل ميزة تحتوي على:
```
feature/
├── data/
│   ├── models/        # نماذج البيانات
│   └── repo/          # Repository
├── logic/
│   └── cubit/         # Business Logic
└── ui/
    ├── screens/       # الشاشات
    └── widgets/       # المكونات
```

### Backend (Laravel)
```
app/
├── Http/Controllers/Api/V1/
│   ├── Employee/      # وظائف الموظفين
│   ├── Dashboard/     # لوحة التحكم
│   └── User/Auth/     # المصادقة
│
├── Models/Hrm/        # النماذج
├── Filament/Hrm/      # Admin Panel
└── Repositories/      # Data Layer
```

---

## 🔗 API Endpoints الرئيسية

### Authentication
```
POST   /api/v1/auth/login           # تسجيل الدخول
POST   /api/v1/auth/logout          # تسجيل الخروج
POST   /api/v1/auth/register        # التسجيل
```

### Attendance
```
POST   /api/v1/employee/attendance/check-in    # حضور
POST   /api/v1/employee/attendance/check-out   # انصراف
GET    /api/v1/employee/attendance/status      # الحالة
GET    /api/v1/employee/attendance/history     # السجل
GET    /api/v1/employee/attendance/duration    # المدة
```

### Leaves
```
GET    /api/v1/leaves/types      # أنواع الإجازات
POST   /api/v1/leaves            # تقديم طلب
GET    /api/v1/leaves            # سجل الطلبات
GET    /api/v1/leaves/balance    # الرصيد
DELETE /api/v1/leaves/{id}       # إلغاء طلب
```

### Profile
```
GET    /api/v1/profile                    # عرض الملف
PUT    /api/v1/profile                    # تحديث
POST   /api/v1/profile/change-password    # تغيير كلمة المرور
```

### Dashboard
```
GET    /api/v1/dashboard/stats    # الإحصائيات
```

---

## 🔐 نظام المصادقة

### Flow
```
1. المستخدم يدخل email + password
2. Flutter يرسل للـ Backend
3. Backend يتحقق ويصدر token
4. Flutter يحفظ الـ token في SecureStorage
5. كل الطلبات اللاحقة تحتوي على:
   Authorization: Bearer {token}
```

### في Flutter
```dart
// تسجيل الدخول
final response = await dioClient.post('/auth/login', {
  'email': email,
  'password': password,
});

// حفظ الـ token
await secureStorage.write(
  key: 'auth_token',
  value: response.data['access_token'],
);
```

### في Laravel
```php
// التحقق وإصدار token
$employee = Employee::where('email', $email)->first();
$token = $employee->createToken('api-token')->plainTextToken;

return response()->json([
  'access_token' => $token,
  'user' => $employee,
]);
```

---

## 📊 Models الرئيسية

### Employee
- الاسم، البريد، الهاتف
- القسم، المنصب، الفرع
- الراتب، تاريخ التعيين
- الحالة (نشط/غير نشط)

### Attendance
- تاريخ الحضور
- وقت الدخول/الخروج
- الموقع (GPS)
- المدة الإجمالية
- خطة العمل

### Leave Request
- نوع الإجازة
- تاريخ البداية/النهاية
- السبب
- الحالة (معلق/موافق/مرفوض)
- المعتمد من

### Department
- الاسم، الوصف
- الحالة

### Position
- الاسم، القسم
- الوصف، الحالة

### Branch
- الاسم، العنوان
- الموقع (GPS + نطاق)
- الحالة

---

## 🔧 الإعدادات المهمة

### 1. تفعيل الـ Backend
```bash
cd C:\Users\B-SMART\Documents\GitHub\flowERP
php artisan serve
```

### 2. تغيير Base URL حسب البيئة
```dart
// في: lib/core/config/api_config.dart
static const String baseUrl = baseUrlEmulator; // للإيميوليتر
```

### 3. CORS في Laravel
```php
// في: config/cors.php
'allowed_origins' => ['*'],
'supports_credentials' => true,
```

---

## 🛠️ حل المشاكل الشائعة

### مشكلة: Connection Refused
```bash
# تأكد من تشغيل الـ server
php artisan serve

# تأكد من Base URL الصحيح
# للإيميوليتر: http://10.0.2.2:8000/api/v1
```

### مشكلة: 401 Unauthorized
```dart
// تحقق من الـ token
final token = await secureStorage.read(key: 'auth_token');
print('Token: $token');

// تأكد من ApiInterceptor
dio.interceptors.add(ApiInterceptor());
```

### مشكلة: CORS Error
```php
// في config/cors.php
'allowed_origins' => ['*'],
```

---

## 📚 ملفات التوثيق

| الملف | الوصف |
|------|-------|
| `API_DOCUMENTATION.md` | توثيق كامل للـ API |
| `CLAUDE.md` | إرشادات المطورين |
| `PROJECT_ANALYSIS.md` | تحليل شامل للمشروع |
| `BACKEND_INTEGRATION_GUIDE.md` | دليل التكامل |
| `QUICK_REFERENCE.md` | مرجع سريع (هذا الملف) |
| `README.md` | نظرة عامة |

---

## 🎨 تقنيات Flutter

### State Management
```dart
flutter_bloc: ^8.1.3      # BLoC/Cubit
equatable: ^2.0.5         # State comparison
```

### Networking
```dart
dio: ^5.0.0               # HTTP client
json_annotation: ^4.8.1   # JSON serialization
```

### Storage
```dart
shared_preferences: ^2.2.2         # Local storage
flutter_secure_storage: ^9.0.0     # Secure token storage
```

### UI
```dart
fl_chart: ^0.69.0         # Charts
go_router: ^12.0.0        # Navigation
cached_network_image: ^3.3.0  # Image caching
```

### Location
```dart
geolocator: ^10.1.0       # GPS
permission_handler: ^11.0.1  # Permissions
```

---

## 🎨 تقنيات Laravel

### Core
```
Laravel: ^12.0
PHP: ^8.2
Filament: ^3.2
```

### Authentication
```
Laravel Sanctum: ^4.0     # API authentication
```

### Packages
```
spatie/laravel-activitylog  # Activity logging
maatwebsite/excel           # Excel import/export
laravel-fcm                 # Push notifications
```

---

## 🎯 الخطوات التالية

### للمطور Frontend (Flutter)
1. ✅ فهم البنية المعمارية
2. ✅ تعلم نمط BLoC/Cubit
3. ✅ فهم نظام الـ Repository
4. 📝 إضافة ميزات جديدة
5. 🧪 كتابة Unit Tests

### للمطور Backend (Laravel)
1. ✅ فهم Filament Admin Panel
2. ✅ فهم Laravel Sanctum
3. ✅ تطبيق API Controllers
4. 📝 توثيق الـ endpoints
5. 🧪 كتابة Feature Tests

---

## 💡 نصائح مهمة

### Flutter
1. استخدم `build_runner` بعد تعديل Models
2. احفظ الـ token في SecureStorage
3. استخدم `ApiInterceptor` لإضافة token تلقائياً
4. اتبع Clean Architecture
5. استخدم code generation

### Laravel
1. استخدم `php artisan serve` للتطوير
2. فعّل CORS للسماح للـ Flutter
3. استخدم Sanctum للـ API authentication
4. وثّق كل endpoint جديد
5. استخدم Filament للـ Admin Panel

---

## 🔍 الاختبار السريع

### Test Login
```bash
# Postman or cURL
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"employee@example.com","password":"password"}'
```

### Test Protected Endpoint
```bash
curl -X GET http://localhost:8000/api/v1/profile \
  -H "Authorization: Bearer {your_token}"
```

---

## 📞 الدعم

للأسئلة والمساعدة:
- راجع `API_DOCUMENTATION.md` للتوثيق الكامل
- راجع `PROJECT_ANALYSIS.md` للتحليل الشامل
- راجع `BACKEND_INTEGRATION_GUIDE.md` لدليل التكامل

---

**آخر تحديث:** 2025-11-05
**الحالة:** ✅ جاهز للاستخدام
