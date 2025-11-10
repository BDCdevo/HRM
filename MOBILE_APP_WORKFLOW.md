# Mobile App Workflow Documentation

**Production Server Details:**
- **Server:** root@31.97.46.103
- **Backend Path:** /var/www/erp1
- **API Base URL:** https://erp1.bdcbiz.com/api/v1
- **Framework:** Laravel (Filament Admin Panel)
- **Authentication:** Laravel Sanctum (Token-based)
- **Multi-tenancy:** Company-based isolation

---

## Table of Contents

1. [Authentication Flow](#authentication-flow)
2. [Dashboard Flow](#dashboard-flow)
3. [Attendance Flow](#attendance-flow)
4. [Leave Management Flow](#leave-management-flow)
5. [Profile Management Flow](#profile-management-flow)
6. [Notifications Flow](#notifications-flow)
7. [Work Schedule Flow](#work-schedule-flow)
8. [Data Models & Relationships](#data-models--relationships)
9. [Multi-Tenancy System](#multi-tenancy-system)
10. [Key Business Rules](#key-business-rules)
11. [API Response Format](#api-response-format)
12. [Flow Diagrams](#flow-diagrams)

---

## Authentication Flow

### 1. Employee Login

**Endpoint:** `POST /api/v1/auth/login`

**Controller:** `App\Http\Controllers\Api\V1\User\Auth\AuthenticationController@login`

**Request:**
```json
{
  "email": "employee@example.com",
  "password": "password123"
}
```

**Note:** The API accepts both `email` and `identifier` fields for backwards compatibility.

**Process:**
1. Validates email and password (minimum 6 characters)
2. Searches for employee with matching email and active status (`status = true`)
3. Verifies password using Laravel's Hash::check()
4. Generates Sanctum API token: `$employee->createToken('api-token')->plainTextToken`
5. Returns user data with token

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "employee_id": "EMP001",
    "department_id": 5,
    "position_id": 3,
    "department_name": "Engineering",
    "position_name": "Software Developer",
    "image": "https://example.com/avatars/john.jpg",
    "status": 1,
    "access_token": "1|abcdefghijklmnopqrstuvwxyz...",
    "roles": [],
    "permissions": []
  }
}
```

**Error Cases:**
- **401 Unauthorized:** Invalid credentials or inactive account
- **422 Unprocessable Entity:** Validation errors

**State Management:**
- Store `access_token` in secure storage (flutter_secure_storage)
- Store user data in state management (BLoC/Cubit)
- Token automatically added to all subsequent requests via ApiInterceptor

---

### 2. Admin Login

**Endpoint:** `POST /api/v1/admin/auth/login`

**Controller:** `App\Http\Controllers\Api\V1\Admin\Auth\AdminAuthenticationController@login`

**Request:**
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Process:**
1. Validates email and password
2. Finds admin by email
3. Checks if admin is active (`status = true`)
4. Verifies password
5. Updates last login information (timestamp and IP)
6. Generates token with admin scope: `$admin->createToken('admin-token', ['admin'])`
7. Returns admin data with roles and permissions

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Admin User",
      "email": "admin@example.com",
      "phone": "+1234567890",
      "status": true,
      "user_type": "admin",
      "roles": ["Super Admin"],
      "permissions": ["view-dashboard", "manage-employees", ...]
    },
    "access_token": "2|xyz123...",
    "token_type": "Bearer"
  }
}
```

**Error Cases:**
- **401 Unauthorized:** Invalid credentials
- **403 Forbidden:** Account is inactive

---

### 3. Employee Logout

**Endpoint:** `POST /api/v1/auth/logout`

**Authentication:** Required (Bearer token)

**Process:**
1. Retrieves current access token from request
2. Deletes the token: `$request->user()->currentAccessToken()->delete()`
3. Returns success message

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully",
  "data": null
}
```

**Client Action:**
- Clear stored token from secure storage
- Clear user state
- Navigate to login screen

---

### 4. Password Reset

**Endpoint:** `POST /api/v1/auth/reset-password`

**Request:**
```json
{
  "email": "employee@example.com",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Process:**
1. Validates email and password (must be confirmed)
2. Finds employee by email
3. Updates password and sets `password_set_at` timestamp
4. Returns success message

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset successfully",
  "data": null
}
```

---

### 5. Simple Registration (Testing Only)

**Endpoint:** `POST /api/v1/auth/register`

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+1234567890"
}
```

**Process:**
1. Validates required fields
2. Creates employee with default values:
   - `status = true`
   - `gender = 'male'`
   - `marital_status = 'single'`
   - `company_date_of_joining = now()`
3. Auto-generates employee_id (e.g., EMP001, EMP002, ...)
4. Creates API token
5. Returns employee data with token

---

### 6. Check User Existence

**Endpoint:** `POST /api/v1/auth/check-user`

**Request:**
```json
{
  "email": "employee@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "exists": true,
    "name": "John Doe"
  }
}
```

---

## Dashboard Flow

### Get Dashboard Statistics

**Endpoint:** `GET /api/v1/dashboard/stats`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Dashboard\DashboardController@getStats`

**Process:**
1. Retrieves authenticated user
2. Loads employee record (bypassing company scope if needed)
3. Calculates attendance statistics for current month:
   - Present days count
   - Total working days (weekdays only)
   - Attendance percentage
4. Calculates total hours worked this month
5. Fetches department and position names
6. Prepares placeholder data for leave balance, tasks, and performance

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "attendance": {
      "percentage": 85.5,
      "present_days": 18,
      "total_days": 21
    },
    "leave_balance": {
      "days": 0,
      "total_allocated": 0,
      "used_days": 0
    },
    "hours_this_month": {
      "hours": 144.0,
      "expected_hours": 168
    },
    "pending_tasks": {
      "count": 0,
      "overdue": 0,
      "due_today": 0
    },
    "performance": {
      "task_completion": {
        "percentage": 0,
        "label": "0% Complete",
        "value": 0.0
      },
      "monthly_goals": {
        "percentage": 0,
        "label": "0% Achieved",
        "value": 0.0
      }
    },
    "charts": {
      "attendance_trend": [],
      "monthly_hours": [],
      "leave_breakdown": []
    },
    "user_info": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "employee_id": "EMP001",
      "company_id": 1,
      "department_name": "Engineering",
      "position_name": "Software Developer"
    }
  }
}
```

**Working Days Calculation:**
```php
// Count only weekdays (Monday to Friday)
for ($day = 1; $day <= $daysInMonth; $day++) {
    $date = Carbon::create($year, $month, $day);
    if (!$date->isWeekend()) {
        $workingDays++;
    }
}
```

**Attendance Percentage:**
```
percentage = (present_days / total_working_days) * 100
```

---

## Attendance Flow

### Overview

The attendance system supports **unlimited check-in/check-out sessions per day**. This is a critical feature that allows employees to:
- Check-in → Check-out → Check-in → Check-out (unlimited cycles)
- Track multiple work sessions with GPS location
- View all sessions with real-time status

### Key Concepts

1. **Daily Attendance Record (Attendance model):**
   - One record per employee per day
   - Stores summary data: first check-in, last check-out, total hours, late minutes
   - Created on first check-in, updated after each check-out

2. **Attendance Sessions (AttendanceSession model):**
   - Multiple records per day
   - Each check-in creates a new session
   - Each check-out closes the active session
   - Tracks individual session duration

3. **Work Plan:**
   - Defines expected work hours
   - Contains: start_time, end_time, working_days, permission_minutes (grace period)
   - One employee can have multiple work plans (uses first active one)

4. **Branch Validation:**
   - Employee must be assigned to a branch
   - GPS location validated against branch location
   - Uses Haversine formula to calculate distance

---

### 1. Get Today's Status

**Endpoint:** `GET /api/v1/employee/attendance/status`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\AttendanceController@getStatus`

**Process:**
1. Retrieves all sessions for today
2. Finds active session (check_out_time = null)
3. Calculates total duration from all sessions
4. Checks if employee has provided late reason today
5. Returns comprehensive status

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "has_checked_in": true,
    "has_active_session": true,
    "has_late_reason": false,
    "date": "2025-11-10",
    "current_session": {
      "session_id": 15,
      "check_in_time": "09:15:00",
      "duration": "03:45:30"
    },
    "sessions_summary": {
      "total_sessions": 3,
      "completed_sessions": 2,
      "total_duration": "07:30:00",
      "total_hours": 7.5
    },
    "daily_summary": {
      "check_in_time": "08:00:00",
      "check_out_time": null,
      "working_hours": 5.25,
      "working_hours_label": "5.25h",
      "late_minutes": 15,
      "late_label": "15m late"
    },
    "work_plan": {
      "name": "Standard Shift",
      "start_time": "09:00",
      "end_time": "17:00",
      "schedule": "09:00 - 17:00",
      "permission_minutes": 15
    }
  }
}
```

**Critical Field:**
- **`has_active_session`**: Use this to determine button state (Check-In vs Check-Out)
- **DO NOT** use `has_checked_in && !check_out_time` (old single-session pattern)

---

### 2. Check-In

**Endpoint:** `POST /api/v1/employee/attendance/check-in`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\AttendanceController@checkIn`

**Request:**
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "late_reason": "Traffic jam on highway" // Optional, for first check-in if late
}
```

**Process:**

1. **Validate Employee & Branch:**
   ```php
   $employee = Employee::with('branch')->find(auth()->id());
   if (!$employee->branch) {
       return error('No branch assigned');
   }
   ```

2. **Validate GPS Location:**
   ```php
   if ($employee->branch->latitude && $employee->branch->longitude) {
       if (!$employee->branch->isLocationWithinRadius($latitude, $longitude)) {
           $distance = $employee->branch->calculateDistance($latitude, $longitude);
           return error('Too far from branch', [
               'distance_meters' => $distance,
               'allowed_radius' => $employee->branch->radius_meters
           ]);
       }
   }
   ```

3. **Check for Active Session:**
   ```php
   $activeSession = AttendanceSession::where('employee_id', $employee->id)
       ->whereDate('date', today())
       ->whereNull('check_out_time')
       ->first();

   if ($activeSession) {
       return error('You have an active session. Please check out first.');
   }
   ```

4. **Get Work Plan:**
   ```php
   $workPlan = $employee->workPlans()->active()->first();
   if (!$workPlan) {
       return error('No active work plan assigned');
   }
   ```

5. **Create/Update Daily Attendance:**
   ```php
   $attendance = Attendance::firstOrCreate(
       ['employee_id' => $employee->id, 'date' => today()],
       [
           'company_id' => $employee->company_id,
           'work_plan_id' => $workPlan->id,
           'check_in_time' => now(),
           'check_in_latitude' => $latitude,
           'check_in_longitude' => $longitude,
           'is_manual' => false,
       ]
   );

   // Save late reason if provided (only for first check-in)
   if ($lateReason && empty($attendance->notes)) {
       $attendance->notes = $lateReason;
       $attendance->save();
   }
   ```

6. **Create New Session:**
   ```php
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
   ```

7. **Calculate Late Minutes (First Session Only):**
   ```php
   $lateMinutes = 0;
   $isFirstSession = AttendanceSession::where('employee_id', $employee->id)
       ->whereDate('date', today())
       ->count() === 1;

   if ($isFirstSession) {
       $expectedStart = Carbon::parse($workPlan->start_time);
       $actualStart = Carbon::parse($session->check_in_time);

       if ($actualStart->gt($expectedStart)) {
           $lateMinutes = $expectedStart->diffInMinutes($actualStart);
           // Apply grace period
           $lateMinutes = max(0, $lateMinutes - $workPlan->permission_minutes);
       }
   }
   ```

**Response (200):**
```json
{
  "success": true,
  "message": "Checked in successfully",
  "data": {
    "session_id": 15,
    "attendance_id": 10,
    "date": "2025-11-10",
    "check_in_time": "09:15:00",
    "session_number": 1,
    "late_minutes": 0,
    "late_label": "On time",
    "is_first_session": true,
    "branch": {
      "name": "Main Office",
      "address": "123 Business St, City"
    },
    "work_plan": {
      "name": "Standard Shift",
      "start_time": "09:00",
      "end_time": "17:00",
      "schedule": "09:00 - 17:00",
      "permission_minutes": 15
    }
  }
}
```

**Error Cases:**
- **400 Bad Request:** No branch assigned, too far from branch, active session exists, no work plan
- **500 Internal Server Error:** Database error

**GPS Distance Calculation (Haversine Formula):**
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

    $a = sin($latDelta / 2) * sin($latDelta / 2) +
         cos($latFrom) * cos($latTo) *
         sin($lonDelta / 2) * sin($lonDelta / 2);

    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

    return $earthRadius * $c;
}
```

---

### 3. Check-Out

**Endpoint:** `POST /api/v1/employee/attendance/check-out`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\AttendanceController@checkOut`

**Request:**
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060
}
```

**Note:** Location is optional for check-out (not validated against branch)

**Process:**

1. **Find Active Session:**
   ```php
   $session = AttendanceSession::where('employee_id', auth()->id())
       ->whereDate('date', today())
       ->whereNull('check_out_time')
       ->orderBy('check_in_time', 'desc')
       ->first();

   if (!$session) {
       return error('No active check-in session found');
   }
   ```

2. **Update Session:**
   ```php
   $session->update([
       'check_out_time' => now(),
       'check_out_latitude' => $latitude,
       'check_out_longitude' => $longitude,
   ]);

   // Auto-calculates duration_hours and duration_minutes via model boot()
   $session->refresh();
   ```

3. **Update Daily Attendance Summary:**
   ```php
   private function updateDailyAttendanceSummary(Attendance $attendance): void
   {
       $sessions = AttendanceSession::where('attendance_id', $attendance->id)
           ->whereNotNull('check_out_time')
           ->get();

       // Total hours from all completed sessions
       $totalHours = $sessions->sum('duration_hours');

       // First and last times
       $firstSession = AttendanceSession::where('attendance_id', $attendance->id)
           ->orderBy('check_in_time', 'asc')
           ->first();

       $lastSession = AttendanceSession::where('attendance_id', $attendance->id)
           ->whereNotNull('check_out_time')
           ->orderBy('check_out_time', 'desc')
           ->first();

       // Calculate late and missing hours
       // ... (uses work plan expected times)

       $attendance->update([
           'check_in_time' => $firstSession?->check_in_time,
           'check_out_time' => $lastSession?->check_out_time,
           'working_hours' => $totalHours,
           'late_minutes' => $lateMinutes,
           'missing_hours' => $missingHours,
       ]);
   }
   ```

**Response (200):**
```json
{
  "success": true,
  "message": "Checked out successfully",
  "data": {
    "session_id": 15,
    "attendance_id": 10,
    "date": "2025-11-10",
    "check_in_time": "09:00:00",
    "check_out_time": "13:00:00",
    "duration_hours": 4.0,
    "duration_label": "4h",
    "session_number": 1,
    "total_sessions_today": 1
  }
}
```

**Duration Calculation:**
```php
public function calculateDuration(): array
{
    if (!$this->check_out_time) {
        return ['hours' => 0, 'minutes' => 0];
    }

    $checkIn = Carbon::parse($this->check_in_time);
    $checkOut = Carbon::parse($this->check_out_time);

    $totalMinutes = $checkIn->diffInMinutes($checkOut);
    $hours = round($totalMinutes / 60, 2);

    return ['hours' => $hours, 'minutes' => $totalMinutes];
}
```

---

### 4. Get Sessions

**Endpoint:** `GET /api/v1/employee/attendance/sessions?date=2025-11-10`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\AttendanceController@getSessions`

**Query Parameters:**
- `date` (optional): Date in Y-m-d format, defaults to today

**Process:**
1. Retrieves all sessions for the specified date
2. Calculates total duration including active session
3. Returns sessions with summary

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "sessions": [
      {
        "id": 15,
        "date": "2025-11-10",
        "check_in_time": "09:00:00",
        "check_out_time": "13:00:00",
        "duration_hours": 4.0,
        "duration_label": "4h",
        "is_active": false,
        "session_type": "regular",
        "notes": null
      },
      {
        "id": 16,
        "date": "2025-11-10",
        "check_in_time": "14:00:00",
        "check_out_time": null,
        "duration_hours": 0,
        "duration_label": "2h 30m",
        "is_active": true,
        "session_type": "regular",
        "notes": null
      }
    ],
    "summary": {
      "total_sessions": 2,
      "active_sessions": 1,
      "completed_sessions": 1,
      "total_duration": "06:30:00",
      "total_hours": 6.5
    }
  }
}
```

---

### 5. Get Real-Time Duration

**Endpoint:** `GET /api/v1/employee/attendance/duration`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\AttendanceController@getDuration`

**Purpose:** Get real-time duration of current active session

**Process:**
1. Finds active session (check_out_time = null)
2. Calculates duration from check_in_time to now()
3. Also returns total duration including completed sessions

**Response (200) - With Active Session:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "current_session_duration": "03:45:30",
    "total_duration_today": "07:45:30",
    "is_active": true,
    "session_id": 15
  }
}
```

**Response (200) - No Active Session:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "duration": "08:00:00",
    "is_active": false
  }
}
```

**Real-Time Calculation:**
```php
$checkIn = Carbon::parse($session->check_in_time);
$now = now();
$duration = $checkIn->diff($now);

$formattedDuration = sprintf('%02d:%02d:%02d',
    $duration->h + ($duration->days * 24),
    $duration->i,
    $duration->s
);
```

---

### 6. Get Attendance History

**Endpoint:** `GET /api/v1/employee/attendance/history?per_page=15&month=2025-11`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\AttendanceController@getHistory`

**Query Parameters:**
- `per_page` (optional): Items per page, default 15
- `month` (optional): Filter by month (format: YYYY-MM)

**Process:**
1. Queries Attendance records (daily summaries)
2. Filters by month if provided
3. Returns paginated results with work plan info

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "items": [
      {
        "id": 10,
        "date": "2025-11-10",
        "day_name": "Sunday",
        "check_in_time": "09:00:00",
        "check_out_time": "17:00:00",
        "working_hours": 8.0,
        "working_hours_label": "8.00h",
        "missing_hours": 0,
        "missing_hours_label": "0.00h",
        "late_minutes": 0,
        "late_label": "On time",
        "is_manual": false,
        "notes": null,
        "work_plan": {
          "name": "Standard Shift",
          "schedule": "09:00 - 17:00"
        }
      }
    ],
    "pagination": {
      "total": 50,
      "count": 15,
      "per_page": 15,
      "current_page": 1,
      "total_pages": 4
    }
  }
}
```

---

### 7. Get Attendance Summary (Admin/Manager)

**Endpoint:** `GET /api/v1/attendance/summary?date=2025-11-10`

**Authentication:** Required (Admin/Manager)

**Controller:** `App\Http\Controllers\Api\V1\Employee\AttendanceController@getSummary`

**Query Parameters:**
- `date` (optional): Date in Y-m-d format, defaults to today

**Purpose:** View all employees' attendance status for a specific date

**Process:**
1. Retrieves all employees with their attendance for the given date
2. Determines status: absent, present, checked_out, or late
3. Calculates total duration from all sessions
4. Returns summary with counts

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "date": "2025-11-10",
    "total_employees": 50,
    "checked_in": 42,
    "absent": 8,
    "employees": [
      {
        "id": 1,
        "name": "John Doe",
        "employee_id": "EMP001",
        "department": "Engineering",
        "position": "Software Developer",
        "status": "present",
        "check_in_time": "09:00 AM",
        "check_out_time": null,
        "duration": "6h 30m",
        "has_active_session": true,
        "late_minutes": 0,
        "total_sessions": 2
      },
      {
        "id": 2,
        "name": "Jane Smith",
        "employee_id": "EMP002",
        "department": "Marketing",
        "position": "Marketing Manager",
        "status": "late",
        "check_in_time": "09:30 AM",
        "check_out_time": "05:00 PM",
        "duration": "7h 30m",
        "has_active_session": false,
        "late_minutes": 30,
        "total_sessions": 1
      },
      {
        "id": 3,
        "name": "Bob Johnson",
        "employee_id": "EMP003",
        "department": "Sales",
        "position": "Sales Representative",
        "status": "absent",
        "check_in_time": null,
        "check_out_time": null,
        "duration": null,
        "has_active_session": false,
        "late_minutes": 0,
        "total_sessions": 0
      }
    ]
  }
}
```

**Status Determination:**
```php
$status = 'absent';
if ($attendance) {
    $activeSession = $attendance->sessions()->whereNull('check_out_time')->first();
    $hasActiveSession = $activeSession !== null;

    if ($hasActiveSession) {
        $status = 'present';
    } else if ($attendance->sessions()->count() > 0) {
        $status = 'checked_out';
    }

    // Override if late
    if ($attendance->late_minutes > 0 && $status !== 'absent') {
        $status = 'late';
    }
}
```

---

## Leave Management Flow

### Overview

The leave system manages vacation requests with:
- Multiple vacation types (annual, sick, emergency, etc.)
- Balance tracking per type
- Approval workflow
- Eligibility rules (unlock after X months, advance notice)
- Cancellation support

**Key Models:**
- **VacationType**: Defines leave types with balance and rules
- **Request**: Polymorphic model for vacation/attendance requests
- **Employee**: Has company_date_of_joining for eligibility calculation

---

### 1. Get Vacation Types

**Endpoint:** `GET /api/v1/leaves/types`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\LeaveController@getVacationTypes`

**Process:**
1. Retrieves all active vacation types
2. Checks availability for authenticated employee based on:
   - `unlock_after_months`: Minimum months since joining
   - `status`: Must be active

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "name": "Annual Leave",
      "description": "Paid annual vacation leave",
      "balance": 21,
      "unlock_after_months": 0,
      "required_days_before": 7,
      "requires_approval": true,
      "is_available": true
    },
    {
      "id": 2,
      "name": "Sick Leave",
      "description": "Medical leave with doctor's note",
      "balance": 10,
      "unlock_after_months": 0,
      "required_days_before": 0,
      "requires_approval": false,
      "is_available": true
    },
    {
      "id": 3,
      "name": "Maternity Leave",
      "description": "Leave for new mothers",
      "balance": 90,
      "unlock_after_months": 12,
      "required_days_before": 30,
      "requires_approval": true,
      "is_available": false
    }
  ]
}
```

**Availability Check:**
```php
public function isAvailableForEmployee(Employee $employee): bool
{
    if (!$this->status) {
        return false;
    }

    if ($this->unlock_after_months === 0) {
        return true; // Immediately available
    }

    $joiningDate = $employee->company_date_of_joining;
    if (!$joiningDate) {
        return true; // No joining date, allow all
    }

    $monthsSinceJoining = $joiningDate->diffInMonths(now());

    return $monthsSinceJoining >= $this->unlock_after_months;
}
```

---

### 2. Apply for Leave

**Endpoint:** `POST /api/v1/leaves`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\LeaveController@applyLeave`

