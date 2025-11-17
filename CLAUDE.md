# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HRM (Human Resource Management) Flutter application with Laravel (Filament) PHP backend. The app follows Clean Architecture with BLoC/Cubit state management, integrated Figma designs, and comprehensive API documentation.

## Quick Start

**Prerequisites**: Flutter 3.9.2+, Dart SDK 3.9.2+, PHP 8.4+

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. Generate model code
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Configure API endpoint (edit lib/core/config/api_config.dart line 26)
# Choose: baseUrlEmulator (Android), baseUrlSimulator (iOS/Web), baseUrlRealDevice, or baseUrlProduction

# 4. Start backend (if using local development)
cd D:\php_project\filament-hrm && php artisan serve

# 5. Run app
flutter run
```

For detailed setup, see `README.md` or `GETTING_STARTED_5MIN.md`.

## Environment Configuration

### Current Environment
The app is **currently configured for PRODUCTION** (`baseUrlProduction`). Check `lib/core/config/api_config.dart:26` to verify.

### Available Environments

```dart
// lib/core/config/api_config.dart line 26
static const String baseUrl = baseUrlProduction;    // Production: https://erp1.bdcbiz.com/api/v1
// static const String baseUrl = baseUrlEmulator;   // Android Emulator: http://10.0.2.2:8000/api/v1
// static const String baseUrl = baseUrlSimulator;  // iOS/Web: http://localhost:8000/api/v1
// static const String baseUrl = baseUrlRealDevice; // Real Device: http://192.168.1.X:8000/api/v1
```

### Production Server Details
- **URL**: `https://erp1.bdcbiz.com`
- **API Base**: `https://erp1.bdcbiz.com/api/v1`
- **Server IP**: `31.97.46.103`
- **Laravel**: 12.37.0
- **Database**: MySQL (erp1)
- **SSL**: Valid (Let's Encrypt)

### Switching Environments

**To switch to local development**:
1. Open `lib/core/config/api_config.dart`
2. Change line 26 to: `static const String baseUrl = baseUrlEmulator;`
3. Start local backend: `cd D:\php_project\filament-hrm && php artisan serve`
4. Hot restart Flutter app

**To switch back to production**:
1. Change line 26 to: `static const String baseUrl = baseUrlProduction;`
2. Hot restart Flutter app

See `PRODUCTION_SWITCH_README.md` for detailed switching guide.

## Architecture

### Feature Structure (Clean Architecture)

```
lib/features/{feature_name}/
├── data/
│   ├── models/          # Data models with JSON serialization
│   └── repo/            # Repository pattern for API calls
├── logic/
│   └── cubit/           # Business logic (BLoC pattern)
│       ├── {feature}_cubit.dart
│       └── {feature}_state.dart
└── ui/
    ├── screens/         # Full-page screens
    └── widgets/         # Feature-specific widgets
```

### Core Infrastructure

```
lib/core/
├── config/              # API endpoints, environment configs
├── networking/          # DioClient (singleton), ApiInterceptor
├── routing/             # AppRouter, NavigationHelper, route guards, transitions
├── styles/              # AppTheme, AppColors, AppTextStyles
├── widgets/             # Reusable components (CustomButton, CustomTextField)
├── services/            # LocationService for GPS
├── errors/              # Error handling utilities
├── constants/           # App-wide constants
└── integrations/
    └── figma_links/     # Design system references
```

### Existing Features

- `auth` - Login, registration, admin login, token management
- `dashboard` - Dashboard statistics with service cards
- `attendance` - Check-in/out with location tracking, history, calendar, multiple sessions
- `leave` / `leaves` - Leave requests, balance, history (note: separate features for logic vs UI)
- `chat` - WhatsApp-style messaging with real-time chat, file attachments, employee selection
- `profile` - User profile, edit, change password
- `notifications` - Notification list and management
- `work_schedule` - Work schedule display
- `reports` - Monthly reports
- `branches` - Branch management with geofencing
- `home`, `settings`, `about`, `more` - Additional screens

## Development Commands

### Flutter

```bash
# Install dependencies
flutter pub get

# Run code generation (for JSON models)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
flutter pub run build_runner watch

# Run on specific devices
flutter run                    # Android emulator (default)
flutter run -d windows
flutter run -d chrome

# Code quality
flutter analyze
dart format .
flutter test

# Clean build (if issues occur)
flutter clean
flutter pub get

# Build release (recommended with obfuscation and shrinking)
flutter build apk --release --obfuscate --split-debug-info=build/debug_info
flutter build appbundle --release --obfuscate --split-debug-info=build/debug_info
flutter build windows
```

### Backend (Laravel)

#### Local Backend (`D:\php_project\filament-hrm`)

```bash
# Start server
php artisan serve

# Database operations
php artisan migrate
php artisan migrate:fresh --seed  # Reset and seed
php artisan db:seed

# Clear caches (always do this after backend code changes)
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Check routes
php artisan route:list --path=api/v1
```

#### Production Backend (SSH Access)

**Server**: `root@31.97.46.103`
**Laravel Path**: `/var/www/erp1` (confirmed via SSH)

```bash
# Connect to server
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no root@31.97.46.103

# Common commands (run on server)
cd /var/www/erp1
php artisan cache:clear
php artisan config:clear
php artisan migrate
php artisan route:list --path=api/v1

# View logs
tail -f /var/www/erp1/storage/logs/laravel.log
```

**Important**: Test backend changes locally (`D:\php_project\filament-hrm`) before deploying to production.

#### Testing Scripts (`C:\xampp\htdocs\flowERP`)

Additional PHP test utilities for backend testing:
```bash
cd C:\xampp\htdocs\flowERP
php test_multiple_sessions.php  # Test attendance sessions
```

## API Integration

### Base URL Configuration

Edit `lib/core/config/api_config.dart` line 26:

```dart
// Choose based on environment
static const String baseUrl = baseUrlProduction;   // Production: https://erp1.bdcbiz.com/api/v1
static const String baseUrl = baseUrlEmulator;     // Android Emulator: http://10.0.2.2:8000/api/v1
static const String baseUrl = baseUrlSimulator;    // iOS/Web: http://localhost:8000/api/v1
static const String baseUrl = baseUrlRealDevice;   // Real Device: http://192.168.1.X:8000/api/v1
```

**Note**: For real device testing, update the IP in `baseUrlRealDevice` to match your computer's local network IP.

### HTTP Client Pattern

All API calls use DioClient singleton with automatic token injection via ApiInterceptor:

```dart
final _dioClient = DioClient.getInstance();

// Example repository method
Future<Model> fetchData() async {
  final response = await _dioClient.get(ApiConfig.endpoint);
  if (response.statusCode == 200) {
    return Model.fromJson(response.data['data']);
  }
  throw Exception(response.data['message']);
}
```

### API Response Structure

Standard API responses follow this format:

```json
// Success (200)
{
  "success": true,
  "message": "Operation successful",
  "data": { /* payload */ }
}

// Error (4xx, 5xx)
{
  "success": false,
  "message": "Error description",
  "errors": { /* validation errors */ }
}
```

Always check `response.statusCode` and parse `response.data['data']` for success responses.

### Authentication Flow

1. Login stores token in `flutter_secure_storage` (key: `auth_token`)
2. ApiInterceptor automatically adds `Authorization: Bearer {token}` to all requests
3. 401 responses trigger logout flow
4. Supports both employee and admin authentication with separate guards

## Theme System

### Colors

All colors defined in `lib/core/styles/app_colors.dart`:

- **Primary**: `#2D3142` (dark navy)
- **Accent**: `#EF8354` (coral/orange)
- **Success**: `#10B981`, **Error**: `#EF4444`, **Warning**: `#F59E0B`
- Use `AppColors.*` constants, NOT hardcoded hex values

### Usage

```dart
// ✅ Correct
Container(color: AppColors.primary)
CustomButton(text: 'Save', type: ButtonType.primary, onPressed: () {})

// ❌ Wrong
Container(color: Color(0xFF2D3142))
```

Full theme guide: `lib/core/styles/THEME_GUIDE.md`

## Feature Development Workflow

1. **Create feature structure**: `lib/features/{feature_name}/data/models/`, `data/repo/`, `logic/cubit/`, `ui/screens/`, `ui/widgets/`
2. **Define model**: Add JSON serialization annotations (`@JsonSerializable()`)
3. **Generate code**: `flutter pub run build_runner build --delete-conflicting-outputs`
4. **Implement repository**:
   - Use `DioClient.getInstance()` singleton
   - Handle responses: check `statusCode`, parse `response.data['data']`
   - Throw meaningful exceptions for errors
5. **Create cubit**:
   - Extend from BLoC's `Cubit<YourState>`
   - State must extend `Equatable` with `props` list
   - Implement `copyWith` for immutable state updates
   - Use try-catch with loading/success/error flow
6. **Build UI**:
   - Use BlocBuilder/BlocConsumer to watch state
   - Use core widgets: `CustomButton`, `CustomTextField`
   - Follow `AppColors.*` and `AppTextStyles.*`
   - Add route to `AppRouter` if creating new screen
7. **Test**: Unit tests for cubits/repos, widget tests for complex UI
8. **Document**: Update API_DOCUMENTATION.md if adding new endpoints

## Important Architectural Patterns

### Singleton Pattern
- **DioClient**: Use `DioClient.getInstance()` - never instantiate directly
- Ensures single HTTP client instance with shared configuration and interceptors

### Repository Pattern
- All API calls go through repository classes in `features/{name}/data/repo/`
- Repositories use DioClient and return models (not raw responses)
- UI layer (screens/widgets) never calls DioClient directly

### BLoC/Cubit Pattern
- Business logic lives in `features/{name}/logic/cubit/`
- UI subscribes to state changes via `BlocBuilder` or `BlocConsumer`
- Cubits call repositories, never DioClient directly
- Always emit new state instances (immutable pattern)

### Separate Features Pattern
- Note: `leave` and `leaves` are separate features
- `leave` contains business logic (models, repos, cubits)
- `leaves` contains UI layer (screens, widgets)
- This separation allows reusing logic across different UIs

## Code Generation

Models use `json_serializable` for automatic JSON serialization:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

### When to Run Build Runner

Run code generation after:
- Creating a new model with `@JsonSerializable()`
- Adding/removing fields from existing models
- Changing `@JsonKey` annotations
- Getting build errors about missing `.g.dart` files

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generates on file save)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean before building (if conflicts occur)
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Important**: Always commit `.g.dart` files to version control.

