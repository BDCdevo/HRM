# تكامل تتبع الجلسات - Flutter Implementation Complete

**التاريخ**: 2025-11-19
**الإصدار**: 1.1.0+6
**الحالة**: ✅ Flutter Implementation مكتمل | ⏳ Backend Deployment معلق

---

## 📋 الملخص

تم إكمال تكامل نظام تتبع جلسات تسجيل الدخول على جانب Flutter. النظام الآن جاهز لتتبع:
- معلومات الجهاز (نوع، موديل، نظام التشغيل)
- وقت تسجيل الدخول والخروج
- مدة الجلسة
- عنوان IP
- الموقع الجغرافي (اختياري)

---

## ✅ التغييرات المطبقة (Flutter Side)

### 1. الحزم المضافة

**الملف**: `pubspec.yaml`

```yaml
# Device & App Info
device_info_plus: ^10.1.0
package_info_plus: ^8.0.0
```

**الغرض**:
- `device_info_plus`: الحصول على معلومات الجهاز (Android/iOS)
- `package_info_plus`: الحصول على إصدار التطبيق

---

### 2. SessionModel

**الملف**: `lib/features/auth/data/models/session_model.dart`

```dart
@JsonSerializable()
class SessionModel {
  final int id;
  @JsonKey(name: 'user_id') final int userId;
  @JsonKey(name: 'user_type') final String userType;
  @JsonKey(name: 'login_time') final String loginTime;
  @JsonKey(name: 'logout_time') final String? logoutTime;
  @JsonKey(name: 'session_duration') final int? sessionDuration;
  final String status; // active, logged_out, expired, forced_logout

  // Device Info
  @JsonKey(name: 'device_type') final String? deviceType;
  @JsonKey(name: 'device_model') final String? deviceModel;
  @JsonKey(name: 'device_id') final String? deviceId;
  @JsonKey(name: 'os_version') final String? osVersion;
  @JsonKey(name: 'app_version') final String? appVersion;

  // Network & Location Info
  @JsonKey(name: 'ip_address') final String? ipAddress;
  @JsonKey(name: 'login_latitude') final double? loginLatitude;
  @JsonKey(name: 'login_longitude') final double? loginLongitude;
  @JsonKey(name: 'login_method') final String? loginMethod;

  // Helper Methods
  String get durationFormatted; // "3 ساعة و 45 دقيقة"
  String get statusArabic;      // "نشط", "تم الخروج", etc.
  String get deviceIcon;        // 🤖, 🍎, 🌐
  bool get isActive;
}
```

**الميزات**:
- ✅ تخزين شامل لمعلومات الجلسة
- ✅ Helper methods للعرض بالعربية
- ✅ تنسيق المدة الزمنية تلقائياً
- ✅ JSON Serialization جاهز

---

### 3. SessionService

**الملف**: `lib/core/services/session_service.dart`

```dart
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;

  /// Start session after login
  Future<String?> startSession({
    required int userId,
    required String userType,
    String? loginMethod,
    double? latitude,
    double? longitude,
  }) async {
    final deviceInfo = await _getDeviceInfo();
    final response = await _dioClient.post('/sessions/start', data: {
      'user_id': userId,
      'user_type': userType,
      'device_info': deviceInfo,
      'login_method': loginMethod ?? 'unified',
      'location': latitude != null ? {
        'latitude': latitude,
        'longitude': longitude,
      } : null,
    });

    // Save session ID and token
    await _storage.write(key: _sessionIdKey, value: sessionId);
    await _storage.write(key: _sessionTokenKey, value: sessionToken);

    return sessionId;
  }

  /// End session on logout
  Future<bool> endSession() async {
    final sessionId = await _storage.read(key: _sessionIdKey);
    await _dioClient.put('/sessions/$sessionId/end');
    await _storage.delete(key: _sessionIdKey);
    await _storage.delete(key: _sessionTokenKey);
    return true;
  }

  /// Get device information (Android/iOS)
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Returns: type, model, device_id, os_version, app_version
  }

  /// Additional Methods
  Future<String?> getCurrentSessionId();
  Future<List<SessionModel>> getMySessions();
  Future<List<SessionModel>> getActiveSessions();
  Future<bool> forceLogout(int sessionId);
}
```

**الميزات**:
- ✅ Singleton Pattern
- ✅ تلقائي يحصل على معلومات الجهاز
- ✅ يحفظ Session ID محلياً
- ✅ يدعم الموقع الجغرافي (اختياري)
- ✅ دوال لإدارة الجلسات

