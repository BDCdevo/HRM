# تطبيق نظام تسجيل الجلسات - Session Tracking Implementation

**التاريخ**: 2025-11-19
**الإصدار**: 1.1.0+6
**الحالة**: 🚧 قيد التطبيق

---

## 📋 الملخص

نظام شامل لتسجيل وتتبع جلسات تسجيل الدخول للموظفين والإداريين.

---

## 🎯 الأهداف

1. ✅ تسجيل كل محاولة دخول (ناجحة/فاشلة)
2. ✅ تتبع الجلسات النشطة
3. ✅ حفظ معلومات الجهاز
4. ✅ حساب مدة الجلسة
5. ✅ عرض سجل الجلسات للمستخدم
6. ✅ لوحة إدارية لمراقبة النشاط

---

## 📊 التصميم

### 1. قاعدة البيانات

**الجدول**: `login_sessions`

```sql
CREATE TABLE login_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    user_type ENUM('employee', 'admin') NOT NULL DEFAULT 'employee',
    company_id INT UNSIGNED NULL,

    -- Session Info
    session_token VARCHAR(100) UNIQUE,
    login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP NULL,
    session_duration INT NULL COMMENT 'Duration in seconds',
    status ENUM('active', 'logged_out', 'expired', 'forced_logout') DEFAULT 'active',

    -- Device Info
    device_type VARCHAR(20) NULL COMMENT 'Android, iOS, Web',
    device_model VARCHAR(100) NULL,
    device_id VARCHAR(100) NULL COMMENT 'Unique device identifier',
    os_version VARCHAR(50) NULL,
    app_version VARCHAR(20) NULL,

    -- Network Info
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,

    -- Location Info (optional)
    login_latitude DECIMAL(10, 8) NULL,
    login_longitude DECIMAL(11, 8) NULL,

    -- Additional Info
    login_method VARCHAR(20) NULL COMMENT 'unified, employee, admin',
    notes TEXT NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_company_id (company_id),
    INDEX idx_login_time (login_time),
    INDEX idx_status (status),
    INDEX idx_session_token (session_token),

    -- Foreign Keys
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔧 التطبيق

### المرحلة 1: Backend (Laravel)

#### 1.1 Migration

**الملف**: `database/migrations/2025_11_19_create_login_sessions_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('login_sessions', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('user_id');
            $table->enum('user_type', ['employee', 'admin'])->default('employee');
            $table->unsignedInteger('company_id')->nullable();

            // Session Info
            $table->string('session_token', 100)->unique()->nullable();
            $table->timestamp('login_time')->useCurrent();
            $table->timestamp('logout_time')->nullable();
            $table->integer('session_duration')->nullable()->comment('Duration in seconds');
            $table->enum('status', ['active', 'logged_out', 'expired', 'forced_logout'])->default('active');

            // Device Info
            $table->string('device_type', 20)->nullable()->comment('Android, iOS, Web');
            $table->string('device_model', 100)->nullable();
            $table->string('device_id', 100)->nullable()->comment('Unique device identifier');
            $table->string('os_version', 50)->nullable();
            $table->string('app_version', 20)->nullable();

            // Network Info
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();

            // Location Info (optional)
            $table->decimal('login_latitude', 10, 8)->nullable();
            $table->decimal('login_longitude', 11, 8)->nullable();

            // Additional Info
            $table->string('login_method', 20)->nullable()->comment('unified, employee, admin');
            $table->text('notes')->nullable();

            $table->timestamps();

            // Indexes
            $table->index('user_id');
            $table->index('company_id');
            $table->index('login_time');
            $table->index('status');

            // Foreign Keys
            $table->foreign('company_id')->references('id')->on('companies')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('login_sessions');
    }
};
```

#### 1.2 Model

**الملف**: `app/Models/LoginSession.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Traits\CompanyOwned;

class LoginSession extends Model
{
    use CompanyOwned;

    protected $fillable = [
        'user_id',
        'user_type',
        'company_id',
        'session_token',
        'login_time',
        'logout_time',
        'session_duration',
        'status',
        'device_type',
        'device_model',
        'device_id',
        'os_version',
        'app_version',
        'ip_address',
        'user_agent',
        'login_latitude',
        'login_longitude',
        'login_method',
        'notes',
    ];

    protected $casts = [
        'login_time' => 'datetime',
        'logout_time' => 'datetime',
        'login_latitude' => 'decimal:8',
        'login_longitude' => 'decimal:8',
    ];

