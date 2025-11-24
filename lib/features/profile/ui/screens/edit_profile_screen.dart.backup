import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/update_profile_request_model.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';

/// Edit Profile Screen
///
/// Allows users to edit their profile information:
/// - First name
/// - Last name
/// - Bio
/// - Birthdate
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileCubit _profileCubit;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit();
    // Fetch profile to populate fields
    _profileCubit.fetchProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _birthdateController.dispose();
    _profileCubit.close();
    super.dispose();
  }

  void _populateFields(ProfileLoaded state) {
    final profile = state.profile;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _bioController.text = profile.bio ?? '';
    _birthdateController.text = profile.birthdate ?? '';
    if (profile.birthdate != null && profile.birthdate!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(profile.birthdate!.split('-').reversed.join('-'));
      } catch (e) {
        // Invalid date format
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format date as dd-mm-yyyy for display
        _birthdateController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      // Format birthdate for API (yyyy-mm-dd)
      String? formattedBirthdate;
      if (_selectedDate != null) {
        formattedBirthdate =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      }

      final request = UpdateProfileRequestModel(
        firstName: _firstNameController.text.trim().isNotEmpty
            ? _firstNameController.text.trim()
            : null,
        lastName: _lastNameController.text.trim().isNotEmpty
            ? _lastNameController.text.trim()
            : null,
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        birthdate: formattedBirthdate,
      );

      _profileCubit.updateProfile(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _profileCubit,
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
            } else if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              // Go back to profile screen
              Navigator.pop(context);
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.displayMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            // Show loading state on initial fetch
            if (state is ProfileLoading && state is! ProfileLoaded) {
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
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // First Name Field
                    CustomTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Enter your first name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your first name';
                        }
                        if (value.trim().length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        if (value.trim().length > 50) {
                          return 'First name cannot exceed 50 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Last Name Field
                    CustomTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your last name';
                        }
                        if (value.trim().length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        if (value.trim().length > 50) {
                          return 'Last name cannot exceed 50 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bio Field
                    CustomTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell us about yourself',
                      prefixIcon: const Icon(Icons.info_outline),
                      maxLines: 3,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (value.trim().length < 2) {
                            return 'Bio must be at least 2 characters';
                          }
                          if (value.trim().length > 255) {
                            return 'Bio cannot exceed 255 characters';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Birthdate Field
                    CustomTextField(
                      controller: _birthdateController,
                      label: 'Birthdate',
                      hint: 'Select your birthdate',
                      prefixIcon: const Icon(Icons.cake_outlined),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),

                    const SizedBox(height: 32),

                    // Update Button
                    CustomButton(
                      text: 'Update Profile',
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
