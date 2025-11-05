# 🔗 دليل التكامل بين Flutter و Backend (flowERP)

## 📍 معلومات المشروعين

### Flutter Project
- **المسار:** `C:\Users\B-SMART\AndroidStudioProjects\hrm`
- **النوع:** Mobile/Desktop/Web Application
- **Framework:** Flutter 3.9.2+

### Backend Project (flowERP)
- **المسار:** `C:\Users\B-SMART\Documents\GitHub\flowERP`
- **النوع:** Laravel 12 + Filament 3 ERP System
- **API Version:** v1

---

## 🔄 نقاط التكامل الحالية

### 1. Authentication Integration ✅

#### Flutter Side
**File:** `lib/features/auth/data/repo/auth_repository.dart`

```dart
Future<AuthModel> login(String email, String password) async {
  final response = await _dioClient.post(
    ApiConfig.login,
    data: {
      'identifier': email,  // or 'email'
      'password': password,
    },
  );
  return AuthModel.fromJson(response.data['data']);
}
```

#### Backend Side
**File:** `app/Http/Controllers/Api/V1/User/Auth/AuthenticationController.php`

```php
public function login(Request $request): JsonResponse
{
    $email = $request->input('email') ?? $request->input('identifier');
    $employee = Employee::where('email', $email)
        ->where('status', true)
        ->first();
    
    $token = $employee->createToken('api-token')->plainTextToken;
    
    return (new DataResponse([
        'id' => $employee->id,
        'name' => $employee->name,
        'email' => $employee->email,
        'access_token' => $token,
        // ... more fields
    ]))->toJson();
}
```

#### Response Model
**File:** `lib/features/auth/data/models/auth_model.dart`

```dart
@JsonSerializable()
class AuthModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  @JsonKey(name: 'employee_id')
  final String? employeeId;
  @JsonKey(name: 'access_token')
  final String accessToken;
  // ... more fields
  
  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);
}
```

---

### 2. Attendance Integration ✅

#### Flutter Side
**Check-in Request:**
```dart
Future<void> checkIn(double latitude, double longitude) async {
  final response = await _dioClient.post(
    ApiConfig.checkIn,
    data: {
      'latitude': latitude,
      'longitude': longitude,
    },
  );
  return AttendanceModel.fromJson(response.data['data']);
}
```

#### Backend Side
**File:** `app/Http/Controllers/Api/V1/Employee/AttendanceController.php`

```php
public function checkIn(Request $request): JsonResponse
{
    $employee = Employee::with('branch')->find(auth()->id());
    
    // Validate location
    if ($employee->branch->latitude && $employee->branch->longitude) {
        if (!$employee->branch->isLocationWithinRadius(
            $request->latitude, 
            $request->longitude
        )) {
            return (new ErrorResponse(
                'You are too far from the branch location',
                ['distance_meters' => $distance],
                Response::HTTP_BAD_REQUEST
            ))->toJson();
        }
    }
    
    // Create attendance record
    $attendance = Attendance::create([
        'employee_id' => $employee->id,
        'date' => today(),
        'check_in_time' => now(),
        'latitude' => $request->latitude,
        'longitude' => $request->longitude,
    ]);
    
    return (new DataResponse($attendance))->toJson();
}
```

#### Key Features:
- ✅ Location validation
- ✅ Distance calculation
- ✅ Radius checking
- ✅ Duplicate check prevention

---

### 3. Leave Management Integration ✅

#### Get Vacation Types

**Flutter:**
```dart
Future<List<VacationTypeModel>> getVacationTypes() async {
  final response = await _dioClient.get(ApiConfig.vacationTypes);
  return (response.data['data'] as List)
      .map((e) => VacationTypeModel.fromJson(e))
      .toList();
}
```

**Backend:**
```php
public function getVacationTypes(): JsonResponse
{
    $employee = Employee::find(auth()->id());
    
    $vacationTypes = VacationType::where('status', true)
        ->orderBy('name')
        ->get();
    
    $data = $vacationTypes->map(function ($vacationType) use ($employee) {
        return [
            'id' => $vacationType->id,
            'name' => $vacationType->name,
            'balance' => $vacationType->balance,
            'is_available' => $vacationType->isAvailableForEmployee($employee),
        ];
    });
    
    return (new DataResponse($data))->toJson();
}
```

#### Apply for Leave

**Flutter:**
```dart
Future<void> applyLeave({
  required int vacationTypeId,
  required DateTime startDate,
  required DateTime endDate,
  required String reason,
}) async {
  await _dioClient.post(
    ApiConfig.applyLeave,
    data: {
      'vacation_type_id': vacationTypeId,
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      'reason': reason,
    },
  );
}
```

