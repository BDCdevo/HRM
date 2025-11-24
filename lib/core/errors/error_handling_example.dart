/// Error Handling Examples
///
/// Shows how to use the new error handling system in different scenarios

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'error_handler.dart';
import 'app_error.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 1: Basic Error Handling in a Repository
/// ═══════════════════════════════════════════════════════════════════════════

class ExampleRepository {
  final Dio _dio;

  ExampleRepository(this._dio);

  Future<void> fetchData() async {
    try {
      final response = await _dio.get('/api/data');
      // Process response...
    } on DioException catch (e) {
      // Let the error propagate - will be caught by Cubit
      rethrow;
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 2: Error Handling in a Cubit
/// ═══════════════════════════════════════════════════════════════════════════

class ExampleCubit {
  final ExampleRepository _repo;

  ExampleCubit(this._repo);

  Future<void> loadData() async {
    try {
      // Loading state...
      await _repo.fetchData();
      // Success state...
    } on DioException catch (e) {
      // Convert to AppError automatically
      final error = fromDioException(e);

      // Emit error state with AppError
      // emit(ErrorState(error: error));

      // Or just rethrow to be handled in UI
      rethrow;
    } catch (e) {
      // Handle unexpected errors
      final error = UnknownError.unexpected(e);
      // emit(ErrorState(error: error));
      rethrow;
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 3: Display Error in UI - SnackBar (Default)
/// ═══════════════════════════════════════════════════════════════════════════

class Example1Screen extends StatelessWidget {
  const Example1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 1: SnackBar')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _simulateError(context),
          child: const Text('Simulate Network Error'),
        ),
      ),
    );
  }

  void _simulateError(BuildContext context) {
    try {
      // Simulate network error
      throw DioException(
        requestOptions: RequestOptions(path: '/api/test'),
        type: DioExceptionType.connectionTimeout,
      );
    } catch (error) {
      // ✅ Use ErrorHandler to display
      ErrorHandler.handle(
        context: context,
        error: error,
        displayType: ErrorDisplayType.snackbar, // Default
        onRetry: () => _simulateError(context),
      );
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 4: Display Error as Dialog
/// ═══════════════════════════════════════════════════════════════════════════

class Example2Screen extends StatelessWidget {
  const Example2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 2: Dialog')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _simulateError(context),
          child: const Text('Simulate Auth Error'),
        ),
      ),
    );
  }

  void _simulateError(BuildContext context) {
    // ✅ Create custom error
    final error = AuthError.sessionExpired();

    ErrorHandler.handle(
      context: context,
      error: error,
      displayType: ErrorDisplayType.dialog, // Show as dialog
      onRetry: () {
        // Navigate to login
        debugPrint('Navigating to login...');
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 5: Display Error as Toast
/// ═══════════════════════════════════════════════════════════════════════════

class Example3Screen extends StatelessWidget {
  const Example3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 3: Toast')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _simulateError(context),
          child: const Text('Simulate Validation Error'),
        ),
      ),
    );
  }

  void _simulateError(BuildContext context) {
    // ✅ Create validation error with field errors
    final error = ValidationError.fromMap({
      'email': ['البريد الإلكتروني غير صحيح'],
      'password': ['كلمة المرور قصيرة جداً'],
    });

    ErrorHandler.handle(
      context: context,
      error: error,
      displayType: ErrorDisplayType.toast, // Lightweight toast
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 6: Handle Geofence Error
/// ═══════════════════════════════════════════════════════════════════════════

class Example4Screen extends StatelessWidget {
  const Example4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 4: Geofence Error')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _simulateError(context),
          child: const Text('Simulate Geofence Error'),
        ),
      ),
    );
  }

  void _simulateError(BuildContext context) {
    // ✅ Create geofence error with distance info
    final error = GeofenceError.outsideBoundary(
      distance: 250,
      radius: 100,
    );

    ErrorHandler.handle(
      context: context,
      error: error,
      displayType: ErrorDisplayType.dialog,
      onRetry: () {
        debugPrint('Checking location again...');
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 7: BlocListener with ErrorHandler
/// ═══════════════════════════════════════════════════════════════════════════

/*
class ExampleScreenWithBloc extends StatelessWidget {
  const ExampleScreenWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExampleCubit, ExampleState>(
      listener: (context, state) {
        // ✅ Handle error states
        if (state is ExampleError) {
          ErrorHandler.handle(
            context: context,
            error: state.error, // AppError from state
            displayType: ErrorDisplayType.snackbar,
            onRetry: () {
              context.read<ExampleCubit>().loadData();
            },
          );
        }

        // Handle success
        if (state is ExampleSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم التحميل بنجاح')),
          );
        }
      },
      child: BlocBuilder<ExampleCubit, ExampleState>(
        builder: (context, state) {
          if (state is ExampleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExampleSuccess) {
            return ListView(/* data */);
          }

          // Initial or error state
          return const Center(child: Text('اضغط للتحميل'));
        },
      ),
    );
  }
}
*/

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 8: Handle 401 Unauthorized
/// ═══════════════════════════════════════════════════════════════════════════

void handleUnauthorizedExample(BuildContext context) {
  try {
    // Simulate 401 response
    throw DioException(
      requestOptions: RequestOptions(path: '/api/profile'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/profile'),
        statusCode: 401,
        data: {'message': 'Unauthorized'},
      ),
    );
  } catch (error) {
    // ✅ This will be converted to AuthError.sessionExpired()
    ErrorHandler.handle(
      context: context,
      error: error,
      displayType: ErrorDisplayType.dialog,
      onRetry: () {
        // Navigate to login
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 9: Silent Error Handling (Log Only)
/// ═══════════════════════════════════════════════════════════════════════════

void silentErrorExample() {
  try {
    // Some operation
    throw Exception('Background sync failed');
  } catch (error) {
    // ✅ Log error without showing to user
    ErrorHandler.handleSilently(error);
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Example 10: Custom Error Types
/// ═══════════════════════════════════════════════════════════════════════════

void customErrorExample(BuildContext context) {
  // ✅ Create business logic error
  final error = BusinessError.insufficientBalance();

  ErrorHandler.handle(
    context: context,
    error: error,
    displayType: ErrorDisplayType.dialog,
    showRetryButton: false, // Not retryable
  );
}