---

### 4. تكامل مع AuthCubit

**الملف**: `lib/features/auth/logic/cubit/auth_cubit.dart`

**التغييرات**:

1. **إضافة Import**:
```dart
import '../../../../core/services/session_service.dart';
```

2. **إضافة Instance**:
```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  final SessionService _sessionService = SessionService();
  // ...
}
```

3. **تتبع الجلسة عند تسجيل الدخول (موظف)**:
```dart
Future<void> login({required String email, required String password}) async {
  final loginResponse = await _authRepo.login(email: email, password: password);

  // Start session tracking
  final sessionId = await _sessionService.startSession(
    userId: loginResponse.data.id,
    userType: 'employee',
    loginMethod: 'unified',
  );

  if (sessionId != null) {
    print('📊 Session started: $sessionId');
  }

  emit(AuthAuthenticated(loginResponse.data));
}
```

4. **تتبع الجلسة عند تسجيل الدخول (أدمن)**:
```dart
Future<void> loginAdmin({required String email, required String password}) async {
  final loginResponse = await _authRepo.loginAdmin(email: email, password: password);

  // Start session tracking
  final sessionId = await _sessionService.startSession(
    userId: loginResponse.data.id,
    userType: 'admin',
    loginMethod: 'admin',
  );

  emit(AuthAuthenticated(loginResponse.data));
}
```

5. **إنهاء الجلسة عند تسجيل الخروج**:
```dart
Future<void> logout() async {
  emit(const AuthLoading());

  // End session tracking
  final sessionEnded = await _sessionService.endSession();
  if (sessionEnded) {
    print('📊 Session ended successfully');
  }

  await _authRepo.logout();
  emit(const AuthUnauthenticated());
}
```

**الميزات**:
- ✅ تلقائياً يبدأ الجلسة عند نجاح تسجيل الدخول
- ✅ تلقائياً ينهي الجلسة عند تسجيل الخروج
- ✅ يميز بين موظف وأدمن
- ✅ معالجة الأخطاء: حتى لو فشل API، يحذف البيانات المحلية

---

## 🔧 الأوامر المنفذة

```bash
# 1. إضافة الحزم إلى pubspec.yaml
# تم يدوياً

# 2. تثبيت الحزم
flutter pub get
# ✅ Installed: device_info_plus 10.1.2, package_info_plus 8.3.1

# 3. توليد session_model.g.dart
flutter pub run build_runner build --delete-conflicting-outputs
# ✅ Built with build_runner in 51s; wrote 11 outputs
```

---

## 📱 كيفية عمل النظام

### تدفق تسجيل الدخول:
```
1. المستخدم يدخل email & password
2. AuthCubit.login() → AuthRepo.login()
3. ✅ نجح تسجيل الدخول
4. SessionService.startSession()
   ├─ يحصل على معلومات الجهاز (device_info_plus)
   ├─ يحصل على إصدار التطبيق (package_info_plus)
   ├─ يرسل POST /sessions/start
   └─ يحفظ session_id محلياً
5. emit(AuthAuthenticated)
6. ينتقل للشاشة الرئيسية
```

### تدفق تسجيل الخروج:
```
1. المستخدم يضغط Logout
2. AuthCubit.logout()
3. SessionService.endSession()
   ├─ يرسل PUT /sessions/{id}/end
   └─ يحذف session_id المحلي
4. AuthRepo.logout()
5. emit(AuthUnauthenticated)
6. يعود لشاشة تسجيل الدخول
```

---

## 📊 البيانات المُرسلة للـ Backend

### عند تسجيل الدخول (POST /sessions/start):
```json
{
  "user_id": 123,
  "user_type": "employee",
  "login_method": "unified",
  "device_info": {
    "type": "Android",
    "model": "SM-G973F",
    "device_id": "abc123unique",
    "os_version": "Android 13 (SDK 33)",
    "app_version": "1.1.0"
  },
  "location": {
    "latitude": 30.0444,
    "longitude": 31.2357
  }
}
```

### الاستجابة المتوقعة:
```json
{
  "success": true,
  "message": "Session started successfully",
  "data": {
    "session_id": 456,
    "session_token": "xyz789token"
  }
}
```

---

## ⏳ الخطوات المتبقية (Backend)

### 1. إنشاء Migration
```bash
cd /var/www/erp1
php artisan make:migration create_login_sessions_table
```

**محتوى Migration**: راجع `SESSION_TRACKING_IMPLEMENTATION.md` للكود الكامل

