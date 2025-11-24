# Internet Connectivity Handling Guide

## Overview

This app handles internet connectivity **WITHOUT** external packages like `connectivity_plus`.

**Why?**
-  The existing error system already handles network errors perfectly
-  Lighter and faster (no extra dependencies)
-  More reliable (checks actual internet, not just network adapter)
-  Better user experience with clear Arabic messages

---

## How It Works Currently

### Automatic Detection (Already Working!)

```dart
// In any Cubit
try {
  final data = await _repository.getData();
  emit(state.copyWith(data: data));
} on DioException catch (e) {
  // Automatically converts to NetworkError.noInternet() if no internet!
  final error = fromDioException(e);
  emit(state.copyWith(error: error));
}

// User sees:
// =ö "D' JH,/ '*5'D ('D%F*1F*"
// "J1,I 'D*-BB EF '*5'DC ('D%F*1F* H'DE-'HD) E1) #.1I"
// [%9'/) 'DE-'HD)]
```

**This already works for ALL network requests!** 

---

## Optional: Manual Check (ConnectivityHelper)

For cases where you want to check BEFORE making a request:

### Usage 1: Quick Check

```dart
import '../core/services/connectivity_helper.dart';

// Before performing network operation
final hasInternet = await ConnectivityHelper.hasInternetConnection();

if (!hasInternet) {
  // Show error manually
  ErrorHandler.handle(
    context: context,
    error: NetworkError.noInternet(),
    displayType: ErrorDisplayType.dialog,
  );
  return;
}

// Proceed with operation
await performNetworkOperation();
```

### Usage 2: Check Server Availability

```dart
// Check if YOUR server is reachable (not just internet)
final canReach = await ConnectivityHelper.canReachServer(
  'https://erp1.bdcbiz.com/api/v1/health'
);

if (!canReach) {
  ErrorHandler.handle(
    context: context,
    error: ServerError(
      message: ''D.'/E :J1 E*'-',
      details: 'D' JECF 'DH5HD %DI 'D.'/E -'DJ'K',
    ),
  );
  return;
}
```

---

## Best Practices

###  Recommended: Let Dio Handle It

**99% of cases**, you should let the error system handle it automatically:

```dart
//  BEST: Let error system handle it
try {
  final data = await _repository.getData();
  emit(state.copyWith(data: data));
} on DioException catch (e) {
  emit(state.copyWith(error: fromDioException(e)));
}

// In Screen
BlocConsumer<MyCubit, MyState>(
  listener: (context, state) {
    if (state.error != null) {
      ErrorHandler.handle(
        context: context,
        error: state.error!,
        onRetry: () => retry(),
      );
    }
  },
  ...
)
```

###   Use Manual Check Only When:

1. **Heavy operation** - e.g., uploading large file
2. **Before download** - checking before starting download
3. **User confirmation** - want to warn before starting operation

```dart
// Example: Before uploading profile image
Future<void> uploadProfileImage(File image) async {
  // Manual check before heavy operation
  final hasInternet = await ConnectivityHelper.hasInternetConnection();

  if (!hasInternet) {
    ErrorHandler.handle(
      context: context,
      error: NetworkError.noInternet(),
      displayType: ErrorDisplayType.dialog,
    );
    return;
  }

  // Proceed with upload
  try {
    await _repository.uploadImage(image);
    // Success
  } on DioException catch (e) {
    // Still catch errors from actual request
    emit(state.copyWith(error: fromDioException(e)));
  }
}
```

---

## Examples

### Example 1: Simple API Call (Recommended)

```dart
//  Simple and clean - let error system handle it
class ProductsCubit extends Cubit<ProductsState> {
  Future<void> loadProducts() async {
    emit(state.copyWith(isLoading: true));

    try {
      final products = await _repository.getProducts();
      emit(state.copyWith(isLoading: false, products: products));
    } on DioException catch (e) {
      // Automatically shows:
      // "D' JH,/ '*5'D ('D%F*1F*" if no internet
      // "'F*G* EGD) 'D'*5'D" if timeout
      // etc.
      emit(state.copyWith(
        isLoading: false,
        error: fromDioException(e),
      ));
    }
  }
}
```

### Example 2: Check Before Heavy Operation

```dart
// Manual check before file upload
class ProfileCubit extends Cubit<ProfileState> {
  Future<void> uploadImage(File image, BuildContext context) async {
    // 1. Check internet first
    final hasInternet = await ConnectivityHelper.hasInternetConnection();

    if (!hasInternet) {
      ErrorHandler.handle(
        context: context,
        error: NetworkError.noInternet(),
        displayType: ErrorDisplayType.dialog,
      );
      return;
    }

    // 2. Proceed with upload
    emit(state.copyWith(isUploading: true));

    try {
      final imageUrl = await _repository.uploadProfileImage(image);
      emit(state.copyWith(
        isUploading: false,
        profileImageUrl: imageUrl,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isUploading: false,
        error: fromDioException(e),
      ));
    }
  }
}
```

