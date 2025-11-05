# 📱 Flutter Integration - Multiple Check-in/Check-out

## ✅ التحديثات المطبقة على Flutter

### 1. Models Updated

#### ✅ `attendance_session_model.dart`
```dart
class AttendanceSessionModel {
  final int id;
  final int? attendanceId;
  final String date;
  final String checkInTime;
  final String? checkOutTime;
  final double? durationHours;
  final String? durationLabel;
  final String? sessionType;  // 'regular', 'overtime', 'break'
  final String? notes;
  final bool? isActive;
}

class SessionsSummaryModel {
  final int totalSessions;
  final int activeSessions;
  final int completedSessions;
  final String totalDuration;
  final double totalHours;
}

class TodaySessionsDataModel {
  final List<AttendanceSessionModel> sessions;
  final SessionsSummaryModel summary;
  
  AttendanceSessionModel? get activeSession;
  bool get hasActiveSession;
  List<AttendanceSessionModel> get completedSessions;
}
```

#### ✅ `attendance_model.dart` - Enhanced
```dart
class AttendanceStatusModel {
  // Existing fields...
  
  // New fields for multiple sessions
  final CurrentSessionModel? currentSession;
  final SessionsSummaryResponseModel? sessionsSummary;
  final DailySummaryModel? dailySummary;
  
  String get totalDuration;
  double get totalHours;
}

class CurrentSessionModel {
  final int sessionId;
  final String checkInTime;
  final String duration;
}

class SessionsSummaryResponseModel {
  final int totalSessions;
  final int completedSessions;
  final String totalDuration;
  final double totalHours;
}

class DailySummaryModel {
  final String? checkInTime;
  final String? checkOutTime;
  final double workingHours;
  final String workingHoursLabel;
  final int lateMinutes;
  final String lateLabel;
}
```

### 2. Repository Updated

#### ✅ `attendance_repo.dart`
```dart
class AttendanceRepo {
  // Updated check-in with GPS
  Future<AttendanceModel> checkIn({
    double? latitude,
    double? longitude,
    String? notes,
  });
  
  // Updated check-out with GPS
  Future<AttendanceModel> checkOut({
    double? latitude,
    double? longitude,
  });
  
  // Get today's status (includes sessions)
  Future<AttendanceStatusModel> getTodayStatus();
  
  // NEW: Get all sessions for a specific date
  Future<TodaySessionsDataModel> getTodaySessions({String? date});
  
  // Existing
  Future<AttendanceHistoryModel> getHistory({int page, int perPage});
}
```

---

## 🔧 خطوات التثبيت

### 1. Generate Models (Required!)

```bash
cd C:\Users\B-SMART\AndroidStudioProjects\hrm

# Generate .g.dart files
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Update Cubit (التالي)

الآن نحتاج لتحديث `attendance_cubit.dart` لدعم:
- Multiple sessions loading
- Session state management
- Check-in/Check-out flow

### 3. Update UI (التالي)

- عرض list of sessions
- زر check-in/check-out بناءً على الحالة
- عرض total hours من كل sessions

---

## 📊 API Flow Examples

### Flow 1: First Check-in Today

```dart
// 1. User clicks "Check In"
await attendanceRepo.checkIn(
  latitude: 24.7136,
  longitude: 46.6753,
);

// Response:
{
  "session_id": 1,
  "attendance_id": 1,
  "date": "2025-11-05",
  "check_in_time": "09:00:00",
  "session_number": 1,
  "is_first_session": true,
  "late_minutes": 0
}

// 2. Get updated status
final status = await attendanceRepo.getTodayStatus();
// status.hasActiveSession = true
// status.currentSession.sessionId = 1
// status.sessionsSummary.totalSessions = 1

// 3. Get all sessions
final sessions = await attendanceRepo.getTodaySessions();
// sessions.sessions.length = 1
// sessions.hasActiveSession = true
// sessions.activeSession != null
```

### Flow 2: Check-out from Session

```dart
// 1. User clicks "Check Out"
await attendanceRepo.checkOut(
  latitude: 24.7136,
  longitude: 46.6753,
);

