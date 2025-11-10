# Attendance Feature - Multiple Sessions

## Quick Reference

### ✅ Multiple Sessions Per Day
```
Check-in → Check-out → Check-in → Check-out → ...
(Unlimited cycles per day)
```

### 🔑 Key Rule
**Always use `hasActiveSession` from API - NOT `hasCheckedIn && !hasCheckedOut`**

```dart
// ✅ CORRECT
final hasActiveSession = status?.hasActiveSession ?? false;
if (hasActiveSession) {
  // Show Check Out button
}

// ❌ WRONG (breaks with multiple sessions)
if (hasCheckedIn && !hasCheckedOut) {
  // Don't use this pattern!
}
```

## Implementation Checklist

### 1. State Persistence
```dart
// Store last status in widget state
AttendanceStatusModel? _lastStatus;

if (state is AttendanceStatusLoaded) {
  _lastStatus = state.status;
}

// Use persisted status
final status = _lastStatus ?? extractFromState(state);
```

### 2. Auto-refresh After Operations
```dart
listener: (context, state) {
  if (state is CheckInSuccess || state is CheckOutSuccess) {
    context.read<AttendanceCubit>().fetchTodayStatus();
    context.read<AttendanceCubit>().fetchTodaySessions();
  }
}
```

### 3. GPS Check-in
```dart
// Get location
Position position = await LocationService.getCurrentPosition();

// Check in
await cubit.checkIn(
  latitude: position.latitude,
  longitude: position.longitude,
);
```

### 4. Type Converter for API
```dart
@JsonKey(name: 'duration_hours')
@DurationHoursConverter()  // Handles String and num
final double? durationHours;
```

## Files Structure

```
attendance/
├── data/
│   ├── models/
│   │   ├── attendance_model.dart           # Status with hasActiveSession
│   │   └── attendance_session_model.dart   # Session with DurationHoursConverter
│   └── repo/
│       └── attendance_repo.dart            # API calls
├── logic/
│   └── cubit/
│       ├── attendance_cubit.dart           # checkIn, checkOut, fetchStatus
│       └── attendance_state.dart           # States
└── ui/
    ├── screens/
    │   └── attendance_history_screen.dart
    └── widgets/
        ├── attendance_check_in_widget.dart # Main check-in/out UI
        └── sessions_list_widget.dart       # Sessions display
```

## API Endpoints

### Get Status
```
GET /api/v1/employee/attendance/status
Response: { "has_active_session": true, ... }
```

### Check In
```
POST /api/v1/employee/attendance/check-in
Body: { "latitude": 37.42, "longitude": -122.08 }
```

### Check Out
```
POST /api/v1/employee/attendance/check-out
```

### Get Sessions
```
GET /api/v1/employee/attendance/sessions
Response: { "sessions": [...], "summary": {...} }
```

## Testing

```bash
# Backend test
cd C:\xampp\htdocs\flowERP
php test_multiple_sessions.php

# Flutter test
flutter test test/features/attendance/
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Button doesn't update after check-in | Add auto-refresh in listener |
| Type casting error with duration_hours | Use `@DurationHoursConverter()` |
| Multiple active sessions error | Backend prevents this - check logs |
| GPS not working | Check LocationService permissions |

## Full Documentation
See `ATTENDANCE_FEATURE_DOCUMENTATION.md` in project root for complete details.

---

**Last Updated**: 2025-01-05
**Status**: ✅ Production Ready
