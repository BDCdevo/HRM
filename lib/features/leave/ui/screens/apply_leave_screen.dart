import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../logic/cubit/leave_cubit.dart';
import '../../logic/cubit/leave_state.dart';
import '../../data/models/vacation_type_model.dart';

/// Apply Leave Screen
///
/// Allows employees to submit leave requests
class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  late final LeaveCubit _leaveCubit;
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  VacationTypeModel? _selectedVacationType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _leaveCubit = LeaveCubit();
    _leaveCubit.fetchVacationTypes();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _leaveCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _leaveCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.white,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Apply for Leave',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        body: BlocConsumer<LeaveCubit, LeaveState>(
          listener: (context, state) {
            if (state is LeaveApplied) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم تقديم طلب الإجازة بنجاح'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              Navigator.pop(context, true); // Return true to indicate success
            } else if (state is LeaveError) {
              ErrorSnackBar.show(
                context: context,
                message: ErrorSnackBar.getArabicMessage(state.displayMessage),
                isNetworkError: ErrorSnackBar.isNetworkRelated(state.displayMessage),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vacation Type Selection
                    _buildSectionTitle('Vacation Type'),
                    const SizedBox(height: 12),
                    _buildVacationTypeSelector(state),

                    const SizedBox(height: 24),

                    // Date Range Selection
                    _buildSectionTitle('Leave Period'),
                    const SizedBox(height: 12),
                    _buildDateSelector(),

                    const SizedBox(height: 24),

                    // Duration Display
                    if (_startDate != null && _endDate != null)
                      _buildDurationDisplay(),

                    const SizedBox(height: 24),

                    // Reason Input
                    _buildSectionTitle('Reason'),
                    const SizedBox(height: 12),
                    _buildReasonInput(),

                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVacationTypeSelector(LeaveState state) {
    if (state is VacationTypesLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state is VacationTypesLoaded) {
      final availableTypes = state.availableTypes;

      if (availableTypes.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'No vacation types available at this time',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return DropdownButtonFormField<VacationTypeModel>(
        initialValue: _selectedVacationType,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        hint: Text('Select vacation type', style: AppTextStyles.bodyMedium),
        items: availableTypes.map((vacationType) {
          return DropdownMenuItem<VacationTypeModel>(
            value: vacationType,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vacationType.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (vacationType.description != null)
                  Text(
                    vacationType.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedVacationType = value;
            // Auto-set start date to minimum allowed date
            if (value != null) {
              debugPrint('🔵 Selected: ${value.name}');
              debugPrint('🔵 requiredDaysBefore from model: ${value.requiredDaysBefore}');
              final minDate = _getMinimumStartDateForType(value);
              debugPrint('🔵 Calculated minDate: $minDate');
              _startDate = minDate;
              _endDate = null; // Reset end date
            }
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a vacation type';
          }
          return null;
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDateSelector() {
    // Show notice period info if vacation type is selected
    final hasNoticeRequirement = _selectedVacationType != null &&
        _selectedVacationType!.requiredDaysBefore > 0;
    final minStartDate = _selectedVacationType != null
        ? _getMinimumStartDate()
        : DateTime.now();

    return Column(
      children: [
        // Notice period info banner - shows minimum allowed start date
        if (_selectedVacationType != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'إشعار مسبق: ${_selectedVacationType!.requiredDaysBefore} أيام\n'
                    'اليوم: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}\n'
                    'أقرب تاريخ: ${DateFormat('yyyy/MM/dd').format(minStartDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Start Date
        InkWell(
          onTap: () => _selectStartDate(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _startDate != null
                            ? DateFormat('MMM dd, yyyy').format(_startDate!)
                            : hasNoticeRequirement
                                ? 'أقرب تاريخ: ${DateFormat('MMM dd').format(minStartDate)}'
                                : 'Select start date',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: _startDate != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _startDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // End Date
        InkWell(
          onTap: () => _selectEndDate(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _endDate != null
                            ? DateFormat('MMM dd, yyyy').format(_endDate!)
                            : 'Select end date',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: _endDate != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _endDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDisplay() {
    if (_startDate == null || _endDate == null) return const SizedBox.shrink();

    final days = _endDate!.difference(_startDate!).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            'Total Duration: $days ${days == 1 ? 'day' : 'days'}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonInput() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Enter reason for leave request...',
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a reason for your leave request';
        }
        if (value.trim().length < 10) {
          return 'Reason must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(LeaveState state) {
    final isLoading = state is ApplyingLeave;

    return CustomButton(
      text: isLoading ? 'Submitting...' : 'Submit Leave Request',
      onPressed: isLoading ? null : _submitLeaveRequest,
      isLoading: isLoading,
    );
  }

  /// Calculate minimum start date for a specific vacation type
  DateTime _getMinimumStartDateForType(VacationTypeModel type) {
    final requiredDays = type.requiredDaysBefore;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If no notice required, can start from today
    if (requiredDays <= 0) {
      return today;
    }

    // requiredDaysBefore = 7 means you need 7 days notice
    // Today = Nov 25, then first valid date = Nov 25 + 7 = Dec 2
    final minDate = today.add(Duration(days: requiredDays));

    debugPrint('📅 =====================================');
    debugPrint('📅 Now: $now');
    debugPrint('📅 Today (midnight): $today');
    debugPrint('📅 Required days from API: $requiredDays');
    debugPrint('📅 Calculated min date: $minDate');
    debugPrint('📅 =====================================');

    return minDate;
  }

  /// Calculate minimum start date based on selected vacation type's required notice days
  DateTime _getMinimumStartDate() {
    if (_selectedVacationType == null) {
      return DateTime.now();
    }
    return _getMinimumStartDateForType(_selectedVacationType!);
  }

  Future<void> _selectStartDate() async {
    // Check if vacation type is selected first
    if (_selectedVacationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء اختيار نوع الإجازة أولاً'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final minStartDate = _getMinimumStartDate();
    final requiredDays = _selectedVacationType!.requiredDaysBefore;

    // Debug: Print calculated dates
    debugPrint('🗓️ Today: ${DateTime.now()}');
    debugPrint('🗓️ Required Days Before: $requiredDays');
    debugPrint('🗓️ Min Start Date: $minStartDate');

    // Always start with minStartDate as the initial selected date
    // If user already selected a date, use it only if it's still valid
    DateTime initialDate = minStartDate;
    if (_startDate != null && !_startDate!.isBefore(minStartDate)) {
      initialDate = _startDate!;
    }

    debugPrint('🗓️ Initial Date for picker: $initialDate');
    debugPrint('🗓️ First Date (disabled before): $minStartDate');

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minStartDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: requiredDays > 0
          ? 'أقرب تاريخ: ${DateFormat('yyyy/MM/dd').format(minStartDate)}'
          : 'اختر تاريخ البداية',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _startDate = selected;
        // Reset end date if it's before the new start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _endDate = selected;
      });
    }
  }

  void _submitLeaveRequest() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVacationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء اختيار نوع الإجازة'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء اختيار تاريخ البداية والنهاية'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Final validation: Check if start date respects notice period
    final minStartDate = _getMinimumStartDate();
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final startDateOnly = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);

    if (startDateOnly.isBefore(minStartDate)) {
      final requiredDays = _selectedVacationType!.requiredDaysBefore;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تاريخ البداية غير صالح!\n'
            'هذا النوع من الإجازات يتطلب إشعار مسبق $requiredDays ${requiredDays == 1 ? 'يوم' : 'أيام'}\n'
            'أقرب تاريخ متاح: ${DateFormat('yyyy/MM/dd').format(minStartDate)}',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    // Additional validation: Check if start date is not in the past
    if (startDateOnly.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لا يمكن اختيار تاريخ في الماضي'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    _leaveCubit.applyLeave(
      vacationTypeId: _selectedVacationType!.id,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      reason: _reasonController.text.trim(),
    );
  }
}
