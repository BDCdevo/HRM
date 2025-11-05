import 'package:equatable/equatable.dart';

/// User Type Enum
enum UserType {
  employee,
  admin;

  static UserType fromString(String? type) {
    if (type == null) return UserType.employee;
    switch (type.toLowerCase()) {
      case 'admin':
        return UserType.admin;
      case 'employee':
      default:
        return UserType.employee;
    }
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

  /// Is Admin getter
  bool get isAdmin => userType == UserType.admin;

  /// Is Employee getter
  bool get isEmployee => userType == UserType.employee;

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
      userType: UserType.fromString(json['user_type'] as String?),
      roles: json['roles'] != null
          ? (json['roles'] as List).map((e) => e.toString()).toList()
          : null,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List).map((e) => e.toString()).toList()
          : null,
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
      'user_type': userType == UserType.admin ? 'admin' : 'employee',
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