## State Management

Uses `flutter_bloc` with Cubit pattern. States must extend `Equatable` for efficient rebuilds:

```dart
// State with Equatable
class FeatureState extends Equatable {
  final bool isLoading;
  final String? error;
  final Data? data;

  const FeatureState({this.isLoading = false, this.error, this.data});

  FeatureState copyWith({bool? isLoading, String? error, Data? data}) {
    return FeatureState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, data];
}

// Cubit with error handling
class FeatureCubit extends Cubit<FeatureState> {
  final FeatureRepo _repo;

  FeatureCubit(this._repo) : super(const FeatureState());

  Future<void> fetchData() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _repo.getData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
```

**Important**: Always implement `copyWith` method for state classes to enable immutable updates.

### Using BlocListener for Side Effects

Use `BlocListener` for actions like navigation, snackbars, or triggering other operations:

```dart
BlocListener<FeatureCubit, FeatureState>(
  listener: (context, state) {
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
    if (state.data != null) {
      // Navigate, refresh, or trigger other cubits
      context.read<OtherCubit>().fetchData();
    }
  },
  child: YourWidget(),
)
```

Use `BlocConsumer` when you need both listening and building from the same cubit.

## Key Dependencies

**State & Networking**:
- **flutter_bloc**: State management (Cubit pattern)
- **equatable**: Value equality for states (required for BLoC rebuilds)
- **dio**: HTTP client (singleton pattern via DioClient)
- **flutter_secure_storage**: Secure token storage (key: `auth_token`)

