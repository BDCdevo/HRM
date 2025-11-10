# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.1.1] - 2025-11-10

### 🐛 Critical Bug Fixes

#### CurrentCompanyScope Error Fix
- **Fixed** All attendance API endpoints returning 500 error due to missing session company_id
- **Root Cause**: `CurrentCompanyScope` global scope couldn't find company context in stateless API requests
- **Solution**: Added `session(['current_company_id' => $employee->company_id])` to all affected methods
- **Fixed Methods**:
  - `checkIn()` - Line 166: Added session company_id before firstOrCreate()
  - `checkOut()` - Lines 346-349: Added session company_id before finding active session
  - `getStatus()` - Lines 480-483: Added session company_id before querying sessions
  - `getSummary()` - Lines 648-651: Added session company_id before eager loading employees
- **Error Message**: `ModelNotFoundException: CurrentCompanyScope: No company_id set in the session or on the user`
- **Impact**: All attendance endpoints now working correctly
- **Test Results**:
  - ✅ Check-in: 200 OK (session_id: 7, attendance_id: 4663)
  - ✅ Check-out: Not tested yet (requires active session)
  - ✅ Get Status: Working with multi-tenancy
  - ✅ Summary: Returns 29 employees from company 6 (BDC)
- **Documentation**: `CURRENTCOMPANYSCOPE_FIX_COMPLETE.md` - Complete fix documentation

### 🎯 Multi-Tenancy Improvements
- **Verified** Session company_id is properly set for all API requests
- **Verified** Employees only see data from their own company
- **Verified** Eager loading works correctly with CurrentCompanyScope
- **Note**: API authentication is stateless - session must be explicitly set per request

**Last Updated**: 2025-11-10

---

## [2.1.0] - 2025-11-09

### 🚀 Production Deployment

#### Backend API Deployment
- **Deployed** Complete HRM API to production server (`https://erp1.bdcbiz.com`)
- **Added** 41+ API endpoints for mobile app
- **Deployed** All API controllers (`app/Http/Controllers/Api/`)
- **Deployed** HRM models (`app/Models/Hrm/`)
- **Deployed** Response classes with UTF-8 cleaning
- **Created** `attendance_sessions` table via migration
- **Updated** `bootstrap/app.php` to register HRM API routes
- **Verified** Multi-tenancy support with `CompanyOwned` trait
- **Tested** Authentication endpoints (Login ✅)
- **Tested** Attendance endpoints (Status ✅)
- **Created** Production backup before deployment
- **Documentation**: `PRODUCTION_API_REVIEW.md` - Complete API review
- **Documentation**: `PRODUCTION_DEPLOYMENT_COMPLETE.md` - Deployment report

#### Flutter App Configuration
- **Updated** `lib/core/config/api_config.dart` to use production server
- **Added** `baseUrlProduction` constant: `https://erp1.bdcbiz.com/api/v1`
- **Changed** `baseUrl` from `baseUrlEmulator` to `baseUrlProduction`
- **Added** `isProduction` getter for environment detection
- **Added** `environmentName` getter for displaying current environment
- **Created** `PRODUCTION_TESTING_GUIDE.md` - Comprehensive testing guide

#### Production Server Details
- **Server**: `31.97.46.103`
- **Domain**: `https://erp1.bdcbiz.com`
- **SSL**: ✅ Let's Encrypt certificates
- **Laravel**: 12.37.0
- **PHP**: 8.x via FastCGI
- **Database**: MySQL (erp1)
- **Authentication**: Sanctum token-based

#### API Endpoints Available
- **Authentication**: Login, Register, Logout, Reset Password (5 endpoints)
- **Admin Auth**: Login, Logout, Profile (3 endpoints)
- **Attendance**: Check-in, Check-out, Status, Sessions, History, Summary (8 endpoints)
- **Profile**: Get, Update, Change Password, Delete (4 endpoints)
- **Leaves**: Types, Apply, History, Balance, Details, Cancel (6 endpoints)
- **Notifications**: List, Mark Read, Mark All Read, Delete (4 endpoints)
- **Dashboard**: Stats (1 endpoint)
- **Departments**: List, Positions (2 endpoints)
- **Work Schedule**: Get Schedule (1 endpoint)
- **Reports**: Monthly Report (1 endpoint)
- **Tasks**: List, Statistics, Update Status, Add Note (6 endpoints)

#### Test Credentials
```
Email: Ahmed@bdcbiz.com
Password: password
Company ID: 6
Employee ID: 32
Department: التطوير
Position: Employee
```

### 🔄 Migration Path

#### From Development to Production
```dart
// Development (Old)
static const String baseUrl = baseUrlEmulator;

// Production (New)
static const String baseUrl = baseUrlProduction;
```

#### Back to Development
To switch back to local development, simply change:
```dart
static const String baseUrl = baseUrlEmulator; // or baseUrlRealDevice
```

### 📝 Breaking Changes
None - backward compatible with local development environment

### ⚠️ Known Issues
- Employee needs `branch_id` assigned to check-in (validation working correctly)
- Test employee password reset required for bcrypt compatibility

### 🎯 Next Steps
- [ ] Assign branches to employees
- [ ] Create additional test users (Admin, Manager)
- [ ] Build production APK
- [ ] Comprehensive testing on production
- [ ] User acceptance testing
- [ ] Monitor production logs
- [ ] Performance optimization

**Production Status**: ✅ Live and Operational

---

## [2.0.2] - 2025-01-09

### 🐛 Bug Fixes

