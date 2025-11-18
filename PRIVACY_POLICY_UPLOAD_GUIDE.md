# دليل رفع سياسة الخصوصية

تم إنشاء ملف سياسة الخصوصية: `privacy_policy.html`

## الخطوات لرفع السياسة على Google Play Console:

### الطريقة 1: رفع على GitHub Pages (مجاني وسهل) ✅ الأسهل

1. **إنشاء مستودع GitHub جديد:**
   - اذهب إلى https://github.com/new
   - اسم المستودع: `hrm-privacy-policy`
   - اجعله Public
   - أنشئ المستودع

2. **رفع الملف:**
   - افتح المستودع الجديد
   - اضغط "Add file" → "Upload files"
   - ارفع ملف `privacy_policy.html`
   - سمّي الملف: `index.html` (مهم جداً!)
   - اضغط "Commit changes"

3. **تفعيل GitHub Pages:**
   - اذهب إلى Settings → Pages
   - في "Source" اختر: `main` branch
   - اضغط Save
   - انتظر دقيقة وستحصل على رابط مثل:
     `https://your-username.github.io/hrm-privacy-policy/`

4. **استخدام الرابط في Google Play Console:**
   - انسخ الرابط
   - افتح Google Play Console
   - اذهب إلى App content → Privacy Policy
   - الصق الرابط واحفظ

---

### الطريقة 2: رفع على موقعك الحالي

إذا كان لديك موقع إلكتروني (مثل bdcbiz.com):

1. ارفع ملف `privacy_policy.html` على الموقع
2. الرابط سيكون مثل: `https://bdcbiz.com/hrm-privacy-policy.html`
3. استخدم هذا الرابط في Google Play Console

---

### الطريقة 3: استخدام Google Sites (مجاني)

1. اذهب إلى https://sites.google.com/new
2. أنشئ موقع جديد
3. اسمه "HRM Privacy Policy"
4. انسخ محتوى ملف `privacy_policy.html` والصقه
5. انشر الموقع واحصل على الرابط
6. استخدم الرابط في Google Play Console

---

## معلومات سياسة الخصوصية المُنشأة:

### البيانات المجمعة:
- ✅ معلومات الحساب (اسم، بريد، قسم)
- ✅ بيانات الموقع (GPS عند الحضور/الانصراف فقط)
- ✅ التسجيلات الصوتية (للرسائل الصوتية فقط)
- ✅ بيانات الحضور والإجازات
- ✅ رسائل الدردشة والملفات

### الأذونات المشروحة:
- ✅ RECORD_AUDIO - للرسائل الصوتية
- ✅ ACCESS_FINE_LOCATION - لتسجيل الحضور
- ✅ INTERNET - للاتصال بالخادم
- ✅ CAMERA - لالتقاط الصور
- ✅ STORAGE - لحفظ الملفات

### النقاط المهمة:
- ✅ لا نبيع البيانات لطرف ثالث
- ✅ البيانات محمية بـ SSL/HTTPS
- ✅ الموقع والميكروفون يُستخدمان فقط عند الحاجة
- ✅ للموظفين البالغين فقط (+18)
- ✅ حقوق المستخدم في الوصول والحذف

---

## الخطوات التالية في Google Play Console:

1. **رفع AAB الجديد (version 1.1.0+3)**
   - ✅ تم البناء بنجاح

2. **إضافة سياسة الخصوصية**
   - App content → Privacy Policy
   - أضف رابط السياسة (بعد رفعها بإحدى الطرق أعلاه)

3. **إكمال استبيان أمان البيانات (Data Safety)**
   - App content → Data Safety
   - أجب على الأسئلة بناءً على المعلومات في سياسة الخصوصية:
     - نعم، نجمع بيانات الموقع (للحضور)
     - نعم، نجمع التسجيلات الصوتية (للدردشة)
     - نعم، نجمع معلومات شخصية (اسم، بريد)
     - لا، لا نشارك البيانات مع طرف ثالث
     - البيانات مشفرة أثناء النقل

4. **مراجعة المحتوى**
   - تأكد من إكمال جميع الأقسام المطلوبة
   - Content rating
   - Target audience
   - App category

5. **إرسال للمراجعة**
   - بعد إكمال كل المتطلبات، اضغط "Submit for review"

---

## ملاحظات هامة:

⚠️ **تأكد من أن الرابط يعمل قبل إرساله لـ Google Play:**
- افتح الرابط في المتصفح
- تأكد من ظهور السياسة كاملة
- الرابط يجب أن يبدأ بـ https:// (وليس http://)

⚠️ **Google Play تتحقق من السياسة:**
- يجب أن تكون السياسة متاحة دائماً
- لا تحذف الملف بعد الموافقة على التطبيق
- يجب تحديث السياسة عند إضافة أذونات جديدة

⚠️ **وقت المراجعة:**
- قد تستغرق مراجعة Google من يوم إلى 7 أيام
- تأكد من الرد على أي استفسارات من فريق المراجعة

---

## مثال على الإجابات في Data Safety:

### Does your app collect or share any of the required user data types?
✅ Yes

### Data types collected:
- **Location** → Approximate location, Precise location
  - Why: "For attendance check-in/check-out verification"
  - Collected: Yes, Shared: No, Encrypted: Yes, Can be deleted: Yes

- **Audio** → Voice or sound recordings
  - Why: "For chat voice messages"
  - Collected: Yes, Shared: No, Encrypted: Yes, Can be deleted: Yes

- **Personal info** → Name, Email address
  - Why: "For account functionality and communication"
  - Collected: Yes, Shared: No, Encrypted: Yes, Can be deleted: Yes

- **Photos and videos** → Photos
  - Why: "For chat image messages"
  - Collected: Yes, Shared: No, Encrypted: Yes, Can be deleted: Yes

- **Files and docs** → Files and docs
  - Why: "For chat file attachments"
  - Collected: Yes, Shared: No, Encrypted: Yes, Can be deleted: Yes

- **Messages** → Emails, SMS or MMS, Other in-app messages
  - Why: "For employee communication"
  - Collected: Yes, Shared: No, Encrypted: Yes, Can be deleted: Yes

### Is all of the user data collected by your app encrypted in transit?
✅ Yes (HTTPS/SSL)

### Do you provide a way for users to request that their data is deleted?
✅ Yes (Contact HR or delete account in app settings)

---

## جاهز للرفع! 🚀

الملفات الجاهزة:
- ✅ `app-release.aab` (version 1.1.0+3)
- ✅ `privacy_policy.html`

الخطوة التالية:
1. ارفع `privacy_policy.html` على GitHub Pages أو موقعك
2. احصل على الرابط
3. أدخل الرابط في Google Play Console
4. ارفع AAB الجديد
5. أكمل Data Safety
6. أرسل للمراجعة

حظاً موفقاً! 🎉