**Backend:**
```php
public function applyLeave(HttpRequest $request): JsonResponse
{
    $validator = Validator::make($request->all(), [
        'vacation_type_id' => 'required|exists:vacation_types,id',
        'start_date' => 'required|date|after_or_equal:today',
        'end_date' => 'required|date|after_or_equal:start_date',
        'reason' => 'required|string|max:500',
    ]);
    
    // Check availability and balance
    // Create request
    // Return response
}
```

---

### 4. Dashboard Integration ✅

#### Flutter Side
```dart
Future<DashboardStatsModel> getDashboardStats() async {
  final response = await _dioClient.get(ApiConfig.dashboardStats);
  return DashboardStatsModel.fromJson(response.data['data']);
}
```

#### Backend Side
**File:** `app/Http/Controllers/Api/V1/Dashboard/DashboardController.php`

```php
public function getStats(): JsonResponse
{
    $user = auth('sanctum')->user();
    
    $stats = [
        'attendance' => $this->getAttendanceStats($user->id),
        'leave_balance' => $this->getLeaveBalanceStats($user->id),
        'hours_this_month' => $this->getHoursStats($user->id),
        'pending_tasks' => [
            'count' => $this->getPendingTasksCount($user->id),
            'overdue' => $this->getOverdueTasksCount($user->id),
        ],
        'charts' => [
            'attendance_trend' => $this->getAttendanceTrendData($user->id),
            'monthly_hours' => $this->getMonthlyHoursData($user->id),
        ],
    ];
    
    return (new DataResponse($stats))->toJson();
}
```

---

## 🔧 Configuration Setup

### 1. API Base URL Configuration

#### في Flutter
**File:** `lib/core/config/api_config.dart`

```dart
class ApiConfig {
  // For Android Emulator
  static const String baseUrlEmulator = 'http://10.0.2.2:8000/api/v1';
  
  // For iOS Simulator / Web
  static const String baseUrlSimulator = 'http://localhost:8000/api/v1';
  
  // For Real Device (your IP)
  static const String baseUrlRealDevice = 'http://192.168.1.X:8000/api/v1';
  
  // Active URL
  static const String baseUrl = baseUrlEmulator; // <-- Change this
}
```

### 2. Laravel CORS Configuration

**File:** `config/cors.php`

```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // In production, specify your domain
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### 3. Sanctum Configuration

**File:** `config/sanctum.php`

```php
return [
    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
        '%s%s',
        'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
        env('APP_URL') ? ','.parse_url(env('APP_URL'), PHP_URL_HOST) : ''
    ))),
    
    'expiration' => null, // Never expire
    
    'middleware' => [
        'verify_csrf_token' => App\Http\Middleware\VerifyCsrfToken::class,
        'encrypt_cookies' => App\Http\Middleware\EncryptCookies::class,
    ],
];
```

---

## 🔐 Authentication Flow

### Complete Authentication Process

```
┌─────────────┐         ┌──────────────┐         ┌────────────┐
│   Flutter   │         │   Laravel    │         │  Database  │
│     App     │         │   Backend    │         │            │
└──────┬──────┘         └──────┬───────┘         └─────┬──────┘
       │                       │                       │
       │  POST /auth/login     │                       │
       │  {email, password}    │                       │
       ├──────────────────────>│                       │
       │                       │                       │
       │                       │  Check credentials    │
       │                       ├──────────────────────>│
       │                       │                       │
       │                       │  Employee record      │
       │                       │<──────────────────────┤
       │                       │                       │
       │                       │  Create token         │
       │                       ├──────────────────────>│
       │                       │                       │
       │  Response with token  │                       │
       │<──────────────────────┤                       │
       │                       │                       │
       │  Store token in       │                       │
       │  SecureStorage        │                       │
       │                       │                       │
       │  Subsequent requests  │                       │
       │  with Bearer token    │                       │
       ├──────────────────────>│                       │
       │                       │                       │
       │                       │  Verify token         │
       │                       ├──────────────────────>│
       │                       │                       │
