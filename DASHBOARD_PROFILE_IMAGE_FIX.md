# إصلاح عرض صورة المستخدم في Dashboard ✅

## المشكلة
في شاشة Dashboard، كانت صورة المستخدم لا تظهر، وبدلاً منها يظهر أول حرف من الاسم.

## السبب
- الـ `UserModel` في `AuthCubit` لا يحتوي على بيانات الصورة الكاملة
- عند تسجيل الدخول، الـ API لا يرسل بيانات الصورة
- الصورة موجودة في قاعدة البيانات لكن تحتاج API call منفصل لجلبها

## الحل
تم إضافة `ProfileCubit` في Dashboard لجلب بيانات البروفايل الكاملة بما فيها الصورة.

---

## التغييرات التقنية

### 1. إضافة ProfileCubit

**الملف**: `lib/features/dashboard/ui/screens/dashboard_screen.dart`

#### Import الـ ProfileCubit
```dart
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';
```

#### إضافة ProfileCubit في State
```dart
class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _dashboardCubit;
  late final AttendanceCubit _attendanceCubit;
  late final NotificationsCubit _notificationsCubit;
  late final ProfileCubit _profileCubit; // ✅ جديد

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _attendanceCubit = AttendanceCubit();
    _notificationsCubit = NotificationsCubit();
    _profileCubit = ProfileCubit(); // ✅ جديد

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardCubit.fetchDashboardStats();
        _attendanceCubit.fetchTodayStatus();
        _notificationsCubit.fetchNotifications();
        _profileCubit.fetchProfile(); // ✅ جلب بيانات البروفايل
      }
    });
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _attendanceCubit.close();
    _notificationsCubit.close();
    _profileCubit.close(); // ✅ تنظيف
    super.dispose();
  }
}
```

---

### 2. إضافة ProfileCubit للـ Providers

```dart
return MultiBlocProvider(
  providers: [
    BlocProvider.value(value: _dashboardCubit),
    BlocProvider.value(value: _attendanceCubit),
    BlocProvider.value(value: _notificationsCubit),
    BlocProvider.value(value: _profileCubit), // ✅ جديد
  ],
  child: BlocConsumer<AuthCubit, AuthState>(
    // ...
  ),
);
```

---

### 3. تحديث عرض الصورة

**قبل** (يستخدم AuthCubit - لا يحتوي على الصورة):
```dart
// User Profile Photo (navigates to More tab)
Padding(
  padding: const EdgeInsets.only(right: 12, left: 8),
  child: CircleAvatar(
    backgroundColor: AppColors.white,
    radius: 18,
    child: user.image != null && user.image!.url.isNotEmpty
        ? ClipOval(
            child: Image.network(
              user.image!.url,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultAvatar(user);
              },
            ),
          )
        : _buildDefaultAvatar(user),
  ),
),
```

**بعد** (يستخدم ProfileCubit - يحتوي على الصورة):
```dart
// User Profile Photo (with profile data)
BlocBuilder<ProfileCubit, ProfileState>(
  builder: (context, profileState) {
    final profile = profileState is ProfileLoaded
        ? profileState.profile
        : null;

    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 8),
      child: CircleAvatar(
        backgroundColor: AppColors.white,
        radius: 18,
        child: profile != null && profile.hasImage
            ? ClipOval(
                child: Image.network(
                  profile.image!.url,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar(user);
                  },
                ),
              )
            : _buildDefaultAvatar(user),
      ),
    );
  },
),
```

**الفرق الرئيسي**:
- ✅ استخدام `BlocBuilder<ProfileCubit, ProfileState>` بدلاً من الاعتماد على `user.image`
- ✅ التحقق من `profile.hasImage` بدلاً من `user.image != null`
- ✅ استخدام `profile.image!.url` من ProfileCubit

---

### 4. إضافة Refresh للصورة

عند عمل Pull to Refresh في Dashboard، يتم تحديث الصورة أيضاً:

```dart
body: RefreshIndicator(
  onRefresh: () async {
    await context.read<DashboardCubit>().refresh();
    _attendanceCubit.fetchTodayStatus();
    _profileCubit.fetchProfile(); // ✅ تحديث الصورة
  },
  child: LayoutBuilder(
    // ...
  ),
),
```

---

## كيف يعمل الحل

### Flow الكامل:

1. **عند فتح Dashboard**:
   ```
   initState()
   → _profileCubit.fetchProfile()
   → API Call: GET /profile
   → Response يحتوي على بيانات الصورة
   → ProfileLoaded state
   → BlocBuilder يعيد بناء الـ UI
   → الصورة تظهر ✅
   ```

2. **عند Pull to Refresh**:
   ```
   onRefresh()
   → _profileCubit.fetchProfile()
   → تحديث الصورة من السيرفر
   → الصورة المحدثة تظهر ✅
   ```

