# Profile Edit Enhancement - Feature Documentation

## تاريخ التحديث
**التاريخ**: 23 نوفمبر 2025
**الإصدار**: 1.1.0+10

## ملخص التحديث

تم تحديث صفحة تعديل الملف الشخصي (Edit Profile Screen) لتشمل معلومات الموظف الكاملة من قاعدة البيانات.

## التحديثات التي تمت

### 1. تحديث ProfileModel

**الملف**: `lib/features/profile/data/models/profile_model.dart`

**الحقول الجديدة المضافة**:
```dart
// Employee-specific fields
final String? phone;              // رقم الهاتف
final String? address;            // العنوان
final String? gender;             // الجنس (male/female)
final String? dateOfBirth;        // تاريخ الميلاد
final String? position;           // المنصب الوظيفي
final String? department;         // القسم
final int? departmentId;          // معرف القسم
final int? positionId;            // معرف المنصب
final String? nationalId;         // الرقم القومي
```

### 2. تحديث UpdateProfileRequestModel

**الملف**: `lib/features/profile/data/models/update_profile_request_model.dart`

**الحقول الجديدة المضافة**:
```dart
final String? phone;              // رقم الهاتف
final String? address;            // العنوان
final String? gender;             // الجنس
final String? dateOfBirth;        // تاريخ الميلاد
final String? nationalId;         // الرقم القومي
```

**ملاحظة**: القسم والمنصب للقراءة فقط ولا يمكن تعديلهما من الموظف.

### 3. تحديث Edit Profile Screen

**الملف**: `lib/features/profile/ui/screens/edit_profile_screen.dart`

#### الحقول المضافة في الواجهة

**قسم المعلومات الشخصية (Personal Information)**:
- ✅ الاسم الكامل (Full Name) - موجود سابقاً
- ✅ البريد الإلكتروني (Email) - للقراءة فقط

**قسم معلومات الاتصال (Contact Information)** - جديد:
- ✅ رقم الهاتف (Phone Number)
  - نوع الإدخال: أرقام
  - التحقق: على الأقل 10 أرقام، بحد أقصى 15 رقم
- ✅ العنوان (Address)
  - نوع الإدخال: نص متعدد الأسطر (2 سطر)
  - التحقق: بحد أقصى 200 حرف

**قسم التفاصيل الشخصية (Personal Details)** - جديد:
- ✅ الرقم القومي (National ID)
  - نوع الإدخال: نص
  - التحقق: بحد أقصى 50 حرف
- ✅ الجنس (Gender)
  - نوع الإدخال: قائمة منسدلة (Dropdown)
  - الخيارات: Male, Female
- ✅ تاريخ الميلاد (Date of Birth)
  - نوع الإدخال: Date Picker
  - النطاق: من 1950 حتى اليوم

## بيانات الموظف المستخدمة للاختبار

**Employee ID**: 56
**Company ID**: 6 (BDC)
**Name**: BassemBishay
**Email**: bassembishay@bdcbiz.com
**Phone**: 0222720333
**Department**: التطوير (ID: 17)
**Position**: Employee (ID: 21)
**Gender**: male
**Status**: Active
**Employee Code**: EMP0030

**الصورة الشخصية**:
- ✅ موجودة في `media` table
- File: employee_30.jpg
- Collection: profile
- Disk: public

## API Endpoint

**Endpoint**: `/api/v1/profile`
**Methods**:
- `GET` - للحصول على بيانات الملف الشخصي
- `PUT` - لتحديث بيانات الملف الشخصي

**Request Body Example** (PUT):
```json
{
  "first_name": "Bassem",
  "last_name": "Bishay",
  "phone": "0222720333",
  "address": "123 Main Street, Cairo",
  "national_id": "12345678901234",
  "gender": "male",
  "date_of_birth": "1990-01-15"
}
```

**Response Example** (GET):
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": 56,
    "first_name": "Bassem",
    "last_name": "Bishay",
    "email": "bassembishay@bdcbiz.com",
    "phone": "0222720333",
    "address": "123 Main Street, Cairo",
    "national_id": "12345678901234",
    "gender": "male",
    "date_of_birth": "1990-01-15",
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

## التحقق من البيانات (Validation)

### في Flutter (Client-side):

**Phone Number**:
- اختياري (Optional)
- إذا تم إدخاله: على الأقل 10 أرقام، بحد أقصى 15 رقم

**Address**:
- اختياري (Optional)
- إذا تم إدخاله: بحد أقصى 200 حرف

**National ID**:
- اختياري (Optional)
- إذا تم إدخاله: بحد أقصى 50 حرف

**Gender**:
- اختياري (Optional)
- القيم المتاحة: male, female

**Date of Birth**:
- اختياري (Optional)
- النطاق: من 1950 حتى اليوم

### في Laravel Backend:

يجب التأكد من أن الـ Backend يقبل هذه الحقول في ProfileController:

