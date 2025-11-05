# 🧭 Navigation & Routing System

## Overview

تم تصميم نظام التنقل (Navigation) في التطبيق ليكون مركزياً، مرناً، وسهل الصيانة. يستخدم النظام Named Routes مع Custom Page Transitions و Authentication Guards.

## 📁 Structure

```
lib/core/routing/
├── app_router.dart           # المسارات المركزية للتطبيق
├── route_transitions.dart    # انتقالات مخصصة بين الصفحات
├── route_guards.dart         # حماية المسارات (Authentication)
├── navigation_helper.dart    # دوال مساعدة للتنقل
└── README.md                 # هذا الملف
```

## 🚀 Usage

### 1. التنقل الأساسي (Basic Navigation)

```dart
// التنقل إلى صفحة جديدة
AppRouter.navigateTo(context, AppRouter.profile);

// التنقل واستبدال الصفحة الحالية
AppRouter.navigateAndReplace(context, AppRouter.mainNavigation);

// التنقل وحذف كل الصفحات السابقة
AppRouter.navigateAndRemoveUntil(context, AppRouter.login);

// العودة إلى الصفحة السابقة
AppRouter.goBack(context);

// التحقق من إمكانية العودة
bool canGoBack = AppRouter.canGoBack(context);
```

### 2. التنقل مع Parameters

```dart
// إرسال بيانات مع التنقل
AppRouter.navigateTo(
  context,
  AppRouter.editProfile,
  arguments: {'userId': 123},
);

// استقبال البيانات في الصفحة المستهدفة
@override
Widget build(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map?;
  final userId = args?['userId'];
  // ...
}
```

### 3. Custom Page Transitions

```dart
// استخدام انتقال مخصص
const ProfileScreen().navigate(
  context,
  transition: RouteTransitionType.slideFromRight,
  duration: Duration(milliseconds: 300),
);

// أنواع الانتقالات المتاحة:
// - material (افتراضي)
// - fade
// - slideFromRight
// - slideFromLeft
// - slideFromBottom
// - slideFromTop
// - scale
// - rotation
// - slideAndFade
```

### 4. Route Guards (حماية المسارات)

```dart
// حماية صفحة تتطلب تسجيل دخول
class SomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      child: Scaffold(
        // محتوى الصفحة المحمية
      ),
    );
  }
}

// حماية صفحة تتطلب صلاحيات Admin
class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      requireAdmin: true,
      child: Scaffold(
        // محتوى صفحة الأدمن
      ),
    );
  }
}
```

### 5. Navigation Helper Methods

```dart
// عرض Bottom Sheet مع انتقال مخصص
NavigationHelper.showCustomBottomSheet(
  context: context,
  child: MyBottomSheetWidget(),
);

// عرض Dialog مع انتقال مخصص
NavigationHelper.showCustomDialog(
  context: context,
  child: MyDialogWidget(),
);

// الانتقال مع Hero Transition
NavigationHelper.navigateWithHero(
  context,
  DetailScreen(),
  'heroTag',
);

// الانتقال إلى Login وحذف كل الصفحات
NavigationHelper.goToLogin(context);

// الانتقال إلى Home وحذف كل الصفحات
NavigationHelper.goToHome(context);

// تسجيل الخروج
NavigationHelper.logout(context);

// عرض dialog تأكيد
bool confirmed = await NavigationHelper.showConfirmationDialog(
  context,
  title: 'Confirm',
  message: 'Are you sure?',
);

// عرض Loading Dialog
NavigationHelper.showLoadingDialog(context);
// ... عملية طويلة
NavigationHelper.hideLoadingDialog(context);
```

## 📋 Available Routes

### Authentication Routes
- `AppRouter.userTypeSelection` - اختيار نوع المستخدم
- `AppRouter.login` - تسجيل دخول الموظف
- `AppRouter.adminLogin` - تسجيل دخول الأدمن
- `AppRouter.register` - التسجيل

