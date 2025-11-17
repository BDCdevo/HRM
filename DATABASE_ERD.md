# HRM System - Entity Relationship Diagram (ERD)

## تاريخ الإنشاء: 2025-11-13
## الإصدار: 2.3.0

---

## 📊 Database Schema Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         HRM System Database Schema                          │
│                        (Multi-Tenant Architecture)                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏢 Core Entities

### 1. **companies** (الشركات)
```
┌─────────────────────────────────┐
│          companies              │
├─────────────────────────────────┤
│ PK  id                 INT      │
│     name               VARCHAR  │
│     code               VARCHAR  │ UNIQUE
│     email              VARCHAR  │
│     phone              VARCHAR  │
│     address            TEXT     │
│     logo               VARCHAR  │
│     is_active          BOOLEAN  │
│     settings           JSON     │
│     created_at         TIMESTAMP│
│     updated_at         TIMESTAMP│
└─────────────────────────────────┘
```

**العلاقات:**
- `1:N` → departments
- `1:N` → branches
- `1:N` → employees
- `1:N` → vacation_types
- `1:N` → work_plans

**الوصف:** جدول الشركات - يدعم Multi-tenancy حيث كل شركة لها بياناتها المستقلة

---

### 2. **departments** (الأقسام)
```
┌─────────────────────────────────┐
│         departments             │
├─────────────────────────────────┤
│ PK  id                 INT      │
│ FK  company_id         INT      │ → companies(id)
│     name               VARCHAR  │
│     code               VARCHAR  │
│     description        TEXT     │
│     manager_id         INT      │ (FK → employees)
│     is_active          BOOLEAN  │
│     created_at         TIMESTAMP│
│     updated_at         TIMESTAMP│
└─────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← companies
- `1:N` → employees
- `1:1` → employees (manager)

**الوصف:** أقسام الشركة (مثل: التطوير، الموارد البشرية، المالية)

---

### 3. **branches** (الفروع)
```
┌─────────────────────────────────┐
│           branches              │
├─────────────────────────────────┤
│ PK  id                 INT      │
│ FK  company_id         INT      │ → companies(id)
│     name               VARCHAR  │
│     code               VARCHAR  │
│     address            TEXT     │
│     latitude           DECIMAL  │ (GPS)
│     longitude          DECIMAL  │ (GPS)
│     radius             INT      │ (meters for geofencing)
│     phone              VARCHAR  │
│     email              VARCHAR  │
│     employees_count    INT      │ (calculated)
│     is_active          BOOLEAN  │
│     created_at         TIMESTAMP│
│     updated_at         TIMESTAMP│
└─────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← companies
- `1:N` → employees
- `1:N` → attendances (via geofencing)

**الوصف:** فروع الشركة مع دعم Geofencing للحضور

---

### 4. **employees** (الموظفين)
```
┌─────────────────────────────────────────┐
│             employees                   │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  company_id             INT          │ → companies(id)
│ FK  department_id          INT          │ → departments(id)
│ FK  branch_id              INT          │ → branches(id)
│ FK  work_plan_id           INT          │ → work_plans(id)
│     employee_id            VARCHAR      │ UNIQUE (e.g., EMP0022)
│     first_name             VARCHAR      │
│     last_name              VARCHAR      │
│     email                  VARCHAR      │ UNIQUE
│     phone                  VARCHAR      │
│     password               VARCHAR      │ (hashed)
│     position_name          VARCHAR      │
│     hire_date              DATE         │
│     birth_date             DATE         │
│     national_id            VARCHAR      │
│     address                TEXT         │
│     image_id               INT          │ (FK → media)
│     is_active              BOOLEAN      │
│     email_verified_at      TIMESTAMP    │
│     roles                  JSON         │ [admin, hr, manager, employee]
│     permissions            JSON         │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← companies
- `N:1` ← departments
- `N:1` ← branches
- `N:1` ← work_plans
- `1:N` → attendances
- `1:N` → attendance_sessions
- `1:N` → leave_requests
- `1:N` → employee_vacation_balances
- `1:N` → conversations (sent)
- `1:N` → conversations (received)
- `1:N` → messages

**الوصف:** بيانات الموظفين الأساسية مع الأدوار والصلاحيات

---

## 📅 Attendance Module (نظام الحضور)

### 5. **work_plans** (خطط العمل)
```
┌─────────────────────────────────────────┐
│            work_plans                   │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  company_id             INT          │ → companies(id)
│     name                   VARCHAR      │
│     start_time             TIME         │ (e.g., 09:00)
│     end_time               TIME         │ (e.g., 17:00)
│     schedule               VARCHAR      │ (display: "09:00 - 17:00")
│     permission_minutes     INT          │ (grace period)
│     late_detection_enabled BOOLEAN      │
│     weekly_hours           INT          │
│     is_active              BOOLEAN      │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← companies
- `1:N` → employees
- `1:N` → attendances

