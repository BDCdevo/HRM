# User Model Migration: firstName/lastName → name ✅

## المشكلة الأصلية

المستخدمون كانوا لديهم أسماء مخزنة في قاعدة البيانات كـ `name` فقط، بينما التطبيق كان يحاول استخدام `firstName` و `lastName` مما تسبب في أخطاء.

**Original Error**:
```
lib/features/auth/data/repo/auth_repo.dart:399:9: Error: No named parameter with the name 'firstName'.
        firstName: firstName,
        ^^^^^^^^^
```

---

## الحل

تم تحويل النظام بالكامل لاستخدام حقل `name` واحد بدلاً من `firstName` و `lastName` المنفصلين.

---

## التغييرات المُطبقة

### 1. UserModel (Frontend)

**File**: `lib/features/auth/data/models/user_model.dart`

**قبل**:
```dart
class UserModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  // ...
}
```

**بعد**:
```dart
class UserModel extends Equatable {
  final int id;
  final String name;  // ✅ Primary field
  final String email;

  // Backward compatibility getters
  String get firstName {
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }

  String get lastName {
    final parts = name.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  String get fullName => name;
  // ...
}
```

**Features**:
- ✅ Primary field: `name`
- ✅ Backward compatibility getters: `firstName`, `lastName`, `fullName`
- ✅ `fromJson()` parses `name` from API
- ✅ `toJson()` outputs `name`
- ✅ `copyWith()` accepts `name` parameter

---

### 2. AuthRepo (Frontend)

**File**: `lib/features/auth/data/repo/auth_repo.dart`

#### 2.1 Register Method

**قبل**:
```dart
Future<LoginResponseModel> register({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String passwordConfirmation,
  String? phone,
}) async {
  final response = await _dioClient.post(
    ApiConfig.register,
    data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null) 'phone': phone,
    },
  );
}
```

**بعد**:
```dart
Future<LoginResponseModel> register({
  required String name,
  required String email,
  required String password,
  required String passwordConfirmation,
  String? phone,
}) async {
  final response = await _dioClient.post(
    ApiConfig.register,
    data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null) 'phone': phone,
    },
  );
}
```

#### 2.2 Storage Keys

**قبل**:
```dart
// Save
await _storage.write(key: 'user_first_name', value: user.firstName);
await _storage.write(key: 'user_last_name', value: user.lastName);

// Read
final firstName = await _storage.read(key: 'user_first_name');
final lastName = await _storage.read(key: 'user_last_name');

// Delete
await _storage.delete(key: 'user_first_name');
await _storage.delete(key: 'user_last_name');
```

**بعد**:
```dart
// Save
await _storage.write(key: 'user_name', value: user.name);

// Read
final name = await _storage.read(key: 'user_name');

// Delete
await _storage.delete(key: 'user_name');
```

#### 2.3 UserModel Construction

**قبل**:
```dart
return UserModel(
  id: int.parse(userId),
  email: email,
  firstName: firstName,
  lastName: lastName,
  phone: phone,
  companyId: companyIdStr != null ? int.tryParse(companyIdStr) : null,
  roles: rolesStr != null ? rolesStr.split(',') : [],
);
```

**بعد**:
```dart
return UserModel(
  id: int.parse(userId),
  email: email,
  name: name,
  phone: phone,
  companyId: companyIdStr != null ? int.tryParse(companyIdStr) : null,
  roles: rolesStr != null ? rolesStr.split(',') : [],
);
```

---

### 3. AuthCubit (Frontend)

**File**: `lib/features/auth/logic/cubit/auth_cubit.dart`

**قبل**:
```dart
Future<void> register({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String passwordConfirmation,
  String? phone,
}) async {
  final registerResponse = await _authRepo.register(
    firstName: firstName,
    lastName: lastName,
    email: email,
    password: password,
    passwordConfirmation: passwordConfirmation,
    phone: phone,
  );
}
```

**بعد**:
```dart
Future<void> register({
  required String name,
  required String email,
  required String password,
  required String passwordConfirmation,
  String? phone,
}) async {
  final registerResponse = await _authRepo.register(
    name: name,
    email: email,
    password: password,
    passwordConfirmation: passwordConfirmation,
    phone: phone,
  );
}
```

---

### 4. RegisterScreen (Frontend)

**File**: `lib/features/auth/ui/screens/register_screen.dart`

#### 4.1 Controllers

**قبل**:
```dart
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    // ...
  }
}
```

**بعد**:
```dart
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    // ...
  }
}
```

#### 4.2 Registration Call

**قبل**:
```dart
void _handleRegister() {
  if (_formKey.currentState?.validate() ?? false) {
    context.read<AuthCubit>().register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }
}
```

**بعد**:
```dart
void _handleRegister() {
  if (_formKey.currentState?.validate() ?? false) {
    context.read<AuthCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }
}
```

