# 📱 دليل ربط Flutter مع PHP Backend

## 🔗 إعداد الاتصال بالـ API

### الخطوة 1: إضافة المكتبات المطلوبة

افتح `pubspec.yaml` وأضف:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP Client
  dio: ^5.0.0

  # State Management
  flutter_bloc: ^8.1.3

  # للتخزين المحلي
  shared_preferences: ^2.2.2

  # للتخزين الآمن (للـ Tokens)
  flutter_secure_storage: ^9.0.0

  # JSON Serialization
  json_annotation: ^4.8.1

dev_dependencies:
  # JSON Code Generation
  json_serializable: ^6.7.1
  build_runner: ^2.4.6
```

ثم شغّل:
```bash
flutter pub get
```

---

### الخطوة 2: إنشاء بنية المشروع

#### أ. هيكل المجلدات

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart          # إعدادات API
│   ├── networking/
│   │   ├── dio_client.dart          # HTTP Client
│   │   └── api_interceptor.dart     # لإضافة Token تلقائياً
│   ├── errors/
│   │   └── api_exception.dart       # معالجة الأخطاء
│   └── services/
│       └── auth_service.dart        # خدمة المصادقة
└── features/
    └── auth/
        ├── data/
        │   ├── models/
        │   │   └── user_model.dart
        │   └── repo/
        │       └── auth_repo.dart
        ├── logic/
        │   └── cubit/
        └── ui/
```

---

### الخطوة 3: إنشاء ملفات التكوين

#### ملف API Config
`lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  // 🔧 غيّر هذا العنوان حسب بيئتك

  // للتشغيل على المحاكي (Android Emulator)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // للتشغيل على جهاز حقيقي (استبدل بـ IP جهازك)
  // static const String baseUrl = 'http://192.168.1.100:8000/api';

  // للتشغيل على الويب أو iOS Simulator
  // static const String baseUrl = 'http://localhost:8000/api';

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/user/profile';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

---

#### ملف Dio Client
`lib/core/networking/dio_client.dart`:

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_interceptor.dart';

class DioClient {
  static DioClient? _instance;
  late Dio dio;

  DioClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: ApiConfig.headers,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        validateStatus: (status) => status! < 500,
      ),
    );

    // إضافة Interceptor للـ Logging والـ Token
    dio.interceptors.add(ApiInterceptor());

    // للـ Debugging (اختياري)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  static DioClient getInstance() {
    _instance ??= DioClient._();
    return _instance!;
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
```

---

#### ملف API Interceptor (لإضافة Token)
`lib/core/networking/api_interceptor.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // إضافة Token تلقائياً لكل Request
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // معالجة خطأ 401 (غير مصرح)
    if (err.response?.statusCode == 401) {
      // هنا يمكنك إعادة توجيه المستخدم لصفحة تسجيل الدخول
      print('Unauthorized! Token expired or invalid.');
    }

    super.onError(err, handler);
  }
}
```

---

### الخطوة 4: مثال على استخدام API

#### Repository للمصادقة
`lib/features/auth/data/repo/auth_repo.dart`:

```dart
import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/user_model.dart';

class AuthRepo {
  final DioClient _dioClient = DioClient.getInstance();

  // تسجيل الدخول
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  // التسجيل
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  // الحصول على بيانات المستخدم
  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get(ApiConfig.profile);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
}
```

---

### الخطوة 5: نموذج بيانات المستخدم

`lib/features/auth/data/models/user_model.dart`:

```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
```

---

### الخطوة 6: مثال على الاستخدام في UI

```dart
import 'package:flutter/material.dart';
import '../data/repo/auth_repo.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepo();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authRepo.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // حفظ Token
      if (user.token != null) {
        await const FlutterSecureStorage()
            .write(key: 'auth_token', value: user.token!);
      }

      // الانتقال للشاشة الرئيسية
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔍 اختبار الاتصال

### 1. تأكد من تشغيل PHP Server:
```bash
cd /d D:\php_project\filament-hrm
php artisan serve
```

### 2. اختبر من Flutter:
- **Android Emulator**: استخدم `http://10.0.2.2:8000/api`
- **iOS Simulator**: استخدم `http://localhost:8000/api`
- **جهاز حقيقي**: استخدم `http://YOUR_IP:8000/api`

### 3. معرفة IP جهازك:
```bash
ipconfig
```
(ابحث عن IPv4 Address)

---

## ❗ مشاكل شائعة

### 1. Connection refused
- تأكد من تشغيل `php artisan serve`
- تأكد من استخدام IP الصحيح

### 2. CORS Error (على الويب)
في `config/cors.php` في Laravel، تأكد من:
```php
'allowed_origins' => ['*'],
```

### 3. Token لا يعمل
- تأكد من أن API Interceptor مضاف
- تحقق من أن Token محفوظ صحيحاً

---

## 📚 مصادر إضافية

- [Dio Documentation](https://pub.dev/packages/dio)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Laravel Sanctum Docs](https://laravel.com/docs/sanctum)

---

**🎉 الآن تطبيق Flutter جاهز للاتصال بـ Backend PHP!**
