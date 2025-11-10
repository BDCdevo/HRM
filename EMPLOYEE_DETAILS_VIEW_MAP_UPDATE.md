# 🗺️ Employee Details - View on Map Feature

**التاريخ:** 2025-11-10
**الهدف:** إضافة زر "View on Map" لفتح موقع الموظف في الخريطة
**الحالة:** ✅ تم التنفيذ

---

## 📋 **المشكلة السابقة**

في Bottom Sheet تفاصيل حضور الموظف:
1. ❌ الموقع يظهر كأرقام فقط: `31.200100, 29.918700`
2. ❌ لا يوجد طريقة سهلة لفتح الموقع في الخريطة
3. ❌ لا يوجد Late Reason ظاهر (كان يعتمد على وجود البيانات من الـ API)

---

## ✅ **التحديثات المطبقة**

### **1. إضافة زر "View on Map"**

**قبل:**
```
Check-in Location
31.200100, 29.918700
```

**بعد:**
```
Check-In Location
┌─────────────────────────┐
│ 📍 31.200100, 29.918700│
│                    [📋] │ ← Copy button
└─────────────────────────┘

[🗺️ View on Map]  ← زر جديد
```

---

### **2. إضافة url_launcher Package**

**ملف:** `pubspec.yaml`

```yaml
dependencies:
  # Location Services
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  url_launcher: ^6.2.2  # ← جديد
```

---

### **3. تحسين UI للموقع**

**ملف:** `lib/features/attendance/ui/widgets/employee_attendance_details_bottom_sheet.dart`

#### **a) Location Section Design:**

```dart
Widget _buildLocationSection() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(...),  // Gradient background
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.info.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        // Title with icon
        Row([
          Icon(location_on_rounded),
          Text('Check-In Location'),
        ]),

        // Coordinates box with copy button
        Container([
          Icon(my_location_rounded),
          Text(coordinates),
          InkWell(Icons.copy_rounded),  // Copy to clipboard
        ]),

        // View on Map button
        ElevatedButton.icon(
          icon: Icons.map_rounded,
          label: 'View on Map',
          onPressed: () => _openMapLocation(...),
        ),
      ],
    ),
  );
}
```

#### **b) Open Map Function:**

```dart
Future<void> _openMapLocation(double latitude, double longitude) async {
  try {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open maps application');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open map: $e')),
    );
  }
}
```

#### **c) Copy to Clipboard:**

```dart
InkWell(
  onTap: () {
    Clipboard.setData(ClipboardData(text: employee.formattedLocation!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coordinates copied to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  },
  child: Icon(Icons.copy_rounded),
)
```

---

## 🎨 **التصميم الجديد**

### **Location Section:**

```
┌──────────────────────────────────────────┐
│  🗺️  Check-In Location                  │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ 📍 31.200100, 29.918700       [📋]│ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │       🗺️  View on Map              │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

---

## 🧪 **كيفية الاستخدام**

### **1. عرض تفاصيل الحضور:**

1. افتح **Dashboard**
2. اذهب إلى **Attendance Summary**
3. اضغط على أي موظف في القائمة
4. **Bottom Sheet يظهر بالتفاصيل**

### **2. عرض الموقع:**

في Bottom Sheet:

**a) نسخ الإحداثيات:**
- اضغط على أيقونة 📋 (Copy)
- سيتم نسخ الإحداثيات إلى Clipboard

**b) فتح الخريطة:**
- اضغط على **"View on Map"**
- سيفتح Google Maps في المتصفح/التطبيق
- الموقع سيظهر على الخريطة مباشرةً ✅

---

## 📊 **Features المضافة**

### **1. View on Map Button:**
- ✅ يفتح Google Maps مباشرةً
- ✅ يعمل على Android, iOS, Web, Desktop
- ✅ يعرض الموقع الدقيق للموظف عند Check-in

### **2. Copy Coordinates:**
- ✅ نسخ الإحداثيات بضغطة واحدة
- ✅ Snackbar confirmation message
- ✅ يمكن لصقها في أي تطبيق خرائط

### **3. Late Reason Display:**
- ✅ موجود بالفعل في الكود (Lines 67-69, 381-454)
- ⚠️ يظهر فقط إذا كان `late_reason` موجود في البيانات من الـ API
- ✅ يظهر في box مميز باللون الأصفر مع أيقونة تحذير

---

## 🔍 **Late Reason Section**

### **الكود الموجود بالفعل:**

```dart
// Line 67-69: Conditional rendering
if (employee.lateReason != null && employee.lateReason!.isNotEmpty)
  _buildLateReasonSection(),

// Lines 381-454: Build method
Widget _buildLateReasonSection() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.warning.withOpacity(0.08),
          AppColors.warning.withOpacity(0.03),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Row([
          Icon(Icons.warning_amber_rounded),
          Text('Late Reason'),
        ]),
        Container(
          child: Text(employee.lateReason!),
        ),
      ],
    ),
  );
}
```

### **متى يظهر Late Reason؟**

Late Reason سيظهر فقط عندما:
1. ✅ الموظف متأخر (status = 'late')
2. ✅ دخل سبب التأخير عند Check-in
3. ✅ الـ API يرسل `late_reason` في الـ response

### **إذا لم يظهر Late Reason:**

تحقق من:
1. **الـ API Response:**
   ```json
   {
     "employee_id": 123,
     "status": "late",
     "late_reason": "Traffic jam"  ← هذا المطلوب
   }
   ```

2. **Model Field:**
   - ✅ موجود في `EmployeeAttendanceModel` (Line 21)
   - ✅ يتم parse من JSON (Line 86)

3. **UI Logic:**
   - ✅ يظهر conditional (Lines 67-69)
   - ✅ التصميم موجود (Lines 381-454)

---

## 📝 **الملفات المعدلة**

### **1. pubspec.yaml**
- ✅ أضيف: `url_launcher: ^6.2.2`

### **2. employee_attendance_details_bottom_sheet.dart**
- ✅ Import: `url_launcher` و `flutter/services.dart`
- ✅ Method جديد: `_openMapLocation()` (Lines 602-628)
- ✅ Location Section محسّن (Lines 456-597)
- ✅ Copy to Clipboard functionality (Lines 538-564)

---

## ✅ **Summary**

### **قبل:**
```
Location:
31.200100, 29.918700
```

### **بعد:**
```
Check-In Location:
┌─────────────────────┐
│ 31.200100, 29.918700│ [📋]
└─────────────────────┘
[🗺️ View on Map]
```

### **Late Reason:**
```
✅ موجود في الكود
✅ يظهر إذا كان في الـ API response
⚠️ تأكد أن الـ API يرسل late_reason
```

---

## 🚀 **للاختبار**

1. **شغّل التطبيق:**
   ```bash
   flutter run -d emulator-5554
   ```

2. **اعمل Check-In متأخر:**
   - Login: `Ahmed@bdcbiz.com` / `password`
   - Go to Dashboard
   - Click "Check In"
   - **إذا متأخر:** أدخل Late Reason
   - Check-In مع Location

3. **افتح Attendance Summary:**
   - Click على اسمك في القائمة
   - Bottom Sheet يفتح

4. **اختبر Features:**
   - ✅ Late Reason يظهر (إذا كان موجود)
   - ✅ Location Box يظهر
   - ✅ اضغط [📋] لنسخ الإحداثيات
   - ✅ اضغط "View on Map" لفتح الخريطة

---

**التنفيذ:** ✅ مكتمل
**الاختبار:** 🧪 جاهز للاختبار
**التوثيق:** ✅ مكتمل

**التاريخ:** November 10, 2025
