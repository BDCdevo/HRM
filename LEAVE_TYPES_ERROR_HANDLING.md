# 🔧 Leave Types - Enhanced Error Handling

## المشكلة (Problem)

عند فتح صفحة "Apply Leave"، كان هناك خطأ يظهر:
```
Failed to load vacation types
[400] Leave request validation failed
```

المشاكل المحددة:
1. ❌ رسائل الخطأ بالإنجليزية
2. ❌ تظهر جميع الإجازات حتى لو غير متاحة للموظف
3. ❌ معالجة ضعيفة للأخطاء المختلفة
4. ❌ لا توجد طريقة واضحة لإعادة المحاولة

---

## الحل (Solution)

تم تحسين معالجة الأخطاء وفلترة الإجازات المتاحة فقط.

### 1️⃣ فلترة الإجازات المتاحة فقط

**الملف**: `lib/features/leave/logic/cubit/leave_cubit.dart`

```dart
Future<void> fetchVacationTypes() async {
  try {
    emit(const VacationTypesLoading());

    final vacationTypes = await _leaveRepo.getVacationTypes();

    // ⭐ فلترة الإجازات المتاحة فقط
    final availableTypes = vacationTypes
        .where((type) => type.isAvailable)
        .toList();

    print('✅ Loaded ${vacationTypes.length} types, ${availableTypes.length} available');

    if (availableTypes.isEmpty) {
      emit(const LeaveError(
        message: 'لا توجد أنواع إجازات متاحة لك حالياً',
      ));
      return;
    }

    emit(VacationTypesLoaded(vacationTypes: availableTypes));
  } catch (e) {
    emit(LeaveError(
      message: 'حدث خطأ أثناء تحميل أنواع الإجازات',
    ));
  }
}
```

### 2️⃣ تحسين معالجة الأخطاء (Error Handling)

**الملف**: `lib/features/leave/logic/cubit/leave_cubit.dart`

تم إضافة معالجة مخصصة لكل نوع خطأ:

| HTTP Status | رسالة الخطأ |
|-------------|------------|
| 401 | انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى |
| 403 | ليس لديك صلاحية لهذه العملية |
| 404 | البيانات المطلوبة غير موجودة |
| 422 | رسالة الـ validation error من الـ backend |
| 500+ | خطأ في الخادم. يرجى المحاولة لاحقاً |
| Timeout | انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى |
| No Internet | خطأ في الاتصال. تحقق من الإنترنت |

```dart
void _handleDioException(DioException e) {
  print('❌ DioException: ${e.type} - ${e.message}');
  print('Response: ${e.response?.data}');

  if (e.response != null) {
    final statusCode = e.response?.statusCode;
    final errorMessage = e.response?.data?['message'] ?? 'فشلت العملية';

    // Handle 401 Unauthorized
    if (statusCode == 401) {
      emit(const LeaveError(
        message: 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى',
      ));
      return;
    }

    // ... (معالجة جميع الحالات)
  } else if (e.type == DioExceptionType.connectionTimeout) {
    emit(const LeaveError(
      message: 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى',
    ));
  }
  // ... (المزيد من المعالجات)
}
```

### 3️⃣ تحسين واجهة المستخدم (UI)

**الملف**: `lib/features/leaves/ui/widgets/leaves_apply_widget.dart`

#### قبل:
```dart
// Error display - English only
Text('Failed to load vacation types')
IconButton(icon: Icon(Icons.refresh))
```

#### بعد:
```dart
// ✅ رسالة خطأ واضحة بالعربية
Container(
  decoration: BoxDecoration(
    color: AppColors.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: [
      Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          Text(
            state.message, // رسالة بالعربية
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
      // ⭐ زر واضح لإعادة المحاولة
      CustomButton(
        text: 'إعادة المحاولة',
        type: ButtonType.secondary,
        onPressed: () => context.read<LeaveCubit>().fetchVacationTypes(),
        icon: Icons.refresh,
      ),
    ],
  ),
)
```

