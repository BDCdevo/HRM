# ✅ Vacation Types - Flutter Integration Complete

## التحديثات (Updates)

تم تفعيل التكامل بين **أنواع الإجازات** والتطبيق بنجاح! 🎉

---

## 🔧 ما تم عمله (Changes Made)

### 1. تفعيل API Call في Repository

**الملف**: `lib/features/leave/data/repo/leave_repo.dart`

**قبل**:
```dart
// TODO: Uncomment when backend endpoint is ready
/*
final response = await _dioClient.get(ApiConfig.vacationTypes);
...
*/

// TEMPORARY: Demo data until backend is ready
await Future.delayed(const Duration(milliseconds: 500));
final List<Map<String, dynamic>> demoData = [...];
```

**بعد**:
```dart
Future<List<VacationTypeModel>> getVacationTypes() async {
  try {
    final response = await _dioClient.get(ApiConfig.vacationTypes);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data == null) return [];

      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => VacationTypeModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch vacation types');
    }
  } catch (e) {
    print('❌ Error fetching vacation types: $e');
    rethrow;
  }
}
```

---

## 📡 API Integration Details

### Endpoint
```
GET /api/v1/leaves/types
Authorization: Bearer {token}
```

### Response Format
```json
{
  "data": [
    {
      "id": 1,
      "name": "الإجازة السنوية",
      "description": "إجازة سنوية مدفوعة الأجر...",
      "balance": 21,
      "unlock_after_months": 12,
      "required_days_before": 14,
      "requires_approval": true,
      "is_available": true
    }
  ]
}
```

### Model Mapping

| API Field | Flutter Field | Type | Notes |
|-----------|---------------|------|-------|
| `id` | `id` | `int` | Required |
| `name` | `name` | `String` | Required |
| `description` | `description` | `String?` | Nullable |
| `balance` | `balance` | `int` | Default: 0 |
| `unlock_after_months` | `unlockAfterMonths` | `int` | Default: 0 |
| `required_days_before` | `requiredDaysBefore` | `int` | Default: 0 |
| `requires_approval` | `requiresApproval` | `bool` | Default: true |
| `is_available` | `isAvailable` | `bool` | Default: true |

---

## 🎯 الأنواع المتوفرة في التطبيق (Available Types)

يجب أن ترى الآن **10 أنواع** من الإجازات في التطبيق:

### 📋 القائمة الكاملة:

1. **الإجازة السنوية** (Annual Leave)
   - الرصيد: 21 يوم
   - فترة الانتظار: 12 شهر
   - إشعار مسبق: 14 يوم

2. **الإجازة المرضية** (Sick Leave)
   - الرصيد: 180 يوم
   - فترة الانتظار: 3 أشهر
   - إشعار مسبق: فوري

3. **إجازة الوضع** (Maternity Leave)
   - الرصيد: 90 يوم
   - فترة الانتظار: 10 أشهر
   - إشعار مسبق: 30 يوم

4. **إجازة الزواج** (Marriage Leave)
   - الرصيد: 7 أيام
   - فترة الانتظار: فوري
   - إشعار مسبق: 7 أيام

5. **إجازة الوفاة** (Bereavement Leave)
   - الرصيد: 3 أيام
   - فترة الانتظار: فوري
   - إشعار مسبق: فوري

6. **إجازة الحج** (Hajj Leave)
   - الرصيد: 30 يوم
   - فترة الانتظار: 12 شهر
   - إشعار مسبق: 60 يوم

7. **الإجازة العارضة** (Casual Leave)
   - الرصيد: 7 أيام
   - فترة الانتظار: 6 أشهر
   - إشعار مسبق: فوري

8. **إجازة بدون أجر** (Unpaid Leave)
   - الرصيد: 30 يوم
   - فترة الانتظار: 6 أشهر
   - إشعار مسبق: 14 يوم

9. **إجازة الامتحانات** (Exam Leave)
   - الرصيد: 15 يوم
   - فترة الانتظار: 6 أشهر
   - إشعار مسبق: 14 يوم

10. **إجازة رعاية الطفل** (Child Care Leave)
    - الرصيد: 365 يوم
    - فترة الانتظار: 12 شهر
    - إشعار مسبق: 30 يوم

---

## 🧪 كيفية الاختبار (How to Test)

### 1. تأكد من الـ Environment

تحقق من `lib/core/config/api_config.dart` line 26:
```dart
static const String baseUrl = baseUrlProduction; // ✅ يجب أن تكون production
```

### 2. تشغيل التطبيق

```bash
# Hot restart (مهم بعد تغيير الكود)
flutter run

# أو إذا كان التطبيق يعمل بالفعل
# اضغط 'R' في terminal للـ Hot Restart
```

### 3. التنقل إلى صفحة الإجازات

في التطبيق:
1. افتح القائمة الرئيسية (Home Screen)
2. اضغط على "Apply for Leave" أو "Leaves"
3. يجب أن ترى dropdown قائمة بـ **10 أنواع إجازات**

### 4. التحقق من البيانات

عند فتح قائمة أنواع الإجازات، يجب أن ترى:
- ✅ أسماء الأنواع باللغة العربية
- ✅ الوصف لكل نوع
- ✅ عدد الأيام المتاحة
- ✅ متطلبات الإشعار المسبق

---

## 🔄 دورة العمل (Workflow)

