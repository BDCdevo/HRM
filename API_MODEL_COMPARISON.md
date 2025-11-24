# API Response vs Flutter Model Comparison

## Date: 23 November 2025

## Overview
This document provides a detailed comparison between Backend API responses and Flutter models to ensure proper data mapping and integration.

---

## 1. LOGIN API RESPONSE vs UserModel

### API Endpoint
**POST** `/api/v1/auth/login`

### Backend Response Structure
**File**: `/var/www/erp1/app/Http/Controllers/Api/V1/User/Auth/AuthenticationController.php`

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": 55,
    "first_name": "Ahmedabdelhamid",
    "name": "Ahmedabdelhamid Abdelhamid",
    "last_name": "Abdelhamid",
    "email": "Ahmedabdelhamid@bdcbiz.com",
    "phone": "0222720333",
    "employee_id": "EMP0029",
    "department_id": 17,
    "position_id": 21,
    "department_name": "التطوير",
    "position_name": "Employee",
    "image": {
      "id": 55,
      "url": "https://erp1.bdcbiz.com/storage/...",
      "file_name": "avatar.png"
    },
    "status": 1,
    "access_token": "265|...",
    "roles": [],
    "permissions": []
  }
}
```

### Flutter Model Structure
**File**: `lib/features/auth/data/models/user_model.dart`

```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? accessToken;
  final MediaModel? image;
  final UserType userType;
  final List<String>? roles;
  final List<String>? permissions;
  final int? companyId;
}

class MediaModel {
  final int id;
  final String url;
  final String fileName;
}
```

### Field Mapping Comparison

| API Field | UserModel Field | Status | Notes |
|-----------|----------------|--------|-------|
| `id` | `id` | ✅ MAPPED | Direct mapping (int → int) |
| `name` | `name` | ✅ MAPPED | **FIXED**: Now included in API response |
| `first_name` | - | ⚠️ EXTRA | API provides but model doesn't use directly |
| `last_name` | - | ⚠️ EXTRA | API provides but model doesn't use directly |
| `email` | `email` | ✅ MAPPED | Direct mapping (String → String) |
| `phone` | `phone` | ✅ MAPPED | Direct mapping (String? → String?) |
| `access_token` | `accessToken` | ✅ MAPPED | Converted from snake_case to camelCase |
| `image` | `image` | ✅ MAPPED | Nested object (MediaModel) |
| `image.id` | `image.id` | ✅ MAPPED | MediaModel field |
| `image.url` | `image.url` | ✅ MAPPED | MediaModel field |
| `image.file_name` | `image.fileName` | ✅ MAPPED | Converted from snake_case to camelCase |
| `roles` | `roles` | ✅ MAPPED | Array of strings |
| `permissions` | `permissions` | ✅ MAPPED | Array of strings |
| - | `companyId` | ❌ MISSING | **NOT INCLUDED** in login response |
| `employee_id` | - | ⚠️ IGNORED | Not stored in UserModel |
| `department_id` | - | ⚠️ IGNORED | Not stored in UserModel |
| `position_id` | - | ⚠️ IGNORED | Not stored in UserModel |
| `department_name` | - | ⚠️ IGNORED | Not stored in UserModel |
| `position_name` | - | ⚠️ IGNORED | Not stored in UserModel |
| `status` | - | ⚠️ IGNORED | Not stored in UserModel |

### Issues Identified

#### ❌ CRITICAL: Missing `company_id` in Login Response
**Impact**: High
**Description**: UserModel expects `companyId` but the login response doesn't include it.
**Current Workaround**: Hardcoded as `6` in `MainNavigationScreen`
**Fix Needed**: Add `company_id` to login response data

```php
// Add to AuthenticationController.php line 82:
'company_id' => $employee->company_id,
```

#### ⚠️ EXTRA FIELDS: first_name and last_name
**Impact**: Low
**Description**: API provides `first_name` and `last_name` separately for backward compatibility
**Current Handling**: UserModel uses `name` and provides computed getters:
```dart
String get firstName {
  final parts = name.split(' ');
  return parts.isNotEmpty ? parts.first : name;
}