```php
public function update(Request $request)
{
    $validated = $request->validate([
        'first_name' => 'nullable|string|max:100',
        'last_name' => 'nullable|string|max:100',
        'phone' => 'nullable|string|max:15',
        'address' => 'nullable|string|max:200',
        'national_id' => 'nullable|string|max:50',
        'gender' => 'nullable|in:male,female',
        'date_of_birth' => 'nullable|date',
    ]);

    $employee = auth()->user();
    $employee->update($validated);

    return response()->json([
        'success' => true,
        'message' => 'Profile updated successfully',
        'data' => new ProfileResource($employee)
    ]);
}
```

## الميزات الإضافية

### 1. صورة الملف الشخصي
- ✅ عرض الصورة من الـ API
- ✅ رفع صورة جديدة عبر الكاميرا أو المعرض
- ✅ Loading state أثناء تحميل الصورة
- ✅ Error handling في حالة فشل التحميل

### 2. Dark Mode Support
- ✅ دعم كامل للوضع الليلي
- ✅ ألوان متناسقة مع نظام الألوان في التطبيق

### 3. User Experience
- ✅ تنظيم الحقول في أقسام واضحة
- ✅ Icons مناسبة لكل حقل
- ✅ Validation messages واضحة بالإنجليزية
- ✅ Loading states أثناء التحديث

## الخطوات التالية للاختبار

### 1. اختبار على Production

```bash
# التأكد من أن baseUrl يشير إلى Production
# في lib/core/config/api_config.dart line 26
static const String baseUrl = baseUrlProduction;
```

### 2. تسجيل الدخول

```
Email: bassembishay@bdcbiz.com
Password: [كلمة المرور الفعلية]
Company: BDC (ID: 6)
```

### 3. الانتقال إلى Edit Profile

1. افتح القائمة الجانبية (More Tab)
2. اضغط على "Profile" أو "Edit Profile"
3. سيتم تحميل البيانات تلقائياً

### 4. اختبار الحقول

- ✅ التأكد من ظهور البيانات الحالية
- ✅ تعديل رقم الهاتف
- ✅ إضافة/تعديل العنوان
- ✅ إضافة/تعديل الرقم القومي
- ✅ اختيار الجنس
- ✅ اختيار تاريخ الميلاد
- ✅ الضغط على "Save Changes"
- ✅ التأكد من ظهور رسالة النجاح
- ✅ التأكد من حفظ البيانات في قاعدة البيانات

### 5. اختبار صورة الملف الشخصي

- ✅ التأكد من ظهور الصورة الحالية
- ✅ التقاط صورة جديدة من الكاميرا
- ✅ اختيار صورة من المعرض
- ✅ التأكد من رفع الصورة بنجاح
- ✅ التأكد من ظهور الصورة الجديدة

## الملفات المعدلة

1. `lib/features/profile/data/models/profile_model.dart`
2. `lib/features/profile/data/models/update_profile_request_model.dart`
3. `lib/features/profile/ui/screens/edit_profile_screen.dart`

## الملفات التي لم تتغير

- `lib/features/profile/data/repo/profile_repo.dart` - الـ Repository يستخدم نفس الـ endpoint
- `lib/features/profile/logic/cubit/profile_cubit.dart` - لا حاجة للتغيير
- `lib/core/config/api_config.dart` - الـ endpoint موجود بالفعل

## ملاحظات مهمة

1. **القسم والمنصب للقراءة فقط**: هذه البيانات يتم عرضها فقط ولا يمكن تعديلها من الموظف
2. **الصورة الشخصية**: يتم رفعها عبر endpoint منفصل (`/profile/upload-image`)
3. **Email للقراءة فقط**: لا يمكن تغيير البريد الإلكتروني من Edit Profile
4. **جميع الحقول اختيارية**: ما عدا Name و Email
5. **Dark Mode**: جميع الحقول تدعم الوضع الليلي

## الأخطاء المحتملة وحلولها

### 1. صورة الملف الشخصي لا تظهر

**السبب**: عنوان URL غير صحيح أو الصورة غير موجودة في Storage

**الحل**:
```bash
# على السيرفر
cd /var/www/erp1
php artisan storage:link
chmod -R 775 storage
```

### 2. فشل تحديث البيانات

**السبب**: Backend لا يقبل الحقول الجديدة

**الحل**: التأكد من تحديث ProfileController في Backend

### 3. Validation Errors

**السبب**: البيانات لا تطابق قواعد التحقق

**الحل**: مراجعة رسائل الأخطاء وتصحيح البيانات المدخلة

## الخلاصة

✅ **تم بنجاح**:
1. إضافة حقول الموظف الكاملة إلى ProfileModel
2. تحديث UpdateProfileRequestModel لإرسال البيانات الجديدة
3. تحديث Edit Profile Screen بواجهة مستخدم شاملة
4. دعم Dark Mode كامل
5. Validation شامل للحقول
6. عرض وتحميل صورة الملف الشخصي

⏳ **التالي**:
1. اختبار الـ API مع Production Server
2. التأكد من حفظ البيانات بنجاح
3. اختبار جميع الحقول والـ Validation
4. اختبار رفع الصورة الشخصية
