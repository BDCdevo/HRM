# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HRM (Human Resource Management) Flutter app with Laravel (Filament) PHP backend. Clean Architecture with BLoC/Cubit state management.

**Version**: 1.1.3+13 | **SDK**: Dart ^3.9.2

## Quick Start

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

**Single Test File**:
```bash
flutter test test/path/to/specific_test.dart
```

## Environment Configuration

**Current**: PRODUCTION (`lib/core/config/api_config.dart:26`)

```dart
static const String baseUrl = baseUrlProduction;    // https://erp1.bdcbiz.com/api/v1
// static const String baseUrl = baseUrlEmulator;   // Android: http://10.0.2.2:8000/api/v1
// static const String baseUrl = baseUrlSimulator;  // iOS/Web: http://localhost:8000/api/v1
```

**CRITICAL**: After changing `baseUrl`, use Hot Restart (`R`), not hot reload.

### Production Server
- **SSH**: `ssh -i ~/.ssh/id_ed25519 root@31.97.46.103`
- **Path**: `/var/www/erp1`

### Local Backend
```bash
cd D:\php_project\filament-hrm && php artisan serve
```

## Architecture

### Feature Structure (Clean Architecture)

```
lib/features/{feature_name}/
├── data/
│   ├── models/          # @JsonSerializable() models + .g.dart files
│   └── repo/            # Repository using DioClient.getInstance()
├── logic/
│   └── cubit/           # Cubit + State (extends Equatable)
└── ui/
    ├── screens/
    └── widgets/
```

### Core Infrastructure

- `lib/core/config/api_config.dart` - API endpoints (all endpoints defined here)
- `lib/core/networking/` - DioClient (singleton), ApiInterceptor (auth token injection)
- `lib/core/routing/app_router.dart` - Custom router (NOT go_router despite pubspec dependency)
- `lib/core/styles/` - AppColors, AppTextStyles, AppColorsExtension
- `lib/core/errors/` - AppError types, ErrorHandler, fromDioException()
- `lib/core/services/websocket_service.dart` - Pusher/Reverb for real-time chat
- `lib/core/navigation/main_navigation_screen.dart` - Main 4-tab layout

### Key Patterns

**DioClient Singleton**: Always use `DioClient.getInstance()`, never instantiate directly.

**Separate Features**: `leave` (logic) and `leaves` (UI) are intentionally separate to allow reusing business logic.

**Chat Models Exception**: Chat models use `fromApiJson()` instead of standard `fromJson()` due to nested API response structure.

**Location/Geofencing**: Attendance check-in uses `geolocator` for branch geofencing validation. Location permission required.

**Firebase**: Crashlytics and Analytics enabled. Initialize in `main.dart` before `runApp()`.

## Development Commands

```bash
# Code generation (run after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk --release --obfuscate --split-debug-info=build/debug_info

# Build release AAB (Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug_info

# Testing & Analysis
flutter test
flutter analyze
dart format .
```

### Backend Commands

```bash
# Local (D:\php_project\filament-hrm)
php artisan serve
php artisan cache:clear && php artisan config:clear

# Production (after SSH)
cd /var/www/erp1
php artisan cache:clear
tail -f storage/logs/laravel.log
```

## API Integration

### Repository Pattern

```dart
final _dioClient = DioClient.getInstance();

Future<Model> fetchData() async {
  final response = await _dioClient.get(ApiConfig.endpoint);
  if (response.statusCode == 200) {
    return Model.fromJson(response.data['data']);  // Parse from 'data' key
  }
  throw Exception(response.data['message']);
}
```

### Authentication
- Token stored in `flutter_secure_storage` (key: `auth_token`)
- ApiInterceptor auto-adds `Authorization: Bearer {token}`
- 401 responses trigger logout via NavigationHelper

## Theme System

**ALWAYS use `AppColors.*` and `AppTextStyles.*` - NEVER hardcode colors or text styles.**

```dart
// Correct
Text('Welcome', style: AppTextStyles.welcomeTitle)
Container(color: AppColors.primary)

// Wrong - never do this
Text('Welcome', style: TextStyle(fontSize: 26))
Container(color: Color(0xFF2D3142))
```

For dark mode support, use `AppColorsExtension`:
```dart
color: Theme.of(context).extension<AppColorsExtension>()!.primary
```

## State Management (BLoC/Cubit)

States MUST extend `Equatable` and implement `copyWith`:

```dart
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
```

## Code Generation

Models use `@JsonSerializable()`. Run after model changes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Commit `.g.dart` files to version control.

## Navigation

Uses **custom AppRouter** (`lib/core/routing/app_router.dart`) - NOT go_router:

```dart
AppRouter.navigateTo(context, AppRouter.profile);
AppRouter.navigateAndReplace(context, AppRouter.mainNavigation);
AppRouter.navigateAndRemoveUntil(context, AppRouter.login);
```