String get lastName {
  final parts = name.split(' ');
  return parts.length > 1 ? parts.sublist(1).join(' ') : '';
}
```
**Status**: ✅ Working correctly

---

## 2. PROFILE API RESPONSE vs UpdateProfileRequestModel

### API Endpoint
**GET** `/api/v1/profile`

### Backend Response Structure
**File**: `/var/www/erp1/app/Http/Resources/ProfileResource.php`

```json
{
  "success": true,
  "data": {
    "id": 56,
    "company_id": 6,
    "name": "Bassem Bishay",
    "first_name": "Bassem",
    "last_name": "Bishay",
    "email": "bassembishay@bdcbiz.com",
    "phone": "0222720333",
    "address": "123 Main St, Cairo",
    "gender": "male",
    "date_of_birth": "1990-01-15",
    "national_id": "12345678901234",
    "bio": "Software Developer",
    "birthdate": "1990-01-15",
    "experience_years": 5,
    "is_verified": true,
    "department": "التطوير",
    "department_id": 17,
    "position": "Employee",
    "position_id": 21,
    "image": {
      "id": 75,
      "url": "https://erp1.bdcbiz.com/storage/media/employee_30.jpg",
      "path": "/var/www/erp1/storage/app/public/media/employee_30.jpg",
      "file_name": "employee_30.jpg",
      "mime_type": "image/jpeg"
    },
    "created_at": "2025-01-15T10:30:00.000000Z",
    "updated_at": "2025-11-23T19:00:00.000000Z"
  }
}
```

### UPDATE Profile API Endpoint
**POST** `/api/v1/profile`

### Backend Validation Rules
**File**: `/var/www/erp1/app/Http/Requests/V1/User/Profile/UpdateProfileRequest.php`

```php
public function rules(): array
{
    return [
        // Basic Info
        'name' => 'sometimes|string|max:255',
        'first_name' => 'sometimes|string|max:100',
        'last_name' => 'sometimes|string|max:100',
        'bio' => 'sometimes|string|max:1000',
        'birthdate' => 'sometimes|date',

        // Employee Fields ✅
        'phone' => 'sometimes|string|max:15',
        'address' => 'sometimes|string|max:200',
        'gender' => 'sometimes|in:male,female',
        'date_of_birth' => 'sometimes|date',
        'national_id' => 'sometimes|string|max:50',

        // Other
        'experience_years' => 'sometimes|integer|min:0|max:100',
        'nationality_id' => 'sometimes|integer|exists:nationalities,id',
        'languages' => 'sometimes|array',
        'languages.*' => 'integer|exists:languages,id',
        'image' => 'sometimes|string', // Base64 or file path
    ];
}
```

### Flutter Request Model
**File**: `lib/features/profile/data/models/update_profile_request_model.dart`

```dart
class UpdateProfileRequestModel {
  final String? name;
  final String? username;
  final String? bio;
  final String? birthdate;
  final int? experienceYears;
  final String? image;
  final int? nationalityId;
  final List<int>? languages;

