# 🎯 Multiple Check-in/Check-out System - Implementation Guide

## 📋 المشكلة
النظام الحالي يسمح بـ **check-in واحد فقط** في اليوم، ولا يمكن للموظف:
- الخروج للغداء والعودة
- الخروج لمهمة والعودة
- تسجيل عدة فترات عمل في نفس اليوم

## ✅ الحل المُطبق

### النظام الجديد
- **جدول جديد:** `attendance_sessions` - يحفظ كل session منفصلة
- **جدول attendance:** يبقى كملخص يومي
- **السماح بعدة sessions** في نفس اليوم

### البنية الجديدة

```
┌──────────────────────────────────────────────────────────┐
│                      Daily Attendance                     │
│  (attendances table - ملخص يومي واحد)                   │
│  ┌────────────────────────────────────────────────────┐  │
│  │ ID: 1                                               │  │
│  │ Employee: Ahmed                                     │  │
│  │ Date: 2025-11-05                                   │  │
│  │ First Check-in: 09:00                              │  │
│  │ Last Check-out: 17:00                              │  │
│  │ Total Working Hours: 7.5 hours                     │  │
│  │ Late Minutes: 0                                     │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
            │
            │ has many
            ↓
┌──────────────────────────────────────────────────────────┐
│                   Attendance Sessions                     │
│  (attendance_sessions table - عدة sessions)              │
│                                                            │
│  ┌───────────────────────────────────────────────────┐   │
│  │ Session #1                                         │   │
│  │ Check-in: 09:00  →  Check-out: 12:30  (3.5h)     │   │
│  └───────────────────────────────────────────────────┘   │
│                                                            │
│  ┌───────────────────────────────────────────────────┐   │
│  │ Session #2                                         │   │
│  │ Check-in: 13:30  →  Check-out: 17:00  (3.5h)     │   │
│  └───────────────────────────────────────────────────┘   │
│                                                            │
│  ┌───────────────────────────────────────────────────┐   │
│  │ Session #3 (Active)                                │   │
│  │ Check-in: 17:30  →  Still working...              │   │
│  └───────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

---

## 🔧 التغييرات على Backend

### 1. Migration الجديدة

**File:** `database/migrations/2025_11_05_143000_create_attendance_sessions_table.php`

```php
Schema::create('attendance_sessions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('employee_id')->constrained()->cascadeOnDelete();
    $table->foreignId('attendance_id')->nullable()->constrained()->cascadeOnDelete();
    $table->foreignId('work_plan_id')->nullable()->constrained()->nullOnDelete();
    $table->date('date');
    $table->dateTime('check_in_time');
    $table->dateTime('check_out_time')->nullable();
    
    // GPS Location
    $table->decimal('check_in_latitude', 10, 8)->nullable();
    $table->decimal('check_in_longitude', 11, 8)->nullable();
    $table->decimal('check_out_latitude', 10, 8)->nullable();
    $table->decimal('check_out_longitude', 11, 8)->nullable();
    
    // Calculated fields
    $table->decimal('duration_hours', 8, 2)->default(0);
    $table->integer('duration_minutes')->default(0);
    
    $table->string('session_type')->default('regular');
    $table->text('notes')->nullable();
    $table->boolean('is_manual')->default(false);
    
    $table->timestamps();
    
    $table->index(['employee_id', 'date']);
});
```

### 2. Model الجديد

**File:** `app/Models/Hrm/AttendanceSession.php`

```php
class AttendanceSession extends Model
{
    protected $fillable = [
        'employee_id',
        'attendance_id',
        'work_plan_id',
        'date',
        'check_in_time',
        'check_out_time',
        'check_in_latitude',
        'check_in_longitude',
        'check_out_latitude',
        'check_out_longitude',
        'duration_hours',
        'duration_minutes',
        'session_type',
        'notes',
        'is_manual',
    ];

    // Relations
    public function employee(): BelongsTo
    public function attendance(): BelongsTo
    public function workPlan(): BelongsTo

