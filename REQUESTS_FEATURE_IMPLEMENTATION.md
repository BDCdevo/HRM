# 📋 Requests Feature Implementation

**Date:** 2025-11-23
**Version:** 1.0.0
**Status:** ✅ Completed (Phase 1)

---

## 📊 Overview

تم تنفيذ ميزة **الطلبات (Requests)** كشاشة مركزية لعرض جميع أنواع الطلبات المتاحة في النظام. حالياً يتم دعم 5 أنواع من الطلبات في الباك إند، منها 2 نوع مفعّل في التطبيق والباقي قيد التطوير.

---

## 🎯 Request Types (أنواع الطلبات)

### ✅ المُفعّلة حالياً

1. **طلب إجازة (Vacation Request)**
   - النوع: `vacation`
   - الحالة: **مُفعّل**
   - التنقل: يفتح شاشة `LeavesMainScreen`
   - الحقول: start_date, end_date, total_days, reason
   - الأيقونة: `Icons.event_busy`
   - اللون: `AppColors.accent` (برتقالي)

2. **طلب حضور (Attendance Request)**
   - النوع: `attendance`
   - الحالة: **مُفعّل**
   - التنقل: يفتح شاشة `AttendanceMainScreen`
   - الحقول: request_date, hours, start_time, end_time, reason
   - الأيقونة: `Icons.access_time`
   - اللون: `AppColors.info` (أزرق)
   - الاستخدام: تعديل أو تبرير الحضور

### 🔜 قيد التطوير

3. **طلب شهادة (Certificate Request)**
   - النوع: `certificate`
   - الحالة: **قريباً**
   - الحقول المتاحة في الباك إند:
     - `certificate_type` - نوع الشهادة (راتب، خبرة، إلخ)
     - `certificate_purpose` - الغرض من الشهادة
     - `certificate_language` - اللغة (عربي/إنجليزي)
     - `certificate_copies` - عدد النسخ
     - `certificate_delivery_method` - طريقة الاستلام
     - `certificate_needed_date` - تاريخ الحاجة
   - الأيقونة: `Icons.description`
   - اللون: `AppColors.success` (أخضر)

4. **طلب تدريب (Training Request)**
   - النوع: `training`
   - الحالة: **قريباً**
   - الحقول المتاحة في الباك إند:
     - `training_type` - نوع التدريب
     - `training_name` - اسم الدورة
     - `training_provider` - الجهة المقدمة
     - `training_location` - المكان
     - `training_start_date` - تاريخ البدء
     - `training_end_date` - تاريخ الانتهاء
     - `training_cost` - التكلفة
     - `training_cost_coverage` - تغطية التكلفة
     - `training_justification` - المبرر
     - `training_expected_benefit` - الفائدة المتوقعة
   - الأيقونة: `Icons.school`
   - اللون: `AppColors.warning` (برتقالي/أصفر)

5. **طلب عام (General Request)**
   - النوع: `general`
   - الحالة: **قريباً**
   - الحقول المتاحة في الباك إند:
     - `general_category` - الفئة
     - `general_subject` - الموضوع
     - `general_description` - الوصف
     - `general_priority` - الأولوية (عالي/متوسط/منخفض)
   - الأيقونة: `Icons.article`
   - اللون: `AppColors.primary` (كحلي)

---

## 🏗️ Architecture

### File Structure

```
lib/features/requests/
└── ui/
    └── screens/
        └── requests_main_screen.dart
```

### Screen Components

#### RequestsMainScreen
- **الموقع**: `lib/features/requests/ui/screens/requests_main_screen.dart`
- **الوصف**: شاشة رئيسية تعرض جميع أنواع الطلبات في Grid Layout
- **التصميم**: 2 أعمدة (Grid 2x3)
- **المميزات**:
  - دعم الوضع الداكن (Dark Mode)
  - رسوم متحركة عند الضغط (Scale Animation)
  - حالات مختلفة (Active/Inactive)
  - Dialog للمميزات القادمة

#### _RequestTypeCard Widget
- بطاقة قابلة للضغط لكل نوع طلب
- تحتوي على:
  - أيقونة ملونة
  - عنوان
  - وصف
  - بادج "قريباً" للمميزات غير المفعلة
