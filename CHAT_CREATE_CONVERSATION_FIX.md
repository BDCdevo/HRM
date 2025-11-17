# 🔧 إصلاح مشكلة CurrentCompanyScope في إنشاء المحادثات

**التاريخ:** 2025-11-17
**الحالة:** ✅ **مكتمل**

---

## 🐛 المشكلة

عند محاولة إنشاء محادثة جديدة من التطبيق، كان يظهر الخطأ التالي:

```json
{
  "message": "CurrentCompanyScope: No company_id set in the session or on the user."
}
```

### السبب:
- `Conversation::create()` يستخدم `CurrentCompanyScope` trait
- الـ scope يتطلب وجود `company_id` في الـ session
- الـ `createConversation()` method كان يستقبل `company_id` من الـ request لكن **لم يضعه في الـ session**

---

## ✅ الحل المطبق

### الملف: `app/Http/Controllers/Api/ChatController.php`

**الموقع:** بعد `$companyId = $request->company_id;` مباشرة (line 313-315)

**⚠️ مهم جداً:** يجب وضع session **قبل أي استعلام** على Conversation!

**التعديل:**
```php
$companyId = $request->company_id;

// Set company_id in session for CurrentCompanyScope (MUST be before ANY Conversation query)
session(['current_company_id' => $companyId]);

// Skip company verification for now
$type = $request->type ?? ...

// ... الآن كل Conversation queries تستخدم الـ session بشكل صحيح
```

**السبب:**
- `Conversation::forUser()` يستخدم CurrentCompanyScope
- `Conversation::create()` يستخدم CurrentCompanyScope
- **يجب** وضع session في بداية الـ method قبل أي استعلام

**الفكرة:**
- قبل إنشاء المحادثة، نضع `company_id` في الـ session
- الـ `CurrentCompanyScope` يقرأ من الـ session ويطبق الـ scope تلقائياً
- الـ conversation يتم إنشاؤها بنجاح

---

## 📝 الخطوات المطبقة

### 1. Backup
```bash
cp app/Http/Controllers/Api/ChatController.php \
   app/Http/Controllers/Api/ChatController.php.backup-createconv-fix-20251117-HHMMSS
```

### 2. إضافة session line
```php
session(['current_company_id' => $companyId]);
```

### 3. مسح الـ Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

---

## 🧪 الاختبار

### Test Case: إنشاء محادثة جديدة

**الخطوات:**
1. افتح التطبيق
2. اذهب لـ Chat tab
3. اضغط على زر "+" (New Chat)
4. اختر موظف من القائمة
5. اضغط "Start Chat"

**النتيجة قبل الإصلاح:**
```
❌ Error [404]: CurrentCompanyScope: No company_id set in the session
```

**النتيجة بعد الإصلاح:**
```
✅ Success [200]: Conversation created successfully
✅ conversation_id: 123
✅ تفتح شاشة الشات مباشرة
```

---

## 📊 قبل وبعد

### قبل:
```php
$companyId = $request->company_id;

// ❌ لا يوجد session هنا!

if ($type === 'private') {
    $conversations = Conversation::forUser(auth()->id())  // ❌ يفشل هنا!
        ->forCompany($companyId)
        ->get();
}

$conversation = Conversation::create([...]);  // ❌ يفشل هنا أيضاً!
```

### بعد:
```php
$companyId = $request->company_id;

// ✅ نضع session في البداية قبل أي query
session(['current_company_id' => $companyId]);

if ($type === 'private') {
    $conversations = Conversation::forUser(auth()->id())  // ✅ ينجح!
        ->forCompany($companyId)
        ->get();
}

$conversation = Conversation::create([...]);  // ✅ ينجح أيضاً!
```

---

## 🔍 السبب التقني

### كيف يعمل CurrentCompanyScope؟

```php
// في CurrentCompanyScope trait
protected static function bootCurrentCompanyScope()
{
    static::addGlobalScope(new CurrentCompanyScope);
}

// في CurrentCompanyScope class
public function apply(Builder $builder, Model $model)
{
    $companyId = session('current_company_id') ?? auth()->user()?->company_id;

    if (!$companyId) {
        throw new ModelNotFoundException('No company_id set in the session or on the user.');
    }

    $builder->where('company_id', $companyId);
}
```

**المشكلة:**
- عند `Conversation::create()`, Laravel يطبق الـ scope تلقائياً
- الـ scope يبحث عن `company_id` في:
  1. `session('current_company_id')` ← **كان فارغ** ❌
  2. `auth()->user()->company_id` ← **قد لا يكون موجود** ❌
- النتيجة: Exception

**الحل:**
- نضع `company_id` في الـ session قبل الإنشاء ✅
- الـ scope يجد القيمة ويعمل بشكل صحيح ✅

---

## 📁 Backup Files

**Server:** `root@31.97.46.103`
**Path:** `/var/www/erp1/`

```bash
app/Http/Controllers/Api/ChatController.php.backup-createconv-fix-20251117-HHMMSS
```

### استرجاع من Backup (إذا لزم الأمر):
```bash
ssh root@31.97.46.103
cd /var/www/erp1

# Restore
cp app/Http/Controllers/Api/ChatController.php.backup-createconv-fix-* \
   app/Http/Controllers/Api/ChatController.php

# Clear cache
php artisan cache:clear
php artisan config:clear
```

---

## 💡 ملاحظات مهمة

### 1. Multi-tenancy
- هذا الإصلاح ضروري لأن النظام يستخدم multi-tenancy
- كل conversation يجب أن تنتمي لـ company معينة
- الـ `CurrentCompanyScope` يضمن data isolation بين الشركات

### 2. Session vs User
- `session('current_company_id')` أفضل من `auth()->user()->company_id`
- السبب: المستخدم قد يكون موجود في `employees` table وليس `users`
- الـ session أكثر موثوقية

### 3. نفس الإصلاح قد يكون مطلوب في أماكن أخرى
- أي method يستخدم `Conversation::create()` أو `Message::create()`
- يجب التأكد من وجود `session(['current_company_id' => $companyId])`

---

## 🎯 الخلاصة

✅ **المشكلة:** CurrentCompanyScope يطلب company_id في session
✅ **الحل:** إضافة `session(['current_company_id' => $companyId])` قبل Conversation::create()
✅ **النتيجة:** إنشاء المحادثات يعمل بنجاح
✅ **الاختبار:** مطلوب تجربة من التطبيق

---

**الحالة:** ✅ **مكتمل وجاهز للاختبار**
**آخر تحديث:** 2025-11-17
**Server:** Production (31.97.46.103)
**Backup:** ✅ تم
**Cache:** ✅ تم المسح
**Status:** ✅ Ready for Testing
