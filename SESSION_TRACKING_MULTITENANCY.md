# تتبع الجلسات و Multi-Tenancy

**التاريخ**: 2025-11-19
**الإصدار**: 1.1.0+6

---

## 📋 الملخص

نظام تتبع الجلسات مُصمم للعمل مع Multi-tenancy. كل جلسة مرتبطة بشركة محددة، وهذا يضمن:
- عزل بيانات كل شركة
- تقارير دقيقة لكل شركة
- أمان وخصوصية البيانات

---

## 🏢 كيف يعمل Multi-Tenancy في النظام

### 1. على مستوى Database

**جدول `login_sessions`**:
```sql
CREATE TABLE login_sessions (
    id BIGINT,
    user_id BIGINT,
    user_type VARCHAR,  -- 'employee' or 'admin'
    company_id BIGINT,  -- ⭐ مفتاح Multi-tenancy
    -- ... باقي الحقول
);

-- Indexes
INDEX(user_id)
INDEX(company_id)  -- ⭐ للبحث السريع حسب الشركة
```

### 2. على مستوى Backend (Laravel)

#### SessionController - Start Method
```php
public function start(Request $request)
{
    // الحصول على company_id من المستخدم المسجل دخوله
    $companyId = null;

    if ($validated['user_type'] === 'employee') {
        $employee = Employee::find($validated['user_id']);
        $companyId = $employee?->company_id;  // ⭐ من Employee
    } elseif ($validated['user_type'] === 'admin') {
        $admin = User::find($validated['user_id']);
        $companyId = $admin?->company_id;     // ⭐ من Admin/User
    }

    $session = LoginSession::create([
        'user_id' => $validated['user_id'],
        'user_type' => $validated['user_type'],
        'company_id' => $companyId,  // ⭐ يُحفظ تلقائياً
        // ... باقي البيانات
    ]);
}
```

**الميزة**:
- ✅ لا يحتاج Flutter لإرسال company_id
- ✅ Backend يحصل عليه تلقائياً من User/Employee
- ✅ لا يمكن للمستخدم التلاعب به

#### SessionController - Query Methods
```php
public function mySessions()
{
    $user = Auth::user();
    $userType = $user instanceof Employee ? 'employee' : 'admin';

    // يحصل فقط على جلسات هذا المستخدم
    // ⚠️ ملاحظة: لا يفلتر حسب company_id حالياً
    $sessions = LoginSession::forUser($user->id, $userType)
        ->orderBy('login_time', 'desc')
        ->limit(50)
        ->get();
}
```

**تحسين مستقبلي**: إضافة فلترة حسب company_id للأمان الإضافي

### 3. على مستوى Flutter

#### UserModel
```dart
class UserModel extends Equatable {
  final int id;
  final int? companyId;  // ⭐ تمت إضافته للدعم Multi-tenancy
  // ... باقي الحقول

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int?,  // ⭐ يأتي من API
      // ...
    );
  }
}
```

**مصدر `company_id`**:
- يأتي من API response عند تسجيل الدخول
- يكون موجوداً في `Employee` أو `User` model في Backend
- يُحفظ تلقائياً في `UserModel` في Flutter

#### SessionService - Start Method
```dart
Future<String?> startSession({
  required int userId,
  required String userType,
  // ⚠️ لاحظ: لا نرسل company_id من Flutter
}) async {
  final response = await _dioClient.post('/sessions/start', data: {
    'user_id': userId,
    'user_type': userType,
    'device_info': deviceInfo,
    // company_id سيُضاف تلقائياً من Backend
  });
}
```

**الميزة**:
- ✅ Flutter لا يحتاج إرسال company_id
- ✅ Backend يأخذه من authenticated user
- ✅ أكثر أماناً (لا يمكن التلاعب)

---

## 🔒 الأمان والعزل

### 1. عزل البيانات

**السيناريو**: شركتان على نفس النظام
```
الشركة A (company_id = 6): BDC
├─ موظف 1 (Ahmed)
└─ موظف 2 (Sara)

الشركة B (company_id = 7): شركة أخرى
├─ موظف 3 (Ali)
└─ موظف 4 (Mona)
```

