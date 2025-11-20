# شاشة Loading الموحدة ⚡

**التاريخ**: 2025-11-19
**الحالة**: ✅ مكتمل

---

## 🎯 المشكلة

كان يوجد **شاشتان loading مختلفتان**:
1. **في `main.dart`**: `CircularProgressIndicator` بسيط عند فتح التطبيق
2. **في `login_screen.dart`**: `CircularProgressIndicator` صغير داخل زر Login

**النتيجة**:
- ❌ تصميم غير موحد
- ❌ صعوبة في التطوير والتخصيص
- ❌ تجربة مستخدم غير متسقة

---

## ✅ الحل

تم إنشاء **شاشة loading موحدة وجميلة** (`AppLoadingScreen`) يمكن استخدامها في كل مكان!

### الميزات:
- ✨ **تصميم موحد** - نفس الشكل في كل مكان
- 🎨 **قابلة للتخصيص** - يمكنك تطويرها بسهولة
- 🌙 **دعم Dark Mode** - تتكيف مع الثيم تلقائياً
- 📱 **Logo متحرك** - Animation جميل عند الظهور
- 💬 **رسائل مخصصة** - يمكنك تغيير الرسالة لكل حالة

---

## 📁 الملف الجديد

### `lib/core/widgets/app_loading_screen.dart`

يحتوي على:

#### 1. **`AppLoadingScreen`** - شاشة Loading كاملة

```dart
AppLoadingScreen(
  message: 'Checking authentication...', // رسالة اختيارية
  showLogo: true,                        // عرض اللوغو (اختياري)
  isDark: false,                         // Dark mode
)
```

**الاستخدامات**:
- ✅ بدء التطبيق (checking auth)
- ✅ تسجيل الدخول
- ✅ أي full-screen loading

#### 2. **`AppLoadingOverlay`** - Loading Overlay

```dart
AppLoadingOverlay(
  message: 'Saving...', // رسالة اختيارية
  isDark: false,
)
```

**طرق الاستخدام**:
```dart
// Show
AppLoadingOverlay.show(context, message: 'Loading...');

// Hide
AppLoadingOverlay.hide(context);
```

**الاستخدامات**:
- ✅ API calls سريعة
- ✅ حفظ بيانات
- ✅ أي loading لا يحتاج full-screen

---

## 🔧 التغييرات المُطبقة

### 1. في `main.dart`

**قبل**:
```dart
if (authState is AuthInitial) {
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(), // ❌ بسيط جداً
    ),
  );
}
```

**بعد**:
```dart
if (authState is AuthInitial || authState is AuthLoading) {
  return AppLoadingScreen(
    message: authState is AuthInitial
        ? 'Checking authentication...'
        : 'Loading...',
    showLogo: true,
    isDark: isDark,
  );
}
```

### 2. في `login_screen.dart`

**قبل**:
```dart
builder: (context, state) {
  final isLoading = state is AuthLoading;

  return SafeArea(
    child: /* Login Form */
  );
}
```

**بعد**:
```dart
builder: (context, state) {
  final isLoading = state is AuthLoading;

  // عرض full-screen loading عند تسجيل الدخول
  if (isLoading) {
    return AppLoadingScreen(
      message: 'Signing you in...',
      showLogo: true,
      isDark: isDark,
    );
  }

  return SafeArea(
    child: /* Login Form */
  );
}
```

**أيضاً**: تم حذف loading من داخل زر Login لأننا نستخدم full-screen الآن.

---

## 🎨 التخصيص المتاح

### تغيير Animation

في `AppLoadingScreen`:
```dart
// حالياً
_controller = AnimationController(
  duration: const Duration(milliseconds: 1500), // ⚠️ يمكنك تغيير السرعة
  vsync: this,
);

_scaleAnimation = Tween<double>(
  begin: 0.8,  // ⚠️ يمكنك تغيير البداية
  end: 1.0,    // ⚠️ والنهاية
).animate(/* ... */);
```

### تغيير الألوان

```dart
// Gradient colors
colors: isDark
  ? [
      AppColors.darkBackground,    // ⚠️ يمكنك تغيير هذه
      AppColors.darkCard,
      AppColors.darkBackground,
    ]
  : [
      AppColors.primaryDark,       // ⚠️ أو هذه
      AppColors.primary,
      AppColors.primaryDark,
    ],
```

### تغيير حجم اللوغو