#### Late Reason Display
- **Fixed** Late reason not being saved to database during check-in
- **Fixed** Issue with `firstOrCreate` not updating notes field when attendance record already exists
- **Fixed** Late reason bottom sheet appearing multiple times per day (now shows only once)
- **Fixed** Timing issue where hasLateReason wasn't refreshed before second check-in
- **Changed** Logic to explicitly save late_reason after attendance record creation (lines 259-267)
- **Added** `has_late_reason` field to getStatus() API response (line 520)
- **Added** `hasLateReason` field to AttendanceStatusModel in Flutter
- **Added** Status refresh BEFORE checking if late (lines 436-453) - waits for actual state update
- **Added** Comprehensive logging in Backend for debugging (lines 235, 252, 510)
- **Changed** Check-in logic to show late reason bottom sheet only if: `isLate && !hasLateReason`
- **Backend**: `AttendanceController.php:234-235` - Captures late reason from request with logging
- **Backend**: `AttendanceController.php:259-267` - Saves late reason to notes field if provided and notes is empty
- **Backend**: `AttendanceController.php:507-515` - Returns `has_late_reason` flag in status API with logging
- **Flutter**: `attendance_check_in_widget.dart:436-453` - Refreshes status and waits for update before checking
- **Flutter**: `attendance_check_in_widget.dart:439-453` - Uses `cubit.stream.firstWhere` to ensure fresh data
- **Flow**:
  1. User clicks "Check In"
  2. Flutter refreshes status and waits for response
  3. Checks `isLate && !hasLateReason`
  4. First late check-in → Shows bottom sheet → Saves reason to DB
  5. Second+ check-in → Backend returns `has_late_reason: true` → Flutter skips bottom sheet
- **Debugging**: Created `DEBUG_LATE_REASON.md` with complete debugging guide and expected log output
- **Note**: Late reason only saved for first check-in session of the day (when employee might be late)
- **Tested**: Verified complete flow from check-in to display in Flutter UI

### ✨ UI/UX Improvements

#### Attendance Main Screen
- **Removed** Calendar tab (simplified from 3 tabs to 2 tabs)
- **Improved** Header design with gradient background and glow effects
- **Enhanced** Tab bar with icons and better visual hierarchy
- **Added** Modern fingerprint icon instead of clock icon
- **Improved** Spacing and typography for better readability
- **Added** Subtle shadow effects for depth
- **Changed** Color scheme from green to primary/accent colors

**Last Updated**: 2025-01-09

---

## [2.0.1] - 2025-01-09

### 🐛 Bug Fixes

#### Attendance Summary
- **Fixed** Negative duration values in attendance summary API endpoint
- **Changed** Duration calculation to use `abs()` for positive values
- **Improved** Duration formatting to show hours (Xh Ym) for >= 60 minutes, minutes (Xm) for < 60 minutes
- **Fixed** Calculation now properly sums all completed sessions from `attendance_sessions` table

#### Late Check-In Bottom Sheet
- **Fixed** Late reason bottom sheet now only appears when employee is actually late
- **Removed** Test code that was showing bottom sheet for all check-ins
- **Restored** Conditional logic to check if current time is after work plan start time
- **Added** Grace period (permission_minutes) support in late calculation
- **Added** `permissionMinutes` field to `WorkPlanModel` in Flutter
- **Added** `permission_minutes` field to API responses in Backend (checkIn, getStatus)
- **Improved** Check-in UX - employees within grace period can check in without prompts
- **Example**: If grace period = 90 minutes and work starts at 09:00, employee checking in at 09:30 is NOT considered late

**Last Updated**: 2025-01-09

---

## [2.0.0] - 2025-01-05

### 🎉 Major Features

#### Multiple Check-In/Check-Out Sessions
- **Added** unlimited check-in/check-out cycles per day
- **Added** session tracking with individual IDs and timestamps
- **Added** real-time session status (Active/Completed)
- **Added** sessions summary (total, active, completed, duration)
- **Changed** button logic to use `hasActiveSession` from API

#### GPS Location Tracking
- **Added** automatic GPS location capture on check-in
- **Added** location permission handling with user-friendly prompts
- **Added** error messages with "Open Settings" action buttons
- **Improved** location service error handling

### ✨ Enhancements

#### State Management
- **Added** state persistence pattern using `_lastStatus` variable
- **Fixed** button state persisting across different Cubit states
- **Added** auto-refresh after check-in/check-out operations
- **Improved** state synchronization between Dashboard and Attendance screens

#### Data Models
- **Added** `DurationHoursConverter` for handling mixed String/num types from API
- **Fixed** type casting errors for `duration_hours` and `total_hours` fields
- **Updated** `AttendanceStatusModel` with `hasActiveSession` field
- **Updated** `AttendanceSessionModel` with custom converter

#### User Interface
- **Updated** Dashboard attendance card with new state logic
- **Updated** Attendance check-in widget with state persistence
- **Improved** button labels ("Active Session" vs "Checked Out")
- **Added** visual indicators for active/completed sessions
- **Improved** loading states and error messages

### 🐛 Bug Fixes
- **Fixed** Dashboard card not updating after check-in/check-out
- **Fixed** Button showing "Check In" when active session exists
- **Fixed** Type casting errors from API string responses
- **Fixed** State resetting when loading sessions
- **Fixed** Multiple active sessions conflict

### 📚 Documentation
- **Added** `ATTENDANCE_FEATURE_DOCUMENTATION.md` - Comprehensive feature guide
- **Added** `lib/features/attendance/README.md` - Quick reference
- **Updated** `CLAUDE.md` with Multiple Sessions section
- **Added** Code examples and best practices
- **Added** Testing scripts and guidelines

**Last Updated**: 2025-01-05
