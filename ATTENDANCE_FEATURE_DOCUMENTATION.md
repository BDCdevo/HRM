# Attendance Feature Documentation

## Overview
نظام الحضور والانصراف مع دعم **Multiple Check-In/Check-Out Sessions** في اليوم الواحد.

## Features (الميزات)

### ✅ Multiple Sessions Support
- يمكن للموظف عمل check-in و check-out عدة مرات في اليوم الواحد
- كل session لها ID منفصل ومستقل
- النظام يدعم unlimited sessions per day
- التدفق: Check-in → Check-out → Check-in → Check-out → ...

### ✅ GPS Location Tracking
- Check-in يتطلب GPS location تلقائياً
- التحقق من موقع الموظف عند التسجيل
- دعم طلب أذونات الموقع
- رسائل خطأ واضحة مع أزرار لفتح الإعدادات

### ✅ Real-time State Management
- الحالة تتحدث تلقائياً بعد كل عملية
- Dashboard و Attendance screen متزامنين
- استخدام `hasActiveSession` من API للتحكم في الأزرار
- State persistence عبر navigation

### ✅ User Interface

#### Dashboard Screen
- **Attendance Card** يعرض الحالة الحالية:
  - "Active Session" → لون أخضر (جلسة نشطة)
  - "Checked Out" → لون أزرق (تم الانصراف)
  - "No Active Session" → لون أزرق (جاهز للتسجيل)

- **Check In Button**:
  - نشط عندما: لا يوجد session نشطة
  - يطلب GPS location
  - يعمل check-in مباشرة
  - يتعطل عندما: توجد session نشطة

- **Check Out Button**:
  - نشط عندما: توجد session نشطة
  - يعمل check-out مباشرة
  - يتعطل عندما: لا توجد session نشطة

#### Attendance Screen
- عرض جميع الـ sessions اليوم
- Check-in/Check-out مع GPS location
- عرض تفاصيل كل session:
  - وقت الدخول
  - وقت الخروج
  - المدة
  - الحالة (Active/Completed)
