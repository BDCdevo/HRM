# 📚 دراسة شاملة لـ Check-In & Check-Out Workflow

**التاريخ**: 2025-11-10
**النظام**: HRM - Production (erp1.bdcbiz.com)
**الإصدار**: 2.1.1

---

## 📋 جدول المحتويات

1. [نظرة عامة](#نظرة-عامة)
2. [Database Schema](#database-schema)
3. [Check-In Workflow](#check-in-workflow)
4. [Check-Out Workflow](#check-out-workflow)
5. [Calculations & Business Logic](#calculations--business-logic)
6. [Validation Rules](#validation-rules)
7. [Multi-Session Support](#multi-session-support)
8. [API Responses](#api-responses)
9. [Error Scenarios](#error-scenarios)
10. [Flutter Integration](#flutter-integration)

---

## 🎯 نظرة عامة

### المفهوم الأساسي

النظام يدعم **Multiple Check-In/Check-Out Sessions** في نفس اليوم:

```
Day Timeline:
├── Session 1: Check-In (09:00) ──► Check-Out (12:00) = 3h
├── Session 2: Check-In (13:00) ──► Check-Out (15:30) = 2.5h
├── Session 3: Check-In (16:00) ──► [Active]
└── Total: 5.5h (completed) + ongoing session
```

### الجداول الرئيسية

1. **`attendances`**: سجل يومي واحد لكل موظف
2. **`attendance_sessions`**: سجل لكل check-in/check-out
3. **`employees`**: بيانات الموظفين
4. **`branches`**: فروع الشركة مع GPS
5. **`work_plans`**: خطط العمل (مواعيد + ساعات)

---

## 💾 Database Schema

### 1. attendance_sessions Table

```sql
CREATE TABLE attendance_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    employee_id BIGINT NOT NULL,
    attendance_id BIGINT NOT NULL,
    work_plan_id BIGINT NOT NULL,
    date DATE NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME NULL,
    check_in_latitude DECIMAL(10,8) NULL,
    check_in_longitude DECIMAL(11,8) NULL,
    check_out_latitude DECIMAL(10,8) NULL,
    check_out_longitude DECIMAL(11,8) NULL,
    duration_hours DECIMAL(5,2) NULL,
    duration_minutes INT NULL,
    session_type VARCHAR(50) DEFAULT 'regular',
    notes TEXT NULL,
    is_manual BOOLEAN DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    INDEX idx_employee_date (employee_id, date),
    INDEX idx_active_session (employee_id, date, check_out_time),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (attendance_id) REFERENCES attendances(id),
    FOREIGN KEY (work_plan_id) REFERENCES work_plans(id)
);
```

**الحقول المهمة**:
- `check_out_time`: إذا كان NULL = session نشط
- `duration_hours`: يتم حسابه تلقائياً عند الحفظ
- `duration_minutes`: نفس الشيء بالدقائق
- `session_type`: 'regular', 'overtime', 'manual'

### 2. attendances Table

```sql
CREATE TABLE attendances (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    employee_id BIGINT NOT NULL,
    company_id BIGINT NOT NULL,
    work_plan_id BIGINT NOT NULL,
    date DATE NOT NULL,
    check_in_time DATETIME NULL,
    check_out_time DATETIME NULL,
    check_in_latitude DECIMAL(10,8) NULL,
    check_in_longitude DECIMAL(11,8) NULL,
    working_hours DECIMAL(5,2) DEFAULT 0,
    late_minutes INT DEFAULT 0,
    missing_hours DECIMAL(5,2) DEFAULT 0,
    notes TEXT NULL,
    is_manual BOOLEAN DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    UNIQUE KEY unique_employee_date (employee_id, date),
    INDEX idx_company_date (company_id, date),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (work_plan_id) REFERENCES work_plans(id)
);
```

**الحقول المهمة**:
- `check_in_time`: من أول session
- `check_out_time`: من آخر session
- `working_hours`: مجموع كل الـ sessions المكتملة
- `late_minutes`: من أول session فقط
- `missing_hours`: الفرق بين المتوقع والفعلي
- `notes`: سبب التأخير (من أول session)

### 3. branches Table

```sql
CREATE TABLE branches (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NULL,
    address TEXT NULL,
    phone VARCHAR(50) NULL,
    email VARCHAR(255) NULL,
    status BOOLEAN DEFAULT 1,
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    radius_meters INT DEFAULT 100,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

**GPS Validation**:
- `latitude` & `longitude`: موقع الفرع
- `radius_meters`: نطاق القبول (default: 100m)

### 4. work_plans Table

```sql
CREATE TABLE work_plans (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    total_hours DECIMAL(5,2) NOT NULL,
    permission_minutes INT DEFAULT 0,
    work_days JSON NULL,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

**Business Rules**:
- `permission_minutes`: فترة سماح للتأخير (grace period)
- `work_days`: أيام العمل `["sunday", "monday", ...]`

---

## 🚀 Check-In Workflow

### Flow Diagram

```
┌──────────────┐
│ Mobile App   │
│ Check-In Btn │
└──────┬───────┘
       │
       ▼
┌─────────────────────────────────────────────────┐
│ 1. Get GPS Location                            │
│    - latitude, longitude                       │
│    - accuracy                                  │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 2. POST /api/v1/employee/attendance/check-in   │
│    Headers: Authorization: Bearer {token}      │
│    Body: { latitude, longitude, late_reason? } │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 3. Backend Validation                          │
│    ✓ Employee exists                           │
│    ✓ Has branch assigned                       │
│    ✓ Within branch radius                      │
│    ✓ No active session                         │
│    ✓ Has active work plan                      │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 4. Database Transaction (BEGIN)                │
│                                                 │
│    A. Get or Create Daily Attendance           │
│       Attendance::firstOrCreate([              │
│         'employee_id' => $id,                  │
│         'date' => today()                      │
│       ], [                                     │
│         'company_id' => $company_id,           │
│         'work_plan_id' => $work_plan_id,       │
│         'check_in_time' => now(),              │
│         ...                                    │
│       ]);                                      │
│                                                 │
│    B. Save Late Reason (if provided)           │
│       if ($late_reason && empty($notes)) {     │
│         $attendance->notes = $late_reason;     │
│         $attendance->save();                   │
│       }                                        │
│                                                 │
│    C. Create New Session                       │
│       AttendanceSession::create([              │
│         'employee_id' => $id,                  │
│         'attendance_id' => $attendance_id,     │
│         'work_plan_id' => $work_plan_id,       │
│         'date' => today(),                     │
│         'check_in_time' => now(),              │
│         'check_in_latitude' => $lat,           │
│         'check_in_longitude' => $lng,          │
│         'session_type' => 'regular',           │
│         'is_manual' => false                   │
│       ]);                                      │
│                                                 │
│    D. Calculate Late Minutes (First Session)   │
│       if (isFirstSession) {                    │
│         $expected = $work_plan->start_time;    │
│         $actual = $session->check_in_time;     │
│         if ($actual > $expected) {             │
│           $late = $expected->diff($actual);    │
│           $late -= $work_plan->permission;     │
│           $late = max(0, $late);               │
│         }                                      │
│       }                                        │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 5. COMMIT Transaction                          │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 6. Response                                    │
│    {                                           │
│      "success": true,                          │
│      "message": "Checked in successfully",     │
│      "data": {                                 │
│        "session_id": 7,                        │
│        "attendance_id": 4663,                  │
│        "date": "2025-11-10",                   │
│        "check_in_time": "11:32:47",            │
│        "session_number": 1,                    │
│        "late_minutes": 182.78,                 │
│        "late_label": "182.78 minutes late",    │
│        "is_first_session": true,               │
│        "branch": { ... },                      │
│        "work_plan": { ... }                    │
│      }                                         │
│    }                                           │
└─────────────────────────────────────────────────┘
```

### Backend Code Analysis

#### Step 1: Authentication & Employee Fetch

```php
public function checkIn(Request $request): JsonResponse
{
    try {
        // Get authenticated employee with branch relation
        $employee = Employee::with('branch')->find(auth()->id());

        if (!$employee) {
            return (new ErrorResponse(
                'Employee not found',
                [],
                Response::HTTP_NOT_FOUND
            ))->toJson();
        }

        // ⭐ Set session company_id for CurrentCompanyScope
        session(['current_company_id' => $employee->company_id]);
```

**Key Points**:
- Uses `auth()->id()` from Sanctum token
- Eager loads `branch` relation
- Sets session company_id for multi-tenancy

#### Step 2: Branch Validation

```php
        // Check if employee has a branch assigned
        if (!$employee->branch) {
            return (new ErrorResponse(
                'No branch assigned to you. Please contact HR.',
                [],
                Response::HTTP_BAD_REQUEST
            ))->toJson();
        }
```

**Business Rule**: كل موظف يجب أن يكون له branch

#### Step 3: GPS Validation

```php
        // Get latitude and longitude from request
        $latitude = $request->input('latitude');
        $longitude = $request->input('longitude');

        // Validate location if branch has location set
        if ($employee->branch->latitude && $employee->branch->longitude) {
            if (!$latitude || !$longitude) {
                return (new ErrorResponse(
                    'Location is required for check-in',
                    [],
                    Response::HTTP_BAD_REQUEST
                ))->toJson();
            }

            // Check if location is within branch radius
            if (!$employee->branch->isLocationWithinRadius($latitude, $longitude)) {
                $distance = round($employee->branch->calculateDistance($latitude, $longitude));
                return (new ErrorResponse(
                    'You are too far from the branch location to check in',
                    [
                        'distance_meters' => $distance,
                        'allowed_radius' => $employee->branch->radius_meters,
                    ],
                    Response::HTTP_BAD_REQUEST
                ))->toJson();
            }
        }
```

**Haversine Formula** (في Branch Model):

```php
public function calculateDistance(float $latitude, float $longitude): float
{
    $earthRadius = 6371000; // meters

    $latFrom = deg2rad($this->latitude);
    $lonFrom = deg2rad($this->longitude);
    $latTo = deg2rad($latitude);
    $lonTo = deg2rad($longitude);

    $latDelta = $latTo - $latFrom;
    $lonDelta = $lonTo - $lonFrom;

    // Haversine formula
    $a = sin($latDelta / 2) * sin($latDelta / 2) +
         cos($latFrom) * cos($latTo) *
         sin($lonDelta / 2) * sin($lonDelta / 2);

    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

    return $earthRadius * $c; // Distance in meters
}
```

**Validation Logic**:

```php
public function isLocationWithinRadius(float $latitude, float $longitude): bool
{
    if (!$this->latitude || !$this->longitude) {
        // No branch location = allow from anywhere
        return true;
    }

    $distance = $this->calculateDistance($latitude, $longitude);
    return $distance <= $this->radius_meters;
}
```

#### Step 4: Active Session Check

```php
        // Check if there's an active session (not checked out yet)
        $activeSession = AttendanceSession::where('employee_id', $employee->id)
            ->whereDate('date', today())
            ->whereNull('check_out_time')
            ->first();

        if ($activeSession) {
            return (new ErrorResponse(
                'You have an active session. Please check out first.',
                [
                    'session_id' => $activeSession->id,
                    'check_in_time' => $activeSession->check_in_time->format('H:i:s'),
                    'duration' => $activeSession->current_duration_label,
                ],
                Response::HTTP_BAD_REQUEST
            ))->toJson();
        }
```

**Business Rule**: لا يمكن check-in إذا كان هناك session نشط

#### Step 5: Work Plan Validation

```php
        // Get employee's work plan
        $workPlan = $employee->workPlans()->active()->first();

        if (!$workPlan) {
            return (new ErrorResponse(
                'No active work plan assigned to you. Please contact HR.',
                [],
                Response::HTTP_BAD_REQUEST
            ))->toJson();
        }
```

#### Step 6: Database Transaction

```php
        DB::beginTransaction();
        try {
            // Get late_reason from request (if employee is checking in late)
            $lateReason = $request->input('late_reason');
            Log::info('CheckIn: late_reason from request', ['late_reason' => $lateReason]);

            // ─────────────────────────────────────────────────
            // A. Get or Create Daily Attendance Record
            // ─────────────────────────────────────────────────
            $attendance = Attendance::firstOrCreate(
                [
                    'employee_id' => $employee->id,
                    'date' => today(),
                ],
                [
                    'company_id' => $employee->company_id,
                    'work_plan_id' => $workPlan->id,
                    'check_in_time' => now(),
                    'check_in_latitude' => $latitude,
                    'check_in_longitude' => $longitude,
                    'is_manual' => false,
                ]
            );

            Log::info('CheckIn: Attendance record', [
                'id' => $attendance->id,
                'was_recently_created' => $attendance->wasRecentlyCreated,
                'notes_before' => $attendance->notes,
            ]);

            // ─────────────────────────────────────────────────
            // B. Update Late Reason (First Session Only)
            // ─────────────────────────────────────────────────
            if ($lateReason && empty($attendance->notes)) {
                $attendance->notes = $lateReason;
                $attendance->save();
                Log::info('CheckIn: Late reason saved', ['notes_after' => $attendance->notes]);
            } elseif ($lateReason && !empty($attendance->notes)) {
                Log::warning('CheckIn: Late reason already exists', ['existing_notes' => $attendance->notes]);
            }

            // ─────────────────────────────────────────────────
            // C. Create New Attendance Session
            // ─────────────────────────────────────────────────
            $session = AttendanceSession::create([
                'employee_id' => $employee->id,
                'attendance_id' => $attendance->id,
                'work_plan_id' => $workPlan->id,
                'date' => today(),
                'check_in_time' => now(),
                'check_in_latitude' => $latitude,
                'check_in_longitude' => $longitude,
                'session_type' => 'regular',
                'is_manual' => false,
            ]);

            // ─────────────────────────────────────────────────
            // D. Calculate Late Minutes (First Session Only)
            // ─────────────────────────────────────────────────
            $lateMinutes = 0;
            $isFirstSession = AttendanceSession::where('employee_id', $employee->id)
                ->whereDate('date', today())
                ->count() === 1;

            if ($isFirstSession) {
                $expectedStart = Carbon::parse($workPlan->start_time);
                $actualStart = Carbon::parse($session->check_in_time);

                if ($actualStart->gt($expectedStart)) {
                    $lateMinutes = $expectedStart->diffInMinutes($actualStart);
                    // Subtract grace period (permission_minutes)
                    $lateMinutes = max(0, $lateMinutes - $workPlan->permission_minutes);
                }
            }

            DB::commit();
```

**Key Points**:
- `firstOrCreate`: إذا سجل موجود لليوم، يرجعه بدون تعديل
- `late_reason`: يحفظ فقط لأول session ولو الـ notes فارغ
- `isFirstSession`: يحسب بعد إنشاء الـ session الجديد
- `permission_minutes`: فترة سماح (grace period) - يطرح من التأخير

#### Step 7: Response

```php
            $data = [
                'session_id' => $session->id,
                'attendance_id' => $attendance->id,
                'date' => $session->date->format('Y-m-d'),
                'check_in_time' => $session->check_in_time->format('H:i:s'),
                'session_number' => AttendanceSession::where('employee_id', $employee->id)
                    ->whereDate('date', today())
                    ->count(),
                'late_minutes' => $lateMinutes,
                'late_label' => $lateMinutes > 0 ? "{$lateMinutes} minutes late" : 'On time',
                'is_first_session' => $isFirstSession,
                'branch' => [
                    'name' => $employee->branch->name,
                    'address' => $employee->branch->address,
                ],
                'work_plan' => [
                    'name' => $workPlan->name,
                    'start_time' => $workPlan->start_time->format('H:i'),
                    'end_time' => $workPlan->end_time->format('H:i'),
                    'schedule' => $workPlan->schedule,
                    'permission_minutes' => $workPlan->permission_minutes,
                ]
            ];

            return (new DataResponse($data, 'Checked in successfully'))->toJson();
```

---

## 🏁 Check-Out Workflow

### Flow Diagram

```
┌──────────────┐
│ Mobile App   │
│ Check-Out Btn│
└──────┬───────┘
       │
       ▼
┌─────────────────────────────────────────────────┐
│ 1. Get GPS Location (Optional)                 │
│    - latitude, longitude                       │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 2. POST /api/v1/employee/attendance/check-out  │
│    Headers: Authorization: Bearer {token}      │
│    Body: { latitude?, longitude? }             │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 3. Find Active Session                         │
│    - employee_id = auth()->id()                │
│    - date = today()                            │
│    - check_out_time IS NULL                    │
│    - ORDER BY check_in_time DESC               │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 4. Database Transaction (BEGIN)                │
│                                                 │
│    A. Update Session                           │
│       $session->update([                       │
│         'check_out_time' => now(),             │
│         'check_out_latitude' => $lat,          │
│         'check_out_longitude' => $lng          │
│       ]);                                      │
│       // duration_hours auto-calculated        │
│                                                 │
│    B. Update Daily Attendance Summary          │
│       - Get all completed sessions             │
│       - Sum total working hours                │
│       - Calculate late/missing hours           │
│       - Update attendance record               │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 5. COMMIT Transaction                          │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│ 6. Response                                    │
│    {                                           │
│      "success": true,                          │
│      "message": "Checked out successfully",    │
│      "data": {                                 │
│        "session_id": 7,                        │
│        "attendance_id": 4663,                  │
│        "date": "2025-11-10",                   │
│        "check_in_time": "11:32:47",            │
│        "check_out_time": "11:41:02",           │
│        "duration_hours": "0.14",               │
│        "duration_label": "8m",                 │
│        "session_number": 1,                    │
│        "total_sessions_today": 1               │
│      }                                         │
│    }                                           │
└─────────────────────────────────────────────────┘
```

### Backend Code Analysis

#### Step 1: Find Active Session

```php
public function checkOut(Request $request): JsonResponse
{
    try {
        // Get employee and set session company_id
        $employee = Employee::find(auth()->id());
        if ($employee) {
            session(['current_company_id' => $employee->company_id]);
        }

        // Find active session (not checked out yet)
        $session = AttendanceSession::where('employee_id', auth()->id())
            ->whereDate('date', today())
            ->whereNull('check_out_time')
            ->orderBy('check_in_time', 'desc')
            ->first();

        if (!$session) {
            return (new ErrorResponse(
                'No active check-in session found for today',
                [],
                Response::HTTP_BAD_REQUEST
            ))->toJson();
        }
```

**Key Points**:
- `whereNull('check_out_time')`: active session
- `orderBy('check_in_time', 'desc')`: آخر check-in

#### Step 2: Update Session

```php
        // Get latitude and longitude from request (optional for checkout)
        $latitude = $request->input('latitude');
        $longitude = $request->input('longitude');

        DB::beginTransaction();
        try {
            // Update session with check-out time and location
            $session->update([
                'check_out_time' => now(),
                'check_out_latitude' => $latitude,
                'check_out_longitude' => $longitude,
            ]);

            // Refresh to get calculated values
            $session->refresh();
```

**Auto-Calculation** (في Model boot method):

```php
// In AttendanceSession model
protected static function boot()
{
    parent::boot();

    static::saving(function ($session) {
        $duration = $session->calculateDuration();
        $session->duration_hours = $duration['hours'];
        $session->duration_minutes = $duration['minutes'];
    });
}
```

```php
public function calculateDuration(): array
{
    if (!$this->check_out_time) {
        return ['hours' => 0, 'minutes' => 0];
    }

    $checkIn = Carbon::parse($this->check_in_time);
    $checkOut = Carbon::parse($this->check_out_time);

    // Calculate from check-in to check-out
    $totalMinutes = $checkIn->diffInMinutes($checkOut);
    $hours = round($totalMinutes / 60, 2);

    return [
        'hours' => $hours,
        'minutes' => $totalMinutes,
    ];
}
```

#### Step 3: Update Daily Summary

```php
            // Update daily attendance summary
            $attendance = $session->attendance;
            if ($attendance) {
                $this->updateDailyAttendanceSummary($attendance);
            }

            DB::commit();
```

**updateDailyAttendanceSummary()** Method:

```php
private function updateDailyAttendanceSummary(Attendance $attendance): void
{
    // ─────────────────────────────────────────────────
    // A. Get All Completed Sessions
    // ─────────────────────────────────────────────────
    $sessions = AttendanceSession::where('attendance_id', $attendance->id)
        ->whereNotNull('check_out_time')
        ->get();

    // ─────────────────────────────────────────────────
    // B. Calculate Total Working Hours
    // ─────────────────────────────────────────────────
    $totalHours = $sessions->sum('duration_hours');

    // ─────────────────────────────────────────────────
    // C. Get First Check-In and Last Check-Out
    // ─────────────────────────────────────────────────
    $firstSession = AttendanceSession::where('attendance_id', $attendance->id)
        ->orderBy('check_in_time', 'asc')
        ->first();

    $lastSession = AttendanceSession::where('attendance_id', $attendance->id)
        ->whereNotNull('check_out_time')
        ->orderBy('check_out_time', 'desc')
        ->first();

    // ─────────────────────────────────────────────────
    // D. Calculate Late Minutes (From First Session)
    // ─────────────────────────────────────────────────
    $lateMinutes = 0;
    if ($firstSession && $attendance->workPlan) {
        $expectedStart = Carbon::parse($attendance->workPlan->start_time);
        $actualStart = Carbon::parse($firstSession->check_in_time);

        if ($actualStart->gt($expectedStart)) {
            $lateMinutes = $expectedStart->diffInMinutes($actualStart);
            $lateMinutes = max(0, $lateMinutes - $attendance->workPlan->permission_minutes);
        }
    }

    // ─────────────────────────────────────────────────
    // E. Calculate Missing Hours
    // ─────────────────────────────────────────────────
    $missingHours = 0;
    if ($attendance->workPlan) {
        $expectedStart = Carbon::parse($attendance->workPlan->start_time);
        $expectedEnd = Carbon::parse($attendance->workPlan->end_time);
        $expectedHours = round($expectedEnd->diffInMinutes($expectedStart) / 60, 2);
        $missingHours = max(0, $expectedHours - $totalHours);
    }

    // ─────────────────────────────────────────────────
    // F. Update Attendance Record
    // ─────────────────────────────────────────────────
    $attendance->update([
        'check_in_time' => $firstSession?->check_in_time,
        'check_out_time' => $lastSession?->check_out_time,
        'working_hours' => $totalHours,
        'late_minutes' => $lateMinutes,
        'missing_hours' => $missingHours,
    ]);
}
```

**Key Business Logic**:

1. **Total Working Hours**: مجموع كل الـ sessions المكتملة
2. **Late Minutes**: من أول session فقط، مع خصم grace period
3. **Missing Hours**: `expected_hours - actual_hours`

---

## 🧮 Calculations & Business Logic

### 1. Duration Calculation

```php
// In AttendanceSession Model
public function calculateDuration(): array
{
    if (!$this->check_out_time) {
        return ['hours' => 0, 'minutes' => 0];
    }

    $checkIn = Carbon::parse($this->check_in_time);
    $checkOut = Carbon::parse($this->check_out_time);

    $totalMinutes = $checkIn->diffInMinutes($checkOut);
    $hours = round($totalMinutes / 60, 2);

    return [
        'hours' => $hours,
        'minutes' => $totalMinutes,
    ];
}
```

**Example**:
```
Check-In:  09:00:00
Check-Out: 12:30:00
Duration:  3.5 hours (210 minutes)
```

### 2. Late Minutes Calculation

```php
// Only for FIRST session of the day
$expectedStart = Carbon::parse($workPlan->start_time);
$actualStart = Carbon::parse($session->check_in_time);

if ($actualStart->gt($expectedStart)) {
    $lateMinutes = $expectedStart->diffInMinutes($actualStart);
    // Subtract grace period
    $lateMinutes = max(0, $lateMinutes - $workPlan->permission_minutes);
}
```

**Example**:
```
Work Plan Start: 09:00
Permission: 30 minutes
Actual Check-In: 09:45

Raw Late: 45 minutes
After Grace: 45 - 30 = 15 minutes late
```

### 3. Missing Hours Calculation

```php
$expectedStart = Carbon::parse($workPlan->start_time);
$expectedEnd = Carbon::parse($workPlan->end_time);
$expectedHours = $expectedEnd->diffInMinutes($expectedStart) / 60;

$actualHours = $sessions->sum('duration_hours');
$missingHours = max(0, $expectedHours - $actualHours);
```

**Example**:
```
Work Plan: 09:00 - 17:00 = 8 hours expected
Actual Work: 6.5 hours
Missing: 8 - 6.5 = 1.5 hours
```

### 4. GPS Distance Calculation (Haversine Formula)

```php
public function calculateDistance(float $lat1, float $lon1): float
{
    $earthRadius = 6371000; // meters

    $latFrom = deg2rad($this->latitude);
    $lonFrom = deg2rad($this->longitude);
    $latTo = deg2rad($lat1);
    $lonTo = deg2rad($lon1);

    $latDelta = $latTo - $latFrom;
    $lonDelta = $lonTo - $lonFrom;

    $a = sin($latDelta / 2) * sin($latDelta / 2) +
         cos($latFrom) * cos($latTo) *
         sin($lonDelta / 2) * sin($lonDelta / 2);

    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

    return $earthRadius * $c; // meters
}
```

**Example**:
```
Branch: (31.2001, 29.9187)
Employee: (31.2010, 29.9190)
Distance: ~110 meters

Allowed Radius: 100 meters
Result: ❌ Too far!
```

---

## ✅ Validation Rules

### Check-In Validations

| # | Rule | Error Message | Status Code |
|---|------|---------------|-------------|
| 1 | Employee exists | "Employee not found" | 404 |
| 2 | Has branch assigned | "No branch assigned to you. Please contact HR." | 400 |
| 3 | Location provided (if branch has GPS) | "Location is required for check-in" | 400 |
| 4 | Within branch radius | "You are too far from the branch location" | 400 |
| 5 | No active session | "You have an active session. Please check out first." | 400 |
| 6 | Has active work plan | "No active work plan assigned to you." | 400 |

### Check-Out Validations

| # | Rule | Error Message | Status Code |
|---|------|---------------|-------------|
| 1 | Has active session | "No active check-in session found for today" | 400 |

---

## 🔄 Multi-Session Support

### Daily Sessions Example

```
Employee: Ahmed Abbas
Date: 2025-11-10
Work Plan: 09:00 - 17:00 (8 hours)

Sessions:
┌──────────┬─────────┬──────────┬──────────┬─────────────┐
│ Session  │ Check-In│ Check-Out│ Duration │ Status      │
├──────────┼─────────┼──────────┼──────────┼─────────────┤
│ 1        │ 09:15   │ 12:00    │ 2.75h    │ ✅ Completed│
│ 2        │ 13:00   │ 15:30    │ 2.50h    │ ✅ Completed│
│ 3        │ 16:00   │ NULL     │ -        │ 🟢 Active   │
└──────────┴─────────┴──────────┴──────────┴─────────────┘

Daily Summary (attendance table):
├─ check_in_time: 09:15 (from session 1)
├─ check_out_time: 15:30 (from session 2)
├─ working_hours: 5.25 (2.75 + 2.50)
├─ late_minutes: 0 (grace period covered)
├─ missing_hours: 2.75 (8 expected - 5.25 actual)
└─ notes: NULL
```

### Button State Logic

```php
// In getStatus() API response
$hasActiveSession = AttendanceSession::where('employee_id', $id)
    ->whereDate('date', today())
    ->whereNull('check_out_time')
    ->exists();

// ⭐ Use this in Flutter to determine button state:
if ($hasActiveSession) {
    // Show "Check Out" button
} else {
    // Show "Check In" button
}
```

**Flutter Implementation**:

```dart
// ✅ Correct approach
final hasActiveSession = status?.hasActiveSession ?? false;

if (hasActiveSession) {
  // Show Check-Out button
  CustomButton(
    text: 'Check Out',
    onPressed: () => cubit.checkOut(lat, lng),
  );
} else {
  // Show Check-In button
  CustomButton(
    text: 'Check In',
    onPressed: () => cubit.checkIn(lat, lng, lateReason),
  );
}

// ❌ Wrong approach (old single-session logic)
if (hasCheckedIn && !hasCheckedOut) {
  // This breaks with multiple sessions!
}
```

---

## 📡 API Responses

### Check-In Success Response

```json
{
  "success": true,
  "message": "Checked in successfully",
  "data": {
    "session_id": 7,
    "attendance_id": 4663,
    "date": "2025-11-10",
    "check_in_time": "11:32:47",
    "session_number": 1,
    "late_minutes": 182.78,
    "late_label": "182.78 minutes late",
    "is_first_session": true,
    "branch": {
      "name": "BDC Main Office",
      "address": "Main Office Location"
    },
    "work_plan": {
      "name": "Flexible Hours (48h/week)",
      "start_time": "08:00",
      "end_time": "23:00",
      "schedule": "08:00 - 23:00",
      "permission_minutes": 30
    }
  }
}
```

### Check-Out Success Response

```json
{
  "success": true,
  "message": "Checked out successfully",
  "data": {
    "session_id": 7,
    "attendance_id": 4663,
    "date": "2025-11-10",
    "check_in_time": "11:32:47",
    "check_out_time": "11:41:02",
    "duration_hours": "0.14",
    "duration_label": "8m",
    "session_number": 1,
    "total_sessions_today": 1
  }
}
```

### Get Status Response

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "has_checked_in": true,
    "has_checked_out": false,
    "has_active_session": true,
    "current_session": {
      "session_id": 7,
      "check_in_time": "11:32:47",
      "duration_label": "2h 15m"
    },
    "sessions_summary": {
      "total_sessions": 3,
      "active_sessions": 1,
      "completed_sessions": 2,
      "total_duration": "05:30:00",
      "total_hours": 5.5
    },
    "work_plan": {
      "name": "Flexible Hours (48h/week)",
      "start_time": "08:00",
      "end_time": "23:00",
      "permission_minutes": 30
    },
    "attendance_summary": {
      "date": "2025-11-10",
      "first_check_in": "11:32:47",
      "last_check_out": "15:30:00",
      "total_working_hours": 5.5,
      "late_minutes": 0,
      "missing_hours": 2.5
    }
  }
}
```

---

## ⚠️ Error Scenarios

### 1. No Branch Assigned

**Request**: Check-In
**Response**:
```json
{
  "success": false,
  "message": "No branch assigned to you. Please contact HR.",
  "errors": []
}
```

**Solution**: HR يعين branch للموظف في Filament

---

### 2. Too Far from Branch

**Request**: Check-In with GPS (37.4219983, -122.084)
**Response**:
```json
{
  "success": false,
  "message": "You are too far from the branch location to check in",
  "errors": {
    "distance_meters": 11500000,
    "allowed_radius": 100
  }
}
```

**Solution**:
- الموظف يقترب من الفرع
- أو HR يزيد الـ radius
- أو يغير موقع الفرع

---

### 3. Active Session Exists

**Request**: Check-In
**Response**:
```json
{
  "success": false,
  "message": "You have an active session. Please check out first.",
  "errors": {
    "session_id": 7,
    "check_in_time": "11:32:47",
    "duration": "2h 15m"
  }
}
```

**Solution**: الموظف يعمل check-out أولاً

---

### 4. No Active Session

**Request**: Check-Out
**Response**:
```json
{
  "success": false,
  "message": "No active check-in session found for today",
  "errors": []
}
```

**Solution**: الموظف يعمل check-in أولاً

---

### 5. No Work Plan

**Request**: Check-In
**Response**:
```json
{
  "success": false,
  "message": "No active work plan assigned to you. Please contact HR.",
  "errors": []
}
```

**Solution**: HR يعين work plan للموظف

---

## 📱 Flutter Integration

### 1. Check-In Flow

```dart
Future<void> _handleCheckIn() async {
  try {
    // 1. Get GPS location
    final position = await LocationService.getCurrentPosition();
    final lat = position.latitude;
    final lng = position.longitude;

    // 2. Check if late (from status)
    final status = await cubit.fetchTodayStatus();
    final isLate = _isEmployeeLate(status);

    String? lateReason;

    // 3. Show late reason bottom sheet if needed
    if (isLate && !status.hasLateReason) {
      lateReason = await _showLateReasonBottomSheet();
      if (lateReason == null) return; // User cancelled
    }

    // 4. Call check-in API
    await cubit.checkIn(lat, lng, lateReason);

    // 5. Refresh status
    await cubit.fetchTodayStatus();
    await cubit.fetchTodaySessions();

  } catch (e) {
    // Show error
    showErrorSnackbar(e.toString());
  }
}
```

### 2. Check-Out Flow

```dart
Future<void> _handleCheckOut() async {
  try {
    // 1. Get GPS location (optional)
    final position = await LocationService.getCurrentPosition();
    final lat = position.latitude;
    final lng = position.longitude;

    // 2. Call check-out API
    await cubit.checkOut(lat, lng);

    // 3. Refresh status
    await cubit.fetchTodayStatus();
    await cubit.fetchTodaySessions();

  } catch (e) {
    // Show error
    showErrorSnackbar(e.toString());
  }
}
```

### 3. Button State Logic

```dart
Widget _buildActionButton(BuildContext context, AttendanceStatusModel? status) {
  final hasActiveSession = status?.hasActiveSession ?? false;

  return CustomButton(
    text: hasActiveSession ? 'Check Out' : 'Check In',
    onPressed: hasActiveSession ? _handleCheckOut : _handleCheckIn,
    type: hasActiveSession ? ButtonType.secondary : ButtonType.primary,
  );
}
```

---

## 🎯 Business Rules Summary

### Check-In Rules

1. ✅ **Branch Assignment**: موظف لازم يكون له branch
2. ✅ **GPS Validation**: لو الـ branch فيه GPS، الموظف لازم يكون جواه
3. ✅ **No Active Session**: مينفعش check-in لو في session نشط
4. ✅ **Work Plan Required**: لازم يكون في work plan active
5. ✅ **Late Reason**: لو متأخر، يسجل السبب (أول session فقط)
6. ✅ **Grace Period**: في فترة سماح (permission_minutes)

### Check-Out Rules

1. ✅ **Active Session Required**: لازم يكون في session نشط
2. ✅ **GPS Optional**: الموقع اختياري في check-out
3. ✅ **Auto-Calculate**: المدة تحسب تلقائياً
4. ✅ **Update Summary**: السجل اليومي يتحدث تلقائياً

### Daily Summary Rules

1. ✅ **First Check-In**: من أول session
2. ✅ **Last Check-Out**: من آخر session مكتمل
3. ✅ **Total Hours**: مجموع كل الـ sessions
4. ✅ **Late Minutes**: من أول session فقط
5. ✅ **Missing Hours**: expected - actual

---

## 📊 Database Queries Performance

### Check-In Queries

```sql
-- 1. Find employee with branch
SELECT * FROM employees WHERE id = ? LIMIT 1;
SELECT * FROM branches WHERE id = ? LIMIT 1;

-- 2. Check active session
SELECT * FROM attendance_sessions
WHERE employee_id = ?
  AND date = ?
  AND check_out_time IS NULL
LIMIT 1;

-- 3. Get work plan
SELECT * FROM work_plans WHERE id = ? AND is_active = 1 LIMIT 1;

-- 4. Get or create attendance
SELECT * FROM attendances WHERE employee_id = ? AND date = ? LIMIT 1;
-- OR
INSERT INTO attendances (...) VALUES (...);

-- 5. Create session
INSERT INTO attendance_sessions (...) VALUES (...);

-- 6. Count sessions for today
SELECT COUNT(*) FROM attendance_sessions
WHERE employee_id = ? AND date = ?;
```

**Total**: ~6-7 queries per check-in

### Check-Out Queries

```sql
-- 1. Find employee
SELECT * FROM employees WHERE id = ? LIMIT 1;

-- 2. Find active session
SELECT * FROM attendance_sessions
WHERE employee_id = ?
  AND date = ?
  AND check_out_time IS NULL
ORDER BY check_in_time DESC
LIMIT 1;

-- 3. Update session
UPDATE attendance_sessions
SET check_out_time = ?,
    check_out_latitude = ?,
    check_out_longitude = ?,
    duration_hours = ?,
    duration_minutes = ?
WHERE id = ?;

-- 4. Get completed sessions for summary
SELECT * FROM attendance_sessions
WHERE attendance_id = ?
  AND check_out_time IS NOT NULL;

-- 5. Get first and last sessions
SELECT * FROM attendance_sessions
WHERE attendance_id = ?
ORDER BY check_in_time ASC
LIMIT 1;

SELECT * FROM attendance_sessions
WHERE attendance_id = ?
  AND check_out_time IS NOT NULL
ORDER BY check_out_time DESC
LIMIT 1;

-- 6. Update attendance summary
UPDATE attendances
SET check_in_time = ?,
    check_out_time = ?,
    working_hours = ?,
    late_minutes = ?,
    missing_hours = ?
WHERE id = ?;
```

**Total**: ~7-8 queries per check-out

### Optimization Recommendations

1. **Index على**:
   - `(employee_id, date, check_out_time)` في attendance_sessions
   - `(employee_id, date)` في attendances
   - `(attendance_id, check_out_time)` في attendance_sessions

2. **Caching**:
   - Work Plans (نادر التغيير)
   - Branches (نادر التغيير)

3. **Eager Loading**:
   - استخدام `with()` دايماً

---

## 🔐 Security Considerations

### 1. Authentication

```php
// Uses Sanctum token
$employee = Employee::find(auth()->id());
```

**Protection**: Sanctum middleware يتحقق من الـ token قبل تنفيذ أي request

### 2. Multi-Tenancy

```php
// Set session for CurrentCompanyScope
session(['current_company_id' => $employee->company_id]);
```

**Protection**: كل موظف يشوف بس بيانات شركته

### 3. GPS Spoofing

**Current**: ✅ Haversine distance validation
**Future**: ⚠️ يمكن إضافة IP validation
**Future**: ⚠️ يمكن إضافة device fingerprinting

### 4. Time Manipulation

**Protection**: Backend يستخدم `now()` دايماً، مش من الـ client

### 5. SQL Injection

**Protection**: استخدام Eloquent ORM مع parameter binding

---

## ✅ Conclusion

### ما تم دراسته:

✅ **Database Structure**: جداول + علاقات + indexes
✅ **Check-In Workflow**: 7 خطوات مع validations
✅ **Check-Out Workflow**: 6 خطوات مع auto-calculations
✅ **Business Logic**: تأخير + ساعات ناقصة + GPS
✅ **Multi-Session**: دعم sessions غير محدودة
✅ **API Integration**: Requests + Responses
✅ **Error Handling**: جميع السيناريوهات
✅ **Flutter Integration**: How to implement
✅ **Performance**: Query analysis
✅ **Security**: Authentication + Multi-tenancy

### التوصيات:

1. ✅ **استخدم `hasActiveSession`** من الـ API لتحديد حالة الزر
2. ✅ **Refresh Status** بعد كل check-in/check-out
3. ✅ **Handle Errors** بشكل واضح للمستخدم
4. ✅ **Test GPS Validation** قبل النشر
5. ✅ **Add Logging** لمراقبة المشاكل
6. ⚠️ **Consider Offline Mode** للـ sessions المفقودة
7. ⚠️ **Add Notifications** عند check-in/out
8. ⚠️ **Report Generation** للإحصائيات

---

**تم بواسطة**: Claude Code
**التاريخ**: 2025-11-10
**النسخة**: Complete Workflow Study v1.0