**Code Generation**:
- **json_annotation** + **build_runner** + **json_serializable**: JSON serialization

**UI & Media**:
- **fl_chart**: Charts and visualizations
- **cached_network_image**: Image caching
- **image_picker**: Image/file selection

**Location & Permissions**:
- **geolocator**: GPS location services (for attendance)
- **permission_handler**: Runtime permissions

**Utilities**:
- **intl**: Date/time formatting
- **timeago**: Relative time formatting
- **shared_preferences**: Local key-value storage

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/logic/cubit/auth_cubit_test.dart

# Run with coverage
flutter test --coverage

# View coverage report (HTML)
genhtml coverage/lcov.info -o coverage/html
```

Use `mockito` for mocking dependencies and `bloc_test` for testing cubits. Current test coverage is minimal - expand as needed.

## Navigation System

**Note**: Despite `go_router` being in dependencies, the app uses a **custom routing system** via `AppRouter` with manual route generation and custom transitions.

### Centralized Routing

All navigation uses named routes via `AppRouter` (not go_router):

```dart
// Navigate to a screen
AppRouter.navigateTo(context, AppRouter.profile);

// Replace current screen
AppRouter.navigateAndReplace(context, AppRouter.mainNavigation);

// Clear stack and navigate
AppRouter.navigateAndRemoveUntil(context, AppRouter.login);
```

### Custom Page Transitions

```dart
// Use extension method with custom transition
const ProfileScreen().navigate(
  context,
  transition: RouteTransitionType.slideFromRight,
);