    // Scopes
    public function scopeToday($query)
    public function scopeActive($query)
    public function scopeForEmployee($query, $employeeId)
}
```

### 3. Controller Updates

**File:** `app/Http/Controllers/Api/V1/Employee/AttendanceController.php`

#### Check-in (محدث)
```php
public function checkIn(Request $request)
{
    // 1. Check for active session (not checked out)
    $activeSession = AttendanceSession::where('employee_id', $employee->id)
        ->whereDate('date', today())
        ->whereNull('check_out_time')
        ->first();

    if ($activeSession) {
        return error('You have an active session. Please check out first.');
    }

    // 2. Get or create daily attendance
    $attendance = Attendance::firstOrCreate([
        'employee_id' => $employee->id,
        'date' => today(),
    ]);

    // 3. Create new session
    $session = AttendanceSession::create([
        'employee_id' => $employee->id,
        'attendance_id' => $attendance->id,
        'date' => today(),
        'check_in_time' => now(),
        // ... location, etc
    ]);

    return response with session data
}
```

#### Check-out (محدث)
```php
public function checkOut(Request $request)
{
    // 1. Find active session
    $session = AttendanceSession::where('employee_id', auth()->id())
        ->whereDate('date', today())
        ->whereNull('check_out_time')
        ->first();

    if (!$session) {
        return error('No active session found');
    }

    // 2. Update session
    $session->update([
        'check_out_time' => now(),
        // ... location, duration
    ]);

    // 3. Update daily summary
    $this->updateDailyAttendanceSummary($session->attendance);

    return response with session data
}
```

#### New: Get Sessions
```php
public function getSessions(Request $request)
{
    $sessions = AttendanceSession::where('employee_id', auth()->id())
        ->whereDate('date', $date)
        ->get();

    return [
        'sessions' => [...],
        'summary' => [
            'total_sessions' => count,
            'active_sessions' => count,
            'total_duration' => '08:30:00',
        ]
    ];
}
```

---

## 📡 API Endpoints

### ✅ Existing (Modified)

```http
POST   /api/v1/employee/attendance/check-in
POST   /api/v1/employee/attendance/check-out
GET    /api/v1/employee/attendance/status
GET    /api/v1/employee/attendance/duration
GET    /api/v1/employee/attendance/history
```

### 🆕 New Endpoint

```http
GET    /api/v1/employee/attendance/sessions
```

---

## 📊 API Request/Response Examples

### 1. Check-in (First Time Today)

**Request:**
```http
POST /api/v1/employee/attendance/check-in
Authorization: Bearer {token}

{
  "latitude": 24.7136,
  "longitude": 46.6753
}
```

**Response:**
```json
{
  "data": {
    "session_id": 1,
    "attendance_id": 1,
    "date": "2025-11-05",
    "check_in_time": "09:00:00",
    "session_number": 1,
    "late_minutes": 0,
    "late_label": "On time",
    "is_first_session": true,
    "branch": {
      "name": "Main Branch",
      "address": "Riyadh"
    },
    "work_plan": {
      "name": "Standard Hours",
      "start_time": "09:00",
      "end_time": "17:00"
    }
  },
  "message": "Checked in successfully",
  "status": 200
}
```

### 2. Check-out (First Session)

**Request:**
```http
POST /api/v1/employee/attendance/check-out
Authorization: Bearer {token}

{
  "latitude": 24.7136,
  "longitude": 46.6753
}
```

**Response:**
```json
{
  "data": {
    "session_id": 1,
    "attendance_id": 1,
    "date": "2025-11-05",
    "check_in_time": "09:00:00",
    "check_out_time": "12:30:00",
    "duration_hours": 3.5,
    "duration_label": "3h 30m",
    "session_number": 1,
    "total_sessions_today": 1
  },
  "message": "Checked out successfully",
  "status": 200
}
```

### 3. Check-in (Second Time - After Lunch)

**Request:**
```http
POST /api/v1/employee/attendance/check-in
Authorization: Bearer {token}

