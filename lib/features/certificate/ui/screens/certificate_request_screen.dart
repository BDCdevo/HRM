import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/success_animation.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../logic/cubit/certificate_cubit.dart';
import '../../logic/cubit/certificate_state.dart';
import '../../data/repo/certificate_repo.dart';

/// Certificate Request Screen
///
/// Screen for submitting certificate requests
class CertificateRequestScreen extends StatelessWidget {
  const CertificateRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CertificateCubit(CertificateRepo()),
      child: const _CertificateRequestView(),
    );
  }
}

class _CertificateRequestView extends StatefulWidget {
  const _CertificateRequestView();

  @override
  State<_CertificateRequestView> createState() => _CertificateRequestViewState();
}

class _CertificateRequestViewState extends State<_CertificateRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _selectedType;
  String _selectedLanguage = 'arabic';
  int _copies = 1;
  String? _selectedDeliveryMethod;
  DateTime? _neededDate;

  final List<Map<String, String>> _certificateTypes = [
    {'value': 'salary', 'label': 'شهادة راتب'},
    {'value': 'experience', 'label': 'شهادة خبرة'},
    {'value': 'employment', 'label': 'شهادة عمل'},
    {'value': 'to_whom_it_may_concern', 'label': 'إلى من يهمه الأمر'},
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'arabic', 'label': 'عربي'},
    {'value': 'english', 'label': 'إنجليزي'},
    {'value': 'both', 'label': 'عربي وإنجليزي'},
  ];

  final List<Map<String, String>> _deliveryMethods = [
    {'value': 'pickup', 'label': 'استلام من المكتب'},
    {'value': 'email', 'label': 'إرسال عبر البريد الإلكتروني'},
    {'value': 'mail', 'label': 'إرسال بالبريد'},
  ];

  @override
  void dispose() {
    _purposeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء اختيار نوع الشهادة'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<CertificateCubit>().submitCertificateRequest(
            certificateType: _selectedType!,
            certificatePurpose: _purposeController.text.trim(),
            certificateLanguage: _selectedLanguage,
            certificateCopies: _copies,
            certificateDeliveryMethod: _selectedDeliveryMethod,
            certificateNeededDate: _neededDate != null
                ? DateFormat('yyyy-MM-dd').format(_neededDate!)
                : null,
            reason: _reasonController.text.trim(),
          );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _neededDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null && picked != _neededDate) {
      setState(() {
        _neededDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
        elevation: 0,
        title: Text(
          'طلب شهادة',
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
      body: BlocConsumer<CertificateCubit, CertificateState>(
        listener: (context, state) {
          if (state is CertificateRequestSubmitted) {
            showSuccessDialog(
              context,
              title: 'تم تقديم الطلب!',
              message: state.message,
              onComplete: () {
                Navigator.of(context).pop();
              },
            );
          } else if (state is CertificateError) {
            ErrorSnackBar.show(
              context: context,
              message: ErrorSnackBar.getArabicMessage(state.message),
              isNetworkError: ErrorSnackBar.isNetworkRelated(state.message),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SubmittingCertificateRequest;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(isDark),
                  const SizedBox(height: 24),

                  // Certificate Type
                  _buildSectionTitle('نوع الشهادة', textColor),
                  const SizedBox(height: 12),
                  _buildCertificateTypeSelector(cardColor, textColor, isDark),
                  const SizedBox(height: 24),

                  // Purpose
                  _buildSectionTitle('الغرض من الشهادة', textColor),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _purposeController,
                    label: 'الغرض',
                    hint: 'مثال: للتقديم على قرض، للسفر، إلخ',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال الغرض';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Language
                  _buildSectionTitle('اللغة', textColor),
                  const SizedBox(height: 12),
                  _buildLanguageSelector(cardColor, textColor, isDark),
                  const SizedBox(height: 24),

                  // Copies
                  _buildSectionTitle('عدد النسخ', textColor),
                  const SizedBox(height: 12),
                  _buildCopiesSelector(cardColor, textColor, isDark),
                  const SizedBox(height: 24),

                  // Delivery Method
                  _buildSectionTitle('طريقة الاستلام', textColor),
                  const SizedBox(height: 12),
                  _buildDeliveryMethodSelector(cardColor, textColor, isDark),
                  const SizedBox(height: 24),

                  // Needed Date
                  _buildSectionTitle('التاريخ المطلوب (اختياري)', textColor),
                  const SizedBox(height: 12),
                  _buildDatePicker(cardColor, textColor, isDark),
                  const SizedBox(height: 24),

                  // Additional Notes
                  _buildSectionTitle('ملاحظات إضافية', textColor),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _reasonController,
                    label: 'ملاحظات',
                    hint: 'أي تفاصيل إضافية...',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إضافة ملاحظات';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: isLoading ? 'جاري التقديم...' : 'تقديم الطلب',
                    onPressed: isLoading ? null : _submitRequest,
                    type: ButtonType.primary,
                    isLoading: isLoading,
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

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkCardElevated]
              : [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
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
              Icons.description,
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
                  'طلب شهادة',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'املأ النموذج لتقديم طلب شهادة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCertificateTypeSelector(Color cardColor, Color textColor, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _certificateTypes.map((type) {
        final isSelected = _selectedType == type['value'];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedType = type['value'];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                  : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                    : (isDark ? AppColors.darkBorder : AppColors.black.withValues(alpha: 0.1)),
                width: 1.5,
              ),
            ),
            child: Text(
              type['label']!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelector(Color cardColor, Color textColor, bool isDark) {
    return Row(
      children: _languages.map((lang) {
        final isSelected = _selectedLanguage == lang['value'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedLanguage = lang['value']!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                      : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                        : (isDark ? AppColors.darkBorder : AppColors.black.withValues(alpha: 0.1)),
                  ),
                ),
                child: Text(
                  lang['label']!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCopiesSelector(Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'عدد النسخ المطلوبة',
            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_copies > 1) {
                    setState(() {
                      _copies--;
                    });
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_copies',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_copies < 10) {
                    setState(() {
                      _copies++;
                    });
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSelector(Color cardColor, Color textColor, bool isDark) {
    return Column(
      children: _deliveryMethods.map((method) {
        final isSelected = _selectedDeliveryMethod == method['value'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedDeliveryMethod = method['value'];
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1))
                    : cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                      : (isDark ? AppColors.darkBorder : AppColors.black.withValues(alpha: 0.1)),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected
                        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method['label']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(Color cardColor, Color textColor, bool isDark) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _neededDate != null
                    ? DateFormat('yyyy-MM-dd').format(_neededDate!)
                    : 'اختر التاريخ المطلوب',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _neededDate != null ? textColor : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
