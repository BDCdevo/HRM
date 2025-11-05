# 🚀 دليل المرجع السريع - HRM App

## 📱 التشغيل السريع

```bash
# 1. تشغيل Backend
cd D:\php_project\filament-hrm && php artisan serve

# 2. تشغيل Flutter
cd C:\Users\B-SMART\AndroidStudioProjects\hrm
flutter run
```

---

## 🧭 التنقل (Navigation)

### الطرق السريعة

```dart
// Navigate
AppRouter.navigateTo(context, AppRouter.profile);

// Replace
AppRouter.navigateAndReplace(context, AppRouter.mainNavigation);

// Go Back
AppRouter.goBack(context);

// Logout
NavigationHelper.logout(context);
```

### المسارات المتاحة

| المسار | الوصف |
|--------|--------|
| `AppRouter.login` | تسجيل دخول الموظف |
| `AppRouter.adminLogin` | تسجيل دخول الأدمن |
| `AppRouter.mainNavigation` | الصفحة الرئيسية |
| `AppRouter.profile` | الملف الشخصي |
| `AppRouter.applyLeave` | طلب إجازة |
| `AppRouter.leaveHistory` | سجل الإجازات |
| `AppRouter.leaveBalance` | رصيد الإجازات |
| `AppRouter.notifications` | الإشعارات |
| `AppRouter.settings` | الإعدادات |

---

## ⏰ الحضور (Attendance)

### الوظائف

```dart
// Check In
context.read<AttendanceCubit>().checkIn();

// Check Out
context.read<AttendanceCubit>().checkOut();

// Get Today Status
context.read<AttendanceCubit>().fetchTodayStatus();
```

### API Endpoints

```
POST   /employee/attendance/check-in
POST   /employee/attendance/check-out
GET    /employee/attendance/status
```

---

## 🏖️ الإجازات (Leaves)

### Apply Leave

```dart
// 1. جلب أنواع الإجازات
context.read<LeaveCubit>().fetchVacationTypes();

// 2. إرسال طلب
context.read<LeaveCubit>().applyLeave(
  vacationTypeId: 1,
  startDate: '2025-11-10',
  endDate: '2025-11-20',
  reason: 'Family vacation',
);
```

### History & Balance

```dart
// جلب السجل
context.read<LeaveCubit>().fetchLeaveHistory();

// تصفية
context.read<LeaveCubit>().fetchLeaveHistory(status: 'pending');

// جلب الرصيد
context.read<LeaveCubit>().fetchLeaveBalance();

// إلغاء طلب
context.read<LeaveCubit>().cancelLeave(leaveId);
```

### API Endpoints

```
GET    /leaves/types
POST   /leaves
GET    /leaves?page=1&per_page=15&status=pending
GET    /leaves/balance
DELETE /leaves/{id}
```

---

## 🔧 API Configuration

### Base URL

```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// iOS/Web
static const String baseUrl = 'http://localhost:8000/api/v1';

// Real Device
static const String baseUrl = 'http://192.168.1.X:8000/api/v1';
```

### Headers

```dart
{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer {token}',
}
```

---

## 🎨 Theme

### Colors

```dart
AppColors.primary      // #2D3142 (Dark Navy)
AppColors.accent       // #EF8354 (Coral/Orange)
AppColors.success      // #10B981 (Green)
AppColors.error        // #EF4444 (Red)
AppColors.warning      // #F59E0B (Orange)
AppColors.info         // #3B82F6 (Blue)
```

### Text Styles

```dart
AppTextStyles.displayLarge
AppTextStyles.displayMedium
AppTextStyles.displaySmall
AppTextStyles.headlineLarge
AppTextStyles.headlineMedium
AppTextStyles.headlineSmall
AppTextStyles.titleLarge
AppTextStyles.titleMedium
AppTextStyles.titleSmall
AppTextStyles.bodyLarge
AppTextStyles.bodyMedium
AppTextStyles.bodySmall
AppTextStyles.labelLarge
AppTextStyles.labelMedium
AppTextStyles.labelSmall
```

---

## 🐛 حل المشاكل السريع

### 1. Backend لا يعمل
```bash
cd D:\php_project\filament-hrm
php artisan serve
```

### 2. Network Error في Emulator
```dart
// استخدم 10.0.2.2 بدلاً من localhost
const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

### 3. No vacation types available
```bash
php artisan tinker
\App\Models\VacationType::create([
    'name' => 'Annual Leave',
    'total_days' => 20,
]);
```

### 4. Build Runner Issues
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Session Expired
```dart
// سجل خروج وادخل مرة أخرى
NavigationHelper.logout(context);
```

---

## 📦 Dependencies الرئيسية

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State Management
  equatable: ^2.0.5             # Value Equality
  dio: ^5.4.0                   # HTTP Client
  flutter_secure_storage: ^9.0.0 # Secure Storage
  intl: ^0.18.1                 # Internationalization
  fl_chart: ^0.66.0             # Charts
```

---

## 🔑 Keyboard Shortcuts (VS Code)

```
Ctrl + .          Quick Fix
Ctrl + Space      IntelliSense
F2                Rename
Alt + Enter       Show Intents
Ctrl + Shift + R  Refactor
```

---

## 📝 Code Snippets

### BLoC Consumer

```dart
BlocConsumer<MyCubit, MyState>(
  listener: (context, state) {
    if (state is MySuccess) {
      // Show success message
    } else if (state is MyError) {
      // Show error message
    }
  },
  builder: (context, state) {
    if (state is MyLoading) {
      return CircularProgressIndicator();
    }
    return MyWidget();
  },
);
```

### Custom Button

```dart
CustomButton(
  text: 'Submit',
  onPressed: () => handleSubmit(),
  type: ButtonType.primary,
  size: ButtonSize.large,
  icon: Icon(Icons.send),
);
```

### Custom TextField

```dart
CustomTextField(
  controller: _controller,
  label: 'Email',
  hint: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty ?? true
      ? 'Email is required'
      : null,
);
```

---

## 🧪 Testing Commands

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/features/auth/logic/cubit/auth_cubit_test.dart

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .
```

---

## 📚 Documentation Files

| الملف | الوصف |
|------|--------|
| `README.md` | نظرة عامة على المشروع |
| `CLAUDE.md` | تعليمات للتطوير |
| `CHANGELOG.md` | سجل التغييرات التفصيلي |
| `QUICK_REFERENCE.md` | هذا الملف |
| `API_DOCUMENTATION.md` | توثيق API |
| `lib/core/routing/README.md` | دليل التنقل |
| `lib/core/styles/THEME_GUIDE.md` | دليل التصميم |

---

## 🚨 Important Notes

1. ⚠️ **لا تنسى**: تشغيل Backend قبل Flutter
2. ⚠️ **Base URL**: تأكد من تكوينه بشكل صحيح
3. ⚠️ **Build Runner**: شغله بعد تعديل Models
4. ⚠️ **Token**: يُحفظ في `flutter_secure_storage`
5. ⚠️ **Emulator**: استخدم `10.0.2.2` بدلاً من `localhost`

---

## ✅ Checklist للـ Development

- [ ] Backend يعمل (`php artisan serve`)
- [ ] Base URL مضبوط في `api_config.dart`
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Models generated (`build_runner build`)
- [ ] No errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)

---

## 📞 روابط مفيدة

- **Backend**: http://localhost:8000
- **API Base**: http://localhost:8000/api/v1
- **Admin Panel**: http://localhost:8000/admin
- **Figma**: https://www.figma.com/design/gNAzHVWnkINNfxNmDZX7Nt

---

**آخر تحديث**: 2 نوفمبر 2025