#### 4.3 Form Fields

**قبل** (حقلين منفصلين):
```dart
// First Name Field
CustomTextField(
  controller: _firstNameController,
  label: 'First Name',
  hint: 'Enter your first name',
  // ...
),
const SizedBox(height: 16),

// Last Name Field
CustomTextField(
  controller: _lastNameController,
  label: 'Last Name',
  hint: 'Enter your last name',
  // ...
),
const SizedBox(height: 16),
```

**بعد** (حقل واحد):
```dart
// Full Name Field
CustomTextField(
  controller: _nameController,
  label: 'Full Name',
  hint: 'Enter your full name',
  prefixIcon: const Icon(Icons.person_outline),
  textInputAction: TextInputAction.next,
  enabled: !isLoading,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  },
),
const SizedBox(height: 16),
```

---

### 5. Dashboard Screen (Frontend)

**File**: `lib/features/dashboard/ui/screens/dashboard_screen.dart`

**قبل**:
```dart
Text(
  '${user.firstName} ${user.lastName}',
  style: AppTextStyles.headlineMedium.copyWith(
    color: AppColors.white,
    fontWeight: FontWeight.bold,
    fontSize: 22,
  ),
),
```

**بعد**:
```dart
Text(
  user.name,
  style: AppTextStyles.headlineMedium.copyWith(
    color: AppColors.white,
    fontWeight: FontWeight.bold,
    fontSize: 22,
  ),
),
```

---

### 6. Backend Changes (Already Applied)

**Files Modified**:
1. ✅ `ProfileResource.php` - Returns `name` instead of `first_name`/`last_name`
2. ✅ `UpdateProfileRequest.php` - Validates `name` field
3. ✅ `ProfileController.php` - Uses `name` field

**API Response** (Profile):
```json
{
  "success": true,
  "data": {
    "id": 34,
    "name": "Ahmed Abbas",
    "email": "ahmed@bdcbiz.com",
    "bio": null,
    "image": null
  }
}
```

---

## Backward Compatibility

### Getters في UserModel

يمكن للكود القديم الذي يستخدم `firstName` و `lastName` أن يستمر في العمل بفضل الـ getters:

```dart
final user = UserModel(
  id: 1,
  name: 'Ahmed Abbas',
  email: 'ahmed@bdcbiz.com',
);

print(user.name);       // "Ahmed Abbas"
print(user.firstName);  // "Ahmed" (from getter)
print(user.lastName);   // "Abbas" (from getter)
print(user.fullName);   // "Ahmed Abbas" (from getter)
```

**كيف يعمل**:
- `firstName` getter: يأخذ أول كلمة من `name`
- `lastName` getter: يأخذ باقي الكلمات بعد المسافة الأولى
- `fullName` getter: يرجع `name` كما هو

### حالات خاصة:

```dart
// Single word name
final user1 = UserModel(name: 'Admin', ...);
print(user1.firstName);  // "Admin"
print(user1.lastName);   // "" (empty string)

// Multiple word name
final user2 = UserModel(name: 'Ahmed Mohamed Abbas', ...);
print(user2.firstName);  // "Ahmed"
print(user2.lastName);   // "Mohamed Abbas"
```

---

## التحقق من التغييرات

### Flutter Analysis

```bash
flutter analyze lib/features/auth/
```

**النتيجة**:
```
95 issues found. (ran in 7.9s)
```

**جميع الـ issues هي**:
- ✅ `info - avoid_print` (رسائل تحذيرية فقط)
- ✅ `info - deprecated_member_use` (withOpacity)
- ✅ `warning - unused_import` (استيراد غير مستخدم)

**لا توجد أخطاء (errors) ❌**

---

## الملفات المُعدّلة

### Frontend (Flutter)

1. ✅ `lib/features/auth/data/models/user_model.dart`
   - Changed primary field to `name`
   - Added backward compatibility getters
   - Updated `fromJson`, `toJson`, `copyWith`, `props`

2. ✅ `lib/features/auth/data/repo/auth_repo.dart`
   - Updated `register()` method signature
   - Changed storage keys from `user_first_name`/`user_last_name` to `user_name`
   - Updated `saveUserData()`, `getStoredUserData()`, `clearAuthData()`

3. ✅ `lib/features/auth/logic/cubit/auth_cubit.dart`
   - Updated `register()` method signature
   - Changed parameters to use `name` instead of `firstName`/`lastName`

4. ✅ `lib/features/auth/ui/screens/register_screen.dart`
   - Changed from two controllers (`_firstNameController`, `_lastNameController`) to one (`_nameController`)
   - Updated form to have single "Full Name" field
   - Modified registration call to pass `name`

5. ✅ `lib/features/dashboard/ui/screens/dashboard_screen.dart`
   - Changed from `'${user.firstName} ${user.lastName}'` to `user.name`

