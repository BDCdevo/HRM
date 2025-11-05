# 🎨 Figma Node IDs - Quick Reference

> آخر تحديث: 2025-11-02
> جميع الروابط محدثة باستخدام Node IDs الحقيقية من Figma

## 📋 Node IDs المستخدمة

| الشاشة | Node ID | الرابط المباشر |
|--------|---------|----------------|
| **🔐 Authentication** |||
| Login Screen | `439-5989` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-5989&t=1cpzGuxQnM6DuWTC-4) |
| Register Screen | `439-6162` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6162&t=1cpzGuxQnM6DuWTC-4) |
| Forgot Password | `439-6273` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6273&t=1cpzGuxQnM6DuWTC-4) |
| **🏠 Dashboard** |||
| Main Dashboard | `439-6682` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6682&t=1cpzGuxQnM6DuWTC-4) |
| **📅 Attendance** |||
| Check In/Out | `439-7193` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-7193&t=1cpzGuxQnM6DuWTC-4) |
| Attendance History | `442-6323` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-6323&t=1cpzGuxQnM6DuWTC-4) |
| **👤 Profile** |||
| Profile Screen | `442-7079` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-7079&t=1cpzGuxQnM6DuWTC-4) |
| Edit Profile | `442-7079` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-7079&t=1cpzGuxQnM6DuWTC-4) |
| Change Password | `439-6273` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6273&t=1cpzGuxQnM6DuWTC-4) |
| **📝 Requests** |||
| Requests List | `442-6323` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-6323&t=1cpzGuxQnM6DuWTC-4) |
| Create Request | `439-7193` | [Open](https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-7193&t=1cpzGuxQnM6DuWTC-4) |

## 🔗 استخدام في الكود

```dart
import 'package:hrm/core/config/figma_config.dart';

// Method 1: Get link by feature name
String loginUrl = FigmaConfig.getFeatureLink('login')!;

// Method 2: Build link using node ID
String dashboardUrl = FigmaConfig.getScreenUrl('439-6682');

// Method 3: Access all feature links
Map<String, String> allLinks = FigmaConfig.featureLinks;
```

## 📊 ملاحظات

- **Node IDs مشتركة:** بعض الشاشات تستخدم نفس الـ Node ID (مثل Profile و Edit Profile)
- **التحديثات:** إذا تم تحديث التصميم في Figma، احصل على Node ID الجديد وحدث الملفات
- **الملفات المتأثرة:**
  1. `lib/core/config/figma_config.dart`
  2. `lib/core/integrations/figma_links/figma_map.yaml`
  3. هذا الملف

## 🎯 الأولوية في التطوير

| المرحلة | الشاشة | Node ID | الحالة |
|---------|--------|---------|--------|
| **Phase 1 (MVP)** ||||
| 1 | Login Screen | 439-5989 | ✅ Approved |
| 2 | Dashboard | 439-6682 | ✅ Approved |
| 3 | Profile Screen | 442-7079 | ✅ Approved |
| **Phase 2 (Core)** ||||
| 4 | Check In/Out | 439-7193 | ✅ Approved |
| 5 | Attendance History | 442-6323 | ✅ Approved |
| **Phase 3 (Advanced)** ||||
| 6 | Requests List | 442-6323 | ✅ Approved |
| 7 | Create Request | 439-7193 | ✅ Approved |
| **Phase 4 (Extra)** ||||
| 8 | Register Screen | 439-6162 | ✅ Approved |
| 9 | Forgot Password | 439-6273 | ✅ Approved |
| 10 | Edit Profile | 442-7079 | ✅ Approved |
| 11 | Change Password | 439-6273 | ✅ Approved |

---

**💡 نصيحة:** احفظ هذا الملف كمرجع سريع عند تطوير الشاشات!