**Request:**
```json
{
  "vacation_type_id": 1,
  "start_date": "2025-11-15",
  "end_date": "2025-11-20",
  "reason": "Family vacation"
}
```

**Validation Rules:**
- `vacation_type_id`: Required, must exist
- `start_date`: Required, must be today or later
- `end_date`: Required, must be >= start_date
- `reason`: Required, max 500 characters

**Process:**

1. **Validate Request:**
   ```php
   $validator = Validator::make($request->all(), [
       'vacation_type_id' => 'required|exists:vacation_types,id',
       'start_date' => 'required|date|after_or_equal:today',
       'end_date' => 'required|date|after_or_equal:start_date',
       'reason' => 'required|string|max:500',
   ]);
   ```

2. **Check Vacation Type:**
   ```php
   $vacationType = VacationType::find($request->vacation_type_id);
   if (!$vacationType || !$vacationType->status) {
       return error('Vacation type not available');
   }
   ```

3. **Calculate Total Days:**
   ```php
   $startDate = Carbon::parse($request->start_date);
   $endDate = Carbon::parse($request->end_date);
   $totalDays = $startDate->diffInDays($endDate) + 1;
   ```

4. **Create Leave Request:**
   ```php
   $leaveRequest = new Request([
       'employee_id' => $user->id,
       'request_type' => 'vacation',
       'requestable_id' => $vacationType->id,
       'requestable_type' => VacationType::class,
       'status' => 'pending',
       'reason' => $request->reason,
       'start_date' => $startDate,
       'end_date' => $endDate,
       'total_days' => $totalDays,
       'request_date' => now(),
   ]);
   ```

