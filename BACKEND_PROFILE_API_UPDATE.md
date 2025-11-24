# Backend Profile API Update

## التاريخ
23 نوفمبر 2025

## المشكلة
التطبيق كان بيعدل البيانات بس التعديلات **مش بتتسمع على الكنترول بانل** (Filament Admin).

## السبب
الـ **Backend API** كان:
1. ❌ `UpdateProfileRequest` مش فيه الحقول الجديدة (`phone`, `address`, `gender`, `date_of_birth`, `national_id`)
2. ❌ `ProfileResource` مش بيرجع الحقول الجديدة
3. ❌ بيستخدم `name` بس، مش `first_name` و `last_name`

## الحل

### 1. تحديث UpdateProfileRequest

**الملف**: `/var/www/erp1/app/Http/Requests/V1/User/Profile/UpdateProfileRequest.php`

**القديم**:
```php
public function rules(): array
{
    return [
        'name' => 'sometimes|string|max:255',
        'bio' => 'sometimes|string|max:1000',
        'birthdate' => 'sometimes|date',
        // ... فقط
    ];
}
```

**الجديد**:
```php
public function rules(): array
{
    return [
        // Basic Info
        'name' => 'sometimes|string|max:255',
        'first_name' => 'sometimes|string|max:100',
        'last_name' => 'sometimes|string|max:100',
        'bio' => 'sometimes|string|max:1000',
        'birthdate' => 'sometimes|date',

        // Employee Fields ✅
        'phone' => 'sometimes|string|max:15',
        'address' => 'sometimes|string|max:200',
        'gender' => 'sometimes|in:male,female',
        'date_of_birth' => 'sometimes|date',
        'national_id' => 'sometimes|string|max:50',

        // Other
        'experience_years' => 'sometimes|integer|min:0|max:100',
        'nationality_id' => 'sometimes|integer|exists:nationalities,id',
        'languages' => 'sometimes|array',
        'languages.*' => 'integer|exists:languages,id',
    ];
}
```

### 2. تحديث ProfileResource

**الملف**: `/var/www/erp1/app/Http/Resources/ProfileResource.php`

**القديم**:
```php
public function toArray(Request $request): array
{
    $profileMedia = $this->getFirstMedia('profile');

    return [
        'id' => $this->id,
        'name' => $this->name,
        'email' => $this->email,
        'bio' => $this->bio,
        // ... فقط
    ];
}
```

**الجديد**:
```php
public function toArray(Request $request): array
{
    $profileMedia = $this->getFirstMedia('profile');
    $nameParts = explode(' ', $this->name ?? '', 2);
    $firstName = $nameParts[0] ?? '';
    $lastName = $nameParts[1] ?? '';

    return [
        'id' => $this->id,
        'name' => $this->name,
        'first_name' => $firstName,         // ✅
        'last_name' => $lastName,           // ✅
        'email' => $this->email,
        'phone' => $this->phone,            // ✅
        'address' => $this->address,        // ✅
        'gender' => $this->gender,          // ✅
        'date_of_birth' => $this->date_of_birth,  // ✅
        'national_id' => $this->national_id,      // ✅
        'bio' => $this->bio,
        'birthdate' => $this->birthdate,
        'experience_years' => $this->experience_years,
        'is_verified' => (bool) $this->is_verified,
        'department' => $this->department->name ?? null,    // ✅
        'department_id' => $this->department_id,            // ✅
        'position' => $this->position->name ?? null,        // ✅
        'position_id' => $this->position_id,                // ✅
        'image' => $profileMedia ? [
            'id' => $profileMedia->id,
            'url' => $profileMedia->getUrl(),
            'path' => $profileMedia->getPath(),
            'file_name' => $profileMedia->file_name,
            'mime_type' => $profileMedia->mime_type,
        ] : null,
        'created_at' => $this->created_at?->toISOString(),
        'updated_at' => $this->updated_at?->toISOString(),
    ];
}
```

### 3. تنظيف الـ Cache