  // Employee-specific fields
  final String? phone;
  final String? address;
  final String? gender;
  final String? dateOfBirth;
  final String? nationalId;
}
```

### Field Mapping Comparison

| Request Field (Flutter) | API Field (Backend) | Validation | Status | Notes |
|------------------------|---------------------|------------|--------|-------|
| `name` | `name` | `string\|max:255` | ✅ MAPPED | Direct mapping |
| `username` | - | ❌ NOT ACCEPTED | ⚠️ IGNORED | Backend doesn't accept `username` |
| `bio` | `bio` | `string\|max:1000` | ✅ MAPPED | Direct mapping |
| `birthdate` | `birthdate` | `date` | ✅ MAPPED | Date format required |
| `experienceYears` | `experience_years` | `integer\|min:0\|max:100` | ✅ MAPPED | Converted to snake_case |
| `image` | `image` | `string` | ✅ MAPPED | Base64 encoded |
| `nationalityId` | `nationality_id` | `integer\|exists:nationalities,id` | ✅ MAPPED | Converted to snake_case |
| `languages` | `languages` | `array` | ✅ MAPPED | Array of integers |
| `phone` | `phone` | `string\|max:15` | ✅ MAPPED | Employee field |
| `address` | `address` | `string\|max:200` | ✅ MAPPED | Employee field |
| `gender` | `gender` | `in:male,female` | ✅ MAPPED | Employee field |
| `dateOfBirth` | `date_of_birth` | `date` | ✅ MAPPED | Employee field |
| `nationalId` | `national_id` | `string\|max:50` | ✅ MAPPED | Employee field |
| - | `first_name` | `string\|max:100` | ⚠️ EXTRA | Backend accepts but Flutter doesn't send |
| - | `last_name` | `string\|max:100` | ⚠️ EXTRA | Backend accepts but Flutter doesn't send |

### Issues Identified

#### ⚠️ USERNAME Field Not Accepted
**Impact**: Low
**Description**: Flutter model includes `username` but backend doesn't accept it
**Current Handling**: Field is sent but ignored by backend (no error occurs)
**Recommendation**: Remove `username` from UpdateProfileRequestModel or add validation to backend

#### ✅ All Employee Fields Working
**Status**: All employee-specific fields (phone, address, gender, date_of_birth, national_id) are properly validated and saved

---

## 3. PROFILE RESPONSE vs ProfileModel

### Backend Response
**Same as Section 2 above** - ProfileResource returns complete employee data

### Flutter Profile Model
**File**: `lib/features/profile/data/models/profile_model.dart`

**NOTE**: Based on the screenshot and previous conversations, the app displays profile data but might not have a dedicated ProfileModel. Profile data is likely handled through UserModel or direct state management.

### Current Implementation
The Edit Profile Screen uses:
1. **UserModel** from AuthCubit for basic user info
2. **Controllers** for form fields (phone, address, etc.)
3. **UpdateProfileRequestModel** for sending updates

**Architecture**:
```
Edit Profile Screen
    ↓
Gets data from: AuthCubit.state.user (UserModel)
    ↓
Updates via: ProfileCubit.updateProfile(UpdateProfileRequestModel)
    ↓
Backend: ProfileController@update → ProfileResource response
    ↓