5. **Validate Business Rules:**
   ```php
   $validationErrors = $leaveRequest->validateRequest();
   if (!empty($validationErrors)) {
       return error('Leave request validation failed', ['errors' => $validationErrors]);
   }
   ```

6. **Save Request:**
   ```php
   $leaveRequest->save();
   ```

**Response (200):**
```json
{
  "success": true,
  "message": "Leave request submitted successfully",
  "data": {
    "id": 25,
    "vacation_type": "Annual Leave",
    "start_date": "2025-11-15",
    "end_date": "2025-11-20",
    "total_days": 6,
    "status": "pending",
    "reason": "Family vacation",
    "request_date": "2025-11-10",
    "message": "Leave request submitted successfully"
  }
}
```

**Business Rule Validation:**

```php
protected function validateVacationRequest(): array
{
    $errors = [];

    // 1. Check if vacation type is available (unlock_after_months)
    if (!$this->isVacationTypeAvailable()) {
        $errors[] = "This vacation type is not yet available. You need to wait {$this->requestable->unlock_after_months} months after joining.";
    }

    // 2. Check remaining balance
    $remainingBalance = $this->getEmployeeRemainingBalance();
    if ($this->total_days > $remainingBalance) {
        $errors[] = "Insufficient balance. You have {$remainingBalance} days remaining for this vacation type.";
    }

    // 3. Check notice period (required_days_before)
    if ($this->requestable->required_days_before > 0) {
        $noticeDate = now()->addDays($this->requestable->required_days_before);
        if ($this->start_date && $this->start_date->lt($noticeDate)) {
            $errors[] = "This vacation type requires {$this->requestable->required_days_before} days advance notice.";
        }
    }

    return $errors;
}
```

**Error Cases:**
- **400 Bad Request:** Validation failed (insufficient balance, no advance notice, etc.)
- **422 Unprocessable Entity:** Input validation errors

---

### 3. Get Leave History

**Endpoint:** `GET /api/v1/leaves?per_page=15&status=pending`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\LeaveController@getHistory`

**Query Parameters:**
- `per_page` (optional): Items per page, default 15
- `status` (optional): Filter by status (pending, approved, rejected, cancelled)

**Process:**
1. Queries Request records for authenticated employee
2. Filters by status if provided
3. Orders by request_date descending
4. Returns paginated results with vacation type info

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "data": [
      {
        "id": 25,
        "vacation_type": {
          "id": 1,
          "name": "Annual Leave"
        },
        "start_date": "2025-11-15",
        "end_date": "2025-11-20",
        "total_days": 6,
        "status": "pending",
        "reason": "Family vacation",
        "admin_notes": null,
        "request_date": "2025-11-10",
        "approved_at": null,
        "approver_name": null,
        "can_cancel": true
      },
      {
        "id": 24,
        "vacation_type": {
          "id": 2,
          "name": "Sick Leave"
        },
        "start_date": "2025-10-05",
        "end_date": "2025-10-07",
        "total_days": 3,
        "status": "approved",
        "reason": "Medical treatment",
        "admin_notes": "Approved - doctor's note received",
        "request_date": "2025-10-03",
        "approved_at": "2025-10-04 10:30:00",
        "approver_name": "HR Manager",
        "can_cancel": true
      },
      {
        "id": 23,
        "vacation_type": {
          "id": 1,
          "name": "Annual Leave"
        },
        "start_date": "2025-09-01",
        "end_date": "2025-09-05",
        "total_days": 5,
        "status": "approved",
        "reason": "Summer vacation",
        "admin_notes": "Approved",
        "request_date": "2025-08-20",
        "approved_at": "2025-08-22 14:15:00",
        "approver_name": "System Admin",
        "can_cancel": false
      }
    ],
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 45
  }
}
```

**Can Cancel Logic:**
```php
public function canBeCancelled(): bool
{
    return in_array($this->status, ['pending', 'approved']);
}
```

---

### 4. Get Leave Balance

**Endpoint:** `GET /api/v1/leaves/balance`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\LeaveController@getBalance`

**Process:**
1. Retrieves all active vacation types
2. Calculates used days for current year (approved requests only)
3. Calculates remaining balance per type
4. Checks availability based on unlock_after_months

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "balances": [
      {
        "id": 1,
        "name": "Annual Leave",
        "total_balance": 21,
        "used_days": 11,
        "remaining_days": 10,
        "is_available": true
      },
      {
        "id": 2,
        "name": "Sick Leave",
        "total_balance": 10,
        "used_days": 3,
        "remaining_days": 7,
        "is_available": true
      },
      {
        "id": 3,
        "name": "Maternity Leave",
        "total_balance": 90,
        "used_days": 0,
        "remaining_days": 90,
        "is_available": false
      }
    ],
    "total_remaining": 17,
    "year": 2025
  }
}
```

**Calculation:**
```php
$currentYear = now()->year;

// Get used days by vacation type
$usedDays = Request::where('employee_id', $user->id)
    ->where('request_type', 'vacation')
    ->where('requestable_type', VacationType::class)
    ->where('status', 'approved')
    ->whereYear('start_date', $currentYear)
    ->selectRaw('requestable_id, SUM(total_days) as used_days')
    ->groupBy('requestable_id')
    ->pluck('used_days', 'requestable_id');

// Calculate remaining for each type
$used = $usedDays[$vacationType->id] ?? 0;
$remaining = max(0, $vacationType->balance - $used);
```

---

### 5. Get Leave Details

**Endpoint:** `GET /api/v1/leaves/{id}`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\LeaveController@getLeaveDetails`

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "id": 25,
    "vacation_type": {
      "id": 1,
      "name": "Annual Leave",
      "description": "Paid annual vacation leave"
    },
    "start_date": "2025-11-15",
    "end_date": "2025-11-20",
    "total_days": 6,
    "status": "pending",
    "reason": "Family vacation",
    "admin_notes": null,
    "request_date": "2025-11-10",
    "approved_at": null,
    "approver_name": null,
    "can_cancel": true
  }
}
```

---

### 6. Cancel Leave Request

**Endpoint:** `DELETE /api/v1/leaves/{id}`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\LeaveController@cancelLeave`

**Process:**
1. Finds leave request by ID for authenticated employee
2. Checks if can be cancelled (status = pending or approved)
3. Updates status to 'cancelled'

**Response (200):**
```json
{
  "success": true,
  "message": "Leave request cancelled successfully",
  "data": {
    "id": 25,
    "status": "cancelled",
    "message": "Leave request cancelled successfully"
  }
}
```

**Error Cases:**
- **404 Not Found:** Leave request not found
- **400 Bad Request:** Cannot be cancelled (already rejected or cancelled)

---

## Profile Management Flow

### 1. Get Profile

**Endpoint:** `GET /api/v1/profile`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Profile\ProfileController@get`

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "id": 1,
    "name": "John Doe",
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "personal_email": "john.personal@gmail.com",
    "phone": "+1234567890",
    "business_phone": "+1234567891",
    "employee_id": "EMP001",
    "date_of_birth": "1990-01-15",
    "gender": "male",
    "marital_status": "married",
    "national_id": "1234567890",
    "address": "123 Main St, City",
    "emergency_contact_name": "Jane Doe",
    "emergency_contact_relation": "Spouse",
    "emergency_contact_phone": "+1234567892",
    "department_id": 5,
    "position_id": 3,
    "department_name": "Engineering",
    "position_name": "Software Developer",
    "branch_id": 1,
    "branch_name": "Main Office",
    "level": "senior",
    "contract_type": "full_time",
    "social_insurance_status": "active",
    "social_insurance_number": "SSN123456",
    "reporting_to": 10,
    "manager_name": "Manager Name",
    "company_date_of_joining": "2020-01-01",
    "status": true,
    "image": "https://example.com/avatars/john.jpg"
  }
}
```

---

### 2. Update Profile

**Endpoint:** `PUT /api/v1/profile`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Profile\ProfileController@update`

