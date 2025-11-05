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

# 3. Configure API endpoint (edit lib/core/config/api_config.dart line 22)
# Choose: baseUrlEmulator (Android), baseUrlSimulator (iOS/Web), or baseUrlRealDevice

# 4. Start backend (in separate terminal)
cd D:\php_project\filament-hrm && php artisan serve

# 5. Run app
flutter run
```

For detailed setup, see `README.md` or `GETTING_STARTED_5MIN.md`.

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
- `dashboard` - Dashboard statistics
- `attendance` - Check-in/out with location tracking, history, calendar, multiple sessions
- `leave` / `leaves` - Leave requests, balance, history (note: separate features for logic vs UI)
- `profile` - User profile, edit, change password
- `notifications` - Notification list and management
- `work_schedule` - Work schedule display
- `reports` - Monthly reports
- `branches` - Branch management
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
flutter run -d windows
flutter run -d chrome
flutter run                    # Android emulator

# Code quality
flutter analyze
dart format .
flutter test

# Build release
flutter build apk --obfuscate --split-debug-info=build/debug_info
flutter build appbundle
flutter build windows
```

### Backend (Laravel at `D:\php_project\filament-hrm`)

```bash
# Start server
php artisan serve

# Database operations
php artisan migrate
php artisan migrate:fresh --seed  # Reset and seed
php artisan db:seed

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Check specific routes
php artisan route:list --path=api/v1
```

## API Integration

### Base URL Configuration

Edit `lib/core/config/api_config.dart` line 22:

```dart
// Choose based on environment
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

Models use `json_serializable`:

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

After adding/modifying models, run: `flutter pub run build_runner build --delete-conflicting-outputs`

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

## Key Dependencies

- **dio**: HTTP client
- **flutter_bloc**: State management
- **equatable**: Value equality for states
- **flutter_secure_storage**: Secure token storage
- **json_annotation** + **build_runner** + **json_serializable**: JSON code generation
- **fl_chart**: Charts and visualizations
- **go_router**: Routing
- **cached_network_image**: Image caching
- **intl**: Date/time formatting
- **geolocator**: GPS location services
- **permission_handler**: Runtime permissions
- **image_picker**: Image selection
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

### Centralized Routing

All navigation uses named routes via `AppRouter`:

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

## Documentation References

- **API Documentation**: `API_DOCUMENTATION.md` - All backend endpoints and response formats
- **Flutter API Setup**: `FLUTTER_API_SETUP.md` - Arabic guide for API integration
- **Theme Guide**: `lib/core/styles/THEME_GUIDE.md` - Complete theme system documentation
- **Navigation Guide**: `lib/core/routing/README.md` - Routing system details
- **Quick Reference**: `QUICK_REFERENCE.md` - Quick reference guide (Arabic)
- **Changelog**: `CHANGELOG.md` - Detailed change history
- **Figma Designs**: https://www.figma.com/design/gNAzHVWnkINNfxNmDZX7Nt
- **Backend Location**: `D:\php_project\filament-hrm`

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
- Android Emulator: Use `10.0.2.2` instead of `localhost`
- Real device: Ensure same WiFi network, use computer's IP address
- Check backend is running: `php artisan serve`

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

### Location Permission Issues
- Ensure location services are enabled on device
- Check manifest/plist files for proper permission declarations
- Test permission flow: denied → request → granted