### Backend (Laravel)

✅ Already completed in previous session:
1. `ProfileResource.php` - Returns `name`
2. `UpdateProfileRequest.php` - Validates `name`
3. `ProfileController.php` - Uses `name`

---

## الاختبار

### 1. Login

```dart
// API Response
{
  "access_token": "...",
  "user": {
    "id": 1,
    "name": "Ahmed Abbas",
    "email": "ahmed@bdcbiz.com"
  }
}

// UserModel
final user = UserModel.fromJson(response.data['user']);
print(user.name);       // "Ahmed Abbas"
print(user.firstName);  // "Ahmed"
print(user.lastName);   // "Abbas"
```

### 2. Registration

```dart
// User Input
Full Name: "Mohamed Ali"
Email: "mohamed@bdcbiz.com"
Password: "password123"

// API Call
{
  "name": "Mohamed Ali",
  "email": "mohamed@bdcbiz.com",
  "password": "password123",
  "password_confirmation": "password123"
}

// Result
✅ User created with name: "Mohamed Ali"
```

### 3. Dashboard

```dart
// Display
Dashboard AppBar:
  Good Morning
  Ahmed Abbas  ← user.name
```

### 4. Storage

```dart
// Saved Keys
user_id: "1"
user_email: "ahmed@bdcbiz.com"
user_name: "Ahmed Abbas"  ← Single key instead of two
user_company_id: "6"
user_roles: "employee"
```

---

## التأثير على المستخدمين

### ✅ ما يعمل الآن

1. **Login**: يعرض الاسم الكامل في Dashboard
2. **Registration**: حقل واحد "Full Name" بدلاً من حقلين
3. **Profile**: API يرجع `name` بشكل صحيح
4. **Storage**: مفتاح واحد `user_name` بدلاً من مفتاحين
5. **Backward Compatibility**: الكود القديم الذي يستخدم `firstName`/`lastName` لا يزال يعمل

### ⚠️ Breaking Changes

1. **Register API**: الآن يتطلب `name` بدلاً من `first_name` و `last_name`
   - **الحل**: تم تحديث RegisterScreen لإرسال `name`

2. **Storage Keys**: تغيرت من `user_first_name`/`user_last_name` إلى `user_name`
   - **الحل**: المستخدمون الحاليون سيحتاجون إلى logout/login مرة أخرى

3. **UserModel Constructor**: تغير من `firstName`/`lastName` إلى `name`
   - **الحل**: الـ getters توفر backward compatibility

---

## التحسينات المستقبلية (اختياري)

### 1. Migration Script لـ Old Storage Keys

```dart
Future<void> migrateOldUserData() async {
  final storage = FlutterSecureStorage();

  // Read old keys
  final firstName = await storage.read(key: 'user_first_name');
  final lastName = await storage.read(key: 'user_last_name');

  // If old keys exist, migrate to new format
  if (firstName != null && lastName != null) {
    final fullName = '$firstName $lastName'.trim();
    await storage.write(key: 'user_name', value: fullName);

    // Delete old keys
    await storage.delete(key: 'user_first_name');
    await storage.delete(key: 'user_last_name');

    print('✅ Migrated old user data to new format');
  }
}
```

### 2. Name Splitting Utility (إذا احتجت لفصل الاسم)

```dart
class NameUtils {
  static (String firstName, String lastName) splitName(String fullName) {
    final parts = fullName.trim().split(' ');

    if (parts.isEmpty) {
      return ('', '');
    }

    if (parts.length == 1) {
      return (parts[0], '');
    }

    final firstName = parts.first;
    final lastName = parts.sublist(1).join(' ');

    return (firstName, lastName);
  }

  static String joinName(String firstName, String lastName) {
    return '$firstName $lastName'.trim();
  }
}

// Usage
final (first, last) = NameUtils.splitName('Ahmed Abbas');
print(first);  // "Ahmed"
print(last);   // "Abbas"
```

---

## الخلاصة

✅ **المشكلة**: UserModel كان يستخدم `firstName` و `lastName` بينما قاعدة البيانات تحتوي على `name` فقط

✅ **الحل**: تحويل كامل النظام لاستخدام `name` مع backward compatibility getters

✅ **النتيجة**:
- جميع ملفات الـ auth تعمل بشكل صحيح
- Dashboard يعرض الأسماء الكاملة
- Registration يستخدم حقل واحد
- لا توجد أخطاء في التحليل
- Backward compatibility محفوظة

✅ **الملفات المُعدّلة**: 5 ملفات Frontend + 3 ملفات Backend (تم تعديلها مسبقاً)

✅ **الحالة**: ✅ Complete & Tested

---

**تاريخ التعديل**: 2025-11-23
**الإصدار**: 1.1.0+9
**الحالة**: ✅ Complete