**Request:**
```json
{
  "name": "John Updated Doe",
  "phone": "+1234567890",
  "personal_email": "john.updated@gmail.com",
  "address": "456 New St, City",
  "emergency_contact_name": "Jane Doe",
  "emergency_contact_phone": "+1234567892"
}
```

**Note:** Fields allowed for update may be restricted based on business rules

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    // Updated profile data (same structure as Get Profile)
  }
}
```

---

### 3. Change Password

**Endpoint:** `POST /api/v1/profile/change-password`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Profile\ProfileController@changePassword`

**Request:**
```json
{
  "current_password": "oldpassword123",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Validation Rules:**
- `current_password`: Required
- `password`: Required, min 6 characters, must be confirmed
- `password_confirmation`: Required, must match password

**Process:**
1. Validates current password
2. Validates new password requirements
3. Updates password and sets `password_set_at` timestamp

**Response (200):**
```json
{
  "success": true,
  "message": "updated_successfully",
  "data": null
}
```

**Error Cases:**
- **400 Bad Request:** Current password incorrect
- **422 Unprocessable Entity:** Validation errors

---

### 4. Delete Account

**Endpoint:** `DELETE /api/v1/profile`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Profile\ProfileController@deleteAccount`

**Response (200):**
```json
{
  "success": true,
  "message": "deleted_successfully",
  "data": null
}
```

**Note:** This is a soft delete or status change, not permanent deletion

---

## Notifications Flow

### 1. Get Notifications

**Endpoint:** `GET /api/v1/notifications?per_page=15`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Common\NotificationController@index`

**Query Parameters:**
- `per_page` (optional): Items per page, default 15

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "data": [
      {
        "id": "9c8e7d6f-5e4d-3c2b-1a0f-9e8d7c6b5a4f",
        "type": "App\\Notifications\\LeaveApproved",
        "notifiable_type": "App\\Models\\Hrm\\Employee",
        "notifiable_id": 1,
        "data": {
          "title": "Leave Request Approved",
          "message": "Your annual leave request has been approved",
          "action_url": "/leaves/25"
        },
        "read_at": null,
        "created_at": "2025-11-10 10:30:00"
      },
      {
        "id": "8b7a6c5d-4e3f-2d1c-0b9a-8e7d6c5b4a3f",
        "type": "App\\Notifications\\AttendanceReminder",
        "notifiable_type": "App\\Models\\Hrm\\Employee",
        "notifiable_id": 1,
        "data": {
          "title": "Attendance Reminder",
          "message": "Don't forget to check in today",
          "action_url": "/attendance"
        },
        "read_at": "2025-11-10 09:00:00",
        "created_at": "2025-11-10 08:00:00"
      }
    ],
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 45,
    "unread_count": 5
  }
}
```

---

### 2. Mark as Read

**Endpoint:** `POST /api/v1/notifications/{id}/read`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Common\NotificationController@markAsRead`

**Response (200):**
```json
{
  "success": true,
  "message": "Notification marked as read",
  "data": null
}
```

---

### 3. Mark All as Read

**Endpoint:** `POST /api/v1/notifications/read-all`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Common\NotificationController@markAllAsRead`

**Response (200):**
```json
{
  "success": true,
  "message": "All notifications marked as read",
  "data": null
}
```

---

### 4. Delete Notification

**Endpoint:** `DELETE /api/v1/notifications/{id}`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\User\Common\NotificationController@destroy`

**Response (200):**
```json
{
  "success": true,
  "message": "Notification deleted",
  "data": null
}
```

---

## Work Schedule Flow

### Get Work Schedule

**Endpoint:** `GET /api/v1/work-schedule`

**Authentication:** Required

**Controller:** `App\Http\Controllers\Api\V1\Employee\WorkScheduleController@getWorkSchedule`

**Process:**
1. Retrieves employee with work plans
2. Gets first active work plan
3. Builds weekly schedule array
4. Calculates total weekly hours

**Response (200):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "work_plan": {
      "id": 1,
      "name": "Standard Shift",
      "start_time": "09:00 AM",
      "end_time": "05:00 PM",
      "permission_minutes": 15,
      "working_days": [1, 2, 3, 4, 5]
    },
    "schedule": {
      "shift_type": "Standard Shift",
      "work_days_count": 5,
      "weekly_hours": "40h",
      "break_time": "1 Hour (12:00 PM - 01:00 PM)"
    },
    "weekly_schedule": {
      "Monday": {
        "start": "09:00 AM",
        "end": "05:00 PM",
        "hours": "8h",
        "is_working_day": true
      },
      "Tuesday": {
        "start": "09:00 AM",
        "end": "05:00 PM",
        "hours": "8h",
        "is_working_day": true
      },
      "Wednesday": {
        "start": "09:00 AM",
        "end": "05:00 PM",
        "hours": "8h",
        "is_working_day": true
      },
      "Thursday": {
        "start": "09:00 AM",
        "end": "05:00 PM",
        "hours": "8h",
        "is_working_day": true
      },
      "Friday": {
        "start": "09:00 AM",
        "end": "05:00 PM",
        "hours": "8h",
        "is_working_day": true
      },
      "Saturday": {
        "start": "Day Off",
        "end": "",
        "hours": "0h",
        "is_working_day": false
      },
      "Sunday": {
        "start": "Day Off",
        "end": "",
        "hours": "0h",
        "is_working_day": false
      }
    }
  }
}
```

**Working Days Values:**
- 1 = Monday
- 2 = Tuesday
- 3 = Wednesday
- 4 = Thursday
- 5 = Friday
- 6 = Saturday
- 7 = Sunday

---

## Data Models & Relationships

### 1. Employee Model

**Table:** `employees`

**Key Fields:**
```php
- id (primary key)
- name (string)
- phone (string)
- business_phone (string, nullable)
- date_of_birth (date, nullable)
- gender (enum: male, female)
- marital_status (enum: single, married, divorced, widowed)
- email (string, unique)
- personal_email (string, nullable)
- national_id (string, nullable)
- address (text, nullable)
- emergency_contact_name (string, nullable)
- emergency_contact_relation (string, nullable)
- emergency_contact_phone (string, nullable)
- password (string, hashed)
- employee_id (string, unique, auto-generated: EMP001, EMP002, ...)
- department_id (foreign key, nullable)
- branch_id (foreign key, nullable)
- position_id (foreign key, nullable)
- level (enum: junior, mid, senior, lead, manager)
- contract_type (enum: full_time, part_time, contract, internship)
- social_insurance_status (enum: active, inactive, pending)
- social_insurance_number (string, nullable)
- reporting_to (foreign key to employees.id, nullable)
- company_date_of_joining (date)
- status (boolean, default true)
- password_set_at (datetime, nullable)
- roles (json, nullable)
- permissions (json, nullable)
- company_id (foreign key - for multi-tenancy)
```

**Relationships:**
```php
- department: BelongsTo Department
- branch: BelongsTo Branch
- position: BelongsTo Position
- manager: BelongsTo Employee (self-reference via reporting_to)
- directReports: HasMany Employee (employees reporting to this employee)
- workPlans: BelongsToMany WorkPlan (pivot table: employee_work_plan)
- attendances: HasMany Attendance
- attendanceSessions: HasMany AttendanceSession
- documents: HasMany Document
- assets: HasMany Asset
- medicalInsurance: HasMany MedicalRecord
```

**Authentication:**
- Uses Laravel Sanctum for API tokens
- Implements `HasApiTokens` trait
- Supports notifications via `Notifiable` trait
- Supports media uploads via `HasMedia` trait (profile images)

**Employee ID Generation:**
```php
public static function generateEmployeeId(): string
{
    $prefix = 'EMP';
    $lastEmployee = static::where('employee_id', 'like', $prefix . '%')
        ->orderBy('employee_id', 'desc')
        ->first();

    if ($lastEmployee) {
        $lastNumber = (int) substr($lastEmployee->employee_id, strlen($prefix));
        $newNumber = $lastNumber + 1;
    } else {
        $newNumber = 1;
    }

    return $prefix . str_pad($newNumber, 3, '0', STR_PAD_LEFT);
}
```

---

### 2. Attendance Model

**Table:** `attendances`

**Purpose:** Daily attendance summary (one record per employee per day)

**Key Fields:**
```php
- id (primary key)
- employee_id (foreign key)
- work_plan_id (foreign key)
- date (date)
- check_in_time (time, nullable)
- check_out_time (time, nullable)
- check_in_latitude (decimal(10,8), nullable)
- check_in_longitude (decimal(11,8), nullable)
- check_out_latitude (decimal(10,8), nullable)
- check_out_longitude (decimal(11,8), nullable)
- working_hours (decimal(5,2), auto-calculated)
- missing_hours (decimal(5,2), auto-calculated)
- late_minutes (integer, auto-calculated)
- notes (text, nullable - stores late reason)
- is_manual (boolean, default false)
- company_id (foreign key - for multi-tenancy)
```

**Relationships:**
```php
- employee: BelongsTo Employee
- workPlan: BelongsTo WorkPlan
- sessions: HasMany AttendanceSession
```

**Auto-Calculated Fields (on save):**
```php
protected static function boot()
{
    parent::boot();

    static::saving(function ($attendance) {
        $attendance->working_hours = $attendance->calculateWorkingHours();
        $attendance->missing_hours = $attendance->calculateMissingHours();
        $attendance->late_minutes = $attendance->calculateLateMinutes();
    });
}
```

**Calculations:**

1. **Working Hours:**
   ```php
   public function calculateWorkingHours(): float
   {
       // Sum duration_hours from all completed sessions
       $totalHours = $this->sessions()
           ->whereNotNull('check_out_time')
           ->sum('duration_hours');

       return round($totalHours, 2);
   }
   ```

