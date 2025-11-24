# تحديث CLAUDE.md - نظام معالجة الأخطاء

## القسم المقترح للإضافة في CLAUDE.md

أضف هذا القسم بعد قسم "Common Development Patterns":

---

## Error Handling System

The app uses a comprehensive error handling system for displaying errors professionally to users.

### Error Types (7 Types)

All errors inherit from `AppError` base class:

```dart
// Network errors
NetworkError.noInternet()
NetworkError.timeout()
NetworkError.serverUnreachable()

// Auth errors
AuthError.invalidCredentials()
AuthError.sessionExpired()
AuthError.unauthorized()

// Server errors (5xx)
ServerError.internal()
ServerError.serviceUnavailable()

// Validation errors
ValidationError.fromMap(response.data['errors'])

// Business logic errors
BusinessError.notFound('resource')
BusinessError.insufficientBalance()

// Permission errors
PermissionError.locationDenied()
PermissionError.locationDisabled()

// Geofencing errors
GeofenceError.outsideBoundary(distance: 250, radius: 100)
GeofenceError.noBranchAssigned()
```

### Error Display Methods

**4 ways to display errors**:

```dart
import 'package:hrm/core/errors/error_handler.dart';

// 1. SnackBar (default)
ErrorHandler.handle(
  context: context,
  error: error,
  displayType: ErrorDisplayType.snackbar,
  onRetry: () => retry(),
);

// 2. Dialog (important errors)
ErrorHandler.handle(
  context: context,
  error: error,
  displayType: ErrorDisplayType.dialog,
);

// 3. Toast (lightweight)
ErrorHandler.handle(
  context: context,
  error: error,
  displayType: ErrorDisplayType.toast,
);

// 4. Full Screen (critical errors)
if (state is ErrorState) {
  return ErrorScreen(error: state.error, onRetry: () => retry());
}
```

### Using in BLoC/Cubit

**Repository Pattern** (no change):
```dart
class ProfileRepository {
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      rethrow; // Let cubit handle
    }
  }
}
```

**Cubit Pattern**:
```dart
import 'package:dio/dio.dart';
import 'package:hrm/core/errors/app_error.dart';

class ProfileCubit extends Cubit<ProfileState> {
  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final profile = await _repo.getProfile();
      emit(ProfileLoaded(profile));
    } on DioException catch (e) {
      // ✅ Auto-convert to AppError
      final error = fromDioException(e);
      emit(ProfileError(error));
    } catch (e) {
      emit(ProfileError(UnknownError.unexpected(e)));
    }
  }
}
```

**State Classes**:
```dart
import 'package:hrm/core/errors/app_error.dart';

class ProfileError extends ProfileState {
  final AppError error;  // Use AppError, not String
  const ProfileError(this.error);
}
```

**UI Pattern** (BlocListener):
```dart
import 'package:hrm/core/errors/error_handler.dart';

BlocListener<ProfileCubit, ProfileState>(
  listener: (context, state) {
    if (state is ProfileError) {
      ErrorHandler.handle(
        context: context,
        error: state.error,
        onRetry: () => context.read<ProfileCubit>().loadProfile(),
      );
    }
  },
  child: /* UI */,
)
```

### Error Severity Levels

Affects display duration and color:

```dart
enum ErrorSeverity {
  info,      // ℹ️ Blue, 2s
  warning,   // ⚠️ Orange, 3s
  error,     // ❌ Red, 4s
  critical   // 🚨 Dark red, 6s
}
```

### Global Error Boundary

Catches all uncaught errors and prevents red screen:

```dart
// In main.dart
import 'core/errors/error_boundary.dart';

void main() {
  // ✅ Enable error boundary
  initializeErrorBoundary();
  setCustomErrorWidget();

  runApp(const MyApp());
}
```

**Features**:
- Catches Flutter framework errors
- Catches async errors
- Shows custom error screen instead of red screen
- Detailed logging with emojis
- Ready for Crashlytics/Sentry integration

### Error Logging

Structured logging with visual indicators:

```
❌ [ErrorSeverity.error] NetworkError: لا يوجد اتصال بالإنترنت
   📝 Details: يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى
   🔍 Original: DioException [connectionTimeout]
   ⏱️ Connection timeout
```

### ApiInterceptor Integration

ApiInterceptor automatically handles common HTTP errors:

- **401 Unauthorized**: Clears token, calls logout callback
- **403 Forbidden**: Logs access denied
- **404 Not Found**: Logs resource missing
- **5xx Server Errors**: Logs server issues

**Setup with callback**:
```dart
// In DioClient
dio.interceptors.add(
  ApiInterceptor(
    onUnauthorized: () {
      // Navigate to login automatically
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    },
  ),
);
```

### Auto-Conversion from DioException

All DioExceptions are automatically converted to appropriate AppError types:

```dart
// Network timeout → NetworkError.timeout()
// 401 response → AuthError.sessionExpired()
// 422 with errors → ValidationError.fromMap()
// 500 response → ServerError.internal()
// No internet → NetworkError.noInternet()
```

### Documentation Files

- **ERROR_HANDLING_GUIDE.md** - Complete guide with examples
- **ERROR_HANDLING_QUICK_START.md** - 5-minute quick start
- **ERROR_HANDLING_BEFORE_AFTER.md** - Before/after comparisons
- **lib/core/errors/error_handling_example.dart** - 10 practical examples

### Common Patterns

**Pattern 1: Standard Error Handling**
```dart
try {
  await operation();
} on DioException catch (e) {
  emit(ErrorState(fromDioException(e)));
} catch (e) {
  emit(ErrorState(UnknownError.unexpected(e)));
}
```

**Pattern 2: Custom Error**
```dart
if (balance < amount) {
  emit(ErrorState(BusinessError.insufficientBalance()));
}
```

**Pattern 3: Geofence Error with Details**
```dart
if (distance > allowedRadius) {
  emit(CheckInError(
    GeofenceError.outsideBoundary(
      distance: distance,
      radius: allowedRadius,
    ),
  ));
}
```

### Error Widget Components

Available in `lib/core/widgets/error_widgets.dart`:

- **ErrorDialog** - Professional error popup with icon and retry
- **ErrorToast** - Lightweight animated notification
- **ErrorScreen** - Full-screen error with illustration
- **InlineErrorWidget** - Inline error for forms

All widgets support:
- ✅ Dark mode
- ✅ Arabic messages
- ✅ Custom icons per error type
- ✅ Retry functionality
- ✅ Animated transitions

---

## الموقع المقترح في CLAUDE.md

أضف هذا القسم بعد "Common Development Patterns" وقبل "Important Architectural Patterns".

## سطر واحد للإضافة في قسم Documentation References

```markdown
- **Error Handling Guide**: `ERROR_HANDLING_GUIDE.md` - Comprehensive error handling system
```