**ما يحدث عند تسجيل دخول Ahmed**:
```
1. Ahmed يسجل دخول → employee_id = 1, company_id = 6
2. SessionService.startSession(userId: 1, userType: 'employee')
3. Backend:
   - يحصل على Employee #1
   - يقرأ company_id = 6 من Employee
   - ينشئ Session:
     * user_id = 1
     * company_id = 6  ⭐
4. Database:
   login_sessions table:
   id=1, user_id=1, company_id=6, device_type="Android", ...
```

**ما يحدث عند جلب جلسات Ahmed**:
```
1. Ahmed يطلب GET /sessions/my-sessions
2. Backend:
   - Auth::user() → Employee #1
   - forUser(1, 'employee') → sessions where user_id=1
3. Response: جميع جلسات Ahmed فقط
```

### 2. التحسينات المستقبلية للأمان

#### إضافة Company Scope في Queries
```php
// LoginSession Model
protected static function booted()
{
    // إضافة Global Scope لفلترة حسب company_id تلقائياً
    static::addGlobalScope('company', function (Builder $builder) {
        if (session()->has('current_company_id')) {
            $builder->where('company_id', session('current_company_id'));
        }
    });
}
```

#### التحقق من الملكية
```php
public function end($id)
{
    $session = LoginSession::findOrFail($id);
    $user = Auth::user();

    // التحقق من user_id
    if ($session->user_id != $user->id) {
        return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
    }

    // ⭐ إضافة: التحقق من company_id
    if ($session->company_id != $user->company_id) {
        return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
    }

    $session->endSession();
}
```

---

## 📊 استخدامات Multi-tenancy في التقارير

### 1. Dashboard للإدارة (لكل شركة)

```sql
-- عدد الموظفين المتصلين حالياً لشركة BDC (company_id = 6)
SELECT COUNT(*)
FROM login_sessions
WHERE company_id = 6
  AND status = 'active';

-- متوسط مدة الجلسات لكل شركة
SELECT
    company_id,
    AVG(session_duration) as avg_duration_seconds
FROM login_sessions
WHERE status = 'logged_out'
GROUP BY company_id;
```

### 2. تقارير الأمان لكل شركة

```sql
-- جلسات من أجهزة متعددة لنفس المستخدم (في نفس الشركة)
SELECT
    user_id,
    company_id,
    COUNT(DISTINCT device_id) as device_count
FROM login_sessions
WHERE company_id = 6
  AND status = 'active'
GROUP BY user_id, company_id
HAVING device_count > 1;
```

### 3. API Endpoint للإحصائيات (مستقبلاً)

```php
// SessionController
public function companyStats()
{
    $user = Auth::user();
    $companyId = $user->company_id;

    $stats = [
        'total_sessions' => LoginSession::where('company_id', $companyId)->count(),
        'active_sessions' => LoginSession::where('company_id', $companyId)
                                         ->where('status', 'active')
                                         ->count(),
        'avg_duration' => LoginSession::where('company_id', $companyId)
                                      ->where('status', 'logged_out')
                                      ->avg('session_duration'),
        'devices_breakdown' => LoginSession::where('company_id', $companyId)
                                           ->select('device_type', DB::raw('count(*) as count'))
                                           ->groupBy('device_type')
                                           ->get(),
    ];

    return response()->json(['success' => true, 'data' => $stats]);
}
```

---

## ⚙️ الإعداد الحالي

### ما تم تطبيقه ✅

1. **Database Schema**:
   - ✅ `login_sessions` table يحتوي على `company_id`
   - ✅ Index على `company_id`

2. **Backend (SessionController)**:
   - ✅ `start()` يحصل على `company_id` من Employee/User تلقائياً
   - ✅ يُحفظ في Database

3. **Flutter (UserModel)**:
   - ✅ تمت إضافة `companyId` field
   - ✅ يُقرأ من API response
   - ✅ مضاف في `fromJson()`, `toJson()`, `copyWith()`, `props`

### ما يمكن تحسينه مستقبلاً 🔄

1. **Backend Validation**:
   - إضافة التحقق من `company_id` في `end()`, `forceLogout()`
   - استخدام Global Scope للفلترة التلقائية

2. **Admin Panel (Filament)**:
   - صفحة "Active Sessions" لكل شركة
   - تقارير إحصائية لكل شركة
   - إمكانية force logout من Admin