{
  "latitude": 24.7136,
  "longitude": 46.6753
}
```

**Response:**
```json
{
  "data": {
    "session_id": 2,
    "attendance_id": 1,
    "date": "2025-11-05",
    "check_in_time": "13:30:00",
    "session_number": 2,
    "late_minutes": 0,
    "is_first_session": false,
    "branch": { ... },
    "work_plan": { ... }
  },
  "message": "Checked in successfully"
}
```

### 4. Get All Sessions

**Request:**
```http
GET /api/v1/employee/attendance/sessions?date=2025-11-05
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "sessions": [
      {
        "id": 1,
        "date": "2025-11-05",
        "check_in_time": "09:00:00",
        "check_out_time": "12:30:00",
        "duration_hours": 3.5,
        "duration_label": "3h 30m",
        "is_active": false,
        "session_type": "regular"
      },
      {
        "id": 2,
        "date": "2025-11-05",
        "check_in_time": "13:30:00",
        "check_out_time": "17:00:00",
        "duration_hours": 3.5,
        "duration_label": "3h 30m",
        "is_active": false,
        "session_type": "regular"
      },
      {
        "id": 3,
        "date": "2025-11-05",
        "check_in_time": "17:30:00",
        "check_out_time": null,
        "duration_hours": 0,
        "duration_label": "1h 15m",
        "is_active": true,
        "session_type": "overtime"
      }
    ],
    "summary": {
      "total_sessions": 3,
      "active_sessions": 1,
      "completed_sessions": 2,
      "total_duration": "08:15:00",
      "total_hours": 8.25
    }
  },
  "status": 200
}
```

### 5. Get Status (with Multiple Sessions)

**Request:**
```http
GET /api/v1/employee/attendance/status
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "has_checked_in": true,
    "has_active_session": true,
    "date": "2025-11-05",
    "current_session": {
      "session_id": 3,
      "check_in_time": "17:30:00",
      "duration": "01:15:30"
    },
    "sessions_summary": {
      "total_sessions": 3,
      "completed_sessions": 2,
      "total_duration": "08:15:30",
      "total_hours": 8.26
    },
    "daily_summary": {
      "check_in_time": "09:00:00",
      "check_out_time": "17:00:00",
      "working_hours": 7.0,
      "working_hours_label": "7.00h",
      "late_minutes": 0,
      "late_label": "On time"
    },
    "work_plan": { ... }
  },
  "status": 200
}
```

---

## 🔄 سيناريو الاستخدام

### يوم عمل عادي مع استراحة غداء

```
09:00 → Check-in (Session #1)
12:30 → Check-out (خروج للغداء)
------
13:30 → Check-in (Session #2)  
17:00 → Check-out (نهاية الدوام)
------
Total: 7 hours (3.5h + 3.5h)
```

### يوم مع مهمة خارجية

```
09:00 → Check-in (Session #1)
11:00 → Check-out (خروج لمهمة)
------
14:00 → Check-in (Session #2)
15:00 → Check-out (مهمة أخرى)
------
15:30 → Check-in (Session #3)
17:00 → Check-out (نهاية الدوام)
------
Total: 4.5 hours (2h + 1h + 1.5h)
```

---

## 📝 خطوات التطبيق

### Backend (Laravel)

1. **Run Migration**
```bash
cd C:\Users\B-SMART\Documents\GitHub\flowERP
php artisan migrate
```

2. **Test Endpoints**
```bash
# Using Postman or cURL
POST http://localhost:8000/api/v1/employee/attendance/check-in
POST http://localhost:8000/api/v1/employee/attendance/check-out
GET  http://localhost:8000/api/v1/employee/attendance/sessions
GET  http://localhost:8000/api/v1/employee/attendance/status
```

### Frontend (Flutter) - Coming Next

1. Update Models
2. Update Repository
3. Update Cubit/Logic
4. Update UI

---

## ✅ الفوائد

### للموظف
- ✅ تسجيل عدة فترات عمل
- ✅ الخروج والعودة بحرية
- ✅ تتبع دقيق للساعات
- ✅ مرونة أكبر

### للإدارة
- ✅ تقارير أدق
- ✅ تتبع كل session
- ✅ حساب ساعات فعلية
- ✅ تحليل أنماط العمل

### للنظام
- ✅ بيانات أكثر تفصيلاً
- ✅ تقارير أفضل
- ✅ Flexibility
- ✅ Scalability

---

## 🔒 القيود والتحقق

### 1. لا يمكن Check-in مرتين بدون Check-out
```json
{
  "message": "You have an active session. Please check out first.",
  "session_id": 123,
  "check_in_time": "09:00:00"
}
```

### 2. التحقق من الموقع الجغرافي
```json
{
  "message": "You are too far from the branch location",
  "distance_meters": 500,
  "allowed_radius": 100
}
```

### 3. يجب وجود Work Plan
```json
{
  "message": "No active work plan assigned to you. Please contact HR."
}
```

---

## 📊 Database Schema

### attendance_sessions
```sql
CREATE TABLE attendance_sessions (
    id BIGINT PRIMARY KEY,
    employee_id BIGINT,
    attendance_id BIGINT,
    work_plan_id BIGINT,
    date DATE,
    check_in_time DATETIME,
    check_out_time DATETIME NULL,
    check_in_latitude DECIMAL(10,8),
    check_in_longitude DECIMAL(11,8),
    check_out_latitude DECIMAL(10,8),
    check_out_longitude DECIMAL(11,8),
    duration_hours DECIMAL(8,2),
    duration_minutes INT,
    session_type VARCHAR(255),
    notes TEXT,
    is_manual BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### attendances (unchanged)
```sql
CREATE TABLE attendances (
    id BIGINT PRIMARY KEY,
    employee_id BIGINT,
    work_plan_id BIGINT,
    date DATE,
    check_in_time TIME,      -- First session check-in
    check_out_time TIME,     -- Last session check-out
    working_hours DECIMAL,   -- Sum of all sessions
    missing_hours DECIMAL,
    late_minutes INT,        -- From first session
    notes TEXT,
    is_manual BOOLEAN,
    UNIQUE(employee_id, date)
);
```

---

## 🚀 الخطوة التالية

**الآن جاهز للاستخدام على Backend!**

سنقوم بتحديث Flutter App في الخطوة التالية:
1. إنشاء `AttendanceSessionModel`
2. تحديث `AttendanceRepository`
3. تحديث `AttendanceCubit`
4. تحديث UI لعرض Sessions

---

**تاريخ التطبيق:** 2025-11-05
**الحالة:** ✅ Backend Complete - Ready for Flutter Integration
**الملفات المضافة:**
- Migration: `2025_11_05_143000_create_attendance_sessions_table.php`
- Model: `AttendanceSession.php`
- Controller: Updated `AttendanceController.php`
- Routes: Updated `hrm_api.php`