    // Relationships
    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'user_id')->where('user_type', 'employee');
    }

    public function admin(): BelongsTo
    {
        return $this->belongsTo(Admin::class, 'user_id')->where('user_type', 'admin');
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeForUser($query, int $userId, string $userType)
    {
        return $query->where('user_id', $userId)->where('user_type', $userType);
    }

    public function scopeRecent($query, int $days = 30)
    {
        return $query->where('login_time', '>=', now()->subDays($days));
    }

    // Accessors
    public function getDurationFormattedAttribute(): string
    {
        if (!$this->session_duration) {
            return 'نشط';
        }

        $hours = floor($this->session_duration / 3600);
        $minutes = floor(($this->session_duration % 3600) / 60);

        if ($hours > 0) {
            return "{$hours} ساعة و {$minutes} دقيقة";
        }

        return "{$minutes} دقيقة";
    }

    // Methods
    public function endSession(): void
    {
        $this->logout_time = now();
        $this->session_duration = $this->login_time->diffInSeconds($this->logout_time);
        $this->status = 'logged_out';
        $this->save();
    }

    public function forceLogout(string $reason = null): void
    {
        $this->logout_time = now();
        $this->session_duration = $this->login_time->diffInSeconds($this->logout_time);
        $this->status = 'forced_logout';
        if ($reason) {
            $this->notes = ($this->notes ? $this->notes . "\n" : '') . "Forced logout: $reason";
        }
        $this->save();
    }

    public function markAsExpired(): void
    {
        $this->status = 'expired';
        $this->save();
    }
}
```

#### 1.3 Controller

**الملف**: `app/Http/Controllers/Api/SessionController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LoginSession;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;

class SessionController extends Controller
{
    /**
     * Start a new login session
     */
    public function startSession(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => 'required|integer',
            'user_type' => 'required|in:employee,admin',
            'device_info' => 'required|array',
            'device_info.type' => 'required|string',
            'device_info.model' => 'nullable|string',
            'device_info.device_id' => 'nullable|string',
            'device_info.os_version' => 'nullable|string',
            'device_info.app_version' => 'nullable|string',
            'location' => 'nullable|array',
            'location.latitude' => 'nullable|numeric',
            'location.longitude' => 'nullable|numeric',
            'login_method' => 'nullable|string',
        ]);

        // Get company_id based on user type
        $companyId = null;
        if ($validated['user_type'] === 'employee') {
            $employee = \App\Models\Employee::find($validated['user_id']);
            $companyId = $employee?->company_id;
        }

        // Create session
        $session = LoginSession::create([
            'user_id' => $validated['user_id'],
            'user_type' => $validated['user_type'],
            'company_id' => $companyId,
            'session_token' => Str::random(64),
            'login_time' => now(),
            'status' => 'active',
            'device_type' => $validated['device_info']['type'] ?? null,
            'device_model' => $validated['device_info']['model'] ?? null,
            'device_id' => $validated['device_info']['device_id'] ?? null,
            'os_version' => $validated['device_info']['os_version'] ?? null,
            'app_version' => $validated['device_info']['app_version'] ?? null,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'login_latitude' => $validated['location']['latitude'] ?? null,
            'login_longitude' => $validated['location']['longitude'] ?? null,
            'login_method' => $validated['login_method'] ?? 'unified',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Session started successfully',
            'data' => [
                'session_id' => $session->id,
                'session_token' => $session->session_token,
            ],
        ]);
    }

    /**
     * End a login session (logout)
     */
    public function endSession(Request $request, int $sessionId): JsonResponse
    {
        $session = LoginSession::findOrFail($sessionId);

        // Verify ownership
        $user = $request->user();
        if ($session->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $session->endSession();

        return response()->json([
            'success' => true,
            'message' => 'Session ended successfully',
            'data' => [
                'session_duration' => $session->session_duration,
                'duration_formatted' => $session->duration_formatted,
            ],
        ]);
    }

    /**
     * Get my sessions (current user)
     */
    public function mySessions(Request $request): JsonResponse
    {
        $user = $request->user();
        $userType = $user instanceof \App\Models\Employee ? 'employee' : 'admin';

        $sessions = LoginSession::forUser($user->id, $userType)
            ->orderBy('login_time', 'desc')
            ->limit(50)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $sessions->map(function ($session) {
                return [
                    'id' => $session->id,
                    'login_time' => $session->login_time->format('Y-m-d H:i:s'),
                    'logout_time' => $session->logout_time?->format('Y-m-d H:i:s'),
                    'duration' => $session->session_duration,
                    'duration_formatted' => $session->duration_formatted,
                    'status' => $session->status,
                    'device_type' => $session->device_type,
                    'device_model' => $session->device_model,
                    'os_version' => $session->os_version,
                    'app_version' => $session->app_version,
                    'ip_address' => $session->ip_address,
                ];
            }),
        ]);
    }

    /**
     * Get active sessions (current user)
     */
    public function activeSessions(Request $request): JsonResponse
    {
        $user = $request->user();
        $userType = $user instanceof \App\Models\Employee ? 'employee' : 'admin';

        $sessions = LoginSession::forUser($user->id, $userType)
            ->active()
            ->orderBy('login_time', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $sessions,
        ]);
    }

    /**
     * Force logout from a specific session
     */
    public function forceLogout(Request $request, int $sessionId): JsonResponse
    {
        $session = LoginSession::findOrFail($sessionId);

        // Verify ownership
        $user = $request->user();
        if ($session->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $session->forceLogout('Logged out by user');

        return response()->json([
            'success' => true,
            'message' => 'Session terminated successfully',
        ]);
    }

    /**
     * Admin: Get all sessions
     */
    public function adminGetAllSessions(Request $request): JsonResponse
    {
        // TODO: Add admin authorization check

        $query = LoginSession::with(['employee', 'company'])
            ->orderBy('login_time', 'desc');

        // Filters
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('date_from')) {
            $query->where('login_time', '>=', $request->date_from);
        }

        $sessions = $query->paginate(50);

        return response()->json([
            'success' => true,
            'data' => $sessions,
        ]);
    }
}
```

#### 1.4 Routes

**الملف**: `routes/api.php`

```php
// Session Management Routes
Route::middleware(['auth:sanctum'])->group(function () {
    // Employee/User Session Routes
    Route::prefix('sessions')->group(function () {
        Route::post('/start', [SessionController::class, 'startSession']);
        Route::put('/{sessionId}/end', [SessionController::class, 'endSession']);
        Route::get('/my-sessions', [SessionController::class, 'mySessions']);
        Route::get('/active', [SessionController::class, 'activeSessions']);
        Route::delete('/{sessionId}/force-logout', [SessionController::class, 'forceLogout']);
    });

    // Admin Session Routes
    Route::prefix('admin/sessions')->middleware('admin')->group(function () {
        Route::get('/', [SessionController::class, 'adminGetAllSessions']);
    });
});
```

---

### المرحلة 2: Flutter

#### 2.1 إضافة Dependencies

**الملف**: `pubspec.yaml`

```yaml
dependencies:
  # ... existing dependencies
  device_info_plus: ^10.1.0
  package_info_plus: ^8.0.0
