import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/success_animation.dart';
import '../../../leave/logic/cubit/leave_cubit.dart';
import '../../../leave/logic/cubit/leave_state.dart';
import '../../../leave/data/models/vacation_type_model.dart';

/// Leaves Apply Widget
///
/// Form to apply for leave with modern UI design
class LeavesApplyWidget extends StatefulWidget {
  const LeavesApplyWidget({super.key});

  @override
  State<LeavesApplyWidget> createState() => _LeavesApplyWidgetState();
}

class _LeavesApplyWidgetState extends State<LeavesApplyWidget> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  int? _selectedLeaveTypeId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Fetch vacation types when widget loads
    context.read<LeaveCubit>().fetchVacationTypes();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocConsumer<LeaveCubit, LeaveState>(
      listener: (context, state) {
        // Show success/error messages
        if (state is LeaveApplied) {
          // Show success animation dialog
          showSuccessDialog(
            context,
            title: 'Leave Request Submitted!',
            message: state.message,
            onComplete: () {
              // Clear form after dialog closes
              setState(() {
                _selectedLeaveTypeId = null;
                _startDate = null;
                _endDate = null;
                _reasonController.clear();
              });
              // Refresh leave history
              context.read<LeaveCubit>().fetchLeaveHistory();
            },
          );
        } else if (state is LeaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Get vacation types (both available and unavailable)
        final List<VacationTypeModel> vacationTypes = state is VacationTypesLoaded
            ? state.allTypes
            : [];

        final bool isLoading = state is VacationTypesLoading || state is ApplyingLeave;
        final bool hasError = state is LeaveError;

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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                        ? [
                            AppColors.darkCard,
                            AppColors.darkCardElevated,
                          ]
                        : [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Leaves Animation
                      SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: Lottie.asset(
                          'assets/svgs/leaves.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.event_available,
                              color: AppColors.white,
                              size: 60,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'طلب إجازة',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اختر نوع الإجازة وحدد التواريخ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Loading indicator
                if (state is VacationTypesLoading)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'جاري تحميل أنواع الإجازات...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error message for vacation types
                if (hasError && vacationTypes.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'إعادة المحاولة',
                          type: ButtonType.secondary,
                          onPressed: () => context.read<LeaveCubit>().fetchVacationTypes(),
                        ),
                      ],
                    ),
                  ),

                // Leave Type Section
                if (vacationTypes.isNotEmpty) ...[
                  Text(
                    'نوع الإجازة',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _LeaveTypeSelector(
                    selectedTypeId: _selectedLeaveTypeId,
                    vacationTypes: vacationTypes,
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                    onChanged: (typeId) {
                      setState(() {
                        _selectedLeaveTypeId = typeId;
                        // Reset dates when changing vacation type
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Show notice requirement if vacation type is selected
                  if (_selectedLeaveTypeId != null)
                    Builder(
                      builder: (context) {
                        final selectedType = vacationTypes.firstWhere(
                          (type) => type.id == _selectedLeaveTypeId,
                        );

                        if (selectedType.requiredDaysBefore > 0) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                              boxShadow: isDark ? [] : [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.schedule,
                                    color: AppColors.accent,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'إشعار مسبق مطلوب',
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'يجب تقديم الطلب قبل ${selectedType.requiredDaysBefore} يوم من تاريخ البدء',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                  // Date Range Section
                  Text(
                    'فترة الإجازة',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _DateSelector(
                          label: 'تاريخ البداية',
                          date: _startDate,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateSelector(
                          label: 'تاريخ النهاية',
                          date: _endDate,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duration Info
                  if (_startDate != null && _endDate != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.success.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مدة الإجازة',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                '${_calculateDuration()} يوم',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Reason Section
                  Text(
                    'سبب الإجازة',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _reasonController,
                    label: 'السبب',
                    hint: 'اكتب سبب طلب الإجازة...',
                    maxLines: 5,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: isLoading ? 'جاري الإرسال...' : 'إرسال طلب الإجازة',
                    onPressed: isLoading ? null : _handleSubmit,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: AppColors.white,
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ملاحظات هامة:',
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• تأكد من توفر رصيد كافٍ من الإجازات\n'
                                '• سيتم مراجعة الطلب من قبل المدير المباشر\n'
                                '• ستصلك إشعارات عند الموافقة أو الرفض',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: secondaryTextColor,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (state is! VacationTypesLoading && !hasError)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          color: AppColors.warning,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد أنواع إجازات متاحة',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يرجى التواصل مع قسم الموارد البشرية',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Select Date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // Get selected vacation type
    final state = context.read<LeaveCubit>().state;
    final vacationTypes = state is VacationTypesLoaded ? state.availableTypes : <VacationTypeModel>[];

    DateTime firstSelectableDate = DateTime.now();

    // If vacation type is selected, apply notice period
    if (_selectedLeaveTypeId != null && vacationTypes.isNotEmpty) {
      final selectedType = vacationTypes.firstWhere(
        (type) => type.id == _selectedLeaveTypeId,
        orElse: () => vacationTypes.first,
      );

      // Add required notice days to current date
      if (selectedType.requiredDaysBefore > 0) {
        firstSelectableDate = DateTime.now().add(Duration(days: selectedType.requiredDaysBefore));
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? firstSelectableDate)
          : (_endDate ?? (_startDate ?? firstSelectableDate)),
      firstDate: isStartDate ? firstSelectableDate : (_startDate ?? firstSelectableDate),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
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
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  /// Calculate Duration
  int _calculateDuration() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  /// Handle Submit
  void _handleSubmit() {
    if (_selectedLeaveTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار نوع الإجازة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ البداية والنهاية'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال سبب الإجازة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate notice period
    final state = context.read<LeaveCubit>().state;
    if (state is VacationTypesLoaded) {
      final selectedType = state.availableTypes.firstWhere(
        (type) => type.id == _selectedLeaveTypeId,
        orElse: () => state.availableTypes.first,
      );

      final daysDifference = _startDate!.difference(DateTime.now()).inDays;

      if (daysDifference < selectedType.requiredDaysBefore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا النوع من الإجازة يتطلب إشعاراً مسبقاً ${selectedType.requiredDaysBefore} يوم.\n'
              'يرجى اختيار تاريخ بدء بعد ${selectedType.requiredDaysBefore} يوم من الآن على الأقل.',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    // Submit leave request via BLoC
    context.read<LeaveCubit>().applyLeave(
      vacationTypeId: _selectedLeaveTypeId!,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      reason: _reasonController.text.trim(),
    );
  }
}

/// Leave Type Selector
class _LeaveTypeSelector extends StatelessWidget {
  final int? selectedTypeId;
  final List<VacationTypeModel> vacationTypes;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Function(int) onChanged;

  const _LeaveTypeSelector({
    required this.selectedTypeId,
    required this.vacationTypes,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.onChanged,
  });

  IconData _getIconForType(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('مرض') || lowerName.contains('sick')) {
      return Icons.local_hospital;
    }
    if (lowerName.contains('سنوي') || lowerName.contains('annual')) {
      return Icons.beach_access;
    }
    if (lowerName.contains('وضع') || lowerName.contains('maternity')) {
      return Icons.child_care;
    }
    if (lowerName.contains('زواج') || lowerName.contains('marriage')) {
      return Icons.favorite;
    }
    if (lowerName.contains('وفاة') || lowerName.contains('bereavement')) {
      return Icons.favorite_border;
    }
    if (lowerName.contains('حج') || lowerName.contains('hajj')) {
      return Icons.mosque;
    }
    if (lowerName.contains('عارض') || lowerName.contains('casual')) {
      return Icons.event;
    }
    if (lowerName.contains('بدون') || lowerName.contains('unpaid')) {
      return Icons.money_off;
    }
    if (lowerName.contains('امتحان') || lowerName.contains('exam')) {
      return Icons.school;
    }
    if (lowerName.contains('طفل') || lowerName.contains('child')) {
      return Icons.family_restroom;
    }
    return Icons.event_available;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.5),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: selectedTypeId,
          hint: Text(
            'اختر نوع الإجازة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          dropdownColor: cardColor,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
          ),
          items: vacationTypes.map((type) {
            return DropdownMenuItem<int>(
              value: type.id,
              enabled: type.isAvailable,
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(type.name),
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Type name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: type.isAvailable
                                ? textColor
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (type.description != null && type.description!.isNotEmpty)
                          Text(
                            type.description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Balance badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: type.isAvailable
                          ? AppColors.success.withOpacity(isDark ? 0.2 : 0.15)
                          : AppColors.error.withOpacity(isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type.isAvailable ? Icons.event_available : Icons.lock_outline,
                          color: type.isAvailable ? AppColors.success : AppColors.error,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type.isAvailable ? '${type.balance}' : '0',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: type.isAvailable ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (int? value) {
            if (value != null) {
              final type = vacationTypes.firstWhere((t) => t.id == value);
              if (type.isAvailable) {
                onChanged(value);
              }
            }
          },
        ),
      ),
    );
  }
}

/// Date Selector
class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppColors.primary.withOpacity(0.5)
                : borderColor.withOpacity(0.5),
            width: date != null ? 2 : 1,
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: date != null
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: date != null ? AppColors.primary : secondaryTextColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd/MM/yyyy').format(date!)
                        : 'اختر التاريخ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: date != null
                          ? textColor
                          : secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