// Available transitions: material, fade, slideFromRight, slideFromLeft,
// slideFromBottom, slideFromTop, scale, rotation, slideAndFade
```

### Route Guards

Protect routes requiring authentication:

```dart
class ProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      child: Scaffold(/* content */),
      requireAdmin: false, // Set true for admin-only routes
    );
  }
}
```

### Navigation Helpers

```dart
// Quick navigation methods
NavigationHelper.goToLogin(context);
NavigationHelper.goToHome(context);
NavigationHelper.logout(context);

// Show dialogs
NavigationHelper.showCustomDialog(context: context, child: widget);
NavigationHelper.showConfirmationDialog(context, title: '...', message: '...');
NavigationHelper.showLoadingDialog(context);
```

### Adding New Routes

1. Add route name in `lib/core/routing/app_router.dart`
2. Add case in `onGenerateRoute` method
3. Use `AppRouter.navigateTo(context, AppRouter.yourRoute)`

Full navigation guide: `lib/core/routing/README.md`

### Bottom Navigation Structure

The app uses `MainNavigationScreen` as the main container with 4 tabs:

1. **Home** (`HomeMainScreen`) - Dashboard with attendance widget and service cards
2. **Chat** (`ChatListScreen`) - WhatsApp-style messaging
3. **Leaves** (`LeavesMainScreen`) - Leave management (apply, history, balance)
4. **More** (`MoreMainScreen`) - Settings, reports, profile, etc.

**Important**:
- After login, users land on `MainNavigationScreen` (not individual screens)
- Each tab maintains its own navigation stack
- Company ID is currently hardcoded to `6` (BDC) in `MainNavigationScreen` - TODO: Add to UserModel

## Documentation References

- **API Documentation**: `API_DOCUMENTATION.md` - All backend endpoints and response formats
- **Flutter API Setup**: `FLUTTER_API_SETUP.md` - Arabic guide for API integration
- **Theme Guide**: `lib/core/styles/THEME_GUIDE.md` - Complete theme system documentation
- **Navigation Guide**: `lib/core/routing/README.md` - Routing system details
- **Quick Reference**: `QUICK_REFERENCE.md` - Quick reference guide (Arabic)
- **Changelog**: `CHANGELOG.md` - Detailed change history
- **Production Testing**: `PRODUCTION_TESTING_GUIDE.md` - Production testing checklist
- **Production Switch**: `PRODUCTION_SWITCH_README.md` - Environment switching guide
- **Chat Implementation**: `CHAT_FEATURE_IMPLEMENTATION_REPORT.md` - Complete chat feature documentation
- **Security Guide**: `SECURITY_QUICK_GUIDE.md` - Security improvements and testing (Arabic)
- **Attendance Documentation**: `ATTENDANCE_FEATURE_DOCUMENTATION.md` - Multiple sessions implementation
- **Figma Designs**: https://www.figma.com/design/gNAzHVWnkINNfxNmDZX7Nt
- **Backend Location**: `D:\php_project\filament-hrm` (local), `/var/www/erp1` (production server)

## Location Services

The app uses GPS location for attendance check-in/check-out:

```dart
// LocationService provides:
- isLocationServiceEnabled()
- checkPermission() / requestPermission()
- getCurrentPosition()
```

Required permissions configured in:
- **Android**: `android/app/src/main/AndroidManifest.xml` (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)
- **iOS**: `ios/Runner/Info.plist` (NSLocationWhenInUseUsageDescription)

## Common Issues

### API Connection
- **Android Emulator**: Use `10.0.2.2` instead of `localhost`
- **Real device**: Ensure same WiFi network, use computer's IP address
- **Production**: Ensure internet connectivity, verify `baseUrl = baseUrlProduction`
- **Check backend**: For local dev, verify `php artisan serve` is running

### Build Runner Issues
```bash
# Clear and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Token Issues
- Token stored in `flutter_secure_storage` with key `auth_token`
- ApiInterceptor handles 401 responses
- Check token in login response: `response.data['data']['access_token']`
- If persistent issues: logout and login again