### عند فتح صفحة Apply Leave:

1. **التطبيق يستدعي**:
   ```dart
   context.read<LeaveCubit>().fetchVacationTypes();
   ```

2. **LeaveCubit يستدعي Repository**:
   ```dart
   final types = await _leaveRepo.getVacationTypes();
   ```

3. **Repository يستدعي API**:
   ```dart
   GET https://erp1.bdcbiz.com/api/v1/leaves/types
   ```

4. **API يرجع البيانات من Database**:
   ```sql
   SELECT * FROM vacation_types
   WHERE status = 1 AND company_id = 6
   ORDER BY name
   ```

5. **التطبيق يعرض القائمة** في Dropdown

---

## 📱 User Experience Flow

```
1. User opens "Apply Leave" screen
   ↓
2. App shows loading indicator
   ↓
3. App fetches vacation types from API
   ↓
4. Dropdown populated with 10 types
   ↓
5. User selects a type
   ↓
6. Form shows:
   - Type name & description
   - Available balance
   - Required notice period
   - Start/End date fields
   - Reason field
   ↓
7. User fills form and submits
   ↓
8. App sends leave request to API
   ↓
9. Success message shown
```

---

## 🐛 Troubleshooting

### ❌ "لا توجد أنواع إجازات" (No vacation types)

**السبب المحتمل**:
1. API connection issue
2. Authentication token expired
3. Multi-tenancy: company_id = null

**الحل**:
```bash
# 1. Check backend cache
ssh root@31.97.46.103
cd /var/www/erp1
php artisan cache:clear

# 2. Verify vacation types exist with company_id
php artisan tinker --execute='
  dump(App\Models\Hrm\VacationType::where("company_id", 6)->count());
'

# 3. Re-login in the app
```

### ❌ "Unauthorized" Error

**السبب**: Token منتهي

**الحل**:
1. Logout من التطبيق
2. Login مرة أخرى
3. جرب Apply Leave مرة أخرى

### ❌ "Failed to load vacation types"

**السبب**: Network or API error

**الحل**:
1. تحقق من الإنترنت
2. تحقق أن `baseUrl = baseUrlProduction`
3. اضغط على زر Refresh (🔄)

---

## 📊 State Management

### LeaveCubit States:

```dart
// Initial state
LeaveInitial()

// Loading vacation types
VacationTypesLoading()

// Vacation types loaded successfully
VacationTypesLoaded(
  availableTypes: List<VacationTypeModel>
)

// Error loading vacation types
LeaveError(message: String)

// Applying leave
ApplyingLeave()

// Leave applied successfully
LeaveApplied(message: String)
```

---

## 🎨 UI Components

### Vacation Type Dropdown

**الملف**: `lib/features/leaves/ui/widgets/leaves_apply_widget.dart`

```dart
DropdownButtonFormField<int>(
  value: _selectedLeaveTypeId,
  hint: Text('Select leave type'),
  items: vacationTypes.map((type) {
    return DropdownMenuItem<int>(
      value: type.id,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type.name),
          if (type.description != null)
            Text(
              type.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedLeaveTypeId = value;
    });
  },
)
```

---

## ✅ Success Criteria

التكامل يعتبر ناجح إذا:

- ✅ التطبيق يعرض 10 أنواع إجازات
- ✅ الأسماء باللغة العربية
- ✅ الوصف واضح ومفصّل
- ✅ الرصيد (balance) صحيح لكل نوع
- ✅ متطلبات الإشعار المسبق صحيحة
- ✅ يمكن اختيار نوع وتقديم طلب إجازة
- ✅ لا توجد أخطاء في Console

---

## 📝 الملفات المعدّلة (Modified Files)

### Flutter
1. ✅ `lib/features/leave/data/repo/leave_repo.dart`
   - تفعيل API call
   - إزالة demo data

### Backend
- ✅ قاعدة البيانات: تحديث `company_id = 6` لجميع السجلات
- ✅ Cache: تم التنظيف

### Documentation
1. ✅ `VACATION_TYPES_EGYPTIAN_LAW.md` - توثيق الأنواع
2. ✅ `VACATION_TYPES_COMPANY_FIX.md` - حل مشكلة Multi-tenancy
3. ✅ `VACATION_TYPES_FLUTTER_INTEGRATION.md` - هذا الملف

---

## 🎯 Next Steps

1. ✅ **Test في التطبيق** - تأكد من ظهور الأنواع
2. ⏳ **تعيين الإجازات للموظفين** - ربط كل موظف بالأنواع المناسبة
3. ⏳ **تفعيل workflow الموافقات** - من يوافق على أي نوع
4. ⏳ **عرض الرصيد المتبقي** - لكل موظف حسب نوع الإجازة
5. ⏳ **إشعارات الإجازات** - عند الموافقة/الرفض

---

## 🔗 References

- **API Documentation**: `API_DOCUMENTATION.md`
- **Egyptian Law Types**: `VACATION_TYPES_EGYPTIAN_LAW.md`
- **Multi-Tenancy Fix**: `VACATION_TYPES_COMPANY_FIX.md`
- **CLAUDE.md**: Section "Leave Management"

---

**تاريخ التكامل**: 11 نوفمبر 2025
**الحالة**: ✅ جاهز للاختبار
**المطور**: Claude Code
**الإصدار**: 1.0