### Main Navigation Structure
- 4 tabs: Home, Chat, Requests, More
- Central FAB opens requests dialog
- Company ID hardcoded to `6` (BDC) - TODO: Add to UserModel

### Assets
- `assets/images/logo/` - App logos
- `assets/svgs/` - SVG icons (use `flutter_svg`)
- `assets/animations/` - Lottie JSON animations (use `lottie` package)

## Error Handling

Use `fromDioException()` for network errors:

```dart
try {
  final data = await _repository.getData();
  emit(state.copyWith(data: data));
} on DioException catch (e) {
  emit(state.copyWith(error: fromDioException(e)));
}
```

For UI display, use `ErrorHandler.handle()` from `lib/core/errors/error_handler.dart`.

## Real-time Chat (WebSocket)

Uses `pusher_channels_flutter` with Laravel Reverb backend:
- Service: `lib/core/services/websocket_service.dart`
- Channel pattern: `private-chat.{companyId}.conversation.{conversationId}`
- Reverb host: `ws://31.97.46.103:8081`

## Online Status Indicator

Real-time online status is tracked via `last_seen_at` timestamp on the User model.

### How It Works
1. **Backend Middleware** (`UpdateUserLastSeen`): Updates `last_seen_at` on every API request
2. **Online Threshold**: User is "online" if `last_seen_at` is within last 5 minutes
3. **API Response**: `is_online` boolean included in `/conversations` and `/users` endpoints

### Backend Files (Production Server)
- **Middleware**: `/var/www/erp1/app/Http/Middleware/UpdateUserLastSeen.php`
- **Registration**: `/var/www/erp1/bootstrap/app.php` (added to `api` middleware group)
- **Routes**: `/var/www/erp1/routes/hrm_api.php` (uses `update.last.seen` middleware)

### Flutter Implementation
Online indicator shown in 3 places:
1. **ConversationCard** (`conversation_card.dart:368`): Green dot on avatar
2. **RecentContactsSection** (`recent_contacts_section.dart:213`): Green dot on contact avatars
3. **ChatAppBarWidget** (`chat_app_bar_widget.dart:237`): Green dot + "Online" text in header

### Important: Employee → User Mapping
Sanctum authenticates with Employee model, but `last_seen_at` is on User table. The middleware maps Employee email to User and updates the correct record:
```php
if ($authUser instanceof Employee) {
    $user = User::where('email', $authUser->email)->first();
    $user->update(['last_seen_at' => now()]);
}
```

## Attendance: Multiple Sessions

Use `hasActiveSession` from API (NOT `hasCheckedIn && !hasCheckedOut`):

```dart
final hasActiveSession = status?.hasActiveSession ?? false;
if (hasActiveSession) { /* Check Out */ } else { /* Check In */ }
```

## Multi-Tenancy

Backend uses `CurrentCompanyScope`. If you get "No company_id set" error:
```php
session(['current_company_id' => $employee->company_id]);
```

## Test Credentials

**Production**: `Ahmed@bdcbiz.com` / `password` (Company ID: 6)
**Local**: `employee@example.com` / `password`

## Feature Modules

The app contains these feature modules under `lib/features/`:

| Module | Purpose |
|--------|---------|
| `auth` | Login, registration, admin login |
| `attendance` | Check-in/out, geofencing, sessions |
| `chat` | Real-time messaging with Pusher/Reverb |
| `dashboard` | Home stats and quick actions |
| `home` | Home screen widgets |
| `leave` | Leave request logic and screens |
| `leaves` | Leave UI components (separate for reuse) |
| `profile` | User profile, edit, change password |
| `notifications` | Push notifications |
| `requests` | General request management |
| `reports` | Monthly reports |
| `work_schedule` | Work schedule display |
| `more` | More tab with navigation options |
| `about` | About screen |
| `settings` | App settings |
| `branches` | Branch data and geofencing |
| `holidays` | Company holidays |
| `training` | Training features |
| `certificate` | Employee certificates |
| `general_request` | General request forms |

## Key Files Quick Reference

| Purpose | Location |
|---------|----------|
| API Endpoints | `lib/core/config/api_config.dart` |
| HTTP Client | `lib/core/networking/dio_client.dart` |
| Auth Interceptor | `lib/core/networking/api_interceptor.dart` |
| Router | `lib/core/routing/app_router.dart` |
| Colors | `lib/core/styles/app_colors.dart` |
| Text Styles | `lib/core/styles/app_text_styles.dart` |
| Error Types | `lib/core/errors/app_error.dart` |
| WebSocket | `lib/core/services/websocket_service.dart` |
| Main Nav | `lib/core/navigation/main_navigation_screen.dart` |

## Windows Development Notes

This project is developed on Windows. Use backslash paths in Windows commands or escape appropriately. The project uses `cmd.exe` style paths (e.g., `D:\php_project\filament-hrm`).