Updates: AuthCubit refreshes UserModel
```

---

## 4. SUMMARY OF ISSUES AND RECOMMENDATIONS

### Critical Issues

#### 1. Missing `company_id` in Login Response ❌
**File**: `/var/www/erp1/app/Http/Controllers/Api/V1/User/Auth/AuthenticationController.php`
**Line**: ~82
**Fix**:
```php
$data = [
    'id' => $employee->id,
    'company_id' => $employee->company_id,  // ← ADD THIS
    'first_name' => explode(' ', $employee->name)[0] ?? $employee->name,
    'name' => $employee->name,
    // ... rest of fields
];
```

**Impact**: Currently hardcoded as `6` in MainNavigationScreen, preventing multi-tenancy support

---

### Minor Issues

#### 2. Username Field Not Used ⚠️
**File**: `lib/features/profile/data/models/update_profile_request_model.dart`
**Options**:
- **Option A**: Remove `username` field from Flutter model (recommended)
- **Option B**: Add `username` validation to backend UpdateProfileRequest

**Current Impact**: None (field is silently ignored)

---

### Working Correctly ✅

#### 3. Name Field Mapping
- ✅ Backend returns `name`, `first_name`, `last_name`
- ✅ Flutter UserModel uses `name` with computed getters for first/last
- ✅ Profile updates send `name` directly
- ✅ **FIXED** in previous session

#### 4. Employee Fields
- ✅ All employee fields properly validated in backend
- ✅ ProfileResource returns all employee fields
- ✅ UpdateProfileRequestModel sends all employee fields
- ✅ **FIXED** in previous session

#### 5. Image Upload
- ✅ Image upload uses Spatie Media Library
- ✅ Images saved to 'profile' collection
- ✅ ProfileResource returns complete image data (id, url, path, file_name, mime_type)
- ✅ UserModel MediaModel properly maps image data
- ⚠️ **Cache issue**: Filament header shows cached images (requires hard refresh)

---

## 5. FIELD-BY-FIELD REFERENCE

### UserModel Fields
| Field | Source | Required | Notes |
|-------|--------|----------|-------|
| `id` | Login API | ✅ Yes | Employee ID |
| `name` | Login API | ✅ Yes | Full name |
| `email` | Login API | ✅ Yes | Email address |
| `phone` | Login API | ❌ No | Phone number |
| `accessToken` | Login API | ✅ Yes | Bearer token |
| `image` | Login API | ❌ No | MediaModel object |
| `userType` | Hardcoded | ✅ Yes | Always 'employee' |
| `roles` | Login API | ❌ No | Array of role names |
| `permissions` | Login API | ❌ No | Array of permission names |
| `companyId` | **MISSING** | ❌ No | **NOT IN API RESPONSE** |

### UpdateProfileRequestModel Fields
| Field | Backend Field | Validation | Notes |
|-------|---------------|------------|-------|
| `name` | `name` | `string\|max:255` | Full name |
| `username` | - | ❌ NOT ACCEPTED | **UNUSED** |
| `bio` | `bio` | `string\|max:1000` | Biography |
| `birthdate` | `birthdate` | `date` | Birth date |
| `experienceYears` | `experience_years` | `integer\|min:0\|max:100` | Years of experience |
| `image` | `image` | `string` | Base64 encoded image |
| `nationalityId` | `nationality_id` | `integer\|exists` | Nationality FK |
| `languages` | `languages` | `array` | Language IDs |
| `phone` | `phone` | `string\|max:15` | Phone number |
| `address` | `address` | `string\|max:200` | Address |
| `gender` | `gender` | `in:male,female` | Gender |
| `dateOfBirth` | `date_of_birth` | `date` | Date of birth |
| `nationalId` | `national_id` | `string\|max:50` | National ID |

---

## 6. TESTING CHECKLIST

### Login Flow
- [x] Login returns `name` field ✅
- [x] Login returns `access_token` ✅
- [x] Login returns `roles` and `permissions` ✅
- [x] Login returns `image` object ✅
- [ ] Login returns `company_id` ❌ **NEEDS FIX**

### Profile Update Flow
- [x] Update sends `name` field ✅
- [x] Update sends employee fields (phone, address, gender, etc.) ✅
- [x] Update saves to database ✅
- [x] Update visible in Filament ✅
- [x] Update returns updated profile ✅

### Image Upload Flow
- [x] Image upload works from Flutter ✅
- [x] Image saved to Spatie Media Library ✅
- [x] Image URL returned in response ✅
- [ ] Image updates in Filament header ⚠️ **CACHE ISSUE**

---

## 7. RECOMMENDED ACTIONS

### Priority 1: Add company_id to Login Response
```php
// File: /var/www/erp1/app/Http/Controllers/Api/V1/User/Auth/AuthenticationController.php
// Line: ~82

$data = [
    'id' => $employee->id,
    'company_id' => $employee->company_id,  // ← ADD THIS LINE
    'first_name' => explode(' ', $employee->name)[0] ?? $employee->name,
    'name' => $employee->name,
    // ... rest of fields
];
```

### Priority 2: Remove Unused username Field
```dart
// File: lib/features/profile/data/models/update_profile_request_model.dart
// Remove this field:

class UpdateProfileRequestModel extends Equatable {
  final String? name;
  // final String? username;  // ← REMOVE THIS LINE
  final String? bio;
  // ... rest of fields
}
```

### Priority 3: Fix Filament Image Cache (Optional)
**Current Workaround**: Hard refresh browser (Ctrl+Shift+R)
**Programmatic Fix**: Modify `Employee::getFilamentAvatarUrl()` to add cache busting (previous attempt failed with syntax error)

---

## 8. CONCLUSION

### Overall Status: ✅ 90% Complete

**Working**:
- ✅ Login API integration
- ✅ Profile fetch and update
- ✅ Image upload functionality
- ✅ Employee fields integration
- ✅ Name field mapping (after fix)

**Needs Attention**:
- ❌ `company_id` missing from login response (Priority 1)
- ⚠️ `username` field unused (Priority 2)
- ⚠️ Filament image cache issue (Priority 3)

**Next Steps**:
1. Add `company_id` to login response
2. Test login flow to verify `company_id` is received
3. Remove hardcoded `companyId = 6` from MainNavigationScreen
4. Test multi-tenancy with different company IDs
5. Optionally: Remove `username` field from Flutter model
6. Optionally: Fix Filament image cache issue

---

**Document Version**: 1.0
**Last Updated**: 23 November 2025
**Reviewed By**: Claude Code Assistant
**Status**: Ready for Implementation
