import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../logic/cubit/animation_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_user_animation.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/routing/navigation_helper.dart';

/// Screen for uploading custom Lottie animations
///
/// Features:
/// - Preview current animation
/// - Pick JSON file
/// - Validate before upload
/// - Upload animation
/// - Delete custom animation
class UploadAnimationScreen extends StatefulWidget {
  const UploadAnimationScreen({Key? key}) : super(key: key);

  @override
  State<UploadAnimationScreen> createState() => _UploadAnimationScreenState();
}

class _UploadAnimationScreenState extends State<UploadAnimationScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    // Fetch current animation on load
    context.read<AnimationCubit>().fetchAnimation();
  }

  /// Pick JSON file from device
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      _showErrorSnackbar('حدث خطأ أثناء اختيار الملف');
    }
  }

  /// Upload selected animation
  Future<void> _uploadAnimation() async {
    if (_selectedFilePath != null) {
      await context.read<AnimationCubit>().uploadAnimation(_selectedFilePath!);
    }
  }

  /// Delete custom animation
  Future<void> _deleteAnimation() async {
    // Show confirmation dialog
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      context.read<AnimationCubit>().deleteAnimation();
    }
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف الصورة المتحركة؟\nسيتم استخدام الصورة الافتراضية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصورة المتحركة المخصصة'),
        centerTitle: true,
      ),
      body: BlocConsumer<AnimationCubit, AnimationState>(
        listener: (context, state) {
          if (state is AnimationUploadSuccess) {
            _showSuccessSnackbar(state.message);
            setState(() {
              _selectedFilePath = null;
              _selectedFileName = null;
            });
          } else if (state is AnimationDeleteSuccess) {
            _showSuccessSnackbar(state.message);
          } else if (state is AnimationError) {
            _showErrorSnackbar(state.message);
          }
        },
        builder: (context, state) {
          if (state is AnimationLoading && _selectedFilePath == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Animation Section
                if (state is AnimationLoaded && state.hasCustomAnimation)
                  _buildCurrentAnimationSection(state),

                // Instructions Card
                _buildInstructionsCard(),
                const SizedBox(height: 24),

                // Selected File Section
                if (_selectedFilePath != null) _buildSelectedFileCard(),
                if (_selectedFilePath != null) const SizedBox(height: 16),

                // Choose File Button
                CustomButton(
                  text: _selectedFilePath == null
                      ? 'اختيار ملف JSON'
                      : 'اختيار ملف آخر',
                  type: ButtonType.secondary,
                  onPressed: state is AnimationUploading ? null : _pickFile,
                  icon: Icons.folder_open,
                ),
                const SizedBox(height: 16),

                // Upload Button (only if file selected)
                if (_selectedFilePath != null)
                  CustomButton(
                    text: state is AnimationUploading
                        ? 'جاري الرفع...'
                        : 'رفع الصورة المتحركة',
                    type: ButtonType.primary,
                    onPressed: state is AnimationUploading
                        ? null
                        : _uploadAnimation,
                    icon: state is AnimationUploading
                        ? null
                        : Icons.cloud_upload,
                  ),

                // Delete Button (only if has custom animation)
                if (state is AnimationLoaded && state.hasCustomAnimation) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'حذف الصورة المتحركة',
                    type: ButtonType.danger,
                    onPressed: state is AnimationLoading
                        ? null
                        : _deleteAnimation,
                    icon: Icons.delete,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build current animation section
  Widget _buildCurrentAnimationSection(AnimationLoaded state) {
    return Column(
      children: [
        const Text(
          'الصورة المتحركة الحالية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.background,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomUserAnimation(
              customAnimationUrl: state.animationUrl,
              height: 180,
            ),
          ),
        ),
        if (state.uploadedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'تم الرفع: ${state.uploadedAt}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),
        const Text(
          'رفع صورة متحركة جديدة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build instructions card
  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'تعليمات:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem('يجب أن يكون الملف بصيغة JSON'),
          _buildInstructionItem('الحد الأقصى لحجم الملف: 2 ميجابايت'),
          _buildInstructionItem('يجب أن يكون الملف Lottie animation صالح'),
          _buildInstructionItem(
            'يمكنك تحميل صور متحركة مجانية من lottiefiles.com',
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              // Open lottiefiles.com
              // You can use url_launcher package
            },
            child: Text(
              'زيارة lottiefiles.com →',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build instruction item
  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Build selected file card
  Widget _buildSelectedFileCard() {
    // Get file size
    String fileSize = '';
    if (_selectedFilePath != null) {
      try {
        final file = File(_selectedFilePath!);
        final bytes = file.lengthSync();
        fileSize = ' (${(bytes / 1024).toStringAsFixed(1)} KB)';
      } catch (e) {
        fileSize = '';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الملف المحدد:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedFileName ?? '',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize.isNotEmpty)
                  Text(
                    fileSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedFilePath = null;
                _selectedFileName = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
