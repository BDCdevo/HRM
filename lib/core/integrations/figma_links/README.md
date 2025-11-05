# 🎨 Figma Design Links

هذا المجلد يحتوي على جميع روابط تصميمات Figma للتطبيق.

## 📁 الملفات

### `figma_map.yaml`
ملف YAML يحتوي على تعريف كامل لجميع الشاشات وروابطها في Figma مع:
- رابط Figma الكامل
- Node ID لكل شاشة
- إصدار التصميم
- حالة التصميم (approved, in_progress, in_review)
- وصف الشاشة بالعربي والإنجليزي
- المسار المتوقع للملف في Flutter

### استخدام في الكود

```dart
import 'package:hrm/core/config/figma_config.dart';

// الحصول على رابط شاشة معينة
String loginUrl = FigmaConfig.getFeatureLink('login')!;

// أو باستخدام Node ID مباشرة
String customUrl = FigmaConfig.getScreenUrl('1-9');
```

## 🔗 رابط المشروع الرئيسي

**Cutframe.in Wireframe Kit**
- [فتح المشروع في Figma](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=1-9&p=f&t=1cpzGuxQnM6DuWTC-0)
- File ID: `mO0XvE4zIjUFO7xv6Tioxo`

## 📋 قائمة الشاشات المتاحة

### 🔐 Authentication
- Login Screen (node-id: 1-9)
- Register Screen (node-id: 1-10)
- Forgot Password (node-id: 1-18)

### 🏠 Dashboard
- Main Dashboard (node-id: 1-11)

### 📅 Attendance
- Check In/Out Screen (node-id: 1-12)
- Attendance History (node-id: 1-13)

### 👤 Profile
- Profile Screen (node-id: 1-14)
- Edit Profile (node-id: 1-15)
- Change Password (node-id: 1-19)

### 📝 Requests
- Requests List (node-id: 1-16)
- Create Request (node-id: 1-17)

## 🔧 كيفية إضافة شاشة جديدة

1. **في Figma:**
   - صمم الشاشة الجديدة في نفس الملف
   - حدد Frame الخاص بالشاشة
   - انقر بزر الماوس الأيمن → Copy link

2. **استخرج Node ID:**
   من الرابط المنسوخ مثل:
   ```
   https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/...?node-id=1-20
   ```
   الـ Node ID هو: `1-20`

3. **حدّث الملفات:**
   - أضف الشاشة في `figma_map.yaml`
   - أضف الرابط في `figma_config.dart`
   - حدّث هذا الملف (README.md)

## 📝 مثال على الإضافة

في `figma_map.yaml`:
```yaml
notifications_screen:
  figma_url: "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=1-20"
  node_id: "1-20"
  version: "v1.0"
  status: "in_progress"
  description: "شاشة الإشعارات - Notifications"
  flutter_path: "lib/features/notifications/ui/screens/notifications_screen.dart"
```

في `figma_config.dart`:
```dart
static const Map<String, String> featureLinks = {
  // ... existing links
  "notifications": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=1-20",
};
```

## 🎯 Best Practices

1. **حافظ على التنظيم:** قسّم الشاشات حسب الميزات (auth, profile, attendance...)
2. **حدّث الحالة:** عند البدء بتطوير شاشة، غيّر status من approved إلى in_progress
3. **الإصدارات:** زد رقم الإصدار عند تحديث التصميم (v1.0 → v1.1)
4. **التوثيق:** أضف وصفاً واضحاً بالعربي والإنجليزي لكل شاشة
5. **المسارات:** حدد المسار المتوقع للملف في Flutter

## 🔄 سير العمل (Workflow)

```
1. المصمم ينشئ/يحدث التصميم في Figma
   ↓
2. المطور يحصل على الرابط و Node ID
   ↓
3. تحديث figma_map.yaml و figma_config.dart
   ↓
4. تطوير الشاشة حسب التصميم
   ↓
5. مراجعة بصرية للتأكد من المطابقة
   ↓
6. تحديث الحالة إلى completed
```

## 📞 للمساعدة

إذا واجهت مشكلة في الروابط أو Node IDs:
1. تأكد من أن الرابط يحتوي على `?node-id=X-Y`
2. تحقق من صلاحية الوصول للملف في Figma
3. راجع الأمثلة الموجودة في `figma_map.yaml`

---

**آخر تحديث:** 2025-11-02