### Location Permission Issues
- Ensure location services are enabled on device
- Check manifest/plist files for proper permission declarations
- Test permission flow: denied → request → granted

### Environment Mismatch
- **Symptom**: "Connection refused" or "Cannot connect to server"
- **Solution**: Verify `baseUrl` in `lib/core/config/api_config.dart:26` matches your target environment
- **CRITICAL**: After changing `baseUrl`, you MUST perform a **hot restart** (not hot reload) - press `R` in terminal or use IDE restart button
- Hot reload will NOT pick up `const` changes in `api_config.dart`

## Attendance Feature: Multiple Sessions

### Overview
The attendance system supports **unlimited check-in/check-out sessions per day**. Employees can:
- Check-in → Check-out → Check-in → Check-out (unlimited cycles)
- Track multiple work sessions with GPS location
- View all sessions with real-time status updates

### Key Implementation Details

#### State Management Pattern
Always use `hasActiveSession` from API (NOT `hasCheckedIn` && `!hasCheckedOut`):

```dart
// ✅ Correct approach
final hasActiveSession = status?.hasActiveSession ?? false;

if (hasActiveSession) {
  // Show "Check Out" button
} else {
  // Show "Check In" button
}

// ❌ Wrong (old single-session approach)
if (hasCheckedIn && !hasCheckedOut) {
  // This breaks with multiple sessions
}
```

#### State Persistence
Use state persistence to maintain status during loading states:

```dart
class _AttendanceWidgetState extends State<AttendanceWidget> {
  AttendanceStatusModel? _lastStatus;  // Store last status

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        // Save status when loaded
        if (state is AttendanceStatusLoaded) {
          _lastStatus = state.status;
        }

        // Use persisted status (survives SessionsLoading, etc.)
        final status = _lastStatus ?? extractFromState(state);
        final hasActiveSession = status?.hasActiveSession ?? false;
      },
    );
  }
}
```

#### Auto-refresh Pattern
Always refresh status after successful operations:

```dart
listener: (context, state) {
  if (state is CheckInSuccess || state is CheckOutSuccess) {
    // Refresh to get updated hasActiveSession
    context.read<AttendanceCubit>().fetchTodayStatus();
    context.read<AttendanceCubit>().fetchTodaySessions();
  }
}
```

