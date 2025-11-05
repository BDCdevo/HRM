# 🏢 HRM - Human Resource Management System

A comprehensive Flutter-based HRM application with PHP (Laravel + Filament) backend.

## 📋 Features

### ✅ Implemented
- 🔐 **Authentication**: Employee & Admin login, registration
- ⏰ **Attendance**: Check-in/Check-out system with real-time tracking
- 🏖️ **Leave Management**: Apply, view history, check balance
- 👤 **Profile**: View and edit profile, change password
- 📊 **Dashboard**: Statistics and quick actions
- 🔔 **Notifications**: Push notifications system
- ⚙️ **Settings**: App configuration
- 🧭 **Advanced Navigation**: Named routes with custom transitions

### 🎨 UI/UX
- Clean Architecture
- Material Design 3
- Custom theme system
- Responsive layouts
- Smooth animations
- Loading states
- Error handling

### 🛠️ Technical Stack
- **Frontend**: Flutter 3.9.2+
- **State Management**: BLoC/Cubit
- **Backend**: PHP Laravel + Filament
- **HTTP Client**: Dio
- **Storage**: Flutter Secure Storage
- **Charts**: FL Chart
- **Navigation**: Custom Router with Guards

## 🚀 Getting Started

### Prerequisites
```bash
Flutter SDK: 3.9.2+
Dart SDK: ^3.9.2
PHP: 8.4+
Composer
```

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd hrm
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code for models**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configure API Base URL**
Edit `lib/core/config/api_config.dart`:
```dart
static const String baseUrl = baseUrlEmulator; // For Android Emulator
// or
static const String baseUrl = baseUrlSimulator; // For iOS/Web
// or
static const String baseUrl = baseUrlRealDevice; // For Real Device
```

5. **Run the app**
```bash
flutter run
```

### Backend Setup

1. **Navigate to backend directory**
```bash
cd D:\php_project\filament-hrm
```

2. **Install dependencies**
```bash
composer install
```

3. **Configure environment**
```bash
cp .env.example .env
php artisan key:generate
```

4. **Run migrations**
```bash
php artisan migrate
```

5. **Start server**
```bash
php artisan serve
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── networking/      # HTTP client & interceptors
│   ├── routing/         # Navigation system
│   ├── styles/          # Theme & colors
│   └── widgets/         # Shared widgets
└── features/
    ├── auth/            # Authentication
    ├── attendance/      # Check-in/out system
    ├── leave/           # Leave management (Logic)
    ├── leaves/          # Leave management (UI)
    ├── dashboard/       # Dashboard
    ├── profile/         # User profile
    ├── notifications/   # Notifications
    └── settings/        # Settings
```

## 🧭 Navigation System

### Quick Usage

```dart
// Navigate
AppRouter.navigateTo(context, AppRouter.profile);

// Navigate with transition
const ProfileScreen().navigate(
  context,
  transition: RouteTransitionType.slideFromRight,
);

// Go back
AppRouter.goBack(context);

// Logout
NavigationHelper.logout(context);
```

### Available Routes
- Authentication: `login`, `register`, `adminLogin`
- Main: `mainNavigation`, `profile`, `settings`
- Leaves: `applyLeave`, `leaveHistory`, `leaveBalance`
- And more...

See `lib/core/routing/README.md` for complete documentation.

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Development guidelines
- **[CHANGELOG.md](CHANGELOG.md)** - Detailed change log
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick reference guide
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - API documentation
- **[lib/core/routing/README.md](lib/core/routing/README.md)** - Navigation guide
- **[lib/core/styles/THEME_GUIDE.md](lib/core/styles/THEME_GUIDE.md)** - Theme guide

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .
```

## 🎨 Design System

### Colors
- Primary: `#2D3142` (Dark Navy)
- Accent: `#EF8354` (Coral)
- Success: `#10B981` (Green)
- Error: `#EF4444` (Red)
- Warning: `#F59E0B` (Orange)

### Typography
Uses Material Design 3 text styles with custom font weights.

## 🔧 Development Commands

```bash
# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch

# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d windows

# Build release
flutter build apk --obfuscate --split-debug-info=build/debug_info
```

## 🐛 Troubleshooting

### Common Issues

1. **Network Error in Emulator**
   - Use `10.0.2.2` instead of `localhost` for Android Emulator

2. **No Vacation Types**
   - Ensure backend has vacation types in database
   - Check `/leaves/types` endpoint

3. **Build Runner Conflicts**
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Session Expired**
   - Logout and login again

See [CHANGELOG.md](CHANGELOG.md) for more troubleshooting tips.

## 📦 Dependencies

### Main Dependencies
```yaml
flutter_bloc: ^8.1.3              # State management
dio: ^5.4.0                       # HTTP client
flutter_secure_storage: ^9.0.0   # Secure storage
equatable: ^2.0.5                 # Value equality
intl: ^0.18.1                     # Internationalization
fl_chart: ^0.66.0                 # Charts
```

### Dev Dependencies
```yaml
build_runner: ^2.4.0              # Code generation
json_serializable: ^6.7.0         # JSON serialization
flutter_lints: ^3.0.0             # Linting rules
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is proprietary software.

## 👥 Team

- **Developer**: [Your Name]
- **Backend**: Laravel + Filament
- **Frontend**: Flutter

## 📞 Support

For support and questions:
- Review documentation files
- Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- See [CHANGELOG.md](CHANGELOG.md) for recent changes

---

**Version**: 2.0.0
**Last Updated**: November 2, 2025
**Status**: ✅ Production Ready
