# 🚀 Flutter HRM App – Clean Architecture with Backend Integration

> مشروع تطبيق إدارة الموارد البشرية (HRM) باستخدام Flutter
> مبني على **Clean Architecture** ومربوط مع **Laravel Backend API**
> يتضمن تكامل مع Figma للتصميم و MCP للتوثيق
> مشروع متكامل، قابل للتوسع، ومؤمن للاستخدام الاحترافي

## 📋 Backend API Information
- **Base URL**: `http://localhost:8000/api/v1`
- **Authentication**: Laravel Sanctum (Bearer Token)
- **Documentation**: See `API_DOCUMENTATION.md` in backend project
- **Multi-Panel System**: Admin, Employee, API guards

---

## 🧱 1. الهيكل العام للمجلدات (Linked Project Structure)

```
lib/
│
├── core/
│   ├── config/
│   │   ├── app_config.dart            # إعدادات التطبيق العامة
│   │   ├── api_config.dart            # إعدادات API (Base URL, Endpoints)
│   │   ├── figma_config.dart          # 🔗 ربط مباشر مع ملفات Figma
│   │   └── mcp_config.dart            # 🔗 ربط مباشر مع ملفات MCP
│   ├── constants/
│   │   ├── api_constants.dart         # ثوابت الـ API
│   │   ├── app_constants.dart         # ثوابت التطبيق
│   │   └── storage_keys.dart          # مفاتيح التخزين المحلي
│   ├── di/
│   │   └── injection.dart             # Dependency Injection
│   ├── errors/
│   │   ├── api_exception.dart         # استثناءات الـ API
│   │   └── error_handler.dart         # معالج الأخطاء
│   ├── helpers/
│   │   ├── logger.dart                # سجل الأحداث
│   │   └── validators.dart            # التحقق من البيانات
│   ├── integrations/                  # مكان حفظ روابط الربط العامة
│   │   ├── figma_links/               # روابط وتصميمات Figma
│   │   │   ├── figma_map.yaml
│   │   │   ├── auth_figma_link.txt
│   │   │   ├── attendance_figma_link.txt
│   │   │   └── profile_figma_link.txt
│   │   ├── mcp_docs/                  # ملفات MCP
│   │   │   ├── auth_mcp.yaml
│   │   │   ├── attendance_mcp.yaml
│   │   │   └── profile_mcp.yaml
│   │   └── api_contracts/             # توثيق API
│   │       ├── auth_endpoints.md
│   │       ├── attendance_endpoints.md
│   │       └── profile_endpoints.md
│   ├── networking/
│   │   ├── dio_client.dart            # HTTP Client (Dio)
│   │   └── api_interceptor.dart       # Interceptor للـ Token
│   ├── routing/
│   │   ├── app_router.dart            # مسارات التطبيق
│   │   └── route_names.dart           # أسماء المسارات
│   ├── security/
│   │   └── secure_storage.dart        # تخزين آمن للـ Tokens
│   ├── services/
│   │   ├── auth_service.dart          # خدمة المصادقة
│   │   └── notification_service.dart  # خدمة الإشعارات
│   ├── styles/
│   │   ├── app_colors.dart            # ألوان التطبيق
│   │   └── app_text_styles.dart       # أنماط النصوص
│   ├── theming/
│   │   └── app_theme.dart             # ثيمات التطبيق
│   └── widgets/
│       ├── custom_button.dart         # أزرار مخصصة
│       ├── custom_text_field.dart     # حقول نصية مخصصة
│       └── loading_indicator.dart     # مؤشر التحميل
│
└── features/
    ├── auth/                          # 🔐 المصادقة
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── user_model.dart
    │   │   │   └── login_response_model.dart
    │   │   └── repo/auth_repo.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── auth_cubit.dart
    │   │       └── auth_state.dart
    │   └── ui/
    │       ├── screens/
    │       │   ├── login_screen.dart
    │       │   ├── register_screen.dart
    │       │   └── forgot_password_screen.dart
    │       └── widgets/
    │           └── auth_form_field.dart
    │
    ├── attendance/                    # 📅 الحضور والانصراف
    │   ├── data/
    │   │   ├── models/attendance_model.dart
    │   │   └── repo/attendance_repo.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── attendance_cubit.dart
    │   │       └── attendance_state.dart
    │   └── ui/
    │       ├── screens/
    │       │   ├── check_in_screen.dart
    │       │   └── attendance_history_screen.dart
    │       └── widgets/
    │           ├── attendance_card.dart
    │           └── duration_timer.dart
    │
    ├── profile/                       # 👤 الملف الشخصي
    │   ├── data/
    │   │   ├── models/profile_model.dart
    │   │   └── repo/profile_repo.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── profile_cubit.dart
    │   │       └── profile_state.dart
    │   └── ui/
    │       ├── screens/
    │       │   ├── profile_screen.dart
    │       │   └── edit_profile_screen.dart
    │       └── widgets/
    │           └── profile_info_card.dart
    │
    ├── requests/                      # 📝 الطلبات (إجازات، استئذان)
    │   ├── data/
    │   │   ├── models/request_model.dart
    │   │   └── repo/requests_repo.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── requests_cubit.dart
    │   │       └── requests_state.dart
    │   └── ui/
    │       ├── screens/
    │       │   ├── requests_list_screen.dart
    │       │   └── create_request_screen.dart
    │       └── widgets/
    │           └── request_card.dart
    │
    └── dashboard/                     # 🏠 لوحة التحكم الرئيسية
        ├── data/
        │   ├── models/dashboard_stats_model.dart
        │   └── repo/dashboard_repo.dart
        ├── logic/
        │   └── cubit/
        │       ├── dashboard_cubit.dart
        │       └── dashboard_state.dart
        └── ui/
            ├── screens/dashboard_screen.dart
            └── widgets/
                ├── stats_card.dart
                └── quick_actions_widget.dart
```



