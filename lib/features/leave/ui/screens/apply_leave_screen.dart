import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
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
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context, true); // Return true to indicate success
            } else if (state is LeaveError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.displayMessage),
                  backgroundColor: AppColors.error,
                ),
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
    return Column(
      children: [
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

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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
        const SnackBar(
          content: Text('Please select a vacation type'),
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

    _leaveCubit.applyLeave(
      vacationTypeId: _selectedVacationType!.id,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      reason: _reasonController.text.trim(),
    );
  }
}