- رسوم متحركة: Scale effect عند الضغط

---

## 🔗 Navigation & Routing

### Routes Added

```dart
// في lib/core/routing/app_router.dart
static const String requests = '/requests';

case requests:
  return _buildRoute(
    const RequestsMainScreen(),
    settings: settings,
    transition: RouteTransitionType.slideFromRight,
  );
```

### Entry Points

تم إضافة نقاط دخول للشاشة في 4 أماكن:

1. **Bottom Navigation Bar** ⭐ **رئيسي**
   - الموقع: `lib/core/navigation/main_navigation_screen.dart`
   - استبدل تاب "Leaves" بـ "Requests"
   - الأيقونة: نفس أيقونة Leaves (`assets/svgs/leaves_icon.svg`)
   - الموقع: التاب الثالث في Navigation Bar

2. **Services Grid (Dashboard)**
   - الموقع: `lib/features/dashboard/ui/widgets/services_grid_widget.dart`
   - البطاقة: "Requests" (استبدلت "Claims")
   - الأيقونة: `Icons.assignment`

3. **More Screen**
   - الموقع: `lib/features/more/ui/screens/more_main_screen.dart`
   - القسم: "Requests" (قسم جديد قبل Reports)
   - العنوان: "الطلبات"
   - الوصف: "تقديم وإدارة الطلبات المختلفة"

4. **Direct Route**
   - يمكن التنقل مباشرة عبر:
   ```dart
   Navigator.pushNamed(context, AppRouter.requests);
   ```

---

## 🎨 UI/UX Design

### Color Scheme

```dart
// Active Cards
Vacation:    AppColors.accent   (#EF8354 - برتقالي)
Attendance:  AppColors.info     (#3B82F6 - أزرق)
Certificate: AppColors.success  (#10B981 - أخضر)
Training:    AppColors.warning  (#F59E0B - برتقالي/أصفر)
General:     AppColors.primary  (#2D3142 - كحلي)
```

### Dark Mode Support
- كامل الدعم للوضع الداكن
- الألوان تتكيف تلقائياً
- Background: `AppColors.darkBackground`
- Cards: `AppColors.darkCard`
- Text: `AppColors.darkTextPrimary/Secondary`

### Responsive Design
- Grid Layout: 2 أعمدة
- childAspectRatio: 0.85
- Spacing: 16px بين البطاقات
- Padding: 20px للشاشة

---

## 📡 Backend Integration

### Database Schema

```sql
-- جدول الطلبات
requests (
  id,
  employee_id,
  request_type ENUM('vacation', 'attendance', 'certificate', 'training', 'general'),
  status ENUM('pending', 'approved', 'rejected'),
  reason TEXT,
  admin_notes TEXT,

  -- Vacation fields
  start_date DATE,
  end_date DATE,
  total_days INT,

  -- Attendance fields
  request_date DATE,
  hours DECIMAL,
  start_time TIME,
  end_time TIME,

  -- Certificate fields
  certificate_type VARCHAR,
  certificate_purpose TEXT,
  certificate_language VARCHAR,
  certificate_copies INT,
  certificate_delivery_method VARCHAR,
  certificate_needed_date DATE,

  -- Training fields
  training_type VARCHAR,
  training_name VARCHAR,
  training_provider VARCHAR,
  training_location VARCHAR,
  training_start_date DATE,
  training_end_date DATE,
  training_cost DECIMAL,
  training_cost_coverage VARCHAR,
  training_justification TEXT,
  training_expected_benefit TEXT,

  -- General fields
  general_category VARCHAR,
  general_subject VARCHAR,
  general_description TEXT,
  general_priority VARCHAR DEFAULT 'medium',

  -- Common fields
  approved_by INT,
  approved_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### API Endpoints

```dart
// Existing endpoints
GET  /api/v1/requests             // Get all requests
GET  /api/v1/requests/statistics  // Get statistics
GET  /api/v1/requests/holidays    // Get holidays