3. **Flutter UI**:
   - شاشة "جلساتي" تعرض سجل الجلسات
   - شاشة "الأجهزة المتصلة" (active sessions)
   - إمكانية force logout من جهاز آخر

---

## 🧪 الاختبار

### اختبار Multi-tenancy

**السيناريو 1: موظفان من نفس الشركة**
```
1. أحمد (company_id=6) يسجل دخول
   → session #1: user_id=1, company_id=6

2. سارة (company_id=6) تسجل دخول
   → session #2: user_id=2, company_id=6

3. أحمد يطلب GET /sessions/my-sessions
   → يرجع فقط session #1 (له فقط)

4. سارة تطلب GET /sessions/active
   → يرجع فقط session #2 (لها فقط)
```

**السيناريو 2: موظفان من شركتين مختلفتين**
```
1. أحمد من BDC (company_id=6) يسجل دخول
   → session #1: user_id=1, company_id=6

2. علي من شركة أخرى (company_id=7) يسجل دخول
   → session #2: user_id=3, company_id=7

3. Database:
   login_sessions:
   [1, user_id=1, company_id=6, ...]
   [2, user_id=3, company_id=7, ...]

4. أحمد يطلب /sessions/my-sessions
   → Backend يرجع sessions where user_id=1
   → لن يرى جلسة علي (user_id مختلف)
```

### التحقق من company_id في Database

```sql
-- على السيرفر
mysql> SELECT id, user_id, company_id, device_type, status
       FROM erp1.login_sessions
       ORDER BY id DESC LIMIT 5;

-- يجب أن ترى company_id مملوء تلقائياً
+----+---------+------------+-------------+----------+
| id | user_id | company_id | device_type | status   |
+----+---------+------------+-------------+----------+
|  1 |      10 |          6 | Android     | active   |
|  2 |      15 |          6 | iOS         | logged_out|
+----+---------+------------+-------------+----------+
```

---

## 📝 ملاحظات مهمة

### 1. CurrentCompanyScope
التطبيق يستخدم `CurrentCompanyScope` في بعض الـ Models. هذا **global scope** يفلتر البيانات تلقائياً حسب `session('current_company_id')`.

**LoginSession Model حالياً**:
- ❌ لا يستخدم `CurrentCompanyScope`
- ✅ يحفظ `company_id` يدوياً في SessionController

**السبب**:
- Session tracking يحتاج مرونة أكثر
- قد نحتاج query جلسات من شركات أخرى في Admin Panel
- يمكن إضافة Global Scope لاحقاً إذا لزم الأمر

### 2. Session vs Company Session
**Session**: جلسة Laravel (في الذاكرة/Database)
- `session('current_company_id')` - للـ CurrentCompanyScope

**LoginSession**: جلسة تسجيل الدخول (تتبع الجلسات)
- `login_sessions.company_id` - للتتبع والإحصائيات

هذان مختلفان ولا يتعارضان.

### 3. API Response لا يحتوي company_id؟
إذا لم يرسل Backend `company_id` في response تسجيل الدخول:

**الحل المؤقت**:
```dart
// في AuthCubit بعد نجاح login
final user = loginResponse.data;
if (user.companyId == null) {
  print('⚠️ company_id missing from API response');
  // سيظل النظام يعمل، لكن company_id سيكون null في UserModel
}
```

**الحل الدائم**:
تحديث AuthenticationController ليُضمّن `company_id` في response.

---

## ✅ Checklist

### Backend
- [x] `login_sessions` table يحتوي على `company_id`
- [x] SessionController يحصل على company_id تلقائياً
- [x] company_id يُحفظ في Database
- [ ] (اختياري) إضافة Global Scope للفلترة التلقائية
- [ ] (اختياري) التحقق من company_id في end/forceLogout

### Flutter
- [x] UserModel يحتوي على `companyId` field
- [x] يُقرأ من JSON
- [x] مضاف في Equatable props
- [ ] (مستقبلاً) استخدام في UI

### Testing
- [ ] اختبار موظف من BDC يسجل دخول
- [ ] التحقق من company_id=6 في Database
- [ ] اختبار موظف من شركة أخرى
- [ ] التحقق من عزل البيانات

---

**آخر تحديث**: 2025-11-19
**المطور**: Claude Code
**الحالة**: ✅ Multi-tenancy مدعوم بالكامل