```bash
cd /var/www/erp1
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## كيف يعمل الآن

### Request من Flutter:
```json
{
  "first_name": "Bassem",
  "last_name": "Bishay",
  "phone": "0222720333",
  "address": "123 Main St, Cairo",
  "gender": "male",
  "date_of_birth": "1990-01-15",
  "national_id": "12345678901234"
}
```

### Response من Laravel:
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 56,
    "name": "Bassem Bishay",
    "first_name": "Bassem",
    "last_name": "Bishay",
    "email": "bassembishay@bdcbiz.com",
    "phone": "0222720333",
    "address": "123 Main St, Cairo",
    "gender": "male",
    "date_of_birth": "1990-01-15",
    "national_id": "12345678901234",
    "department": "التطوير",
    "department_id": 17,
    "position": "Employee",
    "position_id": 21,
    "image": {
      "id": 75,
      "url": "https://erp1.bdcbiz.com/storage/media/employee_30.jpg",
      "file_name": "employee_30.jpg"
    }
  }
}
```

### البيانات تتحفظ في جدول `employees`:
```sql
UPDATE employees
SET
  name = 'Bassem Bishay',
  phone = '0222720333',
  address = '123 Main St, Cairo',
  gender = 'male',
  date_of_birth = '1990-01-15',
  national_id = '12345678901234'
WHERE id = 56;
```

## النتيجة

### قبل التحديث ❌
```
1. المستخدم يعدل البيانات في التطبيق
2. البيانات تتبعت للـ API
3. الـ API يرفض البيانات (validation error)
4. البيانات مش بتتحفظ في Database
5. الكنترول بانل مش بيشوف التعديلات ❌
```

### بعد التحديث ✅
```
1. المستخدم يعدل البيانات في التطبيق
2. البيانات تتبعت للـ API
3. الـ API يقبل البيانات ✅
4. البيانات تتحفظ في Database ✅
5. الكنترول بانل يشوف التعديلات فوراً ✅
```

## الاختبار

### 1. من التطبيق (Flutter):

```bash
flutter run
```

1. سجل دخول بحساب موظف
2. اذهب إلى More → Edit Profile
3. عدّل أي بيانات:
   - رقم الهاتف
   - العنوان
   - الجنس
   - تاريخ الميلاد
   - الرقم القومي
4. احفظ التغييرات

### 2. من الكنترول بانل (Filament):

1. افتح المتصفح
2. اذهب إلى: `https://erp1.bdcbiz.com/admin`
3. سجل دخول كـ Admin
4. اذهب إلى: HRM → Employees → ابحث عن الموظف
5. **تحقق**: البيانات المعدلة من التطبيق موجودة ✅

### 3. من الـ API مباشرة:

```bash
curl -X GET "https://erp1.bdcbiz.com/api/v1/profile" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**النتيجة المتوقعة**: البيانات المعدلة ترجع في الـ Response ✅

## ملاحظات مهمة

### 1. التوافق مع Filament
- جدول `employees` في Database هو المصدر الوحيد للبيانات
- Filament و Flutter يقرأون/يكتبون من نفس الجدول
- **لا يوجد تعارض** بين التطبيق والكنترول بانل

### 2. الحقول للقراءة فقط
بعض الحقول **لا يمكن** تعديلها من التطبيق:
- `department` - يُعدّل فقط من الكنترول بانل
- `position` - يُعدّل فقط من الكنترول بانل
- `email` - يُعدّل فقط من الكنترول بانل (أمان)
- `employee_id` - لا يتغير أبداً

### 3. Cache
- **مهم**: بعد أي تعديل في الـ Backend، نظف الـ cache:
  ```bash
  php artisan cache:clear
  php artisan config:clear
  ```

## الخلاصة

✅ **تم بنجاح**:
1. تحديث `UpdateProfileRequest` لقبول الحقول الجديدة
2. تحديث `ProfileResource` لإرجاع الحقول الجديدة
3. إضافة `first_name` و `last_name` للتوافق
4. إضافة `department` و `position` للعرض
5. تنظيف الـ Cache

✅ **النتيجة**:
- التطبيق يعدل البيانات ✅
- البيانات تتحفظ في Database ✅
- الكنترول بانل يشوف التعديلات ✅
- **التكامل الكامل** بين Flutter و Filament ✅
