import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../leave/logic/cubit/leave_cubit.dart';
import '../../../leave/logic/cubit/leave_state.dart';
import '../../../leave/data/models/vacation_type_model.dart';

/// Leaves Apply Widget
///
/// Form to apply for leave
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
    return BlocConsumer<LeaveCubit, LeaveState>(
      listener: (context, state) {
        // Show success/error messages
        if (state is LeaveApplied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${state.message}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );

          // Clear form
          setState(() {
            _selectedLeaveTypeId = null;
            _startDate = null;
            _endDate = null;
            _reasonController.clear();
          });

          // Refresh leave history
          context.read<LeaveCubit>().fetchLeaveHistory();
        } else if (state is LeaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        // Get vacation types
        final List<VacationTypeModel> vacationTypes = state is VacationTypesLoaded
            ? state.availableTypes
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
                // Loading indicator
                if (state is VacationTypesLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // Error message for vacation types
                if (hasError && vacationTypes.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Failed to load vacation types',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.message,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => context.read<LeaveCubit>().fetchVacationTypes(),
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),

                // Leave Type
                Text(
                  'Leave Type',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Show vacation types if loaded
                if (vacationTypes.isNotEmpty)
                  _LeaveTypeSelector(
                    selectedTypeId: _selectedLeaveTypeId,
                    vacationTypes: vacationTypes,
                    onChanged: (typeId) {
                      setState(() {
                        _selectedLeaveTypeId = typeId;
                      });
                    },
                  )
                else if (state is! VacationTypesLoading && !hasError)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No vacation types available. Please contact HR.',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 24),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: _DateSelector(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateSelector(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Duration Info
            if (_startDate != null && _endDate != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Duration: ${_calculateDuration()} day(s)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Reason
            CustomTextField(
              controller: _reasonController,
              label: 'Reason',
              hint: 'Enter reason for leave',
              maxLines: 5,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: isLoading ? 'Submitting...' : 'Submit Leave Request',
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
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Leave requests must be submitted at least 3 days in advance\n'
                    '• Emergency leaves require manager approval\n'
                    '• Check your leave balance before applying',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.warning,
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
          content: Text('Please select a leave type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason for leave'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
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
  final Function(int) onChanged;

  const _LeaveTypeSelector({
    required this.selectedTypeId,
    required this.vacationTypes,
    required this.onChanged,
  });

  IconData _getIconForType(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('sick')) return Icons.local_hospital;
    if (lowerName.contains('annual') || lowerName.contains('vacation')) return Icons.beach_access;
    if (lowerName.contains('emergency')) return Icons.emergency;
    if (lowerName.contains('casual')) return Icons.calendar_today;
    return Icons.event_available;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: vacationTypes.map((type) {
        final isSelected = selectedTypeId == type.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: type.isAvailable ? () => onChanged(type.id) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.warning
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.warning
                      : AppColors.border.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.warning.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForType(type.name),
                        color: isSelected ? AppColors.white : AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isSelected ? AppColors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (type.description != null && type.description!.isNotEmpty)
                              Text(
                                type.description!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? AppColors.white.withOpacity(0.9)
                                      : AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.white.withOpacity(0.2)
                              : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${type.balance} days',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? AppColors.white : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (type.requiredDaysBefore > 0 || !type.isAvailable) ...[
                    const SizedBox(height: 8),
                    Text(
                      type.isAvailable
                          ? type.noticeRequired
                          : type.availabilityInfo,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.white.withOpacity(0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : 'Select Date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
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
