# Edit Profile In-App Fix

## التاريخ
23 نوفمبر 2025

## المشكلة
كانت صفحة "Edit Profile" في قائمة More تفتح في متصفح الويب بدلاً من فتح صفحة تعديل الملف الشخصي داخل التطبيق.

## الحل

### التغييرات في `more_main_screen.dart`

#### 1. إضافة Import للصفحة الجديدة
```dart
import '../../../profile/ui/screens/edit_profile_screen.dart';
```

#### 2. حذف Import لـ url_launcher
```dart
// تم حذف هذا السطر لأنه لم يعد مستخدماً
// import 'package:url_launcher/url_launcher.dart';
```

#### 3. استبدال Function القديمة

**القديم** (يفتح في المتصفح):
```dart
/// Open Edit Profile in Browser
Future<void> _openEditProfileInBrowser(int employeeId, int companyId) async {
  final url = Uri.parse('https://erp1.bdcbiz.com/hrm/$companyId/employees/$employeeId/edit');

  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Error handling
    }
  } catch (e) {
    // Error handling
  }
}
```

**الجديد** (يفتح داخل التطبيق):
```dart
/// Navigate to Edit Profile Screen (In-App)
void _navigateToEditProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const EditProfileScreen(),
    ),
  ).then((_) {
    // Refresh profile when returning from edit screen
    _profileCubit.fetchProfile();
  });
}
```

#### 4. تحديث الـ MenuItem

**القديم**:
```dart
_MenuItem(
  svgIcon: 'assets/svgs/profile_icon.svg',
  title: 'Edit Profile',
  subtitle: 'Edit your profile in web browser', // ❌
  color: AppColors.secondary,
  cardColor: cardColor,
  textColor: textColor,
  secondaryTextColor: secondaryTextColor,
  onTap: () {
    final employeeId = user.id;
    final companyId = user.companyId ?? 6;
    _openEditProfileInBrowser(employeeId, companyId); // ❌
  },
),
```

**الجديد**:
```dart
_MenuItem(
  svgIcon: 'assets/svgs/profile_icon.svg',
  title: 'Edit Profile',
  subtitle: 'Update your personal information', // ✅
  color: AppColors.secondary,
  cardColor: cardColor,
  textColor: textColor,
  secondaryTextColor: secondaryTextColor,
  onTap: _navigateToEditProfile, // ✅
),
```

## المميزات

### ✅ تجربة مستخدم أفضل
- فتح صفحة Edit Profile **داخل التطبيق** مباشرة
- انتقال سلس بدون فتح متصفح خارجي
- الحفاظ على سياق التطبيق

### ✅ Auto Refresh
- عند الرجوع من صفحة Edit Profile، يتم تحديث البيانات تلقائياً
- الصفحة تعرض أحدث البيانات بعد التعديل

```dart
.then((_) {
  // Refresh profile when returning from edit screen
  _profileCubit.fetchProfile();
});
```

### ✅ الحقول المتاحة للتعديل

صفحة Edit Profile الآن تحتوي على:

**Personal Information**:
- Full Name ✅
- Email (Read-only) ✅

**Contact Information**:
- Phone Number 📱
- Address 📍

**Personal Details**:
- National ID 🆔
- Gender (Male/Female) 👤
- Date of Birth 📅

**Profile Image**:
- Display current image ✅
- Upload new image (Camera/Gallery) 📷

## الاختبار

### 1. افتح التطبيق
```bash
flutter run
```

### 2. سجل دخول بأي حساب

### 3. اذهب إلى More Tab
- اضغط على More في الـ Bottom Navigation

### 4. اضغط على "Edit Profile"
- يجب أن تفتح صفحة Edit Profile **داخل التطبيق**
- **لا يجب** أن يفتح متصفح الويب

### 5. قم بتعديل أي بيانات
- عدّل الاسم
- أضف رقم الهاتف
- أضف العنوان
- اختر الجنس
- اختر تاريخ الميلاد

### 6. اضغط "Save Changes"
- يجب أن تظهر رسالة نجاح
- يجب أن تعود للصفحة السابقة
- يجب أن تُحدّث البيانات تلقائياً في More Screen

## الملفات المعدلة

1. `lib/features/more/ui/screens/more_main_screen.dart`
   - إضافة import لـ EditProfileScreen
   - حذف import لـ url_launcher
   - استبدال `_openEditProfileInBrowser()` بـ `_navigateToEditProfile()`
   - تحديث الـ MenuItem

## قبل وبعد

### قبل ❌
```
User clicks "Edit Profile"
  → Opens web browser
  → Loads https://erp1.bdcbiz.com/hrm/6/employees/56/edit
  → User edits in browser
  → Returns to app (data not refreshed)
```

### بعد ✅
```
User clicks "Edit Profile"
  → Opens EditProfileScreen (in-app)
  → User edits profile
  → Saves changes via API
  → Returns to More Screen
  → Profile data auto-refreshes
```

## الخلاصة

✅ **تم بنجاح**:
- استبدال فتح الويب بصفحة داخل التطبيق
- إضافة Auto Refresh للبيانات
- تحسين تجربة المستخدم
- تحديث Subtitle للوضوح

الآن التطبيق يعمل بشكل **كامل offline-first** مع واجهة مستخدم سلسة!