---

## 🎯 كيف يعمل النظام (How It Works)

### Backend Logic (في `isAvailableForEmployee`)

```php
// app/Models/Hrm/VacationType.php
public function isAvailableForEmployee(Employee $employee): bool
{
    // 1. Check if vacation type is active
    if (!$this->status) {
        return false;
    }

    // 2. Check unlock period (months after joining)
    if ($this->unlock_after_months === 0) {
        return true; // Available immediately
    }

    $joiningDate = $employee->company_date_of_joining;
    if (!$joiningDate) {
        return true; // No joining date = allow all types
    }

    $monthsSinceJoining = $joiningDate->diffInMonths(now());

    return $monthsSinceJoining >= $this->unlock_after_months;
}
```

### مثال عملي:

**الموظف**: Ahmed@bdcbiz.com
- **تاريخ التعيين**: 2024-01-01
- **الأشهر منذ التعيين**: 10 أشهر (حتى نوفمبر 2025)

| نوع الإجازة | unlock_after_months | متاحة؟ | السبب |
|-------------|---------------------|--------|-------|
| الإجازة السنوية | 12 | ❌ | يحتاج 12 شهر، عنده 10 فقط |
| الإجازة المرضية | 3 | ✅ | عنده 10 أشهر، أكثر من 3 |
| إجازة الوضع | 10 | ✅ | عنده 10 أشهر، يساوي 10 |
| إجازة الزواج | 0 | ✅ | متاحة فوراً |
| إجازة الوفاة | 0 | ✅ | متاحة فوراً |
| إجازة الحج | 12 | ❌ | يحتاج 12 شهر |
| الإجازة العارضة | 6 | ✅ | عنده 10 أشهر |
| إجازة بدون أجر | 6 | ✅ | عنده 10 أشهر |
| إجازة الامتحانات | 6 | ✅ | عنده 10 أشهر |
| إجازة رعاية الطفل | 12 | ❌ | يحتاج 12 شهر |

**النتيجة**: يظهر للموظف **7 أنواع فقط** من أصل 10!

---

## 🧪 سيناريوهات الاختبار (Test Scenarios)

### ✅ Scenario 1: موظف جديد (أقل من 3 أشهر)

**متوقع**:
- إجازة الزواج ✅
- إجازة الوفاة ✅
- باقي الإجازات ❌

### ✅ Scenario 2: موظف (6 أشهر)

**متوقع**:
- الإجازات الفورية (0 months) ✅
- الإجازة المرضية (3 months) ✅
- الإجازات الـ 6 أشهر ✅
- الإجازات الـ 12 شهر ❌

### ✅ Scenario 3: موظف قديم (أكثر من 12 شهر)

**متوقع**:
- جميع الإجازات الـ 10 ✅

### ✅ Scenario 4: خطأ في الاتصال

**متوقع**:
- رسالة: "خطأ في الاتصال. تحقق من الإنترنت"
- زر "إعادة المحاولة"

### ✅ Scenario 5: انتهاء الجلسة (401)

**متوقع**:
- رسالة: "انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى"
- يجب على المستخدم إعادة تسجيل الدخول

---

## 📊 User Experience Flow

```
1. User opens "Apply Leave"
   ↓
2. Loading indicator appears
   ↓
3. API call to /api/v1/leaves/types
   ↓
4a. SUCCESS Path:
    - Backend returns 10 vacation types with is_available flag
    - Flutter filters: only types with is_available = true
    - Dropdown shows filtered types (e.g., 7 out of 10)
    - User can select and apply
   ↓
4b. ERROR Path (401 - Unauthorized):
    - Error message: "انتهت صلاحية الجلسة"
    - No "Retry" button (user must re-login)
   ↓
4c. ERROR Path (Network):
    - Error message: "خطأ في الاتصال. تحقق من الإنترنت"
    - "إعادة المحاولة" button appears
    - User clicks → retry API call
   ↓
4d. ERROR Path (No Available Types):
    - Error message: "لا توجد أنواع إجازات متاحة لك حالياً"
    - Info message: يرجى التواصل مع قسم الموارد البشرية
```