## 🔒 6. الأمان

- تخزين آمن للمفاتيح باستخدام `flutter_secure_storage`.
- تفعيل Obfuscation للإصدارات النهائية:
  ```bash
  flutter build apk --obfuscate --split-debug-info=build/debug_info
  ```

---

## 🧪 7. الاختبارات (Testing)

- **Unit Tests** → Repos & Cubits  
- **Widget Tests** → Screens  
- **Integration Tests** → رحلات المستخدم الكاملة

---

## 🔧 8. CI/CD Workflow

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

## 🧰 9. أدوات التطوير

- **Git Flow**:  
  - `main` → النسخة المستقرة  
  - `develop` → التطوير  
  - `feature/<name>` → لكل ميزة جديدة  

- **Mason CLI** لإنشاء Feature جديدة:
  ```bash
  mason make feature --name home
  ```

- **Logger مركزي** في `core/helpers/logger.dart`.

- **Git Hooks** لتشغيل الفحوصات قبل أي Commit.

---

## 🎨 10. توثيق المشروع (Docs)

| الملف | الوظيفة |
|--------|----------|
| `core/integrations/figma_links/` | جميع روابط التصميم |
| `core/integrations/mcp_docs/` | ملفات تعريف المكونات |
| `docs/architecture.md` | المعمارية العامة |
| `docs/feature_rules.md` | دورة تطوير الميزة |
| `docs/project_guidelines.md` | معايير كتابة الكود |

---

## 🧮 11. Workflow بين Figma – MCP – Flutter

1. **المصمم** يحدث تصميمه في Figma.  
2. **المطور** يحدث `figma_config.dart` و`mcp_config.dart`.  
3. **الـ Feature** يتم تنفيذها ومراجعتها بناءً على تلك الملفات.  
4. **المراجعة البصرية** تتم لضمان التطابق مع التصميم.  
5. يتم تسجيل الكوميت بهذا الشكل:
   ```
   feat(home): implemented according to Figma v1.0 + MCP v1.0
   ```

---

## 🚀 12. الهدف النهائي

> **تطبيق Flutter HRM احترافي متكامل**
> - **معمارية نظيفة** (Clean Architecture) مبسطة وواضحة
> - **مربوط مع Laravel Backend API** عبر Laravel Sanctum
> - **متكامل مع Figma** لضمان التطابق البصري
> - **موثق بالكامل** مع MCP و API Documentation
> - **مؤمن** باستخدام Secure Storage و Token Authentication
> - **قابل للاختبار** مع Unit, Widget, Integration Tests
> - **قابل للتوسع** لإضافة ميزات جديدة بسهولة
> - **جاهز للإنتاج** مع CI/CD و Code Quality Checks

