# Geofencing Error Messages - تحسين رسائل الخطأ

**التاريخ**: 2025-11-10
**الحالة**: ✅ تم التحسين

---

## 📋 المشكلة

عند محاولة Check-in من خارج نطاق الفرع، كانت الرسالة:
```
[400] You are too far from the branch location to check in
```

المشاكل:
1. ❌ باللغة الإنجليزية فقط
2. ❌ لا تعرض المسافة الفعلية
3. ❌ لا تعرض المسافة المسموحة
4. ❌ لا تُرشد المستخدم ماذا يفعل

---

## ✅ الحل

### Backend Response Structure

Backend يرسل:
```json
{
  "success": false,
  "message": "You are too far from the branch location to check in",
  "errors": {
    "distance_meters": 250,
    "allowed_radius": 100
  }
}
```

### Enhanced Error Message

الآن التطبيق يعرض:
```
[400] أنت بعيد عن موقع الفرع
المسافة الحالية: 250م
المسافة المسموحة: 100م
يرجى الاقتراب من الفرع للتسجيل
```

---

## 🔧 Code Changes

### File: `lib/features/attendance/logic/cubit/attendance_cubit.dart`

**Method**: `_handleDioException()` (lines 162-189)

#### Before:
```dart
void _handleDioException(DioException e) {
  if (e.response != null) {
    final statusCode = e.response?.statusCode;
    final errorMessage = e.response?.data?['message'] ?? 'Operation failed';

    emit(AttendanceError(
      message: '[$statusCode] $errorMessage',
      errorDetails: e.response?.data?.toString(),
    ));
  }
  // ... other error types
}
```

#### After:
```dart
void _handleDioException(DioException e) {
  if (e.response != null) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String errorMessage = data?['message'] ?? 'Operation failed';

    // Special handling for geofencing errors (distance info)
    if (statusCode == 400 && data?['errors'] != null) {
      final errors = data['errors'];
      final distanceMeters = errors['distance_meters'];
      final allowedRadius = errors['allowed_radius'];

      if (distanceMeters != null && allowedRadius != null) {
        // Enhanced error message with distance info
        errorMessage = 'أنت بعيد عن موقع الفرع\n'
            'المسافة الحالية: ${distanceMeters}م\n'
            'المسافة المسموحة: ${allowedRadius}م\n'
            'يرجى الاقتراب من الفرع للتسجيل';
      }
    }

    emit(AttendanceError(
      message: '[$statusCode] $errorMessage',
      errorDetails: data?.toString(),
    ));
  }
  // ... other error types (also translated to Arabic)
}
```

---

## 📊 Error Message Examples

### Error 1: Too Far from Branch
```
Backend:
{
  "message": "You are too far from the branch location to check in",
  "errors": {
    "distance_meters": 250,
    "allowed_radius": 100
  }
}

UI Display:
┌─────────────────────────────────────────────┐
│ ❌                                           │
│ [400] أنت بعيد عن موقع الفرع                │
│ المسافة الحالية: 250م                      │
│ المسافة المسموحة: 100م                      │
│ يرجى الاقتراب من الفرع للتسجيل              │
└─────────────────────────────────────────────┘
```

### Error 2: No Branch Assigned
```
Backend:
{
  "message": "No branch assigned to you. Please contact HR."
}

UI Display:
┌─────────────────────────────────────────────┐
│ ❌                                           │
│ [400] No branch assigned to you.            │
│ Please contact HR.                          │
└─────────────────────────────────────────────┘

(Note: This could be translated too if needed)
```

### Error 3: Location Required
```
Backend:
{
  "message": "Location is required for check-in"
}

UI Display:
┌─────────────────────────────────────────────┐
│ ❌                                           │
│ [400] Location is required for check-in    │
└─────────────────────────────────────────────┘
```

---

## 🌍 Localization Improvements

### Also Translated Other Error Messages:

1. **Timeout Error**:
   - Before: "Request timeout. Please try again."
   - After: "انتهت مهلة الطلب. يرجى المحاولة مرة أخرى."