#### Custom Type Converter
Handle mixed String/num types from API:

```dart
class DurationHoursConverter implements JsonConverter<double?, dynamic> {
  const DurationHoursConverter();

  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(double? value) => value;
}

// Usage in model
@JsonKey(name: 'duration_hours')
@DurationHoursConverter()
final double? durationHours;
```

### API Response Structure

```json
{
  "has_checked_in": true,
  "has_checked_out": false,
  "has_active_session": true,  // ⭐ Use this for button state
  "current_session": {
    "session_id": 15,
    "check_in_time": "09:00:00"
  },
  "sessions_summary": {
    "total_sessions": 3,
    "active_sessions": 1,
    "completed_sessions": 2
  }
}
```

### Testing Multiple Sessions

Backend test script available at `C:\xampp\htdocs\flowERP\test_multiple_sessions.php`:

```bash
cd C:\xampp\htdocs\flowERP
php test_multiple_sessions.php
```

This tests:
- Multiple sequential check-in/check-out cycles
- Status updates after each operation
- Session list accuracy

### Documentation
See `ATTENDANCE_FEATURE_DOCUMENTATION.md` for:
- Complete technical implementation details
- API endpoints with examples
- Troubleshooting guide
- Testing checklist
- Future improvements

## Backend Development

### Backend Locations

**Local Development**: `D:\php_project\filament-hrm`
- Use for testing backend changes before production
- Run `php artisan serve` to start local server

**Production Server**: `/var/www/erp1` (via SSH to `root@31.97.46.103`)
- Live production environment
- Access via SSH: `ssh -i ~/.ssh/id_ed25519 root@31.97.46.103`

**Testing Scripts**: `C:\xampp\htdocs\flowERP`
- PHP utilities for testing backend functionality

### Testing Backend Changes

**Always test locally first**, then deploy to production:

1. **Make changes** in `D:\php_project\filament-hrm`
2. **Clear caches**: `php artisan cache:clear && php artisan config:clear`
3. **Restart server**: `php artisan serve`
4. **Test in Flutter**: Set `baseUrl = baseUrlEmulator` and test thoroughly
5. **Deploy to production**: Copy changes to production server
6. **Clear production caches**: SSH to server and run `php artisan cache:clear`
7. **Test production**: Set `baseUrl = baseUrlProduction` and verify

### Database Seeding

Important seed data for testing:
- **Departments**: Required for employee registration
- **Vacation Types**: Required for leave requests
- **Work Schedules**: Required for attendance tracking

```bash
# Seed specific tables (local)
php artisan db:seed --class=DepartmentSeeder
php artisan db:seed --class=VacationTypeSeeder

# Reset and seed everything (local)
php artisan migrate:fresh --seed
```

**Warning**: Never run `migrate:fresh` on production - it deletes all data!

## Multi-Tenancy

The system supports multi-tenancy with `CurrentCompanyScope`:

### Important Patterns
- All models with `CompanyOwned` trait automatically scope by company
- API requests must set session company_id explicitly
- Employee sees only their company's data

### Common Issue: CurrentCompanyScope Error
**Symptom**: `ModelNotFoundException: CurrentCompanyScope: No company_id set in the session or on the user`

**Solution**: Add session company_id before querying:
```php
session(['current_company_id' => $employee->company_id]);
```

See `CURRENTCOMPANYSCOPE_FIX_COMPLETE.md` for detailed fix documentation.

## Test Credentials

### Production Server
```
Email: Ahmed@bdcbiz.com
Password: password
Company ID: 6 (BDC)
Department: التطوير
```

### Local Development
```
Email: employee@example.com
Password: password
```

Or create test employees via Admin Panel at `http://localhost:8000/admin`

## Chat Feature

### Overview
WhatsApp-inspired chat system with private and group messaging, file attachments, and real-time updates.