**الوصف:** خطط العمل (مثل: 8 ساعات/يوم، Flexible Hours)

---

### 6. **attendances** (سجلات الحضور اليومية)
```
┌─────────────────────────────────────────┐
│            attendances                  │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  employee_id            INT          │ → employees(id)
│ FK  work_plan_id           INT          │ → work_plans(id)
│ FK  branch_id              INT          │ → branches(id)
│     date                   DATE         │ UNIQUE(employee_id, date)
│     check_in_time          TIME         │
│     check_out_time         TIME         │
│     working_hours          DECIMAL      │ (calculated)
│     missing_hours          DECIMAL      │ (calculated)
│     late_minutes           INT          │
│     late_reason            TEXT         │
│     has_late_reason        BOOLEAN      │
│     notes                  TEXT         │
│     is_manual              BOOLEAN      │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← employees
- `N:1` ← work_plans
- `N:1` ← branches
- `1:N` → attendance_sessions

**الوصف:** سجل الحضور اليومي لكل موظف (يوم واحد = سجل واحد)

**Note:** يدعم Multiple Sessions عبر جدول `attendance_sessions`

---

### 7. **attendance_sessions** (جلسات الحضور المتعددة) ⭐ NEW
```
┌─────────────────────────────────────────┐
│        attendance_sessions              │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  attendance_id          INT          │ → attendances(id)
│     date                   DATE         │
│     check_in_time          TIME         │
│     check_out_time         TIME         │
│     duration_hours         DECIMAL      │
│     duration_label         VARCHAR      │ (e.g., "2h 30m")
│     session_type           ENUM         │ [regular, overtime, break]
│     notes                  TEXT         │
│     is_active              BOOLEAN      │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← attendances

**الوصف:** جلسات Check-in/Check-out المتعددة في نفس اليوم

**Use Case:**
```
يوم واحد → attendance واحد → sessions متعددة
- Session 1: 09:00 → 12:00 (3h)
- Session 2: 13:00 → 17:00 (4h)
- Total: 7h working
```

---

## 🏖️ Leave Management Module (نظام الإجازات)

### 8. **vacation_types** (أنواع الإجازات)
```
┌─────────────────────────────────────────┐
│          vacation_types                 │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  company_id             INT          │ → companies(id)
│     name                   VARCHAR      │
│     description            TEXT         │
│     unlock_after_months    INT          │
│     required_days_before   INT          │ (notice period)
│     requires_approval      BOOLEAN      │
│     is_paid                BOOLEAN      │
│     is_active              BOOLEAN      │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← companies
- `1:N` → employee_vacation_balances
- `1:N` → leave_requests

**الوصف:** أنواع الإجازات (سنوية، مرضية، زواج، إلخ)

**Egyptian Law Examples:**
- إجازة سنوية (21 يوم)
- إجازة مرضية (180 يوم)
- إجازة وضع (90 يوم)
- إجازة زواج (3 أيام)

---

### 9. **employee_vacation_balances** (رصيد الإجازات)
```
┌─────────────────────────────────────────┐
│     employee_vacation_balances          │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  employee_id            INT          │ → employees(id)
│ FK  vacation_type_id       INT          │ → vacation_types(id)
│     total_days             INT          │
│     used_days              INT          │
│     balance                INT          │ (calculated: total - used)
│     year                   INT          │
│     is_available           BOOLEAN      │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
│                                         │
│ UNIQUE(employee_id, vacation_type_id, year)│
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← employees
- `N:1` ← vacation_types

**الوصف:** رصيد الإجازات لكل موظف حسب النوع والسنة

---

