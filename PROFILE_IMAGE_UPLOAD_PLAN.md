# 📸 Profile Image Upload - خطة التنفيذ

## 📋 نظرة عامة

### الهدف
السماح لكل موظف برفع وتحديث صورته الشخصية في الملف الشخصي.

### المميزات الرئيسية
- ✅ رفع صورة من المعرض (Gallery)
- ✅ التقاط صورة بالكاميرا (Camera)
- ✅ معاينة الصورة قبل الرفع
- ✅ حذف الصورة والرجوع للـ default
- ✅ Crop & Resize تلقائي
- ✅ تحسين الصورة (Compression)
- ✅ دعم Dark Mode

### المواصفات التقنية
- **حجم الصورة**: حد أقصى 5MB
- **الأنواع المدعومة**: JPG, PNG, JPEG
- **التخزين**: Laravel Storage (public disk)
- **الأبعاد المثالية**: 512x512 px
- **Compression**: 80% quality

---

## 🗓️ الجدول الزمني

| المرحلة | الوقت المتوقع | الوصف |
|--------|--------------|-------|
| المرحلة 1: Backend (Database) | نصف يوم | إضافة عمود للصورة في الجدول |
| المرحلة 2: Backend (API) | يوم واحد | تطوير endpoints للرفع والحذف |
| المرحلة 3: Flutter (Models) | نصف يوم | تحديث UserModel |
| المرحلة 4: Flutter (Repository) | نصف يوم | إنشاء ProfileImageRepository |
| المرحلة 5: Flutter (State Management) | نصف يوم | تحديث ProfileCubit |
| المرحلة 6: Flutter (UI) | يومين | بناء واجهة التفاعل |
| المرحلة 7: Testing | يوم واحد | اختبار شامل |
| المرحلة 8: Deployment | نصف يوم | نشر على السيرفر |
| **الإجمالي** | **6 أيام** | |

---

## 🔧 المرحلة 1: Backend - Database Schema

### الوقت المتوقع: نصف يوم

### الخطوات:

#### 1.1 إنشاء Migration

**المسار**: `D:\php_project\filament-hrm\database\migrations\`

```bash
cd D:\php_project\filament-hrm
php artisan make:migration add_profile_image_to_employees_table
```

**محتوى الـ Migration**:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('employees', function (Blueprint $table) {
            // Add profile image columns
            $table->string('profile_image_path')->nullable()->after('email');
            $table->timestamp('profile_image_uploaded_at')->nullable()->after('profile_image_path');

            // Add index for faster queries
            $table->index('profile_image_path');
        });
    }

    public function down(): void
    {
        Schema::table('employees', function (Blueprint $table) {
            $table->dropIndex(['profile_image_path']);
            $table->dropColumn(['profile_image_path', 'profile_image_uploaded_at']);
        });
    }
};
```

#### 1.2 تشغيل Migration

```bash
# محلي (Local)
cd D:\php_project\filament-hrm
php artisan migrate

# إنتاج (Production) - بعد التأكد من الاختبار المحلي
ssh -i ~/.ssh/id_ed25519 root@31.97.46.103
cd /var/www/erp1
php artisan migrate
```

#### 1.3 تحديث Employee Model

**المسار**: `D:\php_project\filament-hrm\app\Models\Employee.php`

```php
// أضف للـ $fillable
protected $fillable = [
    // ... existing fields
    'profile_image_path',
    'profile_image_uploaded_at',
];

// أضف Accessor للـ image URL
protected $appends = ['profile_image_url'];

public function getProfileImageUrlAttribute(): ?string
{
    if (!$this->profile_image_path) {
        return null;
    }

    // Return full URL
    return Storage::url($this->profile_image_path);
}

// Cast
protected $casts = [
    // ... existing casts
    'profile_image_uploaded_at' => 'datetime',
];

// Helper method to get image URL or default avatar
public function getAvatarUrlAttribute(): string
{
    return $this->profile_image_url ?? asset('images/default-avatar.png');
}
```

---

## 🔧 المرحلة 2: Backend - API Development

### الوقت المتوقع: يوم واحد

### الخطوات:

#### 2.1 إنشاء Controller

```bash
cd D:\php_project\filament-hrm
php artisan make:controller Api/V1/ProfileImageController
```

**المسار**: `D:\php_project\filament-hrm\app\Http\Controllers\Api\V1\ProfileImageController.php`

**محتوى الـ Controller**:

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Intervention\Image\Facades\Image;

/**
 * Profile Image Controller
 *
 * Handles profile image upload, update, and deletion
 */
