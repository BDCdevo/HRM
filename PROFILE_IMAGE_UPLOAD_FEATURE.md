# Profile Image Upload Feature

## نظرة عامة (Overview)

تم إضافة ميزة تحميل صورة البروفايل للمستخدمين. الآن يمكن للمستخدمين:
- التقاط صورة جديدة باستخدام الكاميرا
- اختيار صورة من المعرض
- رفع الصورة إلى السيرفر
- رؤية الصورة المحدثة فوراً

---

## الملفات المعدلة (Modified Files)

### 1. API Configuration
**File**: `lib/core/config/api_config.dart`

```dart
static const String uploadProfileImage = '/profile/upload-image';
```

تم إضافة endpoint جديد لرفع صورة البروفايل.

---

### 2. Profile Repository
**File**: `lib/features/profile/data/repo/profile_repo.dart`

```dart
Future<ProfileModel> uploadProfileImage(File imageFile) async {
  final formData = FormData.fromMap({
    'image': await MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.path.split('/').last,
    ),
  });

  final response = await _dioClient.post(
    ApiConfig.uploadProfileImage,
    data: formData,
  );

  return ProfileResponseModel.fromJson(response.data).data;
}
```

**Features**:
- يرسل الصورة كـ `multipart/form-data`
- يحدد حجم الملف تلقائياً
- يعيد ProfileModel المحدث بعد الرفع

---

### 3. Profile State
**File**: `lib/features/profile/logic/cubit/profile_state.dart`

```dart
class ProfileImageUploaded extends ProfileState {
  final ProfileModel profile;
  final String message;

  const ProfileImageUploaded({
    required this.profile,
    this.message = 'Profile image uploaded successfully',
  });
}
```

State جديدة للإشارة إلى نجاح رفع الصورة.

---

### 4. Profile Cubit
**File**: `lib/features/profile/logic/cubit/profile_cubit.dart`

```dart
Future<void> uploadProfileImage(File imageFile) async {
  try {
    emit(const ProfileLoading());
    final profile = await _profileRepo.uploadProfileImage(imageFile);
    emit(ProfileImageUploaded(profile: profile));
    await fetchProfile(); // Refresh profile
  } on DioException catch (e) {
    _handleDioException(e);
  }
}
```

**Flow**:
1. يظهر loading state
2. يرفع الصورة عبر Repository
3. يعرض success message
4. يحدث refresh للبروفايل للحصول على أحدث البيانات

---

### 5. Profile Screen UI
**File**: `lib/features/profile/ui/screens/profile_screen.dart`

#### أ) زر الكاميرا على صورة البروفايل

```dart
Stack(
  children: [
    CircleAvatar(
      radius: 50,
      backgroundImage: profile.hasImage ? NetworkImage(profile.image!.url) : null,
    ),
    Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => _showImageSourceDialog(context),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: const Icon(Icons.camera_alt, size: 18, color: AppColors.white),
        ),
      ),
    ),
  ],
)
```

**Design**:
- زر كاميرا صغير برتقالي في الزاوية السفلية اليمنى
- Border أبيض حول الزر للتباين
- يفتح bottom sheet عند الضغط

---

#### ب) Bottom Sheet لاختيار مصدر الصورة

```dart
void _showImageSourceDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take Photo'),
            onTap: () => _pickImage(ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from Gallery'),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}
```

**Options**:
1. **Take Photo**: يفتح الكاميرا للتقاط صورة جديدة
2. **Choose from Gallery**: يفتح معرض الصور لاختيار صورة موجودة

---

#### ج) اختيار ورفع الصورة

```dart
Future<void> _pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: source,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );

  if (image != null) {
    _profileCubit.uploadProfileImage(File(image.path));
  }
}
```

**Image Optimization**:
- `maxWidth: 1024` - عرض أقصى
- `maxHeight: 1024` - ارتفاع أقصى
- `imageQuality: 85` - جودة 85% (توازن بين الحجم والجودة)

---

## API Backend Requirements

### Endpoint
```
POST /api/v1/profile/upload-image
```

### Headers
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

### Request Body
```
image: File (required)
```