2. **Missing Hours:**
   ```php
   public function calculateMissingHours(): float
   {
       $workPlan = $this->workPlan;
       if (!$workPlan) return 0;

       $expectedStart = Carbon::parse($workPlan->start_time);
       $expectedEnd = Carbon::parse($workPlan->end_time);
       $expectedHours = round($expectedEnd->diffInMinutes($expectedStart) / 60, 2);

       $actualHours = $this->working_hours;

       return max(0, $expectedHours - $actualHours);
   }
   ```

3. **Late Minutes:**
   ```php
   public function calculateLateMinutes(): int
   {
       $workPlan = $this->workPlan;
       if (!$workPlan) return 0;

       $expectedStart = Carbon::parse($workPlan->start_time);
       $actualStart = Carbon::parse($this->check_in_time);

       if ($actualStart->lte($expectedStart)) {
           return 0; // On time or early
       }

       $lateMinutes = $expectedStart->diffInMinutes($actualStart);

       // Apply grace period
       $lateMinutes = max(0, $lateMinutes - $workPlan->permission_minutes);

       return $lateMinutes;
   }
   ```

**Accessors:**
```php
- day_name: Returns day of week (e.g., "Monday")
- formatted_date: Returns Y-m-d format
- working_hours_label: Returns "8.00h"
- missing_hours_label: Returns "0.50h"
- late_minutes_label: Returns "15m late" or "On time"
```

**Trait:**
- Uses `CompanyOwned` trait for multi-tenancy

---

### 3. AttendanceSession Model

**Table:** `attendance_sessions`

**Purpose:** Individual check-in/check-out sessions (multiple per day)

**Key Fields:**
```php
- id (primary key)
- employee_id (foreign key)
- attendance_id (foreign key)
- work_plan_id (foreign key)
- date (date)
- check_in_time (datetime)
- check_out_time (datetime, nullable)
- check_in_latitude (decimal(10,8), nullable)
- check_in_longitude (decimal(11,8), nullable)
- check_out_latitude (decimal(10,8), nullable)
- check_out_longitude (decimal(11,8), nullable)
- duration_hours (decimal(5,2), auto-calculated)
- duration_minutes (integer, auto-calculated)
- session_type (string, default 'regular')
- notes (text, nullable)
- is_manual (boolean, default false)
```

**Relationships:**
```php
- employee: BelongsTo Employee
- attendance: BelongsTo Attendance
- workPlan: BelongsTo WorkPlan
```

**Auto-Calculated Fields (on save):**
```php
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

**Duration Calculation:**
```php
public function calculateDuration(): array
{
    if (!$this->check_out_time) {
        return ['hours' => 0, 'minutes' => 0];
    }

    $checkIn = Carbon::parse($this->check_in_time);
    $checkOut = Carbon::parse($this->check_out_time);

    $totalMinutes = $checkIn->diffInMinutes($checkOut);
    $hours = round($totalMinutes / 60, 2);

    return ['hours' => $hours, 'minutes' => $totalMinutes];
}
```

**Accessors:**
```php
- is_active: Returns true if check_out_time is null
- duration_label: Returns "4h 30m" or "2h"
- current_duration_label: Returns real-time duration for active session
```

**Scopes:**
```php
- today(): whereDate('date', today())
- active(): whereNull('check_out_time')
- forEmployee($employeeId): where('employee_id', $employeeId)
- forDate($date): whereDate('date', $date)
```

---

### 4. WorkPlan Model

**Table:** `work_plans`

**Purpose:** Defines work schedules (shift timings)

**Key Fields:**
```php
- id (primary key)
- name (string) - e.g., "Standard Shift", "Night Shift"
- start_time (time) - e.g., "09:00:00"
- end_time (time) - e.g., "17:00:00"
- working_days (json array) - e.g., [1, 2, 3, 4, 5] (Monday-Friday)
- permission_minutes (integer) - Grace period for late check-in
- status (boolean, default true)
```

**Relationships:**
```php
- employees: BelongsToMany Employee (pivot table: employee_work_plan)
```

**Accessors:**
```php
- working_days_labels: Returns "Monday, Tuesday, Wednesday, Thursday, Friday"
- schedule: Returns "09:00 - 17:00"
- permission_minutes_label: Returns "15m grace period"
```

**Scope:**
```php
- active(): where('status', true)
```

**Example Data:**
```json
{
  "name": "Standard Shift",
  "start_time": "09:00:00",
  "end_time": "17:00:00",
  "working_days": [1, 2, 3, 4, 5],
  "permission_minutes": 15,
  "status": true
}
```

---

### 5. Branch Model

**Table:** `branches`

**Purpose:** Office/branch locations with GPS validation

**Key Fields:**
```php
- id (primary key)
- name (string)
- code (string, unique)
- address (text, nullable)
- phone (string, nullable)
- email (string, nullable)
- status (boolean, default true)
- latitude (decimal(10,8), nullable)
- longitude (decimal(11,8), nullable)
- radius_meters (integer) - Allowed check-in radius
```

**Relationships:**
```php
- employees: HasMany Employee
```

**GPS Validation Methods:**

1. **Check if location is within radius:**
   ```php
   public function isLocationWithinRadius(float $latitude, float $longitude): bool
   {
       if (!$this->latitude || !$this->longitude) {
           return true; // No location set, allow from anywhere
       }

       $distance = $this->calculateDistance($latitude, $longitude);

       return $distance <= $this->radius_meters;
   }
   ```

2. **Calculate distance (Haversine formula):**
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

       $a = sin($latDelta / 2) * sin($latDelta / 2) +
            cos($latFrom) * cos($latTo) *
            sin($lonDelta / 2) * sin($lonDelta / 2);

       $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

       return $earthRadius * $c; // Distance in meters
   }
   ```

**Scope:**
```php
- active(): where('status', true)
```

---

### 6. VacationType Model

**Table:** `vacation_types`

**Purpose:** Define leave types with rules

**Key Fields:**
```php
- id (primary key)
- name (string) - e.g., "Annual Leave", "Sick Leave"
- description (text, nullable)
- balance (integer) - Total days per year
- unlock_after_months (integer) - Months after joining to unlock
- required_days_before (integer) - Advance notice required
- requires_approval (boolean)
- status (boolean, default true)
```

**Methods:**
```php
public function isAvailableForEmployee(Employee $employee): bool
{
    if (!$this->status) return false;

    if ($this->unlock_after_months === 0) return true;

    $joiningDate = $employee->company_date_of_joining;
    if (!$joiningDate) return true;

    $monthsSinceJoining = $joiningDate->diffInMonths(now());

    return $monthsSinceJoining >= $this->unlock_after_months;
}
```

**Scopes:**
```php
- active(): where('status', true)
- requiresApproval(): where('requires_approval', true)
- immediatelyAvailable(): where('unlock_after_months', 0)
```

**Example Data:**
```json
{
  "name": "Annual Leave",
  "description": "Paid annual vacation leave",
  "balance": 21,
  "unlock_after_months": 0,
  "required_days_before": 7,
  "requires_approval": true,
  "status": true
}
```

---

### 7. Request Model

**Table:** `requests`

**Purpose:** Polymorphic model for vacation/attendance requests

**Key Fields:**
```php
- id (primary key)
- employee_id (foreign key)
- request_type (enum: 'vacation', 'attendance')
- requestable_id (integer) - Polymorphic ID
- requestable_type (string) - Polymorphic type (VacationType, AttendanceType)
- status (enum: 'pending', 'approved', 'rejected', 'cancelled')
- reason (text)
- admin_notes (text, nullable)
- start_date (date)
- end_date (date, nullable)
- total_days (integer)
- request_date (date)
- hours (decimal(5,2), nullable - for attendance requests)
- start_time (time, nullable - for attendance requests)
- end_time (time, nullable - for attendance requests)
- approved_by (foreign key to employees.id, nullable)
- approved_at (datetime, nullable)
- escalate_to (foreign key to employees.id, nullable)
```

**Relationships:**
```php
- employee: BelongsTo Employee
- approver: BelongsTo Employee (via approved_by)
- escalatedTo: BelongsTo Employee
- requestable: MorphTo (VacationType or AttendanceType)
```

**Scopes:**
```php
- pending(): where('status', 'pending')
- approved(): where('status', 'approved')
- rejected(): where('status', 'rejected')
- vacation(): where('request_type', 'vacation')
- attendance(): where('request_type', 'attendance')
```

**Helper Methods:**
```php
- isVacation(): bool
- isAttendance(): bool
- isPending(): bool
- isApproved(): bool
- isRejected(): bool
- canBeApproved(): bool
- canBeRejected(): bool
- canBeCancelled(): bool
- calculateTotalDays(): int
- getEmployeeRemainingBalance(): int
- validateRequest(): array
```

**Validation:**
```php
public function validateRequest(): array
{
    $errors = [];

    if ($this->isVacation()) {
        $errors = array_merge($errors, $this->validateVacationRequest());
    } elseif ($this->isAttendance()) {
        $errors = array_merge($errors, $this->validateAttendanceRequest());
    }

    return $errors;
}
```

**Media Support:**
- Implements `HasMedia` trait
- Collection: `request_attachments` (PDF, images, documents)

---

### 8. Department Model

**Table:** `departments`

**Key Fields:**
```php
- id (primary key)
- name (string)
- status (boolean, default true)
```

**Relationships:**
```php
- employees: HasMany Employee
- positions: HasMany Position
```

**Scope:**
```php
- active(): where('status', true)
```

---

### 9. Position Model

**Table:** `positions`

**Key Fields:**
```php
- id (primary key)
- name (string)
- department_id (foreign key)
- status (boolean, default true)
```

**Relationships:**
```php
- department: BelongsTo Department
- employees: HasMany Employee
```

**Scope:**
```php
- active(): where('status', true)
```

---

### 10. Admin Model

**Table:** `admins`

**Purpose:** Admin users with enhanced permissions

**Key Fields:**
```php
- id (primary key)
- name (string)
- email (string, unique)
- phone (string, nullable)
- password (string, hashed)
- status (boolean, default true)
- last_login_at (datetime, nullable)
- last_login_ip (string, nullable)
```

**Authentication:**
- Uses Laravel Sanctum with 'admin' token abilities
- Separate from Employee authentication

**Token Creation:**
```php
$token = $admin->createToken('admin-token', ['admin'])->plainTextToken;
```

---

## Multi-Tenancy System

### Overview

The system implements **company-based multi-tenancy** where:
- Each company is isolated with its own data
- Data filtering is automatic via global scopes
- Company ID is tracked in session and database

### Key Components

1. **CompanyOwned Trait**
   - Location: `/var/www/erp1/app/Concerns/CompanyOwned.php`
   - Applied to models: Attendance, and other company-specific data
   - Automatically adds `company_id` on model creation
   - Applies `CurrentCompanyScope` global scope