### 10. **leave_requests** (طلبات الإجازات)
```
┌─────────────────────────────────────────┐
│           leave_requests                │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  employee_id            INT          │ → employees(id)
│ FK  vacation_type_id       INT          │ → vacation_types(id)
│ FK  approver_id            INT          │ → employees(id)
│     start_date             DATE         │
│     end_date               DATE         │
│     total_days             INT          │ (duration_days)
│     reason                 TEXT         │
│     status                 ENUM         │ [pending, approved, rejected, cancelled]
│     admin_notes            TEXT         │
│     request_date           TIMESTAMP    │
│     approved_at            TIMESTAMP    │
│     can_cancel             BOOLEAN      │ (calculated)
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← employees (requester)
- `N:1` ← vacation_types
- `N:1` ← employees (approver)

**الوصف:** طلبات الإجازات من الموظفين مع سير العمل (Workflow)

**Status Flow:**
```
pending → approved → (can_cancel if not started)
        ↓
        rejected
        ↓
        cancelled
```

---

## 💬 Chat Module (نظام المحادثات) ⭐ NEW

### 11. **conversations** (المحادثات)
```
┌─────────────────────────────────────────┐
│           conversations                 │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  user1_id               INT          │ → employees(id)
│ FK  user2_id               INT          │ → employees(id)
│     last_message_id        INT          │ → messages(id)
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
│                                         │
│ UNIQUE(user1_id, user2_id)             │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← employees (user1)
- `N:1` ← employees (user2)
- `1:N` → messages

**الوصف:** محادثات ثنائية بين الموظفين (WhatsApp-style)

---

### 12. **messages** (الرسائل)
```
┌─────────────────────────────────────────┐
│              messages                   │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│ FK  conversation_id        INT          │ → conversations(id)
│ FK  sender_id              INT          │ → employees(id)
│ FK  receiver_id            INT          │ → employees(id)
│     message                TEXT         │
│     message_type           ENUM         │ [text, image, file, voice]
│     attachment_url         VARCHAR      │
│     is_read                BOOLEAN      │
│     read_at                TIMESTAMP    │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**العلاقات:**
- `N:1` ← conversations
- `N:1` ← employees (sender)
- `N:1` ← employees (receiver)

**الوصف:** رسائل المحادثات مع دعم النصوص والملفات والصور

---

## 📊 Supporting Entities

### 13. **media** (الملفات والصور)
```
┌─────────────────────────────────┐
│             media               │
├─────────────────────────────────┤
│ PK  id                 INT      │
│     model_type         VARCHAR  │ (polymorphic)
│     model_id           INT      │ (polymorphic)
│     collection_name    VARCHAR  │
│     name               VARCHAR  │
│     file_name          VARCHAR  │
│     mime_type          VARCHAR  │
│     disk               VARCHAR  │
│     url                VARCHAR  │
│     size               BIGINT   │
│     created_at         TIMESTAMP│
│     updated_at         TIMESTAMP│
└─────────────────────────────────┘
```

**الوصف:** مكتبة الملفات (صور الموظفين، مرفقات المحادثات، إلخ)

---

### 14. **notifications** (الإشعارات)
```
┌─────────────────────────────────────────┐
│           notifications                 │
├─────────────────────────────────────────┤
│ PK  id                     UUID         │
│     type                   VARCHAR      │
│ FK  notifiable_id          INT          │ → employees(id)
│     notifiable_type        VARCHAR      │
│     data                   JSON         │
│     read_at                TIMESTAMP    │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**الوصف:** نظام الإشعارات (Laravel Notifications)

---

### 15. **personal_access_tokens** (API Tokens)
```
┌─────────────────────────────────────────┐
│       personal_access_tokens            │
├─────────────────────────────────────────┤
│ PK  id                     INT          │
│     tokenable_type         VARCHAR      │
│     tokenable_id           INT          │
│     name                   VARCHAR      │
│     token                  VARCHAR(64)  │ UNIQUE (hashed)
│     abilities              JSON         │
│     last_used_at           TIMESTAMP    │
│     expires_at             TIMESTAMP    │
│     created_at             TIMESTAMP    │
│     updated_at             TIMESTAMP    │
└─────────────────────────────────────────┘
```