## 📦 13. الميزات الرئيسية المتوقعة في التطبيق

### 🔐 المصادقة (Authentication)
- تسجيل الدخول (Email/Password)
- التسجيل الجديد
- نسيت كلمة المرور
- تسجيل الخروج
- Auto Login (Remember Me)

### 📅 إدارة الحضور (Attendance Management)
- تسجيل حضور (Check-in)
- تسجيل انصراف (Check-out)
- عرض مدة الحضور الحالية (Real-time)
- سجل الحضور (History)
- إحصائيات الحضور

### 👤 الملف الشخصي (Profile)
- عرض بيانات الموظف
- تعديل الملف الشخصي
- تغيير كلمة المرور
- تحميل صورة شخصية
- حذف الحساب

### 📝 إدارة الطلبات (Requests)
- طلبات الإجازات
- طلبات تعديل الحضور
- عرض حالة الطلبات
- إنشاء طلب جديد
- إرفاق مستندات

### 🏠 لوحة التحكم (Dashboard)
- إحصائيات سريعة
- الإجراءات السريعة
- الإشعارات
- التقارير الأسبوعية/الشهرية

### 🔔 الإشعارات (Notifications)
- Push Notifications عبر FCM
- إشعارات داخل التطبيق
- تنبيهات الحضور
- تنبيهات الطلبات

## 🛠️ 14. المتطلبات التقنية

### Backend Requirements
- ✅ Laravel 12 Backend يعمل على `http://localhost:8000`
- ✅ Database مع بيانات تجريبية (Seeded)
- ✅ API Endpoints موثقة
- ✅ Laravel Sanctum مفعّل

### Flutter Requirements
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android Emulator أو جهاز حقيقي

### الحزم المطلوبة (pubspec.yaml)
```yaml
dependencies:
  # HTTP Client
  dio: ^5.0.0

  # State Management
  flutter_bloc: ^8.1.3

  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # JSON Serialization
  json_annotation: ^4.8.1

  # UI
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4

  # Routing
  go_router: ^12.0.0

  # Utils
  intl: ^0.18.1
  equatable: ^2.0.5

dev_dependencies:
  # Testing
  mockito: ^5.4.2
  bloc_test: ^9.1.4

  # Code Generation
  json_serializable: ^6.7.1
  build_runner: ^2.4.6
```

## 🎯 15. الأولويات في التطوير

### المرحلة الأولى (MVP - أساسية)
1. ✅ Authentication (Login/Logout)
2. ✅ Profile Management
3. ✅ Basic Dashboard

### المرحلة الثانية (Core Features)
4. Attendance Check-in/Check-out
5. Real-time Duration Tracking
6. Attendance History

### المرحلة الثالثة (Advanced Features)
7. Requests Management (Vacation/Attendance)
8. Notifications (FCM)
9. Reports & Statistics

### المرحلة الرابعة (Polish & Testing)
10. UI/UX Enhancements
11. Comprehensive Testing
12. Performance Optimization
13. Production Build

---

## 🏁 16. البدء السريع

### الخطوة 1: تجهيز Backend
```bash
# تأكد من تشغيل Laravel Backend
cd C:\xampp\htdocs\filament-hrm
"/c/Users/B-SMART/.config/herd/bin/php84/php.exe" artisan serve

# يجب أن يعمل على http://127.0.0.1:8000
```

### الخطوة 2: إنشاء مشروع Flutter
```bash
# انتقل لمجلد المشاريع
cd C:\Users\B-SMART\AndroidStudioProjects\hrm

# إنشاء مشروع Flutter جديد
flutter create hrm_app
cd hrm_app

# أو إذا كان المشروع موجوداً
flutter pub get
```

### الخطوة 3: إضافة Dependencies
أضف الحزم المطلوبة في `pubspec.yaml` (راجع القسم 14)

```bash
flutter pub get
```

### الخطوة 4: إنشاء الهيكل الأساسي
```bash
# إنشاء المجلدات الأساسية
mkdir -p lib/core/{config,constants,di,errors,helpers,networking,routing,security,services,styles,theming,widgets}
mkdir -p lib/features/auth/{data/{models,repo},logic/cubit,ui/{screens,widgets}}
```

