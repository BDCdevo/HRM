# 🔧 حل خطأ 500 - Backend Troubleshooting

## 🐛 الخطأ
```
Status Code: 500 - Server Error
Message: something_went_wrong
```

## 🔍 الأسباب المحتملة

### 1. Migration لم تعمل ✅ الأكثر احتمالاً
الجدول `attendance_sessions` غير موجود في Database

### 2. Work Plan مفقود
الموظف ليس لديه work plan

### 3. Branch مفقود
الموظف ليس لديه branch

---

## ✅ الحلول السريعة

### الحل 1: Run Migration (الأهم!)

```bash
cd C:\Users\B-SMART\Documents\GitHub\flowERP

# Check migrations
php artisan migrate:status

# Run pending migrations
php artisan migrate

# If error, run fresh (⚠️ سيحذف كل البيانات!)
php artisan migrate:fresh --seed
```

### الحل 2: تحقق من Laravel Logs

```bash
# في مجلد Backend
cd C:\Users\B-SMART\Documents\GitHub\flowERP

# اقرأ آخر سطر في الـ log
type storage\logs\laravel.log | findstr /C:"[20" | findstr /C:"]" | findstr /I "error"
```

أو افتح الملف:
```
storage/logs/laravel.log
```

### الحل 3: تحقق من Database

```sql
-- تحقق من وجود الجدول
SHOW TABLES LIKE 'attendance_sessions';

-- تحقق من البيانات
SELECT * FROM employees WHERE id = YOUR_EMPLOYEE_ID;
SELECT * FROM work_plans;
SELECT * FROM branches;
```

---

## 🔧 خطوات Debugging

### 1. تحقق من Migration Status

```bash
php artisan migrate:status
```

**يجب أن ترى:**
```
2025_11_05_143000_create_attendance_sessions_table ... Pending
```

أو
```
2025_11_05_143000_create_attendance_sessions_table ... Ran
```

### 2. Run Migration

```bash
php artisan migrate
```

**Expected Output:**
```
Migrating: 2025_11_05_143000_create_attendance_sessions_table
Migrated:  2025_11_05_143000_create_attendance_sessions_table (XXms)
```

### 3. تحقق من الجدول

```bash
php artisan tinker
```

ثم:
```php
DB::table('attendance_sessions')->count()
// Should return 0 (table exists but empty)
```

---

## 🎯 السيناريوهات المختلفة

### السيناريو 1: Migration لم تعمل

**الأعراض:**
- Error 500
- Log يقول: `SQLSTATE[42S02]: Base table or view not found: 'attendance_sessions'`

**الحل:**
```bash
php artisan migrate
```

### السيناريو 2: Work Plan مفقود

**الأعراض:**
- Error 500
- Log يقول: `No active work plan assigned`

**الحل:**
```bash
php artisan tinker
```

```php
$employee = App\Models\Hrm\Employee::find(YOUR_ID);
$workPlan = App\Models\Hrm\WorkPlan::first();
$employee->workPlans()->attach($workPlan->id);
```

### السيناريو 3: Branch مفقود

**الأعراض:**
- Error 500
- Log يقول: `No branch assigned`

**الحل:**
```bash
php artisan tinker
```

```php
$employee = App\Models\Hrm\Employee::find(YOUR_ID);
$branch = App\Models\Hrm\Branch::first();
$employee->update(['branch_id' => $branch->id]);
```

---

## 🚨 الحل السريع (Quick Fix)

### إذا كنت متأكد أن المشكلة في Migration:

```bash
cd C:\Users\B-SMART\Documents\GitHub\flowERP

# Run migration
php artisan migrate

# Restart server
php artisan serve
```

### إذا لم يعمل:

```bash
# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Run migration again
php artisan migrate

# Restart
php artisan serve
```

---

## 📋 Checklist للتحقق

### Backend Setup
- [ ] Migration ran successfully
- [ ] Table `attendance_sessions` exists
- [ ] Server is running
- [ ] No errors in `storage/logs/laravel.log`

### Employee Data
- [ ] Employee has branch_id set
- [ ] Employee has work_plan assigned
- [ ] Employee status is active
- [ ] Employee email matches login

### Database
- [ ] Database connection working
- [ ] All migrations up to date
- [ ] No foreign key constraints errors

---

## 💡 كيف تعرف المشكلة بالضبط

### 1. Check Laravel Log

```bash
# Windows Command
cd C:\Users\B-SMART\Documents\GitHub\flowERP
type storage\logs\laravel.log
```

**ابحث عن:**
- `SQLSTATE` - مشكلة في Database
- `Base table or view not found` - الجدول مش موجود
- `No active work plan` - مشكلة في Work Plan
- `No branch assigned` - مشكلة في Branch

### 2. Enable Debug Mode

في `.env`:
```env
APP_DEBUG=true
APP_ENV=local
```

ثم:
```bash
php artisan config:clear
php artisan serve
```

### 3. Test Endpoint Manually

```bash
# Test check-in endpoint
curl -X POST http://localhost:8000/api/v1/employee/attendance/check-in \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"latitude": 24.7136, "longitude": 46.6753}'
```

---

## 🔍 الحل الشامل (Step by Step)

### Step 1: تحقق من Migration
```bash
php artisan migrate:status | findstr attendance_sessions
```

### Step 2: Run Migration إذا لزم الأمر
```bash
php artisan migrate
```

### Step 3: تحقق من البيانات
```bash
php artisan tinker
```

```php
// Check employee
$emp = App\Models\Hrm\Employee::find(1);
echo "Has Branch: " . ($emp->branch_id ? 'Yes' : 'No') . "\n";
echo "Work Plans: " . $emp->workPlans()->count() . "\n";

// Check tables
echo "Attendance Sessions Table: " . (Schema::hasTable('attendance_sessions') ? 'Exists' : 'Missing') . "\n";
```

### Step 4: إصلاح البيانات إذا لزم الأمر
```php
// في tinker
$employee = App\Models\Hrm\Employee::find(1);

// Add branch
if (!$employee->branch_id) {
    $branch = App\Models\Hrm\Branch::first();
    $employee->update(['branch_id' => $branch->id]);
}

// Add work plan
if ($employee->workPlans()->count() == 0) {
    $workPlan = App\Models\Hrm\WorkPlan::first();
    $employee->workPlans()->attach($workPlan->id);
}
```

### Step 5: Test Again
```bash
# Restart server
php artisan serve

# Test from Flutter app
```

---

## 📞 إذا استمرت المشكلة

### أرسل لي:

1. **Laravel Log** (آخر 50 سطر):
```bash
type storage\logs\laravel.log | findstr /N "." | findstr /R "[0-9]*:.*" | findstr /V /R "^[0-9]*:$" | tail -50
```

2. **Migration Status**:
```bash
php artisan migrate:status
```

3. **Employee Data**:
```bash
php artisan tinker
```
```php
App\Models\Hrm\Employee::find(YOUR_ID)->toArray()
```

---

## ✅ بعد الحل

### تأكد من:
- [ ] Migration نجحت
- [ ] Server يعمل
- [ ] Flutter app يتصل بـ Backend
- [ ] Check-in يعمل
- [ ] No errors in log

---

**الحالة:** 🔧 Debugging Mode
**الخطوة التالية:** Run `php artisan migrate` ثم Test

**التاريخ:** 2025-11-05