2. **CurrentCompanyScope**
   - Location: `/var/www/erp1/app/Scopes/CurrentCompanyScope.php`
   - Filters all queries by `company_id`
   - Reads from session: `session('current_company_id')`
   - Falls back to authenticated user's `current_company_id`

### How It Works

**1. Model Creation (CompanyOwned trait):**
```php
public static function bootCompanyOwned(): void
{
    static::creating(static function ($model) {
        if (empty($model->company_id)) {
            // Try session first
            $companyId = session('current_company_id');

            // Fall back to authenticated user
            if (!$companyId && ($user = Auth::user()) && ($companyId = $user->current_company_id)) {
                session(['current_company_id' => $companyId]);
            }

            // Special handling for notifications
            if (!$companyId && $model instanceof Notification && $model->notifiable_type === User::class) {
                $notifiable = $model->notifiable;
                if ($notifiable instanceof User) {
                    $companyId = $notifiable->current_company_id;
                }
            }

            if ($companyId) {
                $model->company_id = $companyId;
            } else {
                Log::error('CurrentCompanyScope: No company_id found for user ' . Auth::id());
                throw new ModelNotFoundException('No company_id set');
            }
        }
    });

    static::addGlobalScope(CurrentCompanyScope::class);
}
```

**2. Query Filtering (CurrentCompanyScope):**
```php
public function apply(Builder $builder, Model $model): void
{
    $companyId = session('current_company_id');

    // Allow console commands to bypass scope
    if (!$companyId && app()->runningInConsole()) {
        return;
    }

    // Try authenticated user
    if (!$companyId && ($user = Auth::user()) && ($companyId = $user->current_company_id)) {
        session(['current_company_id' => $companyId]);
    }

    if ($companyId) {
        $builder->where("{$model->getTable()}.company_id", $companyId);
    } else {
        Log::error('CurrentCompanyScope: No company_id found for user ' . Auth::id());
        throw new ModelNotFoundException('No company_id set');
    }
}
```

**3. Bypassing the Scope (when needed):**
```php
// Example from DashboardController
$employee = Employee::withoutGlobalScope(CurrentCompanyScope::class)->find($user->id);
```

### Models Using CompanyOwned

- Attendance
- Employee (likely)
- Request (likely)
- Other HR-related models

### Important Notes

1. **Session Management:**
   - Company ID stored in session: `session('current_company_id')`
   - Set from authenticated user's `current_company_id` field
   - Persists across requests

2. **User Model:**
   - Each user (Employee/Admin) has `current_company_id` field
   - Set during login or company switching

3. **Data Isolation:**
   - All queries automatically filtered by company_id
   - Prevents cross-company data access
   - Enforced at model level (not controller)

4. **Error Handling:**
   - Throws `ModelNotFoundException` if company_id not found
   - Logs errors for debugging
   - Strict enforcement (no fallback to allow access)

---

## Key Business Rules

### 1. Attendance Rules

**Check-In Requirements:**
1. Employee must have an assigned branch
2. Employee must have an active work plan
3. GPS location must be within branch radius (if branch has location set)
4. Cannot check-in if there's already an active session
5. Late reason can be provided only on first check-in of the day

**Check-Out Requirements:**
1. Must have an active session (check_out_time = null)
2. Check-out location is optional (not validated)

**Late Calculation:**
- Only calculated for first session of the day
- Based on work plan's `start_time`
- Grace period applied: `permission_minutes`
- Formula: `late_minutes = max(0, actual_minutes - expected_minutes - grace_period)`

**Duration Calculation:**
- Session duration: `check_out_time - check_in_time`
- Daily total: Sum of all completed sessions
- Real-time duration: `now() - check_in_time` for active session

**Working Hours Calculation:**
- Expected hours: `work_plan.end_time - work_plan.start_time`
- Actual hours: Sum of all session durations
- Missing hours: `expected_hours - actual_hours` (min: 0)

**Multiple Sessions:**
- Unlimited check-in/check-out cycles per day
- Each cycle creates a new AttendanceSession record
- Daily summary (Attendance) updated after each check-out

---

### 2. Leave Management Rules

**Vacation Type Eligibility:**
1. **Unlock Period:**
   - Check if `unlock_after_months` has passed since `company_date_of_joining`
   - If `unlock_after_months = 0`, immediately available
   - Example: Maternity leave might require 12 months

2. **Balance Check:**
   - Calculate used days for current year: `SUM(approved leave days)`
   - Remaining balance: `vacation_type.balance - used_days`
   - Request must not exceed remaining balance

3. **Advance Notice:**
   - Check if `required_days_before` is met
   - Request date + required_days_before ≤ start_date
   - Example: Annual leave might require 7 days notice

**Leave Request Validation:**
```php
protected function validateVacationRequest(): array
{
    $errors = [];

    // 1. Check availability (unlock_after_months)
    if (!$this->isVacationTypeAvailable()) {
        $errors[] = "Not yet available. Wait {$this->requestable->unlock_after_months} months after joining.";
    }

    // 2. Check balance
    $remainingBalance = $this->getEmployeeRemainingBalance();
    if ($this->total_days > $remainingBalance) {
        $errors[] = "Insufficient balance. You have {$remainingBalance} days remaining.";
    }

    // 3. Check notice period
    if ($this->requestable->required_days_before > 0) {
        $noticeDate = now()->addDays($this->requestable->required_days_before);
        if ($this->start_date && $this->start_date->lt($noticeDate)) {
            $errors[] = "Requires {$this->requestable->required_days_before} days advance notice.";
        }
    }

    return $errors;
}
```

**Cancellation Rules:**
- Can cancel if status is `pending` or `approved`
- Cannot cancel if `rejected` or already `cancelled`
- No time-based restrictions (can cancel approved leaves)

---

### 3. GPS Location Rules

**Branch Location Validation:**
```php
public function isLocationWithinRadius(float $latitude, float $longitude): bool
{
    // If branch has no location set, allow from anywhere
    if (!$this->latitude || !$this->longitude) {
        return true;
    }

    $distance = $this->calculateDistance($latitude, $longitude);

    return $distance <= $this->radius_meters;
}
```

**Distance Calculation (Haversine Formula):**
- Calculates great-circle distance between two points
- Returns distance in meters
- Highly accurate for short distances
- Earth radius: 6,371,000 meters

**Check-In Validation:**
- Required: latitude, longitude
- Validated against branch location
- Error if too far: Returns distance and allowed radius
- Check-out: Location optional, not validated

---

### 4. Work Plan Rules

**Work Plan Structure:**
- `start_time` and `end_time` define shift hours
- `working_days` array defines work schedule (1=Mon, 7=Sun)
- `permission_minutes` provides grace period for late arrivals
- One employee can have multiple work plans (uses first active)

**Grace Period Application:**
```php
// If check-in is within permission_minutes, not considered late
$lateMinutes = $actualMinutesLate - $workPlan->permission_minutes;
$lateMinutes = max(0, $lateMinutes); // Cannot be negative
```

**Expected Hours:**
```php
$expectedStart = Carbon::parse($workPlan->start_time);
$expectedEnd = Carbon::parse($workPlan->end_time);
$expectedHours = round($expectedEnd->diffInMinutes($expectedStart) / 60, 2);
```

---

### 5. Multi-Tenancy Rules

**Company Isolation:**
- All queries automatically filtered by `company_id`
- Employee in Company A cannot see data from Company B
- Enforced at model level via global scopes
- Session-based company tracking

**Company ID Resolution:**
1. Try session: `session('current_company_id')`
2. Fall back to authenticated user: `Auth::user()->current_company_id`
3. For notifications: Use notifiable user's company_id
4. Throw error if not found (strict enforcement)

**Bypassing Scope:**
```php
// Only when absolutely necessary (e.g., system operations)
Model::withoutGlobalScope(CurrentCompanyScope::class)->get();
```

---

### 6. Authentication Rules

**Employee Authentication:**
- Email + password
- Account must be active (`status = true`)
- Token stored in `personal_access_tokens` table
- Token name: 'api-token'
- No token expiration (until logout or revoked)

**Admin Authentication:**
- Separate from employee authentication
- Token abilities: `['admin']`
- Token name: 'admin-token'
- Last login timestamp and IP tracked

**Token Management:**
- One token per session (previous token deleted on new login)
- Logout deletes current token: `$request->user()->currentAccessToken()->delete()`
- Can have multiple active tokens from different devices

---

### 7. Data Validation Rules

**Email Validation:**
- Must be valid email format
- Must be unique in employees table
- Required for login and registration

**Password Rules:**
- Minimum 6 characters
- Must be confirmed (password_confirmation) for registration/reset
- Hashed using bcrypt
- `password_set_at` timestamp tracked

**Date Rules:**
- Leave start_date: Must be today or later
- Leave end_date: Must be >= start_date
- Attendance date: Automatically set to today
- Date format: Y-m-d (2025-11-10)

**GPS Coordinates:**
- Latitude: Decimal(10,8) - e.g., 40.71280000
- Longitude: Decimal(11,8) - e.g., -74.00600000
- Required for check-in (if branch has location)
- Optional for check-out

---

## API Response Format

### Success Response Structure

**Class:** `App\Http\Responses\DataResponse`

**Format:**
```json
{
  "success": true,
  "message": "Success message",
  "data": { /* payload */ }
}
```

**HTTP Status Codes:**
- `200 OK`: Successful GET, PUT, POST, DELETE
- `201 Created`: Successful resource creation (e.g., registration)

**UTF-8 Cleaning:**
The response class automatically cleans UTF-8 data:
```php
private function cleanUtf8(mixed $value): mixed
{
    if (is_string($value)) {
        // Remove invalid UTF-8 characters
        $cleaned = mb_convert_encoding($value, 'UTF-8', 'UTF-8');
        // Remove non-printable characters except newlines and tabs
        return preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/u', '', $cleaned);
    }

    if (is_array($value)) {
        return array_map(fn($item) => $this->cleanUtf8($item), $value);
    }

    if (is_object($value)) {
        $cleaned = [];
        foreach ($value as $key => $val) {
            $cleaned[$key] = $this->cleanUtf8($val);
        }
        return $cleaned;
    }

    return $value;
}
```

**Example:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": 1,
    "name": "John Doe",
    "access_token": "1|abc123..."
  }
}
```

---

### Error Response Structure

**Class:** `App\Http\Responses\ErrorResponse`

**Format:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": { /* optional validation errors */ }
}
```

**HTTP Status Codes:**
- `400 Bad Request`: Business logic error (e.g., active session exists)
- `401 Unauthorized`: Authentication failed
- `403 Forbidden`: Access denied (e.g., inactive account)
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server/database error

