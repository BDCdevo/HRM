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
                  content: const Text('Leave request submitted successfully'),
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

      // Using Container with DropdownButton for better state control
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedVacationType != null ? AppColors.primary : AppColors.border,
            width: _selectedVacationType != null ? 2 : 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<VacationTypeModel>(
            value: _selectedVacationType,
            isExpanded: true,
            hint: Text('Select vacation type', style: AppTextStyles.bodyMedium),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: _selectedVacationType != null ? AppColors.primary : AppColors.textSecondary,
            ),
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
              if (value != null) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final minDate = _getMinimumStartDateForType(value);

                debugPrint('🟢🟢🟢 AUTO-DATE SELECTION 🟢🟢🟢');
                debugPrint('🟢 Device DateTime.now(): $now');
                debugPrint('🟢 Device today (date only): $today');
                debugPrint('🟢 Selected vacation type: ${value.name}');
                debugPrint('🟢 requiredDaysBefore from API: ${value.requiredDaysBefore}');
                debugPrint('🟢 Calculated minDate: $minDate');
                debugPrint('🟢 Expected: today + ${value.requiredDaysBefore} = ${today.add(Duration(days: value.requiredDaysBefore))}');
                debugPrint('🟢🟢🟢 END AUTO-DATE SELECTION 🟢🟢🟢');

                setState(() {
                  _selectedVacationType = value;
                  _startDate = minDate;
                  _endDate = null;
                });

                // Auto-open calendar after state is updated
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _selectStartDate();
                  }
                });
              }
            },
          ),
        ),
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
                    'Request must be submitted ${_selectedVacationType!.requiredDaysBefore} days in advance\n'
                    'Today: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}\n'
                    'Earliest start date: ${DateFormat('yyyy/MM/dd').format(minStartDate)}',
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
              border: Border.all(
                color: _startDate != null ? AppColors.primary : AppColors.border,
                width: _startDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _startDate != null
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: _startDate != null ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
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
                            ? DateFormat('yyyy/MM/dd - EEEE', 'en').format(_startDate!)
                            : 'Select vacation type first',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: _startDate != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _startDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      // Show hint that date was auto-selected
                      if (_startDate != null && hasNoticeRequirement)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Auto-selected (tap to change)',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.info,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_calendar,
                  size: 20,
                  color: _startDate != null ? AppColors.primary : AppColors.textSecondary,
                ),
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
              border: Border.all(
                color: _endDate != null ? AppColors.primary : AppColors.border,
                width: _endDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _endDate != null
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event,
                    color: _endDate != null ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
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
                            ? DateFormat('yyyy/MM/dd - EEEE', 'en').format(_endDate!)
                            : _startDate != null
                                ? 'Select end date'
                                : 'Select start date first',
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
                Icon(
                  Icons.edit_calendar,
                  size: 20,
                  color: _endDate != null ? AppColors.primary : AppColors.textSecondary,
                ),
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
  ///
  /// Backend validation logic (from Request.php):
  /// ```php
  /// $noticeDate = now()->addDays($this->requestable->required_days_before);
  /// if ($this->start_date && $this->start_date->lt($noticeDate)) {
  ///     $errors[] = "This vacation type requires X days advance notice.";
  /// }
  /// ```
  ///
  /// Example: Today = Nov 25, required_days_before = 7
  /// - noticeDate = Nov 25 + 7 = Dec 2
  /// - start_date must NOT be less than Dec 2
  /// - First valid start_date = Dec 2
  DateTime _getMinimumStartDateForType(VacationTypeModel type) {
    final requiredDays = type.requiredDaysBefore;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If no notice required, can start from tomorrow
    if (requiredDays <= 0) {
      return today.add(const Duration(days: 1));
    }

    // Backend validation logic (from Request.php):
    // $noticeDate = now()->addDays(required_days_before);
    // if (start_date < noticeDate) => REJECTED
    //
    // Example: Today = Nov 25, required = 14 days
    // noticeDate = Nov 25 + 14 = Dec 9
    // start_date must be >= Dec 9
    // First valid start_date = Dec 9
    final minDate = today.add(Duration(days: requiredDays));

    debugPrint('📅 =====================================');
    debugPrint('📅 Device now: $now');
    debugPrint('📅 Device today (date only): $today');
    debugPrint('📅 Required days notice: $requiredDays');
    debugPrint('📅 Min start date (today + $requiredDays): $minDate');
    debugPrint('📅 =====================================');

    return minDate;
  }

  /// Calculate minimum start date based on selected vacation type's required notice days
  DateTime _getMinimumStartDate() {
    if (_selectedVacationType == null) {
      return DateTime.now();
    }
    return _getMinimumStartDateForType(_selectedVacationType! );
  }

  Future<void> _selectStartDate() async {
    // Check if vacation type is selected first
    if (_selectedVacationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select vacation type first'),
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
    debugPrint('🗓️ ======= DATE PICKER DEBUG =======');
    debugPrint('🗓️ Today: ${DateTime.now()}');
    debugPrint('🗓️ Required Days Before: $requiredDays');
    debugPrint('🗓️ Min Start Date: $minStartDate');
    debugPrint('🗓️ Current _startDate: $_startDate');

    // Always use minStartDate as initial date (ignore old _startDate)
    // This ensures the calendar opens on the correct minimum date
    final DateTime initialDate = minStartDate;

    debugPrint('🗓️ Initial Date for picker: $initialDate');
    debugPrint('🗓️ ================================');

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minStartDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: requiredDays > 0
          ? 'Earliest date: ${DateFormat('yyyy/MM/dd').format(minStartDate)}'
          : 'Select start date',
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
          content: const Text('Please select vacation type'),
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
          content: const Text('Please select start and end date'),
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

    // Allow the 7th day itself (use < instead of <=)
    // minStartDate is already calculated as today + (requiredDays - 1)
    // So we reject only if startDate < minStartDate
    if (startDateOnly.isBefore(minStartDate)) {
      final requiredDays = _selectedVacationType!.requiredDaysBefore;
      final actualMinDate = today.add(Duration(days: requiredDays));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid start date!\n'
            'Request must be submitted $requiredDays ${requiredDays == 1 ? 'day' : 'days'} in advance\n'
            'Earliest available date: ${DateFormat('yyyy/MM/dd').format(minStartDate)}',
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
          content: const Text('Cannot select a date in the past'),
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
