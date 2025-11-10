# تقرير اختبار نظام HRM
**التاريخ**: 2025-11-10
**الحالة**: ✅ جاهز للاختبار الشامل

---

## ✅ ما تم إنجازه على Backend

### 1. إنشاء نظام Branches

#### الملفات المُنشأة/المُعدلة:
- `/var/www/erp1/app/Filament/Hrm/Resources/BranchResource.php` ✅
- `/var/www/erp1/app/Models/Hrm/Branch.php` ✅
- Database Schema: `branches` table ✅

#### Features:
```php
// Branch Model Fields
- id
- company_id (Multi-tenancy)
- name
- address
- phone
- status (active/inactive)
- latitude (GPS)
- longitude (GPS)
- radius_meters (Geofencing: default 100m)
```

#### Relations:
```
Branch
├── belongsTo → Company
├── hasMany → Employee
└── hasMany → WorkPlan
```

### 2. ربط Work Plans بـ Branches

#### التحديثات:
```sql
-- إضافة branch_id لجدول work_plans
ALTER TABLE work_plans
ADD COLUMN branch_id BIGINT UNSIGNED NULL AFTER company_id;
```

#### Models المُحدثة:
- `/var/www/erp1/app/Models/WorkPlan.php` ✅
- `/var/www/erp1/app/Models/Hrm/WorkPlan.php` ✅

#### العلاقات:
```php
// WorkPlan Model
public function branch(): BelongsTo
{
    return $this->belongsTo(Branch::class);
}
```

### 3. تعيين Branches للموظفين

#### البيانات الحالية (Company 6 - BDC):

| Item | Count | Status |
|------|-------|--------|
| **إجمالي الموظفين** | 29 | ✅ |
| **Branches** | 2 | ✅ |
| **Work Plans** | 5 | ✅ |
| **موظفين بـ Branch** | 29 | ✅ |
| **موظفين بـ Work Plan** | 29 | ✅ |

#### Branches:
```sql
1. BDC Main Office (ID: 1)
   - 29 employees assigned

2. BDC Branch 2 (Test) (ID: 2)
   - For testing purposes
```

#### Work Plans:
```
All 5 work plans linked to branches:
1. Standard Work Hours (08:00-17:00)
2. Morning Shift (06:00-14:00)
3. Evening Shift (14:00-22:00)
4. Night Shift (22:00-06:00)
5. Flexible Hours (08:00-23:00) ← 29 موظفين مرتبطين
```

### 4. البنية الكاملة للعلاقات

```
Employee
├── belongsTo → Company (Multi-tenancy)
├── belongsTo → Branch ✅ NEW
├── belongsTo → Department
├── belongsToMany → WorkPlan ✅ UPDATED
└── hasMany → Attendance

Branch
├── belongsTo → Company (Multi-tenancy)
├── hasMany → Employee ✅
├── hasMany → WorkPlan ✅
└── GPS: (latitude, longitude, radius_meters)

WorkPlan
├── belongsTo → Company (Multi-tenancy)
├── belongsTo → Branch ✅ NEW
└── belongsToMany → Employee

Attendance
├── belongsTo → Employee
├── Multiple Sessions Support ✅
└── GPS Location Tracking ✅
```

---

## ✅ ما تم إنجازه على Mobile App

### 1. التحقق من Configuration

#### API Configuration ✅
```dart
// lib/core/config/api_config.dart
static const String baseUrl = baseUrlProduction;
// ✅ Points to: https://erp1.bdcbiz.com/api/v1
```

