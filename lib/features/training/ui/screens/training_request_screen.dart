import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/repo/training_repo.dart';
import '../../logic/cubit/training_cubit.dart';
import '../../logic/cubit/training_state.dart';

class TrainingRequestScreen extends StatelessWidget {
  const TrainingRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainingCubit(TrainingRepo()),
      child: const _TrainingRequestScreenContent(),
    );
  }
}

class _TrainingRequestScreenContent extends StatefulWidget {
  const _TrainingRequestScreenContent();

  @override
  State<_TrainingRequestScreenContent> createState() =>
      _TrainingRequestScreenContentState();
}

class _TrainingRequestScreenContentState
    extends State<_TrainingRequestScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _trainingNameController = TextEditingController();
  final _providerController = TextEditingController();
  final _locationController = TextEditingController();
  final _costController = TextEditingController();
  final _justificationController = TextEditingController();
  final _benefitController = TextEditingController();
  final _reasonController = TextEditingController();

  String _selectedType = 'technical';
  String _selectedCostCoverage = 'full';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, String>> _trainingTypes = [
    {'value': 'technical', 'label': 'تدريب تقني'},
    {'value': 'soft_skills', 'label': 'مهارات شخصية'},
    {'value': 'management', 'label': 'إدارة وقيادة'},
    {'value': 'language', 'label': 'لغات'},
    {'value': 'certification', 'label': 'شهادة مهنية'},
    {'value': 'other', 'label': 'أخرى'},
  ];

  final List<Map<String, String>> _costCoverageOptions = [
    {'value': 'full', 'label': 'تغطية كاملة'},
    {'value': 'partial', 'label': 'تغطية جزئية'},
    {'value': 'none', 'label': 'بدون تغطية'},
  ];

  @override
  void dispose() {
    _trainingNameController.dispose();
    _providerController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _justificationController.dispose();
    _benefitController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      context.read<TrainingCubit>().submitTrainingRequest(
        trainingType: _selectedType,
        trainingName: _trainingNameController.text,
        trainingProvider: _providerController.text.isNotEmpty
            ? _providerController.text
            : null,
        trainingLocation: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        trainingStartDate: _startDate != null
            ? DateFormat('yyyy-MM-dd').format(_startDate!)
            : null,
        trainingEndDate: _endDate != null
            ? DateFormat('yyyy-MM-dd').format(_endDate!)
            : null,
        trainingCost: _costController.text.isNotEmpty
            ? double.tryParse(_costController.text)
            : null,
        trainingCostCoverage: _selectedCostCoverage,
        trainingJustification: _justificationController.text.isNotEmpty
            ? _justificationController.text
            : null,
        trainingExpectedBenefit: _benefitController.text.isNotEmpty
            ? _benefitController.text
            : null,
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
          'طلب تدريب',
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
      body: BlocConsumer<TrainingCubit, TrainingState>(
        listener: (context, state) {
          if (state is TrainingSubmitted) {
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
                        'تم إرسال الطلب بنجاح',
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
                        'سيتم مراجعة طلبك والرد عليك قريباً',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'حسناً',
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
          } else if (state is TrainingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is TrainingSubmitting;

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
                            : [
                                AppColors.warning,
                                AppColors.warning.withValues(alpha: 0.8),
                              ],
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
                            Icons.school,
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
                                'طلب تدريب',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'املأ النموذج أدناه لتقديم طلب الحصول على دورة تدريبية',
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

                  // Training Type Section
                  Text(
                    'نوع التدريب *',
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
                    children: _trainingTypes.map((type) {
                      final isSelected = _selectedType == type['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = type['value']!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.warning : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.warning
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.black.withValues(
                                            alpha: 0.1,
                                          )),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            type['label']!,
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
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Training Name
                  Text(
                    'اسم الدورة التدريبية *',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _trainingNameController,
                    hint: 'مثال: دورة إدارة المشاريع الاحترافية',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم الدورة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Provider
                  Text(
                    'مقدم التدريب',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _providerController,
                    hint: 'مثال: معهد التطوير المهني',
                  ),
                  const SizedBox(height: 20),

                  // Location
                  Text(
                    'موقع التدريب',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _locationController,
                    hint: 'مثال: الرياض - أونلاين',
                  ),
                  const SizedBox(height: 20),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تاريخ البدء',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _startDate == null
                                          ? 'اختر التاريخ'
                                          : DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(_startDate!),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تاريخ الانتهاء',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _endDate == null
                                          ? 'اختر التاريخ'
                                          : DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(_endDate!),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cost
                  Text(
                    'تكلفة التدريب',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _costController,
                    hint: 'مثال: 5000',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Cost Coverage
                  Text(
                    'تغطية التكلفة',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._costCoverageOptions.map((option) {
                    final isSelected = _selectedCostCoverage == option['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCostCoverage = option['value']!;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.warning
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.black.withValues(alpha: 0.1)),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option['label']!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
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
                  const SizedBox(height: 8),

                  // Justification
                  Text(
                    'مبررات الحصول على التدريب',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _justificationController,
                    hint: 'اشرح لماذا تحتاج هذا التدريب...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Expected Benefit
                  Text(
                    'الفائدة المتوقعة',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _benefitController,
                    hint: 'كيف سيفيدك هذا التدريب في عملك؟',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Additional Notes
                  Text(
                    'ملاحظات إضافية *',
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
                    hint: 'أي ملاحظات أخرى تود إضافتها...',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إضافة ملاحظات';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: 'إرسال الطلب',
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
