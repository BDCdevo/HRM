# Profile Image Cache Fix

## التاريخ
23 نوفمبر 2025

## المشكلة
بعد تحديث الصورة الشخصية من الويب أو من التطبيق، الصورة القديمة لسه موجودة ومش بتتحدث.

## السبب
`Image.network` في Flutter بيعمل **cache** للصور عشان يحسّن الأداء. لما بنحدّث الصورة على السيرفر، Flutter بيعرض الصورة القديمة من الـ cache بدل ما يحمّل الصورة الجديدة.

## الحل

### استخدام Cache Buster
أضفنا **timestamp** للـ URL عشان نجبر Flutter يحمّل الصورة الجديدة كل مرة:

```dart
// قبل التعديل ❌
Image.network(
  profile.image.url,  // مثال: https://erp1.bdcbiz.com/storage/media/employee_30.jpg
  fit: BoxFit.cover,
)

// بعد التعديل ✅
Image.network(
  '${profile.image.url}?v=${DateTime.now().millisecondsSinceEpoch}',
  // مثال: https://erp1.bdcbiz.com/storage/media/employee_30.jpg?v=1732383742000
  fit: BoxFit.cover,
)
```

### كيف يعمل؟
- الـ `?v=` بيضيف query parameter للـ URL
- الـ `DateTime.now().millisecondsSinceEpoch` بيعطي رقم فريد (timestamp) كل مرة
- لما الـ URL يتغير، Flutter بيعتبرها صورة جديدة ويحمّلها من السيرفر

## الملفات المعدلة

### 1. Edit Profile Screen
**الملف**: `lib/features/profile/ui/screens/edit_profile_screen.dart`

**السطر**: ~325

```dart
child: _profileImageUrl != null
    ? Image.network(
        // Add timestamp to bypass cache
        '$_profileImageUrl?v=${DateTime.now().millisecondsSinceEpoch}',
        fit: BoxFit.cover,
        // ... rest of code
      )
```

### 2. More Main Screen
**الملف**: `lib/features/more/ui/screens/more_main_screen.dart`

**السطر**: ~150

```dart
child: profile?.hasImage == true
    ? Image.network(
        // Add timestamp to bypass cache
        '${profile!.image!.url}?v=${DateTime.now().millisecondsSinceEpoch}',
        fit: BoxFit.cover,
        // ... rest of code
      )
```

## النتيجة

### قبل الحل ❌
```
1. المستخدم يرفع صورة جديدة
2. الصورة تتحفظ على السيرفر بنجاح
3. التطبيق يعرض الصورة القديمة من Cache
4. المستخدم يشوف الصورة القديمة ❌
```

### بعد الحل ✅
```
1. المستخدم يرفع صورة جديدة
2. الصورة تتحفظ على السيرفر بنجاح
3. التطبيق يحمّل الصورة الجديدة من السيرفر
4. المستخدم يشوف الصورة الجديدة فوراً ✅
```

## بدائل أخرى (لم نستخدمها)

### 1. CachedNetworkImage مع cacheKey
```dart
CachedNetworkImage(
  imageUrl: profile.image.url,
  cacheKey: '${profile.image.url}_${DateTime.now().millisecondsSinceEpoch}',
  fit: BoxFit.cover,
)
```

**لماذا لم نستخدمه؟**
- يحتاج إضافة package جديد (`cached_network_image`)
- أثقل من الحل البسيط
- Cache buster كافي للحل

### 2. clearCache قبل تحميل الصورة
```dart
PaintingBinding.instance.imageCache.clear();
Image.network(profile.image.url);
```

**لماذا لم نستخدمه؟**
- يمسح **كل** الصور من الـ cache (مش فقط صورة الملف الشخصي)
- يأثر على الأداء
- مش عملي

### 3. NetworkImage مع headers
```dart
Image(
  image: NetworkImage(
    profile.image.url,
    headers: {'Cache-Control': 'no-cache'},
  ),
)
```

**لماذا لم نستخدمه؟**
- بعض السيرفرات مش بتحترم الـ headers
- Cache buster أضمن

## الاختبار

### خطوات الاختبار:

1. **افتح التطبيق**
   ```bash
   flutter run
   ```

2. **سجل دخول**
   - استخدم أي حساب موظف

3. **اذهب إلى More Tab**
   - شوف الصورة الحالية

4. **اضغط Edit Profile**
   - شوف نفس الصورة

5. **ارفع صورة جديدة**
   - اضغط على أيقونة الكاميرا
   - اختر صورة من المعرض أو التقط صورة جديدة
   - انتظر رسالة النجاح

6. **تحقق من التحديث**
   - الصورة الجديدة يجب أن تظهر **فوراً** في Edit Profile
   - ارجع لـ More Screen
   - الصورة الجديدة يجب أن تظهر هناك كمان ✅

### النتيجة المتوقعة:
✅ الصورة الجديدة تظهر فوراً بدون الحاجة لإغلاق التطبيق
✅ الصورة تتحدث في كل الصفحات (Edit Profile, More Screen, إلخ)
✅ لا توجد صور قديمة محفوظة في الـ cache

## ملاحظات مهمة

### 1. Performance
- إضافة timestamp للـ URL **لا يؤثر** على الأداء بشكل ملحوظ
- الصورة بتتحمل بس عند فتح الصفحة
- ليس هناك تحميل مستمر

### 2. Network Usage
- الصورة بتتحمل من السيرفر كل مرة تفتح الصفحة
- لو عايز تقلل استهلاك الإنترنت، استخدم `CachedNetworkImage` مع manual cache management

### 3. صلاحية الحل
- الحل ده شغال مع أي نوع صور (PNG, JPG, WebP, إلخ)
- الحل ده شغال مع أي سيرفر (لا يحتاج server-side changes)

## الخلاصة

✅ **تم بنجاح**:
- حل مشكلة عرض الصورة القديمة
- إضافة cache buster للصور في Edit Profile Screen
- إضافة cache buster للصور في More Main Screen
- تحديث فوري للصور بعد الرفع

⏭️ **التالي** (اختياري):
- إذا أردت تحسين الأداء أكثر، استخدم `CachedNetworkImage` مع custom cache manager
- إضافة placeholder أثناء تحميل الصور
- إضافة error placeholder في حالة فشل التحميل