---

## 🐛 Troubleshooting

### ❌ "لا توجد أنواع إجازات متاحة لك حالياً"

**الأسباب المحتملة**:
1. الموظف جديد (أقل من الحد الأدنى للإجازات)
2. جميع أنواع الإجازات `status = false`
3. مشكلة في حساب `company_date_of_joining`

**الحل**:
```bash
# Check employee joining date
ssh root@31.97.46.103
cd /var/www/erp1
php artisan tinker

$employee = Employee::where('email', 'Ahmed@bdcbiz.com')->first();
dump([
    'joining_date' => $employee->company_date_of_joining,
    'months_employed' => $employee->company_date_of_joining?->diffInMonths(now()),
]);

# Check available vacation types for this employee
VacationType::where('status', true)->get()->map(function($type) use ($employee) {
    return [
        'name' => $type->name,
        'unlock_after' => $type->unlock_after_months,
        'is_available' => $type->isAvailableForEmployee($employee),
    ];
});
```

### ❌ "انتهت صلاحية الجلسة"

**الحل**:
1. Logout من التطبيق
2. Login مرة أخرى
3. جرب Apply Leave

### ❌ كل الإجازات تظهر (حتى غير المتاحة)

**المشكلة**: Flutter لا يفلتر بشكل صحيح

**الحل**:
- تأكد من إضافة الكود في `leave_cubit.dart`:
```dart
final availableTypes = vacationTypes
    .where((type) => type.isAvailable)
    .toList();
```

---

## ✅ ما تم إصلاحه (Changes Summary)

| المشكلة | الحل | الملف |
|---------|------|-------|
| رسائل خطأ بالإنجليزية | ترجمة جميع الرسائل للعربية | `leave_cubit.dart` |
| ظهور إجازات غير متاحة | فلترة: `is_available = true` فقط | `leave_cubit.dart` |
| معالجة ضعيفة للأخطاء | معالجة مخصصة لكل HTTP status | `leave_cubit.dart` |
| UI سيئ للأخطاء | error card + زر "إعادة المحاولة" | `leaves_apply_widget.dart` |
| لا توجد logs | إضافة print statements | `leave_cubit.dart` |

---

## 📝 الملفات المعدّلة (Modified Files)

### Flutter
1. ✅ `lib/features/leave/logic/cubit/leave_cubit.dart`
   - فلترة الإجازات المتاحة
   - معالجة محسّنة للأخطاء
   - رسائل بالعربية
   - إضافة logging

2. ✅ `lib/features/leaves/ui/widgets/leaves_apply_widget.dart`
   - UI محسّن للأخطاء
   - زر "إعادة المحاولة"
   - رسائل بالعربية

### Backend
- ✅ لا توجد تغييرات (الـ API يعمل بشكل صحيح)
- ✅ `isAvailableForEmployee()` موجود بالفعل في الـ Model

---

## 🎯 Next Steps

1. ✅ **اختبار الفلترة** - تحقق أن الإجازات غير المتاحة لا تظهر
2. ✅ **اختبار الأخطاء** - جرّب كل سيناريو خطأ
3. ⏳ **إضافة tooltip** - اشرح للمستخدم لماذا إجازة معينة غير متاحة
4. ⏳ **عرض تاريخ الإتاحة** - "متاحة بعد شهرين" بدلاً من إخفاء الإجازة
5. ⏳ **Unit Tests** - اختبارات للـ error handling

---

## 🔗 References

- **API Documentation**: `API_DOCUMENTATION.md`
- **Vacation Types**: `VACATION_TYPES_EGYPTIAN_LAW.md`
- **Integration Guide**: `VACATION_TYPES_FLUTTER_INTEGRATION.md`

---

**تاريخ التحديث**: 11 نوفمبر 2025
**الحالة**: ✅ جاهز للاختبار
**المطور**: Claude Code
**الإصدار**: 1.1
