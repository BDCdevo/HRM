# 📱 حل مشكلة الاتصال بالإنترنت على الهاتف الحقيقي

**التاريخ:** 2025-11-10
**المشكلة:** التطبيق لا يعمل على الهاتف الحقيقي بسبب مشكلة اتصال بالإنترنت
**الحالة:** 🔍 جاري التشخيص

---

## ✅ **الإعدادات الحالية (صحيحة):**

```dart
// lib/core/config/api_config.dart
static const String baseUrl = baseUrlProduction;  // https://erp1.bdcbiz.com/api/v1
```

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

## 🔍 **خطوات استكشاف الأخطاء:**

### **الخطوة 1: تأكد أن الهاتف متصل بالإنترنت**

**على الهاتف:**
1. افتح Chrome أو أي متصفح
2. اذهب إلى: `https://erp1.bdcbiz.com`
3. هل الموقع يفتح؟
   - ✅ نعم → الإنترنت يعمل، المشكلة في التطبيق
   - ❌ لا → مشكلة في اتصال الهاتف بالإنترنت

---

### **الخطوة 2: اختبر الـ API مباشرة**

**على الهاتف، افتح Chrome:**
```
https://erp1.bdcbiz.com/api/v1/auth/check-user?identifier=ayafaisl@bdcbiz.com
```

**المتوقع:** رسالة JSON
```json
{
  "success": true,
  "message": "User exists",
  ...
}
```

**إذا لم تظهر:**
- ❌ مشكلة في الـ API نفسه
- ❌ أو Certificate SSL issue

---

### **الخطوة 3: تحقق من Logs التطبيق**

**وصل الهاتف بالـ USB وشغل:**
```bash
# شغل التطبيق على الهاتف
flutter run

# أو اقرأ الـ logs
adb logcat | grep -i "flutter\|dio\|error\|exception"
```

**ابحث عن:**
- `SocketException`
- `HandshakeException`
- `Connection refused`
- `Network error`

---

## 🔧 **الحلول المحتملة:**

### **الحل 1: مشكلة WiFi/Mobile Data**

**الأعراض:**
- التطبيق يقول "No Internet"
- Chrome لا يفتح المواقع

**الحل:**
```
1. Settings > WiFi/Mobile Data
2. تأكد أن الاتصال نشط
3. جرب فتح موقع في Chrome للتأكد
4. إذا كان WiFi، تأكد أنه ليس "Limited Connection"
```

---

### **الحل 2: SSL Certificate Issue**

**الأعراض:**
```
HandshakeException: CERTIFICATE_VERIFY_FAILED
```

**السبب:**
- الساعة والتاريخ على الهاتف خطأ
- أو Certificate غير موثوق

**الحل:**
```
1. Settings > Date & Time
2. تأكد أن التاريخ والوقت صحيحين
3. شغّل "Automatic date & time"
```

---

### **الحل 3: Firewall/VPN Issue**

**الأعراض:**
- الموقع يفتح في Chrome
- لكن التطبيق لا يستطيع الاتصال

**الحل:**
```
1. أغلق أي VPN نشط
2. أغلق أي Firewall apps
3. جرب على Mobile Data بدلاً من WiFi
```

---

### **الحل 4: App Permission Issue**

**على بعض الهواتف (Xiaomi, Huawei, etc.):**

```
Settings > Apps > HRM App > Permissions
├── Storage: Allow
├── Location: Allow
└── Background Data: Allow  ⚠️ مهم!
```

**أيضاً:**
```
Settings > Apps > HRM App > Mobile Data
✅ Enable "Background data"
✅ Enable "Unrestricted data usage"
```

---

### **الحل 5: إضافة Network Security Config**

**إذا كانت المشكلة مستمرة، أضف هذا الملف:**