### Example 3: Pull to Refresh

```dart
// In Screen
RefreshIndicator(
  onRefresh: () async {
    // Just call refresh - error system handles connectivity
    await context.read<MyCubit>().refresh();
  },
  child: ListView(...),
)

// In Cubit
Future<void> refresh() async {
  try {
    final data = await _repository.getData();
    emit(state.copyWith(data: data));
  } on DioException catch (e) {
    // Error shown automatically via BlocListener
    emit(state.copyWith(error: fromDioException(e)));
  }
}
```

### Example 4: Retry Pattern

```dart
// In Screen - BlocConsumer with retry
BlocConsumer<MyCubit, MyState>(
  listener: (context, state) {
    if (state.error != null) {
      ErrorHandler.handle(
        context: context,
        error: state.error!,
        displayType: ErrorDisplayType.snackbar,
        onRetry: () {
          // User clicked retry
          context.read<MyCubit>().retry();
        },
      );
    }
  },
  builder: (context, state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.data == null) {
      // Full screen error with retry
      return ErrorScreen(
        error: state.error!,
        onRetry: () => context.read<MyCubit>().retry(),
      );
    }

    return YourDataWidget(data: state.data!);
  },
)
```

---

## Common Scenarios

### Scenario 1: User Opens App (No Internet)

**What happens:**
1. App tries to fetch data
2. Dio detects no internet (SocketException)
3. `fromDioException()` converts to `NetworkError.noInternet()`
4. User sees error screen with retry button
5. User clicks retry when internet is back

**No extra code needed!** 

### Scenario 2: User Loses Internet Mid-Operation

**What happens:**
1. User submits form
2. Internet drops during request
3. Dio throws timeout/connection error
4. Error system shows "D' JH,/ '*5'D ('D%F*1F*"
5. User can retry when internet is back

**No extra code needed!** 

### Scenario 3: Server is Down (But Internet Works)

**What happens:**
1. User has internet
2. Server returns 503 (Service Unavailable)
3. `fromDioException()` converts to `ServerError.serviceUnavailable()`
4. User sees: "'D./E) :J1 E*'-)"
5. Clear distinction from internet error

**No extra code needed!** 

---

## Why NOT Use connectivity_plus?

### Problems with connectivity_plus:

```dart
// L connectivity_plus can lie!
final result = await Connectivity().checkConnectivity();

// result = ConnectivityResult.wifi
// BUT: WiFi might be connected to router with no internet!
// User sees "connected" but requests still fail

// L Another issue: battery drain
// Listening to connectivity changes constantly
StreamSubscription subscription = Connectivity()
    .onConnectivityChanged
    .listen((result) {
      // This runs ALL THE TIME (battery drain)
    });
```

### Our Approach (Better):

```dart
//  Checks actual internet (not just WiFi adapter)
//  Only checks when needed (no battery drain)
//  Uses reliable endpoint (Google DNS)
final hasInternet = await ConnectivityHelper.hasInternetConnection();

//  Even better: Let Dio check automatically
// Your requests will fail if no internet anyway
// So why check twice?
```

---

## Testing

### Test No Internet

```dart
// 1. Turn off WiFi/Mobile data on device
// 2. Try any operation
// 3. Should see: "D' JH,/ '*5'D ('D%F*1F*"
// 4. Turn internet back on
// 5. Click "%9'/) 'DE-'HD)"
// 6. Should work 
```

### Test Timeout

```dart
// 1. Use slow/unstable connection
// 2. Try loading data
// 3. Should see: "'F*G* EGD) 'D'*5'D"
// 4. Can retry 
```

### Test Manual Check

```dart
// In a test screen
ElevatedButton(
  onPressed: () async {
    final hasInternet = await ConnectivityHelper.hasInternetConnection();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasInternet
            ? ' E*5D ('D%F*1F*'
            : 'L D' JH,/ '*5'D',
        ),
      ),
    );
  },
  child: const Text('A-5 'D'*5'D'),
)
```

---

## Summary

###  What You Have Now

1. **Automatic detection** - Dio catches all network errors
2. **Clear messages** - Arabic messages for all error types
3. **Retry support** - Smart retry button
4. **ConnectivityHelper** - Optional manual check

### =« What You DON'T Need

1. L `connectivity_plus` package
2. L `internet_connection_checker` package
3. L Stream subscriptions listening 24/7
4. L Complex connectivity state management

### <¯ Bottom Line

**Keep it simple:**
- Let error system handle connectivity automatically (99% of cases)
- Use `ConnectivityHelper` only for special cases (1% of cases)
- Focus on good UX with clear error messages and retry buttons

---

**Files:**
- `lib/core/services/connectivity_helper.dart` - Manual connectivity check
- `lib/core/errors/app_error.dart` - Error types (NetworkError)
- `lib/core/errors/error_handler.dart` - Automatic error handling

**Status**:  No package needed - Current system is perfect!