### Architecture Pattern
```
ChatListScreen (conversations) → ChatRoomScreen (messages)
      ↓                                    ↓
  ChatCubit                          MessagesCubit
      ↓                                    ↓
           ChatRepository (shared)
```

### Key Implementation Details

**Repository**: `lib/features/chat/data/repo/chat_repository.dart`
- `getConversations(companyId)` - Fetch all conversations
- `createConversation(companyId, participantIds, type, name?)` - Create new chat
- `getMessages(conversationId, companyId)` - Fetch messages
- `sendMessage(conversationId, companyId, body, attachment?)` - Send message with optional file
- `getUsers(companyId)` - Get employees for new chat

**Cubits**:
- `ChatCubit` - Manages conversation list state
- `MessagesCubit` - Manages messages within a conversation
- `EmployeesCubit` - Manages employee selection with search

**Usage Example**:
```dart
// Navigate to chat list
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatListScreen(
      companyId: authState.user.companyId,
      currentUserId: authState.user.id,
    ),
  ),
);
```

**Models**:
- Chat models use special `fromApiJson()` factory methods (not standard `fromJson()`) due to nested API response structure
- Example: `ConversationModel.fromApiJson()` unwraps `data` wrapper from API
- Standard models use `fromJson()` generated by `json_serializable`
- Supports text messages, images, files, and voice messages

**Testing**: Backend test available via `/api/conversations` endpoints

See `CHAT_FEATURE_IMPLEMENTATION_REPORT.md` for complete implementation details.

### Important: Model Parsing Patterns

This codebase uses **two different JSON parsing patterns**:

**Pattern 1: Standard Models** (most features)
```dart
// Uses json_serializable generated fromJson()
final model = UserModel.fromJson(response.data['data']);
```

**Pattern 2: Chat Models** (chat feature only)
```dart
// Uses custom fromApiJson() that handles nested structure
final conversation = ConversationModel.fromApiJson(response.data);
// fromApiJson() internally unwraps response.data['data']
```

**When adding new features**: Use Pattern 1 (standard `fromJson()`) unless dealing with complex nested API structures.

## Real-time Features (WebSocket)

The app supports real-time updates via Laravel Reverb (Pusher protocol) for chat and notifications.

### WebSocketService

**Location**: `lib/core/services/websocket_service.dart`

**Configuration** (Production):
- Host: `31.97.46.103:8081`
- Protocol: `ws://` (WebSocket)
- App Key: `pgvjq8gblbrxpk5ptogp`

**Usage Pattern**:
```dart
// Initialize (typically in main.dart or after login)
await WebSocketService.instance.initialize();

// Subscribe to private channel
WebSocketService.instance.subscribeToPrivateChannel(
  channelName: 'private-user.${userId}',
  eventName: 'NewMessage',
  onEvent: (data) {
    // Handle real-time event
    print('New message: $data');
  },
);

// Disconnect (on logout)
await WebSocketService.instance.disconnect();
```

**Authentication**: Uses `/api/broadcasting/auth` endpoint with Bearer token from `flutter_secure_storage`.

**Important**: WebSocket is optional - features work with polling fallback if WebSocket fails to connect.

## Security Configuration

### Android Release Builds

The app is configured with production-grade security:

**Network Security** (`android/app/src/main/res/xml/network_security_config.xml`):
- HTTPS-only in production (`cleartextTrafficPermitted="false"`)
- Development localhost exception for testing
- SSL certificate pinning configured

**ProGuard** (`android/app/proguard-rules.pro`):
- Code obfuscation enabled in release builds
- Removes debug logs and unused code
- Protects against reverse engineering

**Build Configuration** (`android/app/build.gradle.kts`):
- `isMinifyEnabled = true` - Code shrinking and obfuscation
- `isShrinkResources = true` - Removes unused resources
- `allowBackup = false` - Prevents data extraction
- Package name: `com.bdcbiz.hrm`

**Important**: Before production release, remove localhost exceptions from `network_security_config.xml`

See `SECURITY_QUICK_GUIDE.md` for security testing checklist and MobSF testing instructions.