```

**تشغيل**:
```bash
flutter pub get
```

#### 2.2 إنشاء SessionService

**(سأقوم بإنشاء الملف في الخطوة التالية)**

---

## 📝 خطوات التطبيق على Backend

### على السيرفر المحلي (للاختبار):

```bash
cd D:\php_project\filament-hrm

# 1. إنشاء Migration
php artisan make:migration create_login_sessions_table

# 2. نسخ محتوى Migration من أعلاه
# 3. تشغيل Migration
php artisan migrate

# 4. إنشاء Model
php artisan make:model LoginSession

# 5. إنشاء Controller
php artisan make:controller Api/SessionController

# 6. إضافة Routes في routes/api.php

# 7. مسح الكاش
php artisan cache:clear
php artisan config:clear
```

### على سيرفر البرودكشن:

```bash
ssh root@31.97.46.103
cd /var/www/erp1

# نفس الخطوات أعلاه
# ثم:
php artisan cache:clear
php artisan config:clear
```

---

## 🧪 الاختبار

### 1. اختبار API (Postman/cURL)

```bash
# Start Session
curl -X POST https://erp1.bdcbiz.com/api/v1/sessions/start \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 32,
    "user_type": "employee",
    "device_info": {
      "type": "Android",
      "model": "Samsung Galaxy S21",
      "os_version": "Android 14",
      "app_version": "1.1.0"
    }
  }'

# Get My Sessions
curl -X GET https://erp1.bdcbiz.com/api/v1/sessions/my-sessions \
  -H "Authorization: Bearer YOUR_TOKEN"

# End Session
curl -X PUT https://erp1.bdcbiz.com/api/v1/sessions/{sessionId}/end \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ✅ Checklist

### Backend:
- [ ] Migration created and run
- [ ] LoginSession Model created
- [ ] SessionController created
- [ ] Routes added
- [ ] Tested on local backend
- [ ] Deployed to production

### Flutter:
- [ ] device_info_plus added
- [ ] package_info_plus added
- [ ] SessionService created
- [ ] SessionModel created
- [ ] Integrated with AuthCubit
- [ ] Tested login/logout flow

---

**آخر تحديث**: 2025-11-19
**الحالة**: 🚧 جاري التطبيق