### Response
```json
{
  "success": true,
  "message": "Profile image uploaded successfully",
  "data": {
    "id": 1,
    "name": "Ahmed",
    "email": "ahmed@example.com",
    "image": {
      "id": 123,
      "url": "https://example.com/storage/profiles/image.jpg",
      "path": "/storage/profiles/image.jpg"
    },
    ...
  }
}
```

---

## User Flow

### تدفق المستخدم

1. **المستخدم يفتح صفحة البروفايل**
   - يرى صورة البروفايل الحالية (أو أيقونة افتراضية)
   - يرى زر الكاميرا في الزاوية

2. **المستخدم يضغط على زر الكاميرا**
   - يظهر bottom sheet مع خيارين

3. **المستخدم يختار مصدر الصورة**
   - **Option A**: Take Photo → يفتح الكاميرا
   - **Option B**: Choose from Gallery → يفتح المعرض

4. **المستخدم يختار/يلتقط الصورة**
   - يتم ضغط الصورة تلقائياً إلى 1024×1024
   - يتم تقليل الجودة إلى 85%

5. **رفع الصورة**
   - يظهر loading indicator
   - يتم رفع الصورة عبر API
   - يظهر success message
   - يتم تحديث الصورة فوراً في الـ UI

---

## Error Handling

### Client-Side Errors

```dart
try {
  _profileCubit.uploadProfileImage(File(image.path));
} catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to pick image: ${e.toString()}'),
      backgroundColor: AppColors.error,
    ),
  );
}
```

### Server-Side Errors

```dart
void _handleDioException(DioException e) {
  if (e.response != null) {
    final errorMessage = e.response?.data?['message'] ?? 'Operation failed';
    emit(ProfileError(message: errorMessage));
  }
}
```

**Common Errors**:
- 400: Invalid image format
- 413: File too large
- 401: Unauthorized
- 500: Server error

---

## Testing Checklist

- [ ] فتح صفحة البروفايل
- [ ] الضغط على زر الكاميرا
- [ ] اختيار "Take Photo"
- [ ] التقاط صورة جديدة
- [ ] التأكد من رفع الصورة بنجاح
- [ ] الضغط على زر الكاميرا مرة أخرى
- [ ] اختيار "Choose from Gallery"
- [ ] اختيار صورة من المعرض
- [ ] التأكد من رفع الصورة بنجاح
- [ ] التأكد من تحديث الصورة في الـ UI
- [ ] اختبار مع صورة كبيرة جداً
- [ ] اختبار مع صورة صغيرة جداً
- [ ] اختبار بدون اتصال بالإنترنت
- [ ] اختبار مع token منتهي الصلاحية

---

## Dependencies Used

```yaml
dependencies:
  image_picker: ^latest  # Already in pubspec.yaml
  dio: ^latest          # Already in pubspec.yaml (for multipart upload)
```

---

## Future Improvements

1. **Image Cropping**: إضافة إمكانية قص الصورة قبل الرفع
2. **Image Filters**: إضافة فلاتر للصورة
3. **Remove Image**: إضافة خيار حذف الصورة
4. **Image Preview**: عرض preview قبل الرفع
5. **Compression Settings**: السماح للمستخدم باختيار جودة الصورة
6. **Multiple Uploads**: رفع صور متعددة دفعة واحدة

---

## Notes

- الصورة يتم ضغطها تلقائياً لتقليل استهلاك البيانات
- يتم استخدام `MultipartFile` لرفع الصورة
- يتم تحديث البروفايل تلقائياً بعد رفع الصورة
- يتم التحقق من `mounted` قبل استخدام `BuildContext` في async functions

---

## Generated Files

تم تعديل الملفات التالية:
- `lib/core/config/api_config.dart` ✅
- `lib/features/profile/data/repo/profile_repo.dart` ✅
- `lib/features/profile/logic/cubit/profile_state.dart` ✅
- `lib/features/profile/logic/cubit/profile_cubit.dart` ✅
- `lib/features/profile/ui/screens/profile_screen.dart` ✅

---

تم إنشاء هذا الملف في: 2025-01-20