class ProfileImageController extends Controller
{
    /**
     * Upload or update profile image
     */
    public function upload(Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|mimes:jpeg,jpg,png|max:5120', // Max 5MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'فشل التحقق من الصورة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $employee = $request->user();
            $file = $request->file('image');

            // Delete old image if exists
            if ($employee->profile_image_path) {
                Storage::disk('public')->delete($employee->profile_image_path);
            }

            // Process image with Intervention Image
            $image = Image::make($file);

            // Resize to 512x512 (square)
            $image->fit(512, 512, function ($constraint) {
                $constraint->upsize();
            });

            // Optimize quality
            $image->encode('jpg', 80);

            // Generate unique filename
            $filename = 'profile_' . $employee->id . '_' . time() . '.jpg';
            $path = 'images/profiles/' . $filename;

            // Store processed image
            Storage::disk('public')->put($path, (string) $image);

            // Update employee record
            $employee->update([
                'profile_image_path' => $path,
                'profile_image_uploaded_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم رفع الصورة بنجاح',
                'data' => [
                    'image_url' => Storage::url($path),
                    'image_path' => $path,
                    'uploaded_at' => $employee->profile_image_uploaded_at,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء رفع الصورة',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get current profile image
     */
    public function getImage(Request $request)
    {
        try {
            $employee = $request->user();

            if (!$employee->profile_image_path) {
                return response()->json([
                    'success' => true,
                    'message' => 'لا توجد صورة شخصية',
                    'data' => [
                        'has_image' => false,
                        'image_url' => null,
                    ],
                ], 200);
            }

            // Check if file exists
            if (!Storage::disk('public')->exists($employee->profile_image_path)) {
                // File missing, clear database record
                $employee->update([
                    'profile_image_path' => null,
                    'profile_image_uploaded_at' => null,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'الصورة غير موجودة',
                    'data' => [
                        'has_image' => false,
                        'image_url' => null,
                    ],
                ], 200);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم جلب الصورة بنجاح',
                'data' => [
                    'has_image' => true,
                    'image_url' => Storage::url($employee->profile_image_path),
                    'uploaded_at' => $employee->profile_image_uploaded_at,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب الصورة',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete profile image
     */
    public function delete(Request $request)
    {
        try {
            $employee = $request->user();

            if (!$employee->profile_image_path) {
                return response()->json([
                    'success' => true,
                    'message' => 'لا توجد صورة للحذف',
                ], 200);
            }

            // Delete file from storage
            if (Storage::disk('public')->exists($employee->profile_image_path)) {
                Storage::disk('public')->delete($employee->profile_image_path);
            }

            // Update employee record
            $employee->update([
                'profile_image_path' => null,
                'profile_image_uploaded_at' => null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الصورة بنجاح',
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء الحذف',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
```

#### 2.2 إضافة Routes

**المسار**: `D:\php_project\filament-hrm\routes\api.php`

```php
// أضف داخل مجموعة auth:sanctum
Route::middleware(['auth:sanctum'])->prefix('v1')->group(function () {
    // ... existing routes

    // Profile Image Routes
    Route::post('profile/image/upload', [ProfileImageController::class, 'upload']);
    Route::get('profile/image', [ProfileImageController::class, 'getImage']);
    Route::delete('profile/image', [ProfileImageController::class, 'delete']);
});
```

#### 2.3 تثبيت Intervention Image (للمعالجة)

```bash
cd D:\php_project\filament-hrm
composer require intervention/image
```

**تفعيل في `config/app.php`**:

```php
'providers' => [
    // ...
    Intervention\Image\ImageServiceProvider::class,
],

'aliases' => [
    // ...
    'Image' => Intervention\Image\Facades\Image::class,
],
```

#### 2.4 اختبار الـ Backend

```bash
# تشغيل السيرفر المحلي
cd D:\php_project\filament-hrm
php artisan serve

# اختبار الـ routes
php artisan route:list --path=api/v1/profile

# مسح الـ cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

---

## 📱 المرحلة 3: Flutter - Update UserModel

### الوقت المتوقع: نصف يوم

### الخطوات:

#### 3.1 تحديث UserModel

**المسار**: `lib/features/auth/data/models/user_model.dart`

```dart
// أضف الحقول الجديدة
@JsonKey(name: 'profile_image_path')
final String? profileImagePath;

@JsonKey(name: 'profile_image_url')
final String? profileImageUrl;

@JsonKey(name: 'profile_image_uploaded_at')
final String? profileImageUploadedAt;

// في الـ constructor
const UserModel({
  // ... existing parameters
  this.profileImagePath,
  this.profileImageUrl,
  this.profileImageUploadedAt,
});

// في copyWith
UserModel copyWith({
  // ... existing parameters
  String? profileImagePath,
  String? profileImageUrl,
  String? profileImageUploadedAt,
}) {
  return UserModel(
    // ... existing fields
    profileImagePath: profileImagePath ?? this.profileImagePath,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    profileImageUploadedAt: profileImageUploadedAt ?? this.profileImageUploadedAt,
  );
}

// في props
@override
List<Object?> get props => [
  // ... existing props
  profileImagePath,
  profileImageUrl,
  profileImageUploadedAt,
];

// Helper method to get avatar URL
String get avatarUrl {
  return profileImageUrl ?? 'https://ui-avatars.com/api/?name=$name&size=512';
}
```

**بعد التعديل، شغل build_runner**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📱 المرحلة 4: Flutter - ProfileImageRepository

### الوقت المتوقع: نصف يوم

**المسار**: `lib/features/profile/data/repo/profile_image_repository.dart`

**إنشاء ملف جديد**:

```dart
import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';

/// Repository for handling profile image operations
class ProfileImageRepository {
  final _dioClient = DioClient.getInstance();

  /// Upload profile image
  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: 'profile.jpg',
        ),
      });

      final response = await _dioClient.post(
        '${ApiConfig.baseUrl}/profile/image/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'فشل رفع الصورة');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء رفع الصورة');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Get current profile image
  Future<Map<String, dynamic>> getImage() async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/profile/image',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw Exception(response.data['message'] ?? 'فشل جلب الصورة');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء جلب الصورة');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Delete profile image
  Future<void> deleteImage() async {
    try {
      final response = await _dioClient.delete(
        '${ApiConfig.baseUrl}/profile/image',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      }

      throw Exception(response.data['message'] ?? 'فشل حذف الصورة');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'حدث خطأ أثناء الحذف');
      }
      throw Exception('فشل الاتصال بالسيرفر');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}
```

---

## 📱 المرحلة 5: Flutter - Update ProfileCubit

### الوقت المتوقع: نصف يوم

**تحديث**: `lib/features/profile/logic/cubit/profile_cubit.dart`

**إضافة methods جديدة**:

```dart
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../data/repo/profile_image_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  final ProfileImageRepository _imageRepository = ProfileImageRepository();
  final AuthCubit? _authCubit; // للتحديث بعد الرفع

  ProfileCubit([this._authCubit]) : _repository = ProfileRepository(), super(ProfileInitial());

  // ... existing methods

  /// Upload profile image
  Future<void> uploadProfileImage(String filePath) async {
    emit(ProfileLoading());
    try {
      final data = await _imageRepository.uploadImage(filePath);

      // Update AuthCubit with new image URL
      if (_authCubit != null) {
        final currentState = _authCubit.state;
        if (currentState is AuthAuthenticated) {
          final updatedUser = currentState.user.copyWith(
            profileImageUrl: data['image_url'] as String?,
          );
          _authCubit.updateUser(updatedUser);
        }
      }

      emit(ProfileImageUploaded(
        imageUrl: data['image_url'] as String,
        message: 'تم رفع الصورة بنجاح',
      ));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage() async {
    emit(ProfileLoading());
    try {
      await _imageRepository.deleteImage();

      // Update AuthCubit to remove image
      if (_authCubit != null) {
        final currentState = _authCubit.state;
        if (currentState is AuthAuthenticated) {
          final updatedUser = currentState.user.copyWith(
            profileImageUrl: null,
          );
          _authCubit.updateUser(updatedUser);
        }
      }

      emit(ProfileImageDeleted('تم حذف الصورة بنجاح'));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
```

**إضافة states جديدة في `profile_state.dart`**:

```dart
/// Profile image uploaded successfully
class ProfileImageUploaded extends ProfileState {
  final String imageUrl;
  final String message;

  const ProfileImageUploaded({
    required this.imageUrl,
    required this.message,
  });

  @override
  List<Object?> get props => [imageUrl, message];
}

/// Profile image deleted successfully
class ProfileImageDeleted extends ProfileState {
  final String message;

  const ProfileImageDeleted(this.message);

  @override
  List<Object?> get props => [message];
}
```

---

## 📱 المرحلة 6: Flutter - UI Implementation

### الوقت المتوقع: يومين

### 6.1 إنشاء Image Picker Widget

**المسار**: `lib/core/widgets/profile_image_picker.dart`

**الكود في الملفات المرفقة** ⬇️

### 6.2 تحديث Profile Screen

**المسار**: `lib/features/profile/ui/screens/profile_screen.dart`

**إضافة زر تعديل الصورة**

---

## 🎨 UI Components

### Avatar Widget with Edit Button

```dart
Stack(
  children: [
    // Avatar
    CircleAvatar(
      radius: 60,
      backgroundImage: user.profileImageUrl != null
        ? NetworkImage(user.profileImageUrl!)
        : null,
      child: user.profileImageUrl == null
        ? Text(user.name[0].toUpperCase())
        : null,
    ),

    // Edit button
    Positioned(
      right: 0,
      bottom: 0,
      child: IconButton(
        icon: Icon(Icons.camera_alt),
        onPressed: () => _showImagePickerOptions(),
      ),
    ),
  ],
)
```

---

## 📊 ملخص الميزة

### Backend:
- ✅ عمود في قاعدة البيانات
- ✅ 3 endpoints (upload, get, delete)
- ✅ معالجة الصور (resize, compress)
- ✅ تخزين آمن

### Flutter:
- ✅ تحديث UserModel
- ✅ ProfileImageRepository
- ✅ تحديث ProfileCubit
- ✅ Image Picker (Camera + Gallery)
- ✅ UI متكامل
- ✅ دعم Dark Mode

---

## ⏱️ الوقت الإجمالي: **6 أيام**

---

**الخطوة التالية**: ابدأ بالمرحلة 1 (Backend Database) 🚀
