import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../data/models/update_profile_request_model.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';

/// Edit Profile Screen
///
/// Allows users to edit their essential profile information:
/// - Profile Image
/// - Name (First & Last)
/// - Email
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileCubit _profileCubit;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  bool _isLoading = false;
  String? _profileImageUrl;
  String? _gender;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit();
    // Fetch profile to populate fields
    _profileCubit.fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
    _profileCubit.close();
    super.dispose();
  }

  void _populateFields(ProfileLoaded state) {
    final profile = state.profile;
    _nameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _addressController.text = profile.address ?? '';
    _nationalIdController.text = profile.nationalId ?? '';

    // Update profile image URL and other fields
    if (mounted) {
      setState(() {
        _profileImageUrl = profile.hasImage ? profile.image!.url : null;
        _gender = profile.gender;
        _dateOfBirth = profile.dateOfBirth != null
            ? DateTime.tryParse(profile.dateOfBirth!)
            : null;
      });
    }
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      final request = UpdateProfileRequestModel(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        nationalId: _nationalIdController.text.trim().isNotEmpty ? _nationalIdController.text.trim() : null,
        gender: _gender,
        dateOfBirth: _dateOfBirth != null
            ? '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}'
            : null,
      );

      _profileCubit.updateProfile(request);
    }
  }

  /// Show Image Source Dialog (Camera or Gallery)
  void _showImageSourceDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Upload Profile Picture',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              // Camera Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkAccent : AppColors.accent).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: isDark ? AppColors.darkAccent : AppColors.accent,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              // Gallery Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Pick Image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Upload the image
        _profileCubit.uploadProfileImage(File(image.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => _profileCubit,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.white,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Profile',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoading) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is ProfileLoaded) {
              // Populate fields when profile is loaded
              _populateFields(state);
            } else if (state is ProfileImageUploaded) {
              // Show success message for image upload
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              // Update image URL
              setState(() {
                _profileImageUrl = state.profile.hasImage ? state.profile.image!.url : null;
              });
            } else if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile updated successfully'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              // Go back to previous screen
              Navigator.pop(context);
            } else if (state is ProfileError) {
              ErrorSnackBar.show(
                context: context,
                message: ErrorSnackBar.getArabicMessage(state.displayMessage),
                isNetworkError: ErrorSnackBar.isNetworkRelated(state.displayMessage),
              );
            }
          },
          builder: (context, state) {
            // Show loading state on initial fetch
            if (state is ProfileLoading && _profileImageUrl == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.black54 : Colors.black).withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _profileImageUrl != null
                                  ? Image.network(
                                      // Add timestamp to bypass cache
                                      '$_profileImageUrl?v=${DateTime.now().millisecondsSinceEpoch}',
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                                          child: Icon(
                                            Icons.person,
                                            size: 60,
                                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showImageSourceDialog(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkCard : AppColors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? Colors.black54 : Colors.black).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 22,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Personal Information Section
                    Text(
                      'Personal Information',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Full Name Field
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        if (value.trim().length > 100) {
                          return 'Name cannot exceed 100 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Field (Read-only)
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Your email address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      readOnly: true,
                      enabled: false,
                    ),

                    const SizedBox(height: 8),

                    // Email Note
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Email cannot be changed from here',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Contact Information Section
                    Text(
                      'Contact Information',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phone Field
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 10) {
                            return 'Phone must be at least 10 digits';
                          }
                          if (value.length > 15) {
                            return 'Phone cannot exceed 15 digits';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Address Field
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter your address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      maxLines: 2,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length > 200) {
                          return 'Address cannot exceed 200 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Personal Details Section
                    Text(
                      'Personal Details',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // National ID Field
                    CustomTextField(
                      controller: _nationalIdController,
                      label: 'National ID',
                      hint: 'Enter your national ID',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length > 50) {
                          return 'National ID cannot exceed 50 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        hintText: 'Select your gender',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkCard.withOpacity(0.5)
                            : AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.border,
                          ),
                        ),
                      ),
                      items: ['male', 'female']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender == 'male' ? 'Male' : 'Female',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Date of Birth Field
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth ?? DateTime(1990),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateOfBirth = pickedDate;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: TextEditingController(
                            text: _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : '',
                          ),
                          label: 'Date of Birth',
                          hint: 'Select your date of birth',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          readOnly: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Update Button
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _isLoading ? null : _handleUpdateProfile,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
