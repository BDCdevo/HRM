# 🔧 Vacation Types - Multi-Tenancy Fix

## المشكلة (Problem)

عند عرض صفحة **Vacation Types** في Admin Panel كانت فارغة رغم إضافة 10 أنواع إجازات إلى قاعدة البيانات.

### السبب (Root Cause)

النظام يستخدم **Multi-Tenancy** مع `CurrentCompanyScope` الذي يفلتر البيانات تلقائياً حسب `company_id`:

```php
// App\Models\Hrm\VacationType uses CompanyOwned trait
// This adds a global scope: where('company_id', session('current_company_id'))
```

عند إدخال البيانات، لم يتم تحديد `company_id`، فظهرت القيم كـ `null`:

```sql
SELECT * FROM vacation_types;
-- Result: company_id = NULL for all 10 records
```

وبسبب `CurrentCompanyScope`، لم تظهر هذه السجلات في Admin Panel.

---

## الحل (Solution)

تم تحديث جميع سجلات `vacation_types` لتحتوي على `company_id = 6` (BDC):

```bash
# SSH to production server
ssh root@31.97.46.103

# Update all records with company_id = 6
cd /var/www/erp1
php artisan tinker --execute='DB::table("vacation_types")->whereNull("company_id")->update(["company_id" => 6]);'

# Result: ✅ Updated 10 vacation types for BDC
```

---

## التحقق (Verification)

```bash
# Check records after update
php artisan tinker --execute='
  session(["current_company_id" => 6]);
  dump(App\Models\Hrm\VacationType::all(["id", "name", "balance", "company_id"]));
'
```

**النتيجة**: جميع الـ 10 سجلات تحتوي الآن على `company_id = 6` ✅

---

## الدرس المستفاد (Lesson Learned)

### ⚠️ عند إضافة بيانات جديدة لجداول تستخدم Multi-Tenancy:

1. **تحقق من وجود `company_id` column**:
   ```bash
   php artisan tinker --execute='dump(Schema::hasColumn("table_name", "company_id"));'
   ```

2. **دائماً أضف `company_id` عند الإدخال**:
   ```php
   DB::table('vacation_types')->insert([
       'name' => 'الإجازة السنوية',
       'balance' => 21,
       'company_id' => 6,  // ⭐ مهم جداً!
       'created_at' => now(),
       'updated_at' => now()
   ]);
   ```

3. **تحقق من الـ Model**:
   ```php
   // Check if model uses CompanyOwned trait
   class VacationType extends Model
   {
       use CompanyOwned;  // ⚠️ This adds CurrentCompanyScope!
   }
   ```

---

## الأمثلة الشائعة (Common Examples)

### الجداول التي تستخدم Multi-Tenancy:

- `vacation_types` ✅
- `work_plans` ✅
- `employees` ✅
- `attendance_sessions` ✅
- `leave_requests` ✅
- `departments` ✅
- `branches` ✅

### الجداول التي لا تستخدم Multi-Tenancy:

- `companies` ❌ (الجدول الرئيسي)
- `users` ❌ (قد يكون للمستخدم عدة شركات)

---

## Script للتحديث المستقبلي (Future Updates)

إذا احتجت لإضافة أنواع إجازات جديدة:

```php
// create_vacation_type.php
<?php
require '/var/www/erp1/vendor/autoload.php';
$app = require_once '/var/www/erp1/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

$vacationType = [
    'name' => 'اسم الإجازة',
    'description' => 'الوصف',
    'balance' => 10,
    'unlock_after_months' => 0,
    'required_days_before' => 0,
    'requires_approval' => true,
    'status' => true,
    'company_id' => 6,  // ⭐ BDC Company
    'created_at' => now(),
    'updated_at' => now()
];

DB::table('vacation_types')->insert($vacationType);
echo "✅ Vacation type created successfully!\n";
```

---

## الملفات المتأثرة (Files Affected)

### Backend
- **Model**: `/var/www/erp1/app/Models/Hrm/VacationType.php`
- **Resource**: `/var/www/erp1/app/Filament/Hrm/Resources/VacationTypeResource.php`
- **Trait**: Uses `CompanyOwned` trait (adds `CurrentCompanyScope`)

### Database
- **Table**: `vacation_types`
- **Updated**: 10 records with `company_id = 6`

---

## المرجع (Reference)

- **CLAUDE.md** - Section: "Multi-Tenancy"
- **CURRENTCOMPANYSCOPE_FIX_COMPLETE.md** - Detailed fix documentation
- **VACATION_TYPES_EGYPTIAN_LAW.md** - Complete vacation types list

---

## الحالة (Status)

- ✅ **تم الإصلاح**: 11 نوفمبر 2025
- ✅ **تم التحقق**: جميع السجلات تحتوي على `company_id = 6`
- ✅ **تم تنظيف الـ Cache**: `php artisan cache:clear`
- ✅ **جاهز للاستخدام**: يمكن الآن رؤية أنواع الإجازات في Admin Panel

---

## اختبر الآن! (Test Now)

افتح Admin Panel وحدّث الصفحة:
**https://erp1.bdcbiz.com/hrm/6/vacation-types**

يجب أن ترى الآن **10 أنواع من الإجازات** 🎉