// Response:
{
  "session_id": 1,
  "check_in_time": "09:00:00",
  "check_out_time": "12:30:00",
  "duration_hours": 3.5,
  "duration_label": "3h 30m",
  "session_number": 1,
  "total_sessions_today": 1
}

// 2. Get updated status
final status = await attendanceRepo.getTodayStatus();
// status.hasActiveSession = false
// status.sessionsSummary.completedSessions = 1
// status.sessionsSummary.totalHours = 3.5
```

### Flow 3: Second Check-in (After Lunch)

```dart
// 1. User clicks "Check In" again
await attendanceRepo.checkIn(
  latitude: 24.7136,
  longitude: 46.6753,
);

// Response:
{
  "session_id": 2,
  "attendance_id": 1,  // Same attendance record
  "date": "2025-11-05",
  "check_in_time": "13:30:00",
  "session_number": 2,  // Second session!
  "is_first_session": false
}

// 2. Get all sessions
final sessions = await attendanceRepo.getTodaySessions();
// sessions.sessions.length = 2
// sessions.hasActiveSession = true
// sessions.completedSessions.length = 1
```

---

## 🎨 UI Components to Create

### 1. Sessions List Widget

```dart
class SessionsListWidget extends StatelessWidget {
  final List<AttendanceSessionModel> sessions;
  
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(
          sessionNumber: index + 1,
          checkInTime: session.checkInTime,
          checkOutTime: session.checkOutTime,
          duration: session.durationLabel ?? '0m',
          isActive: session.active,
          sessionType: session.sessionTypeDisplay,
        );
      },
    );
  }
}
```

### 2. Session Card Widget

```dart
class SessionCard extends StatelessWidget {
  final int sessionNumber;
  final String checkInTime;
  final String? checkOutTime;
  final String duration;
  final bool isActive;
  final String sessionType;
  
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('#$sessionNumber'),
          backgroundColor: isActive ? Colors.green : Colors.grey,
        ),
        title: Text('Session $sessionNumber - $sessionType'),
        subtitle: Text(
          'In: $checkInTime ${checkOutTime != null ? "→ Out: $checkOutTime" : "(Active)"}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.timelapse : Icons.check_circle,
              color: isActive ? Colors.orange : Colors.green,
            ),
            Text(duration, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
```

### 3. Summary Widget

```dart
class SessionsSummaryWidget extends StatelessWidget {
  final SessionsSummaryModel summary;
  
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Total Sessions', '${summary.totalSessions}'),
                _buildStat('Completed', '${summary.completedSessions}'),
                _buildStat('Active', '${summary.activeSessions}'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 32),
                SizedBox(width: 8),
                Text(
                  summary.totalDuration,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              '${summary.formattedHours} total working hours',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
```

### 4. Check-in/Check-out Button Logic

```dart
class AttendanceButton extends StatelessWidget {
  final bool hasActiveSession;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: hasActiveSession ? onCheckOut : onCheckIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: hasActiveSession ? Colors.red : Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasActiveSession ? Icons.logout : Icons.login),
          SizedBox(width: 8),
          Text(
            hasActiveSession ? 'Check Out' : 'Check In',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 Cubit States (Suggested)

```dart
// attendance_state.dart

abstract class AttendanceState extends Equatable {
  const AttendanceState();
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceStatusLoaded extends AttendanceState {
  final AttendanceStatusModel status;
  final TodaySessionsDataModel? sessions;  // NEW
  
  const AttendanceStatusLoaded({
    required this.status,
    this.sessions,
  });
}

class AttendanceCheckInSuccess extends AttendanceState {
  final AttendanceModel attendance;
  
  const AttendanceCheckInSuccess(this.attendance);
}

class AttendanceCheckOutSuccess extends AttendanceState {
  final AttendanceModel attendance;
  
  const AttendanceCheckOutSuccess(this.attendance);
}

class AttendanceError extends AttendanceState {
  final String message;
  final String? errorType;  // 'active_session', 'location', 'general'
  
  const AttendanceError(this.message, {this.errorType});
}
```

---

## 🚀 الخطوات التالية

### ✅ تم (Backend)
1. Migration created
2. Model created
3. Controller updated
4. Routes added
5. Testing done

### ✅ تم (Flutter - Models & Repo)
1. Models updated
2. Repository updated
3. API endpoints configured

### 📝 القادم (Flutter - Cubit & UI)
1. Update `attendance_cubit.dart`
2. Update `attendance_state.dart`
3. Create sessions widgets
4. Update main attendance screen
5. Add error handling for active sessions

---

## ⚠️ Important Notes

### Error Handling

#### Active Session Error
```dart
try {
  await checkIn();
} on DioException catch (e) {
  if (e.response?.statusCode == 400) {
    final data = e.response?.data;
    if (data['message'].contains('active session')) {
      // Show message: "You have an active session. Please check out first."
      // Option 1: Auto check-out
      // Option 2: Show session details and let user decide
    }
  }
}
```

#### Location Error
```dart
try {
  await checkIn(latitude: lat, longitude: lng);
} on DioException catch (e) {
  if (e.response?.statusCode == 400) {
    final data = e.response?.data;
    if (data['message'].contains('too far')) {
      final distance = data['distance_meters'];
      final allowed = data['allowed_radius'];
      // Show: "You are $distance meters away. Allowed: $allowed meters"
    }
  }
}
```

### State Management

```dart
// In Cubit
Future<void> loadTodayStatus() async {
  emit(AttendanceLoading());
  
  try {
    // Load status
    final status = await _repo.getTodayStatus();
    
    // Load sessions if has checked in
    TodaySessionsDataModel? sessions;
    if (status.hasCheckedIn) {
      sessions = await _repo.getTodaySessions();
    }
    
    emit(AttendanceStatusLoaded(
      status: status,
      sessions: sessions,
    ));
  } catch (e) {
    emit(AttendanceError(e.toString()));
  }
}
```

---

## 🎯 Usage Example

```dart
// In Screen
class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceCubit>().loadTodayStatus();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance')),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceStatusLoaded) {
            return Column(
              children: [
                // Summary Card
                if (state.sessions != null)
                  SessionsSummaryWidget(summary: state.sessions!.summary),
                
                // Check-in/Check-out Button
                AttendanceButton(
                  hasActiveSession: state.status.hasActiveSession ?? false,
                  onCheckIn: () => _handleCheckIn(),
                  onCheckOut: () => _handleCheckOut(),
                ),
                
                // Sessions List
                if (state.sessions != null && state.sessions!.sessions.isNotEmpty)
                  Expanded(
                    child: SessionsListWidget(
                      sessions: state.sessions!.sessions,
                    ),
                  ),
              ],
            );
          }
          
          if (state is AttendanceLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is AttendanceError) {
            return Center(child: Text(state.message));
          }
          
          return SizedBox();
        },
      ),
    );
  }
  
  Future<void> _handleCheckIn() async {
    // Get location
    final position = await _getLocation();
    
    // Check in
    await context.read<AttendanceCubit>().checkIn(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    
    // Reload status
    context.read<AttendanceCubit>().loadTodayStatus();
  }
  
  Future<void> _handleCheckOut() async {
    // Get location (optional)
    final position = await _getLocation();
    
    // Check out
    await context.read<AttendanceCubit>().checkOut(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    
    // Reload status
    context.read<AttendanceCubit>().loadTodayStatus();
  }
  
  Future<Position> _getLocation() async {
    // Get GPS location
    return await Geolocator.getCurrentPosition();
  }
}
```

---

**الحالة:** ✅ Models & Repository Ready
**التالي:** Update Cubit & UI

**تاريخ التحديث:** 2025-11-05
