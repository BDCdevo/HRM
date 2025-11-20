<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

/**
 * Employee Animation Controller
 *
 * Handles custom Lottie animation uploads for employees
 *
 * @package App\Http\Controllers\Api\V1
 */
class EmployeeAnimationController extends Controller
{
    /**
     * Upload custom Lottie animation
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function upload(Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'animation' => 'required|file|mimes:json|max:2048', // Max 2MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'فشل التحقق من الملف',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $employee = $request->user();
            $file = $request->file('animation');

            // Validate JSON structure
            $jsonContent = file_get_contents($file->getRealPath());
            $decoded = json_decode($jsonContent, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                return response()->json([
                    'success' => false,
                    'message' => 'الملف ليس JSON صالح',
                ], 422);
            }

            // Validate Lottie format (must have version key)
            if (!isset($decoded['v'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'الملف ليس Lottie animation صالح',
                ], 422);
            }

            // Additional validations (optional)
            $fileSize = filesize($file->getRealPath());
            if ($fileSize > 2 * 1024 * 1024) { // 2MB
                return response()->json([
                    'success' => false,
                    'message' => 'حجم الملف كبير جداً (الحد الأقصى 2MB)',
                ], 422);
            }

            // Delete old animation if exists
            if ($employee->custom_animation_path) {
                Storage::disk('public')->delete($employee->custom_animation_path);
            }

            // Store new animation in employee-specific folder
            $path = $file->store('animations/employees/' . $employee->id, 'public');

            // Update employee record
            $employee->update([
                'custom_animation_path' => $path,
                'animation_uploaded_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم رفع الصورة المتحركة بنجاح',
                'data' => [
                    'animation_url' => Storage::url($path),
                    'animation_path' => $path,
                    'uploaded_at' => $employee->animation_uploaded_at,
                    'file_size' => $fileSize,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء رفع الملف',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get employee's custom animation
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getAnimation(Request $request)
    {
        try {
            $employee = $request->user();

            if (!$employee->custom_animation_path) {
                return response()->json([
                    'success' => true,
                    'message' => 'لا توجد صورة متحركة مخصصة',
                    'data' => [
                        'has_custom_animation' => false,
                        'animation_url' => null,
                        'animation_path' => null,
                        'uploaded_at' => null,
                    ],
                ], 200);
            }

            // Check if file exists
            if (!Storage::disk('public')->exists($employee->custom_animation_path)) {
                // File missing, clear database record
                $employee->update([
                    'custom_animation_path' => null,
                    'animation_uploaded_at' => null,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'الملف غير موجود',
                    'data' => [
                        'has_custom_animation' => false,
                        'animation_url' => null,
                        'animation_path' => null,
                        'uploaded_at' => null,
                    ],
                ], 200);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم جلب الصورة المتحركة بنجاح',
                'data' => [
                    'has_custom_animation' => true,
                    'animation_url' => Storage::url($employee->custom_animation_path),
                    'animation_path' => $employee->custom_animation_path,
                    'uploaded_at' => $employee->animation_uploaded_at,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب البيانات',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete custom animation (revert to default)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function delete(Request $request)
    {
        try {
            $employee = $request->user();

            if (!$employee->custom_animation_path) {
                return response()->json([
                    'success' => true,
                    'message' => 'لا توجد صورة متحركة للحذف',
                ], 200);
            }

            // Delete file from storage
            if (Storage::disk('public')->exists($employee->custom_animation_path)) {
                Storage::disk('public')->delete($employee->custom_animation_path);
            }

            // Update employee record
            $employee->update([
                'custom_animation_path' => null,
                'animation_uploaded_at' => null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الصورة المتحركة بنجاح',
                'data' => [
                    'has_custom_animation' => false,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء الحذف',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Validate Lottie JSON before upload
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function validateAnimation(Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'animation' => 'required|file|mimes:json|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'فشل التحقق من الملف',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $file = $request->file('animation');
            $jsonContent = file_get_contents($file->getRealPath());
            $decoded = json_decode($jsonContent, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                return response()->json([
                    'success' => false,
                    'message' => 'الملف ليس JSON صالح',
                    'error' => json_last_error_msg(),
                ], 422);
            }

            if (!isset($decoded['v'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'الملف ليس Lottie animation صالح - مفتاح الإصدار مفقود',
                ], 422);
            }

            // Get animation info
            $animationInfo = [
                'version' => $decoded['v'] ?? null,
                'width' => $decoded['w'] ?? null,
                'height' => $decoded['h'] ?? null,
                'frames' => $decoded['op'] ?? null,
                'frame_rate' => $decoded['fr'] ?? null,
                'name' => $decoded['nm'] ?? 'Unknown',
                'file_size' => filesize($file->getRealPath()),
                'file_size_mb' => round(filesize($file->getRealPath()) / 1024 / 1024, 2),
            ];

            return response()->json([
                'success' => true,
                'message' => 'الملف صالح ويمكن رفعه',
                'data' => $animationInfo,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء التحقق من الملف',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get all employees with custom animations (Admin only)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getAllCustomAnimations(Request $request)
    {
        try {
            // Only for admins
            if (!$request->user()->is_admin) {
                return response()->json([
                    'success' => false,
                    'message' => 'غير مصرح لك بالوصول',
                ], 403);
            }

            $employees = \App\Models\Employee::whereNotNull('custom_animation_path')
                ->select('id', 'name', 'email', 'custom_animation_path', 'animation_uploaded_at')
                ->get()
                ->map(function ($employee) {
                    return [
                        'id' => $employee->id,
                        'name' => $employee->name,
                        'email' => $employee->email,
                        'animation_url' => Storage::url($employee->custom_animation_path),
                        'uploaded_at' => $employee->animation_uploaded_at,
                    ];
                });

            return response()->json([
                'success' => true,
                'message' => 'تم جلب البيانات بنجاح',
                'data' => [
                    'total' => $employees->count(),
                    'employees' => $employees,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب البيانات',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
