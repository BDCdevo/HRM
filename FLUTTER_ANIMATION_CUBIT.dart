import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repo/animation_repository.dart';

// ============================================================================
// STATES
// ============================================================================

/// Base state for Animation feature
abstract class AnimationState extends Equatable {
  const AnimationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AnimationInitial extends AnimationState {}

/// Loading state (fetching animation data)
class AnimationLoading extends AnimationState {}

/// Animation data loaded successfully
class AnimationLoaded extends AnimationState {
  final String? animationUrl;
  final bool hasCustomAnimation;
  final String? uploadedAt;

  const AnimationLoaded({
    this.animationUrl,
    required this.hasCustomAnimation,
    this.uploadedAt,
  });

  @override
  List<Object?> get props => [animationUrl, hasCustomAnimation, uploadedAt];
}

/// Uploading animation state (with optional progress)
class AnimationUploading extends AnimationState {
  final double? progress;

  const AnimationUploading({this.progress});

  @override
  List<Object?> get props => [progress];
}

/// Animation uploaded successfully
class AnimationUploadSuccess extends AnimationState {
  final String animationUrl;
  final String message;

  const AnimationUploadSuccess({
    required this.animationUrl,
    this.message = 'تم رفع الصورة المتحركة بنجاح',
  });

  @override
  List<Object?> get props => [animationUrl, message];
}

/// Animation deleted successfully
class AnimationDeleteSuccess extends AnimationState {
  final String message;

  const AnimationDeleteSuccess({
    this.message = 'تم حذف الصورة المتحركة بنجاح',
  });

  @override
  List<Object?> get props => [message];
}

/// Validation in progress
class AnimationValidating extends AnimationState {}

/// Animation validation success
class AnimationValidationSuccess extends AnimationState {
  final Map<String, dynamic> animationInfo;
  final String message;

  const AnimationValidationSuccess({
    required this.animationInfo,
    this.message = 'الملف صالح ويمكن رفعه',
  });

  @override
  List<Object?> get props => [animationInfo, message];
}

/// Error state
class AnimationError extends AnimationState {
  final String message;

  const AnimationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// CUBIT
// ============================================================================

/// Cubit for managing custom user animations
///
/// Handles:
/// - Fetching user's current animation
/// - Uploading new animation
/// - Validating animation before upload
/// - Deleting custom animation
class AnimationCubit extends Cubit<AnimationState> {
  final AnimationRepository _repository;

  AnimationCubit(this._repository) : super(AnimationInitial());

  /// Fetch current user's animation
  Future<void> fetchAnimation() async {
    emit(AnimationLoading());
    try {
      final data = await _repository.getAnimation();

      emit(AnimationLoaded(
        animationUrl: data['animation_url'] as String?,
        hasCustomAnimation: data['has_custom_animation'] as bool? ?? false,
        uploadedAt: data['uploaded_at'] as String?,
      ));
    } catch (e) {
      emit(AnimationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Upload new custom animation
  ///
  /// [filePath] - Local file path to JSON animation
  /// Automatically validates before uploading
  /// Refreshes animation data after successful upload
  Future<void> uploadAnimation(String filePath) async {
    emit(const AnimationUploading());
    try {
      // Validate first
      await _repository.validateAnimation(filePath);

      // Upload
      final data = await _repository.uploadAnimation(filePath);

      emit(AnimationUploadSuccess(
        animationUrl: data['animation_url'] as String,
        message: 'تم رفع الصورة المتحركة بنجاح',
      ));

      // Refresh animation data
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchAnimation();
    } catch (e) {
      emit(AnimationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Validate animation file without uploading
  ///
  /// [filePath] - Local file path to validate
  /// Returns animation metadata if valid
  Future<void> validateAnimation(String filePath) async {
    emit(AnimationValidating());
    try {
      final data = await _repository.validateAnimation(filePath);

      emit(AnimationValidationSuccess(
        animationInfo: data,
        message: 'الملف صالح ويمكن رفعه',
      ));
    } catch (e) {
      emit(AnimationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Delete custom animation (revert to default)
  ///
  /// Automatically refreshes animation data after successful deletion
  Future<void> deleteAnimation() async {
    emit(AnimationLoading());
    try {
      await _repository.deleteAnimation();

      emit(const AnimationDeleteSuccess(
        message: 'تم حذف الصورة المتحركة بنجاح',
      ));

      // Refresh to show no custom animation
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AnimationLoaded(
        animationUrl: null,
        hasCustomAnimation: false,
        uploadedAt: null,
      ));
    } catch (e) {
      emit(AnimationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Get all custom animations (Admin only)
  Future<void> getAllCustomAnimations() async {
    emit(AnimationLoading());
    try {
      final animations = await _repository.getAllCustomAnimations();

      // You can create a new state for this if needed
      // For now, we'll just emit loaded state
      emit(AnimationLoaded(
        animationUrl: null,
        hasCustomAnimation: false,
      ));
    } catch (e) {
      emit(AnimationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(AnimationInitial());
  }
}