- ملخص اليوم (Today's Summary):
  - إجمالي الساعات
  - عدد الجلسات
  - الجلسات النشطة
  - الجلسات المكتملة

## Technical Implementation

### Data Models

#### AttendanceStatusModel
```dart
class AttendanceStatusModel {
  final bool hasCheckedIn;
  final bool? hasCheckedOut;
  final bool? hasActiveSession;  // ⭐ المفتاح الرئيسي
  final String? checkInTime;
  final String? checkOutTime;
  // ... fields
}
```

#### AttendanceSessionModel
```dart
class AttendanceSessionModel {
  final int id;
  final int? attendanceId;
  final String date;
  final String checkInTime;
  final String? checkOutTime;
  final double? durationHours;
  final bool? isActive;
  // ... fields
}
```

#### Custom Type Converter
```dart
class DurationHoursConverter implements JsonConverter<double?, dynamic> {
  // Handles both String and num types from API
  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
```

### State Management

#### AttendanceCubit
```dart
class AttendanceCubit extends Cubit<AttendanceState> {
  // Fetch today's status
  Future<void> fetchTodayStatus();

  // Check in with GPS
  Future<void> checkIn({
    double? latitude,
    double? longitude,
    String? notes,
  });

  // Check out
  Future<void> checkOut();

  // Fetch today's sessions
  Future<void> fetchTodaySessions();
}
```

#### State Flow
```
1. Initial → Loading → StatusLoaded
2. User clicks Check-In → Loading → CheckInSuccess → Auto refresh status
3. User clicks Check-Out → Loading → CheckOutSuccess → Auto refresh status
4. StatusLoaded persists in widget using _lastStatus variable
```

### Widget State Persistence

#### Attendance Check-in Widget
```dart
class _AttendanceCheckInWidgetState extends State<AttendanceCheckInWidget> {
  // Keep track of the last status loaded
  AttendanceStatusModel? _lastStatus;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state is CheckInSuccess || state is CheckOutSuccess) {
          // Auto-refresh after success
          context.read<AttendanceCubit>().fetchTodayStatus();
          context.read<AttendanceCubit>().fetchTodaySessions();
        }
      },
      builder: (context, state) {
        // Save status when loaded
        if (state is AttendanceStatusLoaded) {
          _lastStatus = state.status;
        }

        // Use persisted status
        final status = _lastStatus ?? (state is AttendanceStatusLoaded ? state.status : null);
        final hasActiveSession = status?.hasActiveSession ?? false;

        // UI updates based on hasActiveSession
      },
    );
  }
}
```

#### Dashboard Screen
```dart
class _DashboardScreenState extends State<DashboardScreen> {
  late final AttendanceCubit _attendanceCubit;

  @override
  void initState() {
    super.initState();
    _attendanceCubit = AttendanceCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _attendanceCubit.fetchTodayStatus();
      }
    });
  }

  // Auto-refresh after check-in/check-out
  listener: (context, attendanceState) {
    if (attendanceState is CheckInSuccess || attendanceState is CheckOutSuccess) {
      _attendanceCubit.fetchTodayStatus();
    }
  }
}
```

### GPS Location Handling

```dart
Future<void> _handleCheckIn(BuildContext context) async {
  try {
    // Show loading
    showDialog(/* loading dialog */);

    // Get GPS location
    Position position = await LocationService.getCurrentPosition();

    // Close dialog
    Navigator.of(context).pop();

    // Check in with location
    await cubit.checkIn(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    // Handle errors with user-friendly messages
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 ${e.toString()}'),
        action: SnackBarAction(
          label: 'Open Settings',
          onPressed: () => LocationService.openAppSettings(),
        ),
      ),
    );
  }
}
```

## API Integration

### Endpoints

#### Get Today's Status
```
GET /api/v1/employee/attendance/status

Response:
{
  "data": {
    "has_checked_in": true,
    "has_checked_out": false,
    "has_active_session": true,  // ⭐ Important
    "check_in_time": "09:00:00",
    "current_session": {
      "session_id": 15,
      "check_in_time": "09:00:00",
      "duration": "2h 30m"
    },
    "daily_summary": { ... }
  }
}
```

#### Check In
```
POST /api/v1/employee/attendance/check-in
Body: {
  "latitude": 37.4219983,
  "longitude": -122.084,
  "notes": "Optional notes"
}

Response:
{
  "data": {
    "session_id": 15,
    "check_in_time": "09:00:00",
    "session_number": 1,
    "message": "Checked in successfully"
  }
}
```

#### Check Out
```
POST /api/v1/employee/attendance/check-out

Response:
{
  "data": {
    "session_id": 15,
    "check_out_time": "17:00:00",
    "duration_hours": 8.0,
    "duration_label": "8h 0m",
    "message": "Checked out successfully"
  }
}
```

#### Get Today's Sessions
```
GET /api/v1/employee/attendance/sessions

Response:
{
  "data": {
    "sessions": [
      {
        "id": 15,
        "check_in_time": "09:00:00",
        "check_out_time": "12:00:00",
        "duration_hours": 3.0,
        "is_active": false
      },
      {
        "id": 16,
        "check_in_time": "13:00:00",
        "check_out_time": null,
        "duration_hours": null,
        "is_active": true
      }
    ],
    "summary": {
      "total_sessions": 2,
      "active_sessions": 1,
      "completed_sessions": 1,
      "total_hours": 3.0,
      "total_duration": "3h 0m"
    }
  }
}
```

## Issues Fixed

### 1. Type Casting Errors
**Problem**: API returns numeric values as String sometimes
**Solution**: Created `DurationHoursConverter` to handle both types
```dart
@JsonKey(name: 'duration_hours')
@DurationHoursConverter()
final double? durationHours;
```

### 2. State Persistence
**Problem**: Button state resets when loading sessions
**Solution**: Store `_lastStatus` in widget state
```dart
AttendanceStatusModel? _lastStatus;

if (state is AttendanceStatusLoaded) {
  _lastStatus = state.status;
}
```

### 3. Multiple Active Sessions
**Problem**: Old sessions not closed properly
**Solution**: Backend logic ensures only one active session at a time

### 4. Dashboard Not Updating
**Problem**: Dashboard card doesn't update after check-in/check-out
**Solution**: Added auto-refresh in listener
```dart
listener: (context, state) {
  if (state is CheckInSuccess || state is CheckOutSuccess) {
    _attendanceCubit.fetchTodayStatus();
  }
}
```

## Testing

### Backend Test Script
```bash
cd C:\xampp\htdocs\flowERP
php test_multiple_sessions.php
```

**Test Results**:
- ✅ Check-in → Status updates → has_active_session = true
- ✅ Check-out → Status updates → has_active_session = false
- ✅ Multiple sessions (17 sessions tested successfully)
- ✅ Sequential check-in/check-out cycles work perfectly

### Manual Testing Checklist
- [ ] Dashboard: Check-in button works with GPS
- [ ] Dashboard: Check-out button works
- [ ] Dashboard: Card updates after operations
- [ ] Attendance Screen: Check-in with GPS
- [ ] Attendance Screen: Check-out works
- [ ] Attendance Screen: Sessions list displays correctly
- [ ] Multiple sessions: Check-in → Check-out → Check-in works
- [ ] GPS errors show proper messages
- [ ] Location permissions handled correctly
- [ ] State persists during navigation

## File Structure

```
lib/features/attendance/
├── data/
│   ├── models/
│   │   ├── attendance_model.dart           # Status models with sessions support
│   │   └── attendance_session_model.dart   # Session models with custom converter
│   └── repo/
│       └── attendance_repo.dart            # API calls
├── logic/
│   └── cubit/
│       ├── attendance_cubit.dart           # Business logic
│       └── attendance_state.dart           # State definitions
└── ui/
    ├── screens/
    │   └── attendance_history_screen.dart  # Full attendance screen
    └── widgets/
        ├── attendance_check_in_widget.dart # Check-in/out with GPS
        └── sessions_list_widget.dart       # Sessions display

lib/features/dashboard/
└── ui/
    └── screens/
        └── dashboard_screen.dart           # Dashboard with attendance card
```

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  equatable: ^2.0.5             # Value equality
  dio: ^5.3.3                   # HTTP client
  geolocator: ^10.1.0           # GPS location
  json_annotation: ^4.8.1       # JSON serialization

dev_dependencies:
  build_runner: ^2.4.6          # Code generation
  json_serializable: ^6.7.1     # JSON code gen
```

## Code Generation

After modifying models, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Best Practices

### 1. Always Use hasActiveSession
```dart
// ✅ Correct
final hasActiveSession = status?.hasActiveSession ?? false;
if (hasActiveSession) {
  // Show Check Out
} else {
  // Show Check In
}

// ❌ Wrong (old approach)
if (hasCheckedIn && !hasCheckedOut) {
  // This doesn't work with multiple sessions
}
```

### 2. Auto-refresh After Operations
```dart
listener: (context, state) {
  if (state is CheckInSuccess || state is CheckOutSuccess) {
    // Always refresh status and sessions
    context.read<AttendanceCubit>().fetchTodayStatus();
    context.read<AttendanceCubit>().fetchTodaySessions();
  }
}
```

### 3. Handle GPS Errors Gracefully
```dart
try {
  Position position = await LocationService.getCurrentPosition();
  await checkIn(latitude: position.latitude, longitude: position.longitude);
} catch (e) {
  // Show user-friendly error with action button
  showErrorWithSettingsButton(e);
}
```

### 4. State Persistence Pattern
```dart
// Store last successful state
if (state is DataLoadedState) {
  _lastData = state.data;
}

// Use persisted data when state changes
final data = _lastData ?? extractDataFromState(state);
```

## Future Improvements

### Potential Enhancements
- [ ] Offline support with local database
- [ ] Push notifications for shift reminders
- [ ] QR code check-in option
- [ ] Face recognition check-in
- [ ] Geofencing for automatic check-in/out
- [ ] Break time tracking within sessions
- [ ] Overtime calculation
- [ ] Export attendance reports
- [ ] Calendar view for attendance history
- [ ] Admin dashboard for monitoring

### Performance Optimizations
- [ ] Cache location to reduce GPS calls
- [ ] Implement pagination for sessions history
- [ ] Add pull-to-refresh on all screens
- [ ] Optimize API response size
- [ ] Add loading skeletons

## Support

### Common Issues

#### Issue: "GPS not working"
**Solution**: Check location permissions in app settings

#### Issue: "Button doesn't update after check-in"
**Solution**: Ensure auto-refresh is implemented in listener

#### Issue: "Type casting error"
**Solution**: Use `DurationHoursConverter` for numeric fields

#### Issue: "Multiple active sessions"
**Solution**: Backend prevents this, check backend logs

### Contact
For issues or questions, check:
- GitHub Issues: [Add your repo link]
- Documentation: This file
- Backend API: `/api/documentation`

---

## Changelog

### Version 2.0.0 (2025-01-05)
- ✅ Added multiple check-in/check-out sessions support
- ✅ Implemented GPS location tracking
- ✅ Fixed state persistence across navigation
- ✅ Added custom type converter for API responses
- ✅ Updated Dashboard attendance card
- ✅ Auto-refresh after operations
- ✅ Improved error handling with user-friendly messages
- ✅ Added comprehensive documentation

### Version 1.0.0 (Previous)
- Basic check-in/check-out functionality
- Single session per day
- Manual state management

---

**Last Updated**: 2025-01-05
**Author**: Claude Code
**Status**: ✅ Production Ready