**ملف جديد:** `android/app/src/main/res/xml/network_security_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Allow cleartext (HTTP) for debugging -->
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <!-- Trust system certificates -->
            <certificates src="system" />
            <!-- Trust user-added certificates -->
            <certificates src="user" />
        </trust-anchors>
    </base-config>

    <!-- Production domain (HTTPS) -->
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">erp1.bdcbiz.com</domain>
    </domain-config>
</network-security-config>
```

**ثم عدّل:** `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="hrm"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:networkSecurityConfig="@xml/network_security_config">  <!-- أضف هذا السطر -->
```

---

## 🧪 **خطوات الاختبار:**

### **Test 1: اختبار سريع**

```bash
# 1. وصّل الهاتف بـ USB
adb devices

# 2. شغل التطبيق
flutter run

# 3. راقب الـ console logs
# ابحث عن أي errors
```

---

### **Test 2: اختبار الـ API من الهاتف مباشرة**

**استخدم Postman أو أي HTTP client على الهاتف:**
```
URL: https://erp1.bdcbiz.com/api/v1/auth/check-user
Method: GET
Query: identifier=ayafaisl@bdcbiz.com

Expected: JSON response with user data
```

---

## 📊 **جدول استكشاف الأخطاء:**

| الأعراض | السبب المحتمل | الحل |
|---------|---------------|------|
| "No Internet Connection" | WiFi/Data مغلق | شغل الإنترنت على الهاتف |
| `SocketException` | Firewall/VPN | أغلق VPN والـ Firewall |
| `HandshakeException` | SSL Certificate | ضبط التاريخ والوقت |
| `Connection timeout` | API مش شغال | تحقق من السيرفر |
| Chrome يفتح، التطبيق لا | Permissions | فعّل Background Data |

---

## 🚀 **الحل السريع (Quick Fix):**

```bash
# 1. تأكد أن الهاتف متصل
adb devices

# 2. افتح Chrome على الهاتف واذهب إلى:
https://erp1.bdcbiz.com

# 3. إذا الموقع فتح، شغل التطبيق:
flutter run

# 4. راقب الـ logs:
adb logcat | grep "DIO\|flutter\|ERROR"
```

**إذا رأيت error محدد، أرسله لي لأساعدك! 🎯**

---

## 💡 **Tips مهمة:**

### **1. Background Data (مهم جداً!):**
```
بعض الهواتف (خاصة Xiaomi، Huawei) بتمنع التطبيقات من استخدام الإنترنت في الخلفية.

الحل:
Settings > Apps > HRM > Mobile Data
✅ Enable "Background data"
```

### **2. Battery Optimization:**
```
بعض الهواتف بتوقف التطبيقات لتوفير البطارية.

الحل:
Settings > Apps > HRM > Battery
✅ Disable "Battery optimization"
```

### **3. Developer Options:**
```
إذا الـ USB Debugging مفعّل:
Developer Options > Networking
✅ Enable "Mobile data always active"
```

---

## 📝 **معلومات مطلوبة للمساعدة:**

إذا المشكلة مستمرة، أرسل:

1. **نوع الهاتف:** (Xiaomi, Samsung, etc.)
2. **Android Version:** (Settings > About Phone)
3. **Error Message من الـ console:**
```bash
flutter run
# انسخ الـ error message
```

4. **هل Chrome يفتح الموقع؟** (نعم/لا)
```
https://erp1.bdcbiz.com
```

---

## ✅ **Checklist:**

قبل ما تبلّغ عن المشكلة، تأكد من:

- [ ] الهاتف متصل بالإنترنت (WiFi أو Mobile Data نشط)
- [ ] Chrome يفتح `https://erp1.bdcbiz.com` بنجاح
- [ ] التاريخ والوقت على الهاتف صحيحين
- [ ] مفيش VPN أو Firewall شغال
- [ ] App Permissions (Background Data) مفعّلة
- [ ] USB Debugging enabled ووصلت الهاتف
- [ ] `adb devices` يعرض الهاتف

---

**أرسل الـ error message من الـ console وسأساعدك فوراً! 🚀**