**Validation Error Example:**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 6 characters."]
  }
}
```

**Business Logic Error Example:**
```json
{
  "success": false,
  "message": "You are too far from the branch location to check in",
  "errors": {
    "distance_meters": 850,
    "allowed_radius": 500
  }
}
```

**Generic Error Example:**
```json
{
  "success": false,
  "message": "Something went wrong"
}
```

---

### Common Error Scenarios

**1. Authentication Errors:**
```json
// 401 Unauthorized - Invalid credentials
{
  "success": false,
  "message": "Invalid credentials"
}

// 403 Forbidden - Account inactive
{
  "success": false,
  "message": "Account is inactive",
  "errors": {
    "status": ["Your account has been deactivated. Please contact support."]
  }
}
```

**2. Attendance Errors:**
```json
// 400 Bad Request - No branch assigned
{
  "success": false,
  "message": "No branch assigned to you. Please contact HR."
}

// 400 Bad Request - Too far from branch
{
  "success": false,
  "message": "You are too far from the branch location to check in",
  "errors": {
    "distance_meters": 850,
    "allowed_radius": 500
  }
}

// 400 Bad Request - Active session exists
{
  "success": false,
  "message": "You have an active session. Please check out first.",
  "errors": {
    "session_id": 15,
    "check_in_time": "09:00:00",
    "duration": "3h 45m"
  }
}

// 400 Bad Request - No active session
{
  "success": false,
  "message": "No active check-in session found for today"
}
```

**3. Leave Request Errors:**
```json
// 400 Bad Request - Validation failed
{
  "success": false,
  "message": "Leave request validation failed",
  "errors": {
    "errors": [
      "Insufficient balance. You have 5 days remaining for this vacation type.",
      "This vacation type requires 7 days advance notice."
    ]
  }
}

// 400 Bad Request - Cannot cancel
{
  "success": false,
  "message": "This leave request cannot be cancelled"
}
```

**4. Profile Errors:**
```json
// 400 Bad Request - Wrong current password
{
  "success": false,
  "message": "Current password is incorrect"
}

// 422 Unprocessable Entity - Validation error
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "password": ["The password confirmation does not match."]
  }
}
```

---

## Flow Diagrams

### 1. User Journey Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        APP LAUNCH                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Check Token     │
                    │ in Storage      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────────────┐
                    │ Token Exists?           │
                    └─────┬─────────────┬─────┘
                          │ No          │ Yes
                          │             │
              ┌───────────▼───────┐     │
              │  LOGIN SCREEN     │     │
              └───────────┬───────┘     │
                          │             │
              ┌───────────▼────────┐    │
              │ Enter Credentials  │    │
              └───────────┬────────┘    │
                          │             │
              ┌───────────▼────────┐    │
              │ POST /auth/login   │    │
              └───────────┬────────┘    │
                          │             │
              ┌───────────▼─────────┐   │
              │ Receive Token       │   │
              │ & User Data         │   │
              └───────────┬─────────┘   │
                          │             │
              ┌───────────▼─────────┐   │
              │ Store Token         │   │
              │ (Secure Storage)    │   │
              └───────────┬─────────┘   │
                          │             │
                          └─────────────┤
                                        │
                             ┌──────────▼──────────┐
                             │  DASHBOARD SCREEN   │
                             └──────────┬──────────┘
                                        │
                             ┌──────────▼──────────┐
                             │ GET /dashboard/stats│
                             └──────────┬──────────┘
                                        │
            ┌───────────────────────────┼───────────────────────────┐
            │                           │                           │
    ┌───────▼────────┐       ┌─────────▼────────┐      ┌──────────▼─────────┐
    │  ATTENDANCE    │       │      LEAVES      │      │      PROFILE       │
    │    SCREEN      │       │      SCREEN      │      │      SCREEN        │
    └───────┬────────┘       └─────────┬────────┘      └──────────┬─────────┘
            │                          │                           │
    ┌───────▼────────┐       ┌─────────▼────────┐      ┌──────────▼─────────┐
    │ Check-In/Out   │       │ Apply Leave      │      │ Edit Profile       │
    │ View History   │       │ View Balance     │      │ Change Password    │
    │ View Sessions  │       │ View History     │      │ View Details       │
    └────────────────┘       └──────────────────┘      └────────────────────┘
```

---

### 2. Attendance Flow (Multiple Sessions)

```
┌─────────────────────────────────────────────────────────────────┐
│                   ATTENDANCE MAIN SCREEN                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ GET /status     │
                    └────────┬────────┘
                             │
                    ┌────────▼─────────────────┐
                    │ has_active_session?      │
                    └─────┬──────────────┬─────┘
                          │ No           │ Yes
                          │              │
              ┌───────────▼───────┐      │
              │ Show CHECK-IN     │      │
              │     Button        │      │
              └───────────┬───────┘      │
                          │              │
              ┌───────────▼────────┐     │
              │ User Taps Check-In │     │
              └───────────┬────────┘     │
                          │              │
              ┌───────────▼────────┐     │
              │ Get GPS Location   │     │
              └───────────┬────────┘     │
                          │              │
              ┌───────────▼────────┐     │
              │ Is First Session?  │     │
              └─────┬─────────┬────┘     │
                    │ Yes     │ No       │
                    │         │          │
        ┌───────────▼───┐     │          │
        │ Check if Late │     │          │
        └───────────┬───┘     │          │
                    │         │          │
        ┌───────────▼───────┐ │          │
        │ Late?             │ │          │
        └─────┬─────────┬───┘ │          │
              │ Yes     │ No  │          │
              │         │     │          │
    ┌─────────▼───┐     │     │          │
    │ Show Late   │     │     │          │
    │ Reason      │     │     │          │
    │ Prompt      │     │     │          │
    └─────────┬───┘     │     │          │
              │         │     │          │
              └─────────┼─────┼──────────┤
                        │     │          │
              ┌─────────▼─────▼──────────▼─┐
              │ POST /check-in             │
              │ (latitude, longitude,      │
              │  late_reason?)             │
              └─────────┬──────────────────┘
                        │
              ┌─────────▼──────────────────┐
              │ Backend:                   │
              │ 1. Validate branch         │
              │ 2. Validate GPS            │
              │ 3. Check active session    │
              │ 4. Create/update daily     │
              │    attendance              │
              │ 5. Create new session      │
              └─────────┬──────────────────┘
                        │
              ┌─────────▼──────────────────┐
              │ Success Response           │
              │ (session_id, late_info)    │
              └─────────┬──────────────────┘
                        │
                        └────────────────────┐
                                             │
                             ┌───────────────▼──────────┐
                             │ Show CHECK-OUT Button    │
                             │ Start Duration Timer     │
                             └───────────────┬──────────┘
                                             │
                             ┌───────────────▼──────────┐
                             │ User Taps Check-Out      │
                             └───────────────┬──────────┘
                                             │
                             ┌───────────────▼──────────┐
                             │ POST /check-out          │
                             │ (latitude?, longitude?)  │
                             └───────────────┬──────────┘
                                             │
                             ┌───────────────▼──────────┐
                             │ Backend:                 │
                             │ 1. Find active session   │
                             │ 2. Update check_out_time │
                             │ 3. Calculate duration    │
                             │ 4. Update daily summary  │
                             └───────────────┬──────────┘
                                             │
                             ┌───────────────▼──────────┐
                             │ Success Response         │
                             │ (duration, session_info) │
                             └───────────────┬──────────┘
                                             │
                             ┌───────────────▼──────────┐
                             │ Back to CHECK-IN Button  │
                             │ (Can check-in again)     │
                             └──────────────────────────┘
```

---

### 3. Leave Request Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     LEAVES MAIN SCREEN                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ GET /balance    │
                    └────────┬────────┘
                             │
                    ┌────────▼──────────────┐
                    │ Display Balance       │
                    │ (per vacation type)   │
                    └────────┬──────────────┘
                             │
                    ┌────────▼──────────────┐
                    │ User Taps             │
                    │ "Apply Leave"         │
                    └────────┬──────────────┘
                             │
                    ┌────────▼──────────────┐
                    │ GET /types            │
                    └────────┬──────────────┘
                             │
                    ┌────────▼──────────────┐
                    │ Show Available        │
                    │ Vacation Types        │
                    └────────┬──────────────┘
                             │
                    ┌────────▼──────────────┐
                    │ User Selects:         │
                    │ - Vacation Type       │
                    │ - Start Date          │
                    │ - End Date            │
                    │ - Reason              │
                    └────────┬──────────────┘
                             │
                    ┌────────▼──────────────┐
                    │ Client Validation:    │
                    │ - End >= Start        │
                    │ - Start >= Today      │
                    │ - Reason not empty    │
                    └────────┬──────────────┘
                             │
                    ┌────────▼──────────────┐
                    │ POST /leaves          │
                    │ (vacation_type_id,    │
                    │  start_date, end_date,│
                    │  reason)              │
                    └────────┬──────────────┘
                             │
                    ┌────────▼──────────────┐
                    │ Backend Validation:   │
                    │ 1. Type available?    │
                    │ 2. Balance enough?    │
                    │ 3. Advance notice OK? │
                    └─────┬──────────┬──────┘
                          │ Valid    │ Invalid
                          │          │
              ┌───────────▼───────┐  │
              │ Create Request    │  │
              │ (status: pending) │  │
              └───────────┬───────┘  │
                          │          │
              ┌───────────▼───────┐  │
              │ Success Response  │  │
              │ (request_id)      │  │
              └───────────┬───────┘  │
                          │          │
              ┌───────────▼────────┐ │
              │ Show Success       │ │
              │ Message            │ │
              └───────────┬────────┘ │
                          │          │
                          └──────────┤
                                     │
                          ┌──────────▼──────────┐
                          │ Show Error Message  │
                          │ (validation errors) │
                          └──────────┬──────────┘
                                     │
                          ┌──────────▼──────────┐
                          │ Back to Form        │
                          └─────────────────────┘
```

---

### 4. Data Sync Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    APP FOREGROUND / PULL TO REFRESH              │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼────────┐  ┌───────▼────────┐  ┌──────▼─────────┐
│ Dashboard Data  │  │ Attendance     │  │ Leave Data     │
│ Sync            │  │ Data Sync      │  │ Sync           │
└────────┬────────┘  └───────┬────────┘  └──────┬─────────┘
         │                   │                   │
┌────────▼────────┐  ┌───────▼────────┐  ┌──────▼─────────┐
│ GET /dashboard/ │  │ GET /employee/ │  │ GET /leaves    │
│     stats       │  │ attendance/    │  │ GET /balance   │
└────────┬────────┘  │     status     │  └──────┬─────────┘
         │           └───────┬────────┘          │
         │                   │                   │
         │           ┌───────▼────────┐          │
         │           │ GET /employee/ │          │
         │           │ attendance/    │          │
         │           │     sessions   │          │
         │           └───────┬────────┘          │
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Update State    │
                    │ (BLoC/Cubit)    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Emit New State  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ UI Rebuilds     │
                    │ (BlocBuilder)   │
                    └─────────────────┘
```