### الخطوة 5: نسخ ملفات التكوين من FLUTTER_API_SETUP.md
- انسخ `api_config.dart`
- انسخ `dio_client.dart`
- انسخ `api_interceptor.dart`
- عدّل Base URL ليكون:
  ```dart
  // للمحاكي
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // لجهاز حقيقي (استبدل بـ IP جهازك)
  // static const String baseUrl = 'http://192.168.1.X:8000/api/v1';
  ```

### الخطوة 6: ابدأ التطوير!
```bash
# شغّل التطبيق
flutter run

# في نافذة أخرى، شغّل code generation (إذا كنت تستخدم json_serializable)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### الخطوة 7: اختبر الاتصال بالـ API
```dart
// في main.dart أو أي صفحة اختبار
import 'package:dio/dio.dart';

void testAPI() async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1',
    ));

    final response = await dio.get('/departments');
    print('API Response: ${response.data}');
    print('✅ API Connection Successful!');
  } catch (e) {
    print('❌ API Connection Failed: $e');
  }
}
```

---

## 📚 17. الملفات المرجعية

| الملف | الموقع | الوصف |
|-------|--------|-------|
| **API Documentation** | `C:\xampp\htdocs\filament-hrm\API_DOCUMENTATION.md` | توثيق شامل لجميع API Endpoints |
| **Backend Setup** | `C:\xampp\htdocs\filament-hrm\SETUP_GUIDE_XAMPP.md` | دليل إعداد Laravel Backend |
| **Quick Start** | `C:\xampp\htdocs\filament-hrm\QUICK_START.md` | الأوامر السريعة للـ Backend |
| **Flutter API Setup** | `C:\Users\B-SMART\AndroidStudioProjects\hrm\FLUTTER_API_SETUP.md` | دليل ربط Flutter بالـ API |
| **CLAUDE.md** | `C:\xampp\htdocs\filament-hrm\CLAUDE.md` | دليل معماري للـ Backend |
| **هذا الملف** | `C:\Users\B-SMART\AndroidStudioProjects\hrm\HRM_FLUTTER_ARCHITECTURE.md` | دليل معماري Flutter HRM |

---

## ✅ 18. Checklist قبل البدء

- [ ] تأكد من تثبيت Flutter SDK (3.0+)
- [ ] تأكد من تثبيت Dart SDK (3.0+)
- [ ] تأكد من عمل Laravel Backend على http://localhost:8000
- [ ] راجع API Documentation لفهم الـ Endpoints
- [ ] جهّز تصميمات Figma (أو ابدأ بتصميم بسيط)
- [ ] أنشئ مستخدم تجريبي للاختبار
- [ ] ثبّت VS Code مع إضافات Flutter/Dart
- [ ] جهّز Android Emulator أو جهاز حقيقي

---

## 🎓 19. نصائح للمطورين

### عند تطوير Feature جديدة:
1. **ابدأ بالـ API** - افهم الـ Endpoint والـ Response أولاً
2. **أنشئ Model** - اجعله مطابقاً تماماً للـ API Response
3. **اختبر Repository** - تأكد من الاتصال بالـ API قبل بناء UI
4. **ابنِ UI تدريجياً** - ابدأ بتخطيط بسيط ثم أضف التفاصيل
5. **استخدم Hot Reload** - لا تنسى الاستفادة من Hot Reload

### عند مواجهة مشاكل:
- **Connection Refused**: تأكد من تشغيل Backend
- **401 Unauthorized**: تحقق من الـ Token
- **422 Validation Error**: راجع الـ Validation Rules في API Docs
- **CORS Error**: تأكد من إعدادات CORS في Laravel

### Best Practices:
- استخدم `const` للـ Widgets عند الإمكان
- لا تكرر الـ Code - استخدم Widgets قابلة لإعادة الاستخدام
- اتبع معايير Dart الرسمية للتسمية
- اكتب تعليقات واضحة للكود المعقد
- استخدم `flutter analyze` بانتظام

---

## 🎉 خلاصة

هذا الملف يوفر لك:
- ✅ هيكل مشروع واضح ومنظم
- ✅ ربط مع Backend API موثق
- ✅ تكامل Figma و MCP
- ✅ دليل خطوة بخطوة للتطوير
- ✅ أفضل الممارسات والأدوات

**الآن أنت جاهز للبدء في تطوير تطبيق Flutter HRM! 🚀**