### 2. إنشاء Model
```bash
php artisan make:model LoginSession
```

### 3. إنشاء Controller
```bash
php artisan make:controller Api/V1/SessionController
```

**Methods المطلوبة**:
- `start()` - POST /sessions/start
- `end()` - PUT /sessions/{id}/end
- `mySessions()` - GET /sessions/my-sessions
- `activeSessions()` - GET /sessions/active
- `forceLogout()` - DELETE /sessions/{id}/force-logout

### 4. إضافة Routes
```php
// routes/api.php
Route::middleware('auth:sanctum')->prefix('v1')->group(function () {
    Route::prefix('sessions')->group(function () {
        Route::post('start', [SessionController::class, 'start']);
        Route::put('{id}/end', [SessionController::class, 'end']);
        Route::get('my-sessions', [SessionController::class, 'mySessions']);
        Route::get('active', [SessionController::class, 'activeSessions']);
        Route::delete('{id}/force-logout', [SessionController::class, 'forceLogout']);
    });
});
```

### 5. تطبيق Migration
```bash
php artisan migrate
```

### 6. مسح الـ Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

---

## 🧪 الاختبار

### اختبار محلي (قبل Production):

1. **تشغيل الـ Backend المحلي**:
```bash
cd D:\php_project\filament-hrm
php artisan serve
```

2. **تغيير الـ baseUrl في Flutter**:
```dart
// lib/core/config/api_config.dart line 26
static const String baseUrl = baseUrlEmulator;
```

3. **تشغيل التطبيق**:
```bash
flutter run
```

4. **السيناريوهات**:
   - ✅ سجل دخول بـ Ahmed@bdcbiz.com / password
   - ✅ تحقق من الـ Console Logs: "📊 Session started: X"
   - ✅ تحقق من Database: SELECT * FROM login_sessions;
   - ✅ سجل خروج
   - ✅ تحقق من logout_time في Database

### اختبار Production:

1. نشر الـ Backend على السيرفر
2. تغيير baseUrl إلى production
3. إعادة اختبار جميع السيناريوهات

---

## 🔍 Troubleshooting

### المشكلة: Session لا يبدأ (sessionId = null)
**الحلول**:
- ✅ تحقق من الـ Backend: هل Migration تم تطبيقها؟
- ✅ تحقق من الـ API Route: `php artisan route:list --path=sessions`
- ✅ تحقق من الـ Logs: `tail -f storage/logs/laravel.log`
- ✅ تحقق من الـ Response في Flutter Console

### المشكلة: Device Info فارغ
**الحلول**:
- ✅ تأكد من تثبيت الحزم: `flutter pub get`
- ✅ تحقق من الـ Permissions (Android Manifest / iOS Info.plist)
- ✅ اختبر على جهاز حقيقي (ليس Emulator)

### المشكلة: Build Runner يفشل
**الحلول**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 الملفات المُنشأة/المُعدلة

### ملفات جديدة:
- ✅ `lib/features/auth/data/models/session_model.dart`
- ✅ `lib/features/auth/data/models/session_model.g.dart` (auto-generated)
- ✅ `lib/core/services/session_service.dart`
- ✅ `SESSION_TRACKING_IMPLEMENTATION.md`
- ✅ `SESSION_TRACKING_FLUTTER_COMPLETE.md` (هذا الملف)

### ملفات معدلة:
- ✅ `pubspec.yaml` - أضيفت device_info_plus و package_info_plus
- ✅ `lib/features/auth/logic/cubit/auth_cubit.dart` - تكامل SessionService

---

## 🎯 الخطوة التالية

**الأولوية**: نشر الـ Backend

```bash
# 1. اتصل بالسيرفر
ssh -i ~/.ssh/id_ed25519 root@31.97.46.103

# 2. انتقل للمشروع
cd /var/www/erp1

# 3. أنشئ Migration
php artisan make:migration create_login_sessions_table

# 4. انسخ الكود من SESSION_TRACKING_IMPLEMENTATION.md

# 5. طبق Migration
php artisan migrate

# 6. أنشئ Model & Controller
php artisan make:model LoginSession
php artisan make:controller Api/V1/SessionController

# 7. امسح الـ Cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# 8. اختبر
curl -X POST https://erp1.bdcbiz.com/api/v1/sessions/start \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user_id":123,"user_type":"employee","device_info":{...}}'
```

---

**آخر تحديث**: 2025-11-19
**المطور**: Claude Code
**الحالة**: ✅ Flutter جاهز | ⏳ Backend معلق