```

---

## 📊 Data Models Mapping

### Employee Model Mapping

| Flutter Field | Backend Field | Type | Notes |
|--------------|---------------|------|-------|
| id | id | int | Primary key |
| name | name | String | Full name |
| email | email | String | Email address |
| phone | phone | String? | Phone number |
| employeeId | employee_id | String? | Employee ID |
| departmentId | department_id | int? | Department FK |
| positionId | position_id | int? | Position FK |
| branchId | branch_id | int? | Branch FK |
| status | status | bool | Active/Inactive |
| profilePhotoUrl | profile_photo_url | String? | Avatar URL |

### Attendance Model Mapping

| Flutter Field | Backend Field | Type | Notes |
|--------------|---------------|------|-------|
| id | id | int | Primary key |
| employeeId | employee_id | int | Employee FK |
| date | date | DateTime | Attendance date |
| checkInTime | check_in_time | DateTime? | Check-in time |
| checkOutTime | check_out_time | DateTime? | Check-out time |
| latitude | latitude | double? | GPS latitude |
| longitude | longitude | double? | GPS longitude |
| workPlanId | work_plan_id | int? | Work plan FK |
| duration | duration | String? | Work duration |

---

## 🔒 Security Best Practices

### 1. Token Storage (Flutter)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

### 2. API Interceptor (Flutter)

**File:** `lib/core/networking/api_interceptor.dart`

```dart
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add token to all requests
    final token = await SecureStorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add accept language
    options.headers['Accept-Language'] = 'en'; // or 'ar'
    
    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Clear token and redirect to login
      await SecureStorageService.deleteToken();
      // Navigate to login screen
    }
    
    super.onError(err, handler);
  }
}
```

### 3. Middleware Protection (Laravel)

```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [ProfileController::class, 'get']);
    Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);
    // ... more protected routes
});
```

---

## 🧪 Testing API Integration

### 1. Using Postman

```bash
# Login
POST http://localhost:8000/api/v1/auth/login
Content-Type: application/json

{
  "email": "employee@example.com",
  "password": "password"
}

# Get Profile (with token)
GET http://localhost:8000/api/v1/profile
Authorization: Bearer {your_token_here}
```

### 2. Using Flutter DevTools

```dart
// Add debug prints in repository
print('📤 Request: ${ApiConfig.login}');
print('📦 Data: ${jsonEncode(data)}');

final response = await _dioClient.post(ApiConfig.login, data: data);

print('📥 Response: ${response.statusCode}');
print('📋 Data: ${jsonEncode(response.data)}');
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: CORS Error
**Error:** `Access to XMLHttpRequest has been blocked by CORS policy`

**Solution:**
```php
// In config/cors.php
'allowed_origins' => ['*'],
'supports_credentials' => true,
```

### Issue 2: 401 Unauthorized
**Error:** `Unauthenticated`

**Solution:**
- Check if token is being sent in headers
- Verify token hasn't expired
- Check if user still exists in database

### Issue 3: Connection Refused
**Error:** `Connection refused on localhost:8000`

**Solution:**
- Make sure Laravel server is running (`php artisan serve`)
- Use correct base URL (10.0.2.2 for emulator)
- Check firewall settings

### Issue 4: Token Not Found
**Error:** `Token not provided`

**Solution:**
```dart
// Check ApiInterceptor is added to Dio
dio.interceptors.add(ApiInterceptor());

// Verify token storage
final token = await SecureStorageService.getToken();
print('Stored token: $token');
```

---

## 📈 Performance Optimization

### 1. Caching Strategy

```dart
class CacheManager {
  static final Map<String, dynamic> _cache = {};
  
  static void set(String key, dynamic value) {
    _cache[key] = {
      'value': value,
      'timestamp': DateTime.now(),
    };
  }
  
  static dynamic get(String key, {Duration maxAge = const Duration(minutes: 5)}) {
    if (!_cache.containsKey(key)) return null;
    
    final cached = _cache[key];
    final age = DateTime.now().difference(cached['timestamp']);
    
    if (age > maxAge) {
      _cache.remove(key);
      return null;
    }
    
    return cached['value'];
  }
}
```

### 2. Request Batching

```dart
// Instead of multiple requests
Future<void> loadDashboard() async {
  final stats = await getDashboardStats(); // Single request with all data
  // Process stats, attendance, leaves, etc.
}
```

### 3. Pagination

```dart
Future<List<AttendanceModel>> getHistory({
  int page = 1,
  int perPage = 15,
}) async {
  final response = await _dioClient.get(
    ApiConfig.attendanceHistory,
    queryParameters: {
      'page': page,
      'per_page': perPage,
    },
  );
  // Handle pagination
}
```

---

## 🚀 Next Steps

### Features to Implement

1. **Task Management** ✨
   - View assigned tasks
   - Update task status
   - Add task notes

2. **Work Schedule** ✨
   - View work plan
   - Shift management
   - Calendar view

3. **Monthly Reports** ✨
   - Attendance summary
   - Leave summary
   - Hours worked

4. **Notifications** ✨
   - FCM integration
   - In-app notifications
   - Push notifications

5. **Offline Support** ✨
   - Local database (SQLite)
   - Sync when online
   - Queue management

---

## 📚 Resources

### Documentation
- [Laravel Sanctum](https://laravel.com/docs/sanctum)
- [Dio Package](https://pub.dev/packages/dio)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Filament PHP](https://filamentphp.com/)

### API Documentation
- **File:** `C:\Users\B-SMART\AndroidStudioProjects\hrm\API_DOCUMENTATION.md`

---

**تاريخ آخر تحديث:** 2025-11-05
**الحالة:** ✅ جاهز للاستخدام