---

### 5. State Management Flow (BLoC Pattern)

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI LAYER                                 │
│  (Screens, Widgets)                                              │
└────────────────────────────┬────────────────────────────────────┘
                             │ User Action
                             │ (e.g., tap check-in button)
                             │
                    ┌────────▼────────┐
                    │  BlocBuilder /  │
                    │  BlocConsumer   │
                    └────────┬────────┘
                             │ Calls cubit method
                             │ context.read<AttendanceCubit>().checkIn()
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       BUSINESS LOGIC LAYER                       │
│  (Cubit)                                                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Emit Loading    │
                    │ State           │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Call Repository │
                    │ Method          │
                    └────────┬────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                        DATA LAYER                                │
│  (Repository)                                                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Call DioClient  │
                    │ Singleton       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ HTTP Request    │
                    │ (with token)    │
                    └────────┬────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                         BACKEND API                              │
│  (Laravel Controllers)                                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Process Request │
                    │ Business Logic  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Database Query  │
                    │ (with company   │
                    │  scope)         │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Return Response │
                    │ (DataResponse)  │
                    └────────┬────────┘
                             │
                             │ Response travels back up
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                        DATA LAYER                                │
│  (Repository)                                                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Parse Response  │
                    │ Create Model    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Return Model    │
                    │ to Cubit        │
                    └────────┬────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       BUSINESS LOGIC LAYER                       │
│  (Cubit)                                                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Emit Success    │
                    │ State (with     │
                    │ data)           │
                    └────────┬────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                         UI LAYER                                 │
│  (Screens, Widgets)                                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ BlocBuilder     │
                    │ Rebuilds with   │
                    │ new state       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ UI Updates      │
                    │ (show data,     │
                    │  success msg)   │
                    └─────────────────┘
```

---

## Complete API Endpoint Reference

### Authentication Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/login` | No | Employee login |
| POST | `/api/v1/auth/register` | No | Employee registration (testing) |
| POST | `/api/v1/auth/logout` | Yes | Employee logout |
| POST | `/api/v1/auth/reset-password` | No | Reset password |
| POST | `/api/v1/auth/check-user` | No | Check if user exists |
| POST | `/api/v1/admin/auth/login` | No | Admin login |
| POST | `/api/v1/admin/auth/logout` | Yes | Admin logout |
| GET | `/api/v1/admin/auth/profile` | Yes | Get admin profile |

### Dashboard Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/dashboard/stats` | Yes | Get dashboard statistics |

### Attendance Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/employee/attendance/check-in` | Yes | Check in (create session) |
| POST | `/api/v1/employee/attendance/check-out` | Yes | Check out (close session) |
| GET | `/api/v1/employee/attendance/status` | Yes | Get today's status |
| GET | `/api/v1/employee/attendance/duration` | Yes | Get real-time duration |
| GET | `/api/v1/employee/attendance/sessions` | Yes | Get sessions (default: today) |
| GET | `/api/v1/employee/attendance/history` | Yes | Get attendance history |
| GET | `/api/v1/attendance/summary/today` | Yes | Get today's summary (all employees) |
| GET | `/api/v1/attendance/summary` | Yes | Get summary for date (all employees) |

### Leave Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/leaves/types` | Yes | Get vacation types |
| POST | `/api/v1/leaves` | Yes | Apply for leave |
| GET | `/api/v1/leaves` | Yes | Get leave history |
| GET | `/api/v1/leaves/balance` | Yes | Get leave balance |
| GET | `/api/v1/leaves/{id}` | Yes | Get leave details |
| DELETE | `/api/v1/leaves/{id}` | Yes | Cancel leave request |

### Profile Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/profile` | Yes | Get profile |
| PUT | `/api/v1/profile` | Yes | Update profile |
| POST | `/api/v1/profile/change-password` | Yes | Change password |
| DELETE | `/api/v1/profile` | Yes | Delete account |

### Notification Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/notifications` | Yes | Get notifications |
| POST | `/api/v1/notifications/{id}/read` | Yes | Mark as read |
| POST | `/api/v1/notifications/read-all` | Yes | Mark all as read |
| DELETE | `/api/v1/notifications/{id}` | Yes | Delete notification |

### Work Schedule Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/work-schedule` | Yes | Get work schedule |

### Department Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/departments` | No | Get all departments |
| GET | `/api/v1/departments/{id}/positions` | No | Get positions for department |

---

## Implementation Checklist for Flutter App

### Priority 1: Core Features (Must Have)

- [ ] **Authentication**
  - [ ] Login screen with email/password
  - [ ] Logout functionality
  - [ ] Token storage (flutter_secure_storage)
  - [ ] Auto-login if token exists
  - [ ] Password reset flow

- [ ] **Attendance**
  - [ ] Check-in with GPS (location permission)
  - [ ] Check-out functionality
  - [ ] Real-time duration display
  - [ ] Multiple sessions support
  - [ ] Late reason prompt (if late on first check-in)
  - [ ] View today's status
  - [ ] View all sessions for today
  - [ ] View attendance history (paginated)

- [ ] **Dashboard**
  - [ ] Display attendance percentage
  - [ ] Display hours worked this month
  - [ ] Display leave balance summary
  - [ ] Quick action cards (check-in, apply leave, etc.)

### Priority 2: Important Features

- [ ] **Leave Management**
  - [ ] View available vacation types
  - [ ] Apply for leave (date picker, reason)
  - [ ] View leave history (with filters)
  - [ ] View leave balance per type
  - [ ] Cancel leave request
  - [ ] View leave details

- [ ] **Profile**
  - [ ] View profile information
  - [ ] Edit profile (limited fields)
  - [ ] Change password
  - [ ] Upload/change profile picture

### Priority 3: Nice to Have

- [ ] **Notifications**
  - [ ] View notifications list
  - [ ] Mark as read
  - [ ] Delete notification
  - [ ] Push notifications (Firebase)

- [ ] **Work Schedule**
  - [ ] View weekly schedule
  - [ ] View work plan details

- [ ] **Admin Features** (if applicable)
  - [ ] View all employees attendance summary
  - [ ] Approve/reject leave requests

### Technical Implementation Tasks

- [ ] **API Integration**
  - [ ] DioClient singleton setup
  - [ ] ApiInterceptor for token injection
  - [ ] Error handling middleware
  - [ ] API response models with json_serializable

- [ ] **State Management**
  - [ ] BLoC/Cubit setup for each feature
  - [ ] State classes with Equatable
  - [ ] copyWith methods for immutable updates
  - [ ] Repository pattern implementation

- [ ] **UI Components**
  - [ ] Custom button widget
  - [ ] Custom text field widget
  - [ ] Loading indicators
  - [ ] Error display widgets
  - [ ] Success/failure snackbars

- [ ] **Navigation**
  - [ ] Named routes setup
  - [ ] Bottom navigation bar
  - [ ] Route guards (protected routes)
  - [ ] Deep linking support

- [ ] **Local Storage**
  - [ ] Token storage (secure)
  - [ ] User data caching
  - [ ] Offline mode support (future)

### Testing Tasks

- [ ] Unit tests for cubits
- [ ] Unit tests for repositories
- [ ] Widget tests for key screens
- [ ] Integration tests for critical flows
- [ ] API endpoint testing (Postman/Insomnia)

---

## Notes for Flutter Developers

### 1. Critical Implementation Details

**Attendance Multiple Sessions:**
- ALWAYS use `has_active_session` from API response to determine button state
- DO NOT rely on `has_checked_in && !check_out_time` (breaks with multiple sessions)
- Implement state persistence to maintain status during loading states
- Auto-refresh status after successful check-in/check-out

**GPS Location:**
- Request location permissions on app start
- Use `geolocator` package for GPS
- Handle location errors gracefully
- Show distance error message to user if too far

**Token Management:**
- Store token in `flutter_secure_storage`
- Add token to all API requests via interceptor
- Handle 401 responses (logout user)
- Refresh token on app resume (if supported)

### 2. Error Handling Pattern

```dart
try {
  emit(state.copyWith(isLoading: true, error: null));

  final data = await _repo.fetchData();

  emit(state.copyWith(
    isLoading: false,
    data: data,
  ));
} catch (e) {
  emit(state.copyWith(
    isLoading: false,
    error: e.toString(),
  ));
}
```

### 3. API Response Parsing

Always check `success` field:
```dart
if (response.statusCode == 200 && response.data['success'] == true) {
  return Model.fromJson(response.data['data']);
} else {
  throw Exception(response.data['message'] ?? 'Unknown error');
}
```

### 4. Date/Time Formatting

Use `intl` package:
```dart
import 'package:intl/intl.dart';

// Format date for API: Y-m-d
final dateString = DateFormat('yyyy-MM-dd').format(date);

// Format time for display: H:i
final timeString = DateFormat('HH:mm').format(dateTime);

// Format date for display: Nov 10, 2025
final displayDate = DateFormat('MMM dd, yyyy').format(date);
```

### 5. Pull-to-Refresh Pattern

```dart
Future<void> _onRefresh() async {
  await Future.wait([
    context.read<AttendanceCubit>().fetchTodayStatus(),
    context.read<AttendanceCubit>().fetchTodaySessions(),
  ]);
}
```

---

## Conclusion

This comprehensive workflow document covers:
- Complete authentication flow (employee & admin)
- Detailed attendance system with multiple sessions support
- Leave management with balance tracking
- Profile and notification management
- Data models and relationships
- Multi-tenancy system architecture
- Business rules and validations
- API response formats
- Flow diagrams

**Key Takeaways:**
1. The system uses token-based authentication (Laravel Sanctum)
2. Attendance supports unlimited check-in/check-out cycles per day
3. Leave requests are validated against balance, eligibility, and advance notice
4. Multi-tenancy is enforced at the model level via global scopes
5. All API responses follow a standardized format (DataResponse/ErrorResponse)
6. GPS validation is critical for attendance check-in

**For Questions or Clarifications:**
Refer to the actual backend code at:
- **Server:** root@31.97.46.103
- **Path:** /var/www/erp1
- **API Base URL:** https://erp1.bdcbiz.com/api/v1

This document should serve as the single source of truth for mobile app development against this backend API.