2. **Network Error**:
   - Before: "Network error. Please check your internet connection."
   - After: "خطأ في الشبكة. يرجى التحقق من اتصال الإنترنت."

3. **Unknown Error**:
   - Before: "An unexpected error occurred"
   - After: "حدث خطأ غير متوقع"

---

## 🧪 Testing Scenarios

### Scenario 1: Inside Branch Radius
```
Employee Location: (24.7136, 46.6753)
Branch Location: (24.7136, 46.6753)
Distance: 0 meters
Allowed Radius: 100 meters

Result: ✅ Check-in succeeds
```

### Scenario 2: Just Outside Radius
```
Employee Location: (24.7146, 46.6753)
Branch Location: (24.7136, 46.6753)
Distance: ~110 meters
Allowed Radius: 100 meters

Result: ❌ Error displayed:
"[400] أنت بعيد عن موقع الفرع
المسافة الحالية: 110م
المسافة المسموحة: 100م
يرجى الاقتراب من الفرع للتسجيل"
```

### Scenario 3: Far from Branch
```
Employee Location: Home (5km away)
Branch Location: Office
Distance: ~5000 meters
Allowed Radius: 100 meters

Result: ❌ Error displayed:
"[400] أنت بعيد عن موقع الفرع
المسافة الحالية: 5000م
المسافة المسموحة: 100م
يرجى الاقتراب من الفرع للتسجيل"
```

---

## 🎯 User Experience Improvements

### Before:
- ❌ Confusing English-only message
- ❌ No indication of how far user is
- ❌ No guidance on what to do

### After:
- ✅ Clear Arabic message
- ✅ Shows actual distance (250م)
- ✅ Shows allowed distance (100م)
- ✅ Clear instruction: "يرجى الاقتراب من الفرع"
- ✅ User knows exactly how much closer to get

---

## 💡 Future Enhancements

### Possible Improvements:

1. **Show on Map** 📍:
   ```dart
   "View on Map" button
   → Opens map showing:
      - Employee location (blue pin)
      - Branch location (red pin)
      - Allowed radius (circle)
      - Distance line with measurement
   ```

2. **Distance Unit Conversion** 🔢:
   ```dart
   if (distanceMeters > 1000) {
     displayDistance = "${(distanceMeters / 1000).toStringAsFixed(1)}كم";
   } else {
     displayDistance = "${distanceMeters}م";
   }
   ```

3. **Estimated Walking Time** ⏱️:
   ```dart
   final walkingSpeed = 5.0; // km/h
   final timeMinutes = (distanceMeters / 1000) / walkingSpeed * 60;

   message += "\nالوقت التقريبي للوصول: ${timeMinutes.ceil()} دقيقة";
   ```

4. **Request Exception** 🆘:
   ```dart
   "طلب استثناء" button
   → Opens form to request check-in exception
   → Sends notification to manager
   → Includes reason and location proof
   ```

5. **Offline Mode** 📵:
   ```dart
   if (no internet) {
     Save GPS location locally
     Queue check-in for later sync
     Show: "سيتم التسجيل عند الاتصال بالإنترنت"
   }
   ```

---

## 📝 Related Code

### Backend Validation
**File**: `/var/www/erp1/app/Http/Controllers/Api/V1/Employee/AttendanceController.php`

**Lines 204-223**:
```php
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
```

### Branch Model
**File**: `/var/www/erp1/app/Models/Hrm/Branch.php`

**Haversine Distance Calculation**:
```php
public function calculateDistance(float $latitude, float $longitude): float
{
    $earthRadius = 6371000; // Earth radius in meters

    // Haversine formula
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

---

## ✅ Status

- ✅ Error message enhanced with distance info
- ✅ Translated to Arabic
- ✅ Clear user guidance
- ✅ Ready for testing

---

## 🔗 Related Documentation

- `BRANCH_GEOFENCING_IMPLEMENTATION.md` - Complete geofencing implementation
- `TESTING_REPORT_2025-11-10.md` - Testing guide

---

**Created by**: Claude Code
**Date**: 2025-11-10
**Status**: ✅ Complete