**الوصف:** JWT tokens للمصادقة (Laravel Sanctum)

---

## 🔗 Complete Relationship Diagram

```
                    ┌──────────────┐
                    │  companies   │
                    └──────┬───────┘
                           │
         ┌─────────────────┼─────────────────┬──────────────────┐
         │                 │                 │                  │
         ▼                 ▼                 ▼                  ▼
  ┌────────────┐    ┌────────────┐   ┌────────────┐    ┌──────────────┐
  │departments │    │  branches  │   │work_plans  │    │vacation_types│
  └─────┬──────┘    └─────┬──────┘   └─────┬──────┘    └──────┬───────┘
        │                 │                 │                  │
        └────────┬────────┴─────────────────┘                  │
                 │                                             │
                 ▼                                             │
          ┌────────────┐                                       │
          │ employees  │◄──────────────────────────────────────┘
          └──────┬─────┘
                 │
     ┌───────────┼───────────┬─────────────┬────────────────┐
     │           │           │             │                │
     ▼           ▼           ▼             ▼                ▼
┌──────────┐ ┌────────┐ ┌─────────┐ ┌──────────────┐ ┌──────────────┐
│attendances│ │messages│ │leave_   │ │employee_     │ │conversations │
│          │ │        │ │requests │ │vacation_     │ │              │
└────┬─────┘ └────────┘ └─────────┘ │balances      │ └──────────────┘
     │                               └──────────────┘
     ▼
┌────────────────────┐
│attendance_sessions │
└────────────────────┘
```

---

## 📈 Key Features

### 1. **Multi-Tenancy Support**
- كل جدول رئيسي يحتوي على `company_id`
- التصفية التلقائية بـ `CurrentCompanyScope`
- عزل بيانات كل شركة بشكل كامل

### 2. **Multiple Attendance Sessions**
- موظف يمكنه Check-in/Check-out عدة مرات في اليوم
- `attendances`: سجل يومي واحد
- `attendance_sessions`: جلسات متعددة

### 3. **Geofencing for Attendance**
- كل `branch` له إحداثيات GPS و `radius`
- التطبيق يتحقق من الموقع قبل Check-in

### 4. **Leave Management Workflow**
```
Request → Pending → Approval Flow → Approved/Rejected
                  ↓
              Can Cancel (if not started)
```

### 5. **Chat System**
- محادثات ثنائية فقط (1-to-1)
- دعم الرسائل النصية والملفات
- WhatsApp-style UI

---

## 🔐 Security & Multi-Tenancy

### Company Scope Implementation
```php
// Every model automatically scoped by company_id
protected static function booted()
{
    static::addGlobalScope(new CurrentCompanyScope);
}
```

### Authentication
- **Laravel Sanctum**: Personal Access Tokens
- **Guards**: `employee`, `admin`
- **JWT Token**: Stored in `flutter_secure_storage`

---

## 📊 Indexes & Performance

### Recommended Indexes:
```sql
-- Primary Keys (auto-indexed)
-- Foreign Keys
CREATE INDEX idx_employees_company ON employees(company_id);
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_attendances_employee_date ON attendances(employee_id, date);
CREATE INDEX idx_leave_requests_employee ON leave_requests(employee_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);

-- Unique Constraints
UNIQUE(employee_id, date) ON attendances;
UNIQUE(employee_id, vacation_type_id, year) ON employee_vacation_balances;
UNIQUE(user1_id, user2_id) ON conversations;
```

---

## 📝 Notes

1. **Backend**: Laravel 12.37.0 + Filament Admin Panel
2. **Frontend**: Flutter 3.9.2+
3. **Database**: MySQL
4. **Production**: `https://erp1.bdcbiz.com`
5. **Multi-Tenancy**: Company-based isolation
6. **API Version**: v1 (`/api/v1/...`)

---

## 🎯 Future Enhancements

- [ ] Add `tasks` table for task management
- [ ] Add `reports` table for saved reports
- [ ] Add `documents` table for employee documents
- [ ] Add `payroll` module
- [ ] Add `performance_reviews` module
- [ ] Group chat support (1-to-many conversations)
- [ ] Real-time chat with WebSockets/Pusher

---

**Generated by:** Claude Code
**Date:** 2025-11-13
**Version:** 2.3.0

