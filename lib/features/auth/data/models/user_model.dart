import 'package:equatable/equatable.dart';

/// User Type Enum (Simplified - All users are employees)
enum UserType {
  employee;

  static UserType fromString(String? type) {
    return UserType.employee; // Always employee
  }
}

/// User Model
///
/// Represents a user in the HRM system
/// Supports both Employee and Admin users
/// Matches the API response from Laravel backend
class UserModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? accessToken;
  final MediaModel? image;
  final UserType userType;
  final List<String>? roles;
  final List<String>? permissions;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.accessToken,
    this.image,
    this.userType = UserType.employee,
    this.roles,
    this.permissions,
  });

  /// Full name getter
  String get fullName {
    // For admin users, name might be in a single 'name' field
    if (firstName.isEmpty && lastName.isEmpty) {
      return email.split('@').first;
    }
    return '$firstName $lastName'.trim();
  }

  /// Has token getter
  bool get hasToken => accessToken != null && accessToken!.isNotEmpty;

  // ============================================
  // ROLES & PERMISSIONS (FOR FUTURE USE)
  // Currently not implemented - all employees have full access
  // TODO: Implement role-based access control in future versions
  // ============================================

  /// Is Admin getter (based on roles instead of user type)
  /// NOTE: Not currently used in UI - for future implementation
  bool get isAdmin => hasRole('admin') || hasRole('super admin');

  /// Is Employee getter (everyone is employee)
  bool get isEmployee => true;

  /// Check if user has specific role
  /// NOTE: Not currently used in UI - for future implementation
  bool hasRole(String role) {
    return roles?.contains(role.toLowerCase()) ?? false;
  }

  /// Check if user has specific permission
  /// NOTE: Not currently used in UI - for future implementation
  bool hasPermission(String permission) {
    return permissions?.contains(permission.toLowerCase()) ?? false;
  }

  /// Check if user is HR
  /// NOTE: Not currently used in UI - for future implementation
  bool get isHR => hasRole('hr') || hasRole('human resources');

  /// Check if user is Manager
  /// NOTE: Not currently used in UI - for future implementation
  bool get isManager => hasRole('manager') || hasRole('supervisor');

  /// Check if user can manage employees (Admin, HR, Manager)
  /// NOTE: Not currently used in UI - for future implementation
  bool get canManageEmployees => isAdmin || isHR || isManager;

  /// Check if user can approve leaves (Admin, HR, Manager)
  /// NOTE: Not currently used in UI - for future implementation
  bool get canApproveLeaves => isAdmin || isHR || isManager;

  /// Check if user can view all attendance (Admin, HR)
  /// NOTE: Not currently used in UI - for future implementation
  bool get canViewAllAttendance => isAdmin || isHR;

  /// Check if user can view reports (Admin, HR, Manager)
  /// NOTE: Not currently used in UI - for future implementation
  bool get canViewReports => isAdmin || isHR || isManager;

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both employee and admin API responses
    final name = json['name'] as String?;
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;

    // If name is provided but first/last aren't, split the name
    String finalFirstName = firstName ?? '';
    String finalLastName = lastName ?? '';

    if (name != null && firstName == null && lastName == null) {
      final nameParts = name.split(' ');
      if (nameParts.isNotEmpty) {
        finalFirstName = nameParts.first;
        if (nameParts.length > 1) {
          finalLastName = nameParts.sublist(1).join(' ');
        }
      }
    }

    return UserModel(
      id: json['id'] as int,
      firstName: finalFirstName,
      lastName: finalLastName,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      accessToken: json['access_token'] as String?,
      image: json['image'] != null && json['image'] is Map
          ? MediaModel.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      userType: UserType.employee, // All users are employees
      roles: json['roles'] != null && json['roles'] is List
          ? (json['roles'] as List)
              .where((e) => e != null)
              .map((e) => e.toString().toLowerCase())
              .toList()
          : [], // Default to empty list instead of null
      permissions: json['permissions'] != null && json['permissions'] is List
          ? (json['permissions'] as List)
              .where((e) => e != null)
              .map((e) => e.toString().toLowerCase())
              .toList()
          : [], // Default to empty list instead of null
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'access_token': accessToken,
      'image': image?.toJson(),
      'user_type': 'employee', // All users are employees now
      'roles': roles,
      'permissions': permissions,
    };
  }

  /// Copy With
  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? accessToken,
    MediaModel? image,
    UserType? userType,
    List<String>? roles,
    List<String>? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      accessToken: accessToken ?? this.accessToken,
      image: image ?? this.image,
      userType: userType ?? this.userType,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        accessToken,
        image,
        userType,
        roles,
        permissions,
      ];
}

/// Media Model for User Image
class MediaModel extends Equatable {
  final int id;
  final String url;
  final String fileName;

  const MediaModel({
    required this.id,
    required this.url,
    required this.fileName,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      fileName: json['file_name'] as String? ?? json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'file_name': fileName,
    };
  }

  @override
  List<Object?> get props => [id, url, fileName];
}