// Query parameters
?status=pending|approved|rejected
?type=vacation|attendance|certificate|training|general
```

### Response Format

```json
{
  "success": true,
  "message": "Requests retrieved successfully",
  "data": [
    {
      "id": 1,
      "employee_id": 123,
      "request_type": "vacation",
      "status": "pending",
      "reason": "...",
      "start_date": "2025-11-25",
      "end_date": "2025-11-30",
      "total_days": 5,
      "created_at": "2025-11-23 10:00:00"
    }
  ]
}
```

---

## 🚀 Next Steps (المراحل القادمة)

### Phase 2: Certificate Requests
- [ ] Create `CertificateRequestScreen`
- [ ] Add form with certificate type selection
- [ ] Implement certificate request submission
- [ ] Add certificate request history
- [ ] Update backend API integration

### Phase 3: Training Requests
- [ ] Create `TrainingRequestScreen`
- [ ] Add training course form
- [ ] Implement cost coverage options
- [ ] Add justification and benefit fields
- [ ] Update backend API integration

### Phase 4: General Requests
- [ ] Create `GeneralRequestScreen`
- [ ] Add category and priority selection
- [ ] Implement flexible description field
- [ ] Update backend API integration

### Phase 5: Requests Management
- [ ] Create unified requests history screen
- [ ] Add filtering by type and status
- [ ] Implement request status tracking
- [ ] Add notifications for status changes
- [ ] Create admin approval workflow

---

## 📝 Testing Checklist

### ✅ Completed Tests

- [x] Navigate to Requests screen from Dashboard
- [x] Navigate to Requests screen from More tab
- [x] Click on Vacation Request → Opens Leaves screen
- [x] Click on Attendance Request → Opens Attendance screen
- [x] Click on Certificate Request → Shows "Coming Soon" dialog
- [x] Click on Training Request → Shows "Coming Soon" dialog
- [x] Click on General Request → Shows "Coming Soon" dialog
- [x] Test Dark Mode compatibility
- [x] Test Scale animation on card press
- [x] Verify all icons and colors display correctly

### 🔜 Pending Tests

- [ ] Test navigation from direct route
- [ ] Test on real device
- [ ] Test RTL layout (Arabic)
- [ ] Performance test with slow devices
- [ ] Accessibility test

---

## 🔧 Technical Notes

### Dependencies
لا توجد dependencies جديدة - تم استخدام المكتبات الموجودة فقط.

### Code Quality
- ✅ No analysis errors
- ✅ Follows clean architecture pattern
- ✅ Uses existing app theme and colors
- ✅ Consistent with app design language
- ✅ Proper widget naming conventions

### Performance
- Lightweight implementation
- Minimal widget rebuilds
- Efficient navigation
- No network calls on initial load

---

## 📚 Related Documentation

- **API Documentation**: `API_DOCUMENTATION.md`
- **Theme Guide**: `lib/core/styles/THEME_GUIDE.md`
- **Navigation Guide**: `lib/core/routing/README.md`
- **Backend Migrations**: `/var/www/erp1/database/migrations/`
  - `2025_11_20_124924_update_request_type_enum_in_requests_table.php`
  - `2025_11_20_123639_add_certificate_training_general_fields_to_requests_table.php`

---

## 👥 Developer Notes

### Adding New Request Type

1. Add to enum in backend migration
2. Create new screen in `lib/features/requests/ui/screens/`
3. Add navigation case in `RequestsMainScreen`
4. Update `isActive` to `true` for the card
5. Implement form and API integration
6. Add to routing if needed
7. Test navigation flow

### Customizing Request Card

```dart
_RequestTypeCard(
  icon: Icons.your_icon,
  iconColor: AppColors.yourColor,
  label: 'عنوان الطلب',
  description: 'وصف الطلب',
  isActive: true,  // Change to true when ready
  onTap: () {
    Navigator.push(/* your screen */);
  },
),
```

---

## 🎉 Summary

تم بنجاح إنشاء شاشة مركزية للطلبات تعرض 5 أنواع من الطلبات:
- ✅ **2 نوع مفعّل**: إجازة وحضور
- 🔜 **3 أنواع قادمة**: شهادة، تدريب، عام

الشاشة جاهزة للتوسع المستقبلي وتتبع معايير التطبيق من حيث التصميم والأداء.