#### Environment:
- Production Server: `https://erp1.bdcbiz.com` ✅
- SSL Certificate: Valid (Let's Encrypt) ✅
- Database: MySQL (erp1) ✅

### 2. Models Review

#### Checked Models:
- `attendance_model.dart` ✅ - Supports late_reason & late_minutes
- `attendance_session_model.dart` ✅ - Multiple sessions support
- `user_model.dart` ⚠️ - NO branch_id field (may need update)

### 3. App Launch ✅

**Status**: التطبيق يعمل على Android Emulator

```
✅ App built successfully
✅ Installed on emulator (sdk gphone64 x86 64)
✅ User logged in (من session سابقة)
✅ Location services initialized
```

---

## 🧪 خطة الاختبار المطلوبة

### Phase 1: اختبار Authentication

#### Test 1.1: تسجيل دخول موظف
**بيانات الاختبار**:
```
Email: Ahmed@bdcbiz.com
Password: password
Company: 6 (BDC)
Branch: BDC Main Office
Work Plan: Flexible Hours
```

**الخطوات**:
1. افتح التطبيق
2. إذا كان مسجل دخول، اضغط Logout أولاً
3. أدخل البيانات أعلاه
4. اضغط تسجيل دخول

**النتيجة المتوقعة**:
- ✅ Login successful
- ✅ Navigate to Dashboard
- ✅ Display employee name: Ahmed Abbas
- ✅ Token saved in secure storage

---

### Phase 2: اختبار Dashboard

#### Test 2.1: عرض الإحصائيات
**الخطوات**:
1. افتح Dashboard
2. تحقق من Cards المعروضة

**النتيجة المتوقعة**:
```
Dashboard يجب أن يعرض:
- ✅ Today Attendance Stats
- ✅ Check-in Card
- ✅ Services Grid:
  - All Employees
  - Pending Leaves
  - Today Attendance
  - Reports
```

#### Test 2.2: API Connectivity
**ما يجب مراقبته في Logs**:
```
🔵 Cubit: fetchTodayStatus called
🌐 DIO: GET https://erp1.bdcbiz.com/api/v1/employee/attendance/status
✅ Cubit: Status fetched successfully
📊 Cubit: hasActiveSession = true/false
```

---

### Phase 3: اختبار Attendance - Multiple Sessions

#### Test 3.1: عرض حالة الحضور
**الخطوات**:
1. اذهب إلى Attendance Screen
2. تحقق من الحالة المعروضة

**النتيجة المتوقعة**:
```
إذا لم يسجل حضور اليوم:
- ✅ "لم تسجل حضور اليوم"
- ✅ Work Plan: Flexible Hours (08:00 - 23:00)
- ✅ زر "Check In" ظاهر

إذا سجل حضور:
- ✅ Check-in Time
- ✅ Duration (real-time)
- ✅ زر "Check Out" ظاهر
```

#### Test 3.2: Multiple Sessions Feature

**Scenario A: First Check-in**
```
1. Click "Check In" button
2. Grant location permissions
3. Verify:
   ✅ GPS location acquired
   ✅ Check-in successful
   ✅ Session #1 started
   ✅ Duration counter starts
   ✅ "Check Out" button appears
```

**Scenario B: First Check-out**
```
1. Click "Check Out" button
2. Verify:
   ✅ Check-out successful
   ✅ Session #1 completed
   ✅ Duration saved
   ✅ "Check In" button appears again
```

**Scenario C: Second Check-in (Multiple Sessions)**
```
1. Click "Check In" again (same day)
2. Verify:
   ✅ Session #2 started
   ✅ Previous session still visible
   ✅ Total duration = Session 1 + Session 2
   ✅ Sessions list shows 2 items
```

**Scenario D: Multiple Cycles**
```
Repeat: Check-in → Check-out → Check-in → Check-out

Expected:
- ✅ Unlimited sessions allowed
- ✅ Each session tracked separately
- ✅ Total duration accumulates
- ✅ hasActiveSession toggles correctly
```

#### Test 3.3: Late Check-in with Reason

**Scenario**: Check-in بعد 08:00 (Work Plan start time)

```
Given: Current time > 08:00
When: Click "Check In"
Then:
  ✅ Late Reason Bottom Sheet appears
  ✅ Enter reason: "مشكلة في المواصلات"
  ✅ Submit
  ✅ Check-in succeeds with late_reason
  ✅ late_minutes calculated
  ✅ Reason stored in database
```

#### Test 3.4: Sessions History
**الخطوات**:
1. اذهب إلى "History" tab
2. اختر اليوم الحالي

**النتيجة المتوقعة**:
```
✅ List of all sessions today
✅ Each session shows:
   - Check-in time
   - Check-out time (if completed)
   - Duration
   - Status (Active/Completed)
```

---

### Phase 4: اختبار Branch Assignment

#### Test 4.1: Employee Branch Display
**الخطوات**:
1. افتح Profile Screen
2. تحقق من البيانات

**النتيجة المتوقعة**:
```
Employee Data:
- Name: Ahmed Abbas
- Email: Ahmed@bdcbiz.com
- Department: التطوير
- Branch: BDC Main Office ⚠️ (IF IMPLEMENTED)
```

**⚠️ ملاحظة**:
- UserModel لا يحتوي حالياً على branch field
- قد نحتاج تحديث Model إذا كان البيان ضرورياً

#### Test 4.2: Branch Geofencing

**Scenario**: Check-in من خارج Branch radius

```
Given:
  - Branch GPS: (lat, lng)
  - Branch Radius: 100m
  - Employee GPS: Outside 100m radius

When: Click "Check In"

Expected (IF IMPLEMENTED):
  ❌ Error: "You are outside the branch area"
  OR
  ⚠️ Warning: "You are far from branch location"
```

**⚠️ TODO**: تأكد من أن Backend يطبق Geofencing validation

---

### Phase 5: اختبار Work Plan

#### Test 5.1: Work Plan Display
**الخطوات**:
1. اذهب إلى Attendance Screen
2. تحقق من Work Plan المعروض

**النتيجة المتوقعة**:
```
Work Plan Card:
- ✅ Name: Flexible Hours
- ✅ Schedule: 08:00 - 23:00
- ✅ Permission: 0 minutes late allowed
```

#### Test 5.2: Late Detection
**Scenario**: Check-in at 09:30 (Work Plan starts at 08:00)

```
Given: Work Plan start = 08:00
When: Check-in at 09:30
Then:
  ✅ late_minutes = 90 (1h 30m)
  ✅ Late reason requested
  ✅ "1h 30m late" displayed
```

---

## 🔧 مشاكل محتملة وحلولها

### Problem 1: No API Logs Visible

**Symptoms**:
```
- App runs but no 🌐 DIO logs
- No 🔵 Cubit logs
```

**Possible Causes**:
1. Dashboard hasn't loaded yet
2. Network error (silent fail)
3. Print statements not flushed to stdout

**Solutions**:
```bash
# Try hot reload
# In Flutter console, press: r

# Or restart app
# In Flutter console, press: R

# Check for errors in DevTools
# Open: http://127.0.0.1:9101?uri=http://127.0.0.1:60309/...
```

### Problem 2: "No branch assigned" Error

**Symptoms**:
```
❌ Error: "No branch assigned to you. Please contact HR."
```

**Cause**: Employee.branch_id = NULL

**Solution**:
```sql
-- On server database
UPDATE employees
SET branch_id = 1
WHERE company_id = 6 AND branch_id IS NULL;
```

**✅ Already Fixed**: All 29 employees assigned to Branch 1

### Problem 3: Certificate Error

**Symptoms**:
```
❌ CERTIFICATE_VERIFY_FAILED
```

**Cause**: SSL certificate validation issue

**Temporary Fix** (Testing Only):
```dart
// In DioClient, add:
(_dio.httpClientAdapter as DefaultHttpClientAdapter)
  .onHttpClientCreate = (client) {
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };
```

⚠️ **Remove in production!**

### Problem 4: Location Permission Denied

**Symptoms**:
```
❌ Error: "Location permission denied"
```

**Solution**:
```
1. Open Android Settings
2. Apps → HRM → Permissions
3. Enable "Location" → "Allow all the time" or "While using app"
4. Retry check-in
```

---

## 📊 Test Results Template

### Test Execution Checklist

#### ✅ Completed Tests
- [ ] Login with Ahmed@bdcbiz.com
- [ ] Dashboard loads with data
- [ ] API connectivity verified
- [ ] Attendance status displays
- [ ] First check-in succeeds
- [ ] First check-out succeeds
- [ ] Second check-in (multiple session) succeeds
- [ ] Second check-out succeeds
- [ ] Sessions list shows all sessions
- [ ] Total duration calculates correctly
- [ ] Late check-in triggers reason request
- [ ] Late reason saves to database
- [ ] Sessions history displays
- [ ] Profile shows correct data
- [ ] Work plan displays correctly
- [ ] Logout works

#### ❌ Failed Tests
```
Test Name: _______________
Error: ___________________
Screenshot: ______________
Logs: ____________________
```

---

## 🎯 Next Steps

### Immediate (اليوم):
1. ✅ اختبار Login والـ Dashboard
2. ✅ اختبار Multiple Sessions (كامل)
3. ✅ اختبار Late Reason feature
4. ✅ التقاط Screenshots للوثائق

### Short-term (هذا الأسبوع):
1. ⏳ تحديث UserModel لإضافة branch field
2. ⏳ تطبيق Geofencing validation
3. ⏳ اختبار على أجهزة متعددة
4. ⏳ بناء APK للـ Production

### Medium-term (الأسبوع القادم):
1. ⏳ User Acceptance Testing (UAT)
2. ⏳ جمع Feedback من المستخدمين
3. ⏳ إصلاح Bugs المكتشفة
4. ⏳ Performance optimization

---

## 📱 بيانات الاختبار

### Test Users

#### موظف عادي:
```
Email: Ahmed@bdcbiz.com
Password: password
Company: BDC (ID: 6)
Department: التطوير
Position: Employee
Branch: BDC Main Office (ID: 1)
Work Plan: Flexible Hours (ID: 5)
```

#### مطلوب إنشاء:
- [ ] Admin user
- [ ] Manager user
- [ ] موظف بدون branch (لاختبار validation)
- [ ] موظف في Branch 2

---

## 🔗 Resources

### Documentation:
- `PRODUCTION_SWITCH_README.md` - Production server setup
- `PRODUCTION_TESTING_GUIDE.md` - Complete testing guide
- `ATTENDANCE_FEATURE_DOCUMENTATION.md` - Multiple sessions docs
- `CLAUDE.md` - Development guidelines

### API Documentation:
- Base URL: `https://erp1.bdcbiz.com/api/v1`
- Auth: Bearer token (Sanctum)
- Endpoints: See `API_DOCUMENTATION.md`

### Backend:
- Location: `/var/www/erp1`
- Filament Admin: `https://erp1.bdcbiz.com/hrm/6`
- Database: `erp1` on MySQL

### Mobile App:
- Location: `C:\Users\B-SMART\AndroidStudioProjects\hrm`
- Config: `lib/core/config/api_config.dart`
- Current Build: Debug (Android Emulator)

---

## 📞 Support

### إذا واجهت مشكلة:

1. **تحقق من Logs**:
   ```bash
   # في Flutter console
   # Look for: 🌐 DIO, 🔵 Cubit, ❌ Error
   ```

2. **راجع التوثيق**:
   - `PRODUCTION_TESTING_GUIDE.md` - Troubleshooting section
   - `ATTENDANCE_FEATURE_DOCUMENTATION.md` - Technical details

3. **افحص Backend**:
   ```bash
   ssh root@31.97.46.103
   cd /var/www/erp1
   tail -f storage/logs/laravel.log
   ```

4. **استشر Claude Code**:
   - Share screenshots
   - Copy error logs
   - Describe expected vs actual behavior

---

## ✅ Summary

### Backend Status: 🟢 READY
- ✅ Branches created and configured
- ✅ Work plans linked to branches
- ✅ All employees assigned
- ✅ Multiple sessions support active
- ✅ GPS tracking enabled

### Mobile App Status: 🟡 TESTING
- ✅ App running on emulator
- ✅ Production server configured
- ✅ User logged in
- ⏳ Dashboard testing needed
- ⏳ Attendance flow testing needed

### Overall: 🟢 Ready for Testing
**جميع البنية التحتية جاهزة للاختبار الشامل**

---

**تم بواسطة**: Claude Code
**التاريخ**: 2025-11-10
**الوقت**: 11:45 UTC