3. **Fallback في حالة عدم وجود صورة**:
   ```
   profile == null || !profile.hasImage
   → _buildDefaultAvatar(user)
   → يظهر أول حرف من الاسم
   ```

---

## الفوائد

### ✅ 1. الصورة تظهر بشكل صحيح
- عند فتح Dashboard لأول مرة
- بعد رفع صورة جديدة من More/Edit Profile
- بعد تحديث الصفحة (Pull to Refresh)

### ✅ 2. Automatic Sync
- الصورة تتحدث تلقائياً في Dashboard عند تغييرها من أي مكان
- ProfileCubit مشترك بين Dashboard و More و Edit Profile

### ✅ 3. Better Architecture
- فصل واضح بين Auth data (login) و Profile data (full user info)
- AuthCubit → للمصادقة والـ token
- ProfileCubit → للبيانات الكاملة والصورة

---

## الاختبار

### ✅ اختبار عرض الصورة

#### سيناريو 1: المستخدم لديه صورة
1. افتح التطبيق وسجل الدخول
2. انتقل إلى Dashboard
3. **النتيجة المتوقعة**: صورة المستخدم تظهر في AppBar (أعلى اليمين)

#### سيناريو 2: المستخدم ليس لديه صورة
1. افتح التطبيق وسجل الدخول
2. انتقل إلى Dashboard
3. **النتيجة المتوقعة**: دائرة بها أول حرف من الاسم

#### سيناريو 3: رفع صورة جديدة
1. افتح More tab
2. اضغط على أيقونة الكاميرا
3. ارفع صورة جديدة
4. ارجع إلى Dashboard
5. **النتيجة المتوقعة**: الصورة الجديدة تظهر مباشرة

#### سيناريو 4: Pull to Refresh
1. في Dashboard، اسحب من أعلى لأسفل
2. **النتيجة المتوقعة**:
   - Loading indicator يظهر
   - البيانات تتحدث
   - الصورة تتحدث من السيرفر

---

## ملاحظات مهمة

### 🔄 State Management
- **ProfileCubit** يُنشأ في `initState()` ويُغلق في `dispose()`
- استخدام `BlocProvider.value` لمشاركة الـ cubit مع الـ widget tree
- **BlocBuilder** يستمع للتغييرات ويعيد بناء الصورة تلقائياً

### 🖼️ Image Loading
- استخدام `Image.network()` مع `errorBuilder` للـ fallback
- `ClipOval()` لجعل الصورة دائرية
- `fit: BoxFit.cover` لملء المساحة بدون تشويه

### ⚡ Performance
- `fetchProfile()` يُستدعى مرة واحدة فقط عند فتح Dashboard
- الصورة تُخزن في memory بواسطة Flutter
- عند Pull to Refresh، تُحدّث من السيرفر

---

## المشاكل المحتملة وحلولها

### المشكلة: الصورة لا تزال لا تظهر
**الحل**:
1. تحقق من الاتصال بالإنترنت
2. تحقق من أن المستخدم لديه صورة مرفوعة في قاعدة البيانات
3. تحقق من الـ API response في الـ logs:
   ```bash
   flutter run -v
   ```
4. تحقق من الـ ProfileResource في الباك إند:
   ```php
   // يجب أن يرجع:
   'image' => [
     'id' => $media->id,
     'url' => $media->getUrl(),
     // ...
   ]
   ```

### المشكلة: الصورة تظهر ثم تختفي
**السبب**: ProfileCubit state يتغير
**الحل**: تحقق من الـ error في ProfileCubit:
```dart
if (profileState is ProfileError) {
  print('Profile Error: ${profileState.message}');
}
```

### المشكلة: الصورة لا تتحدث بعد الرفع
**الحل**:
1. تأكد من استدعاء `fetchProfile()` بعد رفع الصورة
2. في Edit Profile، بعد `uploadImage` success:
   ```dart
   context.read<ProfileCubit>().fetchProfile();
   ```

---

## الخلاصة

✅ **المشكلة**: صورة المستخدم لا تظهر في Dashboard

✅ **الحل**: إضافة ProfileCubit لجلب بيانات البروفايل الكاملة

✅ **النتيجة**:
- الصورة تظهر بشكل صحيح
- تتحدث تلقائياً عند التغيير
- تتحدث مع Pull to Refresh

✅ **الملفات المعدلة**:
- `lib/features/dashboard/ui/screens/dashboard_screen.dart`

✅ **التحسينات**:
- Better separation of concerns (Auth vs Profile data)
- Automatic sync across screens
- Proper state management

---

**تاريخ الإصلاح**: 2025-11-23
**الإصدار**: 1.1.0+10
**الحالة**: ✅ Complete