### Main Routes
- `AppRouter.mainNavigation` - الصفحة الرئيسية بالـ Bottom Navigation

### Profile Routes
- `AppRouter.profile` - الملف الشخصي
- `AppRouter.editProfile` - تعديل الملف الشخصي
- `AppRouter.changePassword` - تغيير كلمة المرور

### Feature Routes
- `AppRouter.notifications` - الإشعارات
- `AppRouter.settings` - الإعدادات
- `AppRouter.about` - حول التطبيق
- `AppRouter.monthlyReport` - التقرير الشهري
- `AppRouter.workSchedule` - جدول العمل

### Leave Routes
- `AppRouter.applyLeave` - طلب إجازة
- `AppRouter.leaveHistory` - سجل الإجازات
- `AppRouter.leaveBalance` - رصيد الإجازات

### Attendance Routes
- `AppRouter.attendanceHistory` - سجل الحضور

## 🎨 Custom Transitions

يمكنك إنشاء انتقالات مخصصة باستخدام `CustomPageRoute`:

```dart
Navigator.push(
  context,
  CustomPageRoute(
    builder: (context) => MyScreen(),
    transitionType: RouteTransitionType.slideAndFade,
    duration: Duration(milliseconds: 400),
  ),
);
```

## 🔐 Authentication Flow

عند تشغيل التطبيق:

1. يتم فحص حالة Authentication في `main.dart`
2. إذا كان المستخدم مسجل دخول → `MainNavigationScreen`
3. إذا لم يكن مسجل دخول → `UserTypeSelectionScreen`

عند تسجيل الخروج:
```dart
// في أي مكان في التطبيق
await context.read<AuthCubit>().logout();
NavigationHelper.logout(context);
```

## 📝 Adding New Routes

لإضافة مسار جديد:

1. أضف اسم المسار في `AppRouter`:
```dart
static const String myNewScreen = '/my-new-screen';
```

2. أضف الحالة في `onGenerateRoute`:
```dart
case myNewScreen:
  return _buildRoute(
    const MyNewScreen(),
    settings: settings,
    transition: RouteTransitionType.slideFromRight,
  );
```

3. استخدم المسار في التطبيق:
```dart
AppRouter.navigateTo(context, AppRouter.myNewScreen);
```

## 🎯 Best Practices

### ✅ DO
- استخدم `AppRouter` للتنقل بدلاً من `Navigator.push` المباشر
- استخدم `Named Routes` دائماً
- استخدم `RouteGuard` للصفحات المحمية
- استخدم Custom Transitions للتجربة الأفضل
- استخدم `NavigationHelper` للعمليات الشائعة

### ❌ DON'T
- لا تستخدم `Navigator.push` مباشرة إلا للحالات الخاصة جداً
- لا تكرر كود التنقل في أماكن متعددة
- لا تنسى إضافة Route Guards للصفحات المحمية
- لا تستخدم transitions ثقيلة قد تبطئ التطبيق

## 🔄 Migration Guide

### من الطريقة القديمة:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ProfileScreen()),
);
```

### إلى الطريقة الجديدة:
```dart
AppRouter.navigateTo(context, AppRouter.profile);

// أو مع custom transition
const ProfileScreen().navigate(
  context,
  transition: RouteTransitionType.slideFromRight,
);
```

## 🚨 Troubleshooting

### المشكلة: الصفحة لا تفتح
**الحل**: تأكد من إضافة المسار في `onGenerateRoute` في `app_router.dart`

### المشكلة: Authentication Guard لا يعمل
**الحل**: تأكد من استخدام `ProtectedRoute` wrapper للصفحة

### المشكلة: Back button لا يعمل بشكل صحيح
**الحل**: استخدم `navigateAndRemoveUntil` لحذف Stack عند الحاجة

## 📚 Examples

تجد أمثلة كاملة في:
- `lib/features/auth/ui/screens/user_type_selection_screen.dart`
- `lib/main.dart`

---

**Last Updated:** 2025-11-02
**Version:** 1.0.0