```dart
Container(
  width: 100,  // ⚠️ يمكنك تغيير الحجم
  height: 100,
  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(24), // ⚠️ أو الـ radius
    boxShadow: [/* ... */],
  ),
  padding: const EdgeInsets.all(22), // ⚠️ أو الـ padding
  child: SvgPicture.asset('assets/images/logo/bdc_logo.svg'),
)
```

### إضافة Animation جديد

**مثال**: Rotation Animation

```dart
late Animation<double> _rotationAnimation;

@override
void initState() {
  super.initState();

  // إضافة Rotation
  _rotationAnimation = Tween<double>(
    begin: 0,
    end: 2 * 3.14159, // 360 degrees
  ).animate(_controller);
}

// في build():
RotationTransition(
  turns: _rotationAnimation,
  child: Container(/* logo */),
)
```

### تغيير الرسالة الافتراضية

```dart
// في main.dart
AppLoadingScreen(
  message: 'جاري التحميل...',  // ⚠️ بالعربي
  showLogo: true,
  isDark: isDark,
)

// في login_screen.dart
AppLoadingScreen(
  message: 'جاري تسجيل الدخول...',  // ⚠️ بالعربي
  showLogo: true,
  isDark: isDark,
)
```

---

## 🚀 الاستخدام في أماكن أخرى

### في أي Screen:

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, MyState>(
      builder: (context, state) {
        // عرض loading عند التحميل
        if (state is MyLoading) {
          return AppLoadingScreen(
            message: 'Loading data...',
            showLogo: false, // بدون logo
            isDark: Theme.of(context).brightness == Brightness.dark,
          );
        }

        return Scaffold(/* normal screen */);
      },
    );
  }
}
```

### مع API Call:

```dart
Future<void> saveData() async {
  // Show overlay
  AppLoadingOverlay.show(
    context,
    message: 'Saving...',
    isDark: isDark,
  );

  try {
    await api.save();
    AppLoadingOverlay.hide(context);

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully!')),
    );
  } catch (e) {
    AppLoadingOverlay.hide(context);

    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

---

## 🎨 أفكار للتطوير

### 1. إضافة Progress Bar

```dart
// إضافة خاصية
final double? progress; // 0.0 to 1.0

// في build()
if (progress != null)
  LinearProgressIndicator(
    value: progress,
    backgroundColor: Colors.white24,
    valueColor: AlwaysStoppedAnimation(Colors.white),
  ),
```

### 2. إضافة Lottie Animation

```dart
// بدلاً من Logo
Lottie.asset(
  'assets/animations/loading.json',
  width: 150,
  height: 150,
),
```

### 3. إضافة Skeleton Loader

```dart
// عرض skeleton بدلاً من loading
ShimmerLoading(
  isLoading: true,
  child: YourContent(),
)
```

### 4. إضافة Custom Spinner

```dart
// استخدام SpinKit package
SpinKitFadingCircle(
  color: Colors.white,
  size: 50.0,
)
```

---

## ✅ الفوائد

| قبل | بعد |
|-----|-----|
| ❌ شاشتان مختلفتان | ✅ شاشة واحدة موحدة |
| ❌ تصميم بسيط | ✅ تصميم جميل مع animations |
| ❌ صعب التطوير | ✅ سهل التخصيص والتطوير |
| ❌ لا يدعم Dark Mode | ✅ دعم كامل للـ Dark Mode |
| ❌ loading صغير في الزر | ✅ full-screen loading احترافي |

---

## 📝 الملفات المُعدلة

1. ✅ **جديد**: `lib/core/widgets/app_loading_screen.dart`
2. ✅ **مُحدّث**: `lib/main.dart`
3. ✅ **مُحدّث**: `lib/features/auth/ui/screens/login_screen.dart`

---

## 🧪 الاختبار

### السيناريوهات:

1. ✅ **فتح التطبيق** → يظهر loading جميل مع logo
2. ✅ **الضغط على Login** → يظهر نفس loading مع رسالة مختلفة
3. ✅ **تبديل Dark Mode** → Loading يتكيف مع الثيم
4. ✅ **Animation** → Logo يظهر بـ scale + fade animation

---

## 💡 نصائح

1. **استخدم `showLogo: false`** في الشاشات الداخلية (ليس الـ splash)
2. **غيّر الرسالة** حسب السياق (Signing in, Loading, Saving, etc.)
3. **استخدم `AppLoadingOverlay`** للـ API calls السريعة
4. **استخدم `AppLoadingScreen`** للـ full-screen loading فقط

---

**الحالة**: ✅ **جاهز للاستخدام والتطوير!**

يمكنك الآن تطوير شاشة Loading واحدة موحدة في كل التطبيق! 🎉
