import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../data/repo/general_request_repo.dart';
import '../../logic/cubit/general_request_cubit.dart';
import '../../logic/cubit/general_request_state.dart';

class GeneralRequestScreen extends StatelessWidget {
  const GeneralRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralRequestCubit(GeneralRequestRepo()),
      child: const _GeneralRequestScreenContent(),
    );
  }
}

class _GeneralRequestScreenContent extends StatefulWidget {
  const _GeneralRequestScreenContent();

  @override
  State<_GeneralRequestScreenContent> createState() =>
      _GeneralRequestScreenContentState();
}

class _GeneralRequestScreenContentState
    extends State<_GeneralRequestScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reasonController = TextEditingController();

  String _selectedCategory = 'hr';
  String _selectedPriority = 'medium';

  final List<Map<String, dynamic>> _categories = [
    {'value': 'hr', 'label': 'Human Resources', 'icon': Icons.people},
    {'value': 'it', 'label': 'IT Department', 'icon': Icons.computer},
    {'value': 'finance', 'label': 'Finance', 'icon': Icons.payments},
    {
      'value': 'admin',
      'label': 'Administration',
      'icon': Icons.admin_panel_settings,
    },
    {'value': 'facilities', 'label': 'Facilities', 'icon': Icons.build},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Low', 'color': AppColors.info},
    {'value': 'medium', 'label': 'Medium', 'color': AppColors.warning},
    {'value': 'high', 'label': 'High', 'color': Colors.orange},
    {'value': 'urgent', 'label': 'Urgent', 'color': AppColors.error},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      context.read<GeneralRequestCubit>().submitGeneralRequest(
        generalCategory: _selectedCategory,
        generalSubject: _subjectController.text,
        generalDescription: _descriptionController.text,
        generalPriority: _selectedPriority,
        reason: _reasonController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.background;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
        elevation: 0,
        title: Text(
          'General Request',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<GeneralRequestCubit, GeneralRequestState>(
        listener: (context, state) {
          if (state is GeneralRequestSubmitted) {
            // Show success animation
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                backgroundColor: AppColors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Lottie.asset(
                          'assets/svgs/success.json',
                          repeat: false,
                          // Performance optimizations
                          frameRate: FrameRate(30),
                          renderCache: RenderCache.raster,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 80,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Request Submitted Successfully',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your request will be reviewed and you will be notified soon',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'OK',
                        type: ButtonType.primary,
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Go back to requests
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is GeneralRequestError) {
            ErrorSnackBar.show(
              context: context,
              message: ErrorSnackBar.getArabicMessage(state.message),
              isNetworkError: ErrorSnackBar.isNetworkRelated(state.message),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is GeneralRequestSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [AppColors.darkCard, AppColors.darkCardElevated]
                            : [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.article,
                            color: AppColors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'General Request',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Submit a request to any department',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Section
                  Text(
                    'Department *',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['value'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.black.withValues(
                                            alpha: 0.1,
                                          )),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category['icon'],
                                color: isSelected
                                    ? AppColors.white
                                    : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.primary),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  category['label'],
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? AppColors.white
                                        : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Subject
                  Text(
                    'Subject *',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _subjectController,
                    hint: 'e.g., Request to update employee data',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the subject';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Detailed Description *',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _descriptionController,
                    hint: 'Explain your request in detail...',
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Priority
                  Text(
                    'Priority *',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _priorities.map((priority) {
                      final isSelected = _selectedPriority == priority['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority['value'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? priority['color'] : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? priority['color']
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.black.withValues(
                                            alpha: 0.1,
                                          )),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.white
                                      : priority['color'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                priority['label'],
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Additional Notes
                  Text(
                    'Additional Notes *',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _reasonController,
                    hint: 'Any additional information you want to add...',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please add notes';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: 'Submit Request',
                    type: ButtonType.primary,
                    onPressed: isSubmitting ? null : _submitRequest,
                    isLoading: isSubmitting,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
