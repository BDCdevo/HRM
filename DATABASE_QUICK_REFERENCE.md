# HRM Database - Quick Reference Guide

## 📊 السريع - الجداول الرئيسية

### 🏢 النظام الأساسي (5 جداول)
```
1. companies          → الشركات
2. departments        → الأقسام
3. branches           → الفروع (مع GPS)
4. employees          → الموظفين
5. work_plans         → خطط العمل
```

### 📅 نظام الحضور (2 جداول)
```
6. attendances        → الحضور اليومي (1 record/day/employee)
7. attendance_sessions → جلسات متعددة (Multiple check-in/out)
```

### 🏖️ نظام الإجازات (3 جداول)
```
8. vacation_types              → أنواع الإجازات
9. employee_vacation_balances  → الرصيد
10. leave_requests             → الطلبات
```

### 💬 نظام المحادثات (2 جداول)
```
11. conversations    → المحادثات الثنائية
12. messages         → الرسائل
```

### 📁 الداعمة (3 جداول)
```
13. media                  → الملفات والصور
14. notifications          → الإشعارات
15. personal_access_tokens → JWT Tokens
```

---

## 🔗 العلاقات الأساسية

```
companies (1) → (N) departments
companies (1) → (N) branches
companies (1) → (N) employees
companies (1) → (N) work_plans
companies (1) → (N) vacation_types

departments (1) → (N) employees
branches (1) → (N) employees
work_plans (1) → (N) employees

employees (1) → (N) attendances
attendances (1) → (N) attendance_sessions

employees (1) → (N) leave_requests
vacation_types (1) → (N) leave_requests

employees (1) → (N) conversations
conversations (1) → (N) messages
```

---

## 📋 أمثلة Queries الشائعة

### 1. Get Employee with Relations
```sql
SELECT e.*,
       d.name as department_name,
       b.name as branch_name,
       w.name as work_plan_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
LEFT JOIN branches b ON e.branch_id = b.id
LEFT JOIN work_plans w ON e.work_plan_id = w.id
WHERE e.company_id = 6
  AND e.id = 49;
```

### 2. Today's Attendance Status
```sql
SELECT a.*,
       COUNT(s.id) as total_sessions,
       SUM(CASE WHEN s.check_out_time IS NULL THEN 1 ELSE 0 END) as active_sessions
FROM attendances a
LEFT JOIN attendance_sessions s ON a.id = s.attendance_id
WHERE a.employee_id = 49
  AND a.date = CURDATE()
GROUP BY a.id;
```

### 3. Get Vacation Balances
```sql
SELECT vt.name,
       evb.total_days,
       evb.used_days,
       (evb.total_days - evb.used_days) as balance
FROM employee_vacation_balances evb
JOIN vacation_types vt ON evb.vacation_type_id = vt.id
WHERE evb.employee_id = 49
  AND evb.year = YEAR(CURDATE());
```

### 4. Leave Requests History
```sql
SELECT lr.*,
       vt.name as vacation_type_name,
       e.first_name, e.last_name
FROM leave_requests lr
JOIN vacation_types vt ON lr.vacation_type_id = vt.id
JOIN employees e ON lr.approver_id = e.id
WHERE lr.employee_id = 49
ORDER BY lr.created_at DESC
LIMIT 10;
```

### 5. Conversations with Unread Count
```sql
SELECT c.*,
       e.first_name, e.last_name,
       COUNT(CASE WHEN m.is_read = 0 AND m.receiver_id = 49 THEN 1 END) as unread_count
FROM conversations c
JOIN employees e ON (c.user1_id = 49 AND e.id = c.user2_id)
                 OR (c.user2_id = 49 AND e.id = c.user1_id)
LEFT JOIN messages m ON c.id = m.conversation_id
WHERE c.user1_id = 49 OR c.user2_id = 49
GROUP BY c.id
ORDER BY c.updated_at DESC;
```

---

## 🎯 Business Rules

### Attendance Rules
```
1. One attendance record per day per employee
2. Multiple sessions allowed (check-in/check-out cycles)
3. Geofencing: Must be within branch radius
4. Late detection: Based on work_plan.start_time + permission_minutes
5. Late reason required if late_minutes > 0
```

### Leave Request Rules
```
1. Must have available balance
2. Status flow: pending → approved/rejected → cancelled
3. Can cancel: Only if status=pending/approved AND start_date > today
4. Notice period: vacation_type.required_days_before
5. Approval required: vacation_type.requires_approval
```

### Chat Rules
```
1. Conversations are 1-to-1 only
2. UNIQUE(user1_id, user2_id)
3. Message types: text, image, file, voice
4. Mark as read: Update is_read + read_at
```

---

## 🔐 Multi-Tenancy

### Global Scope (Laravel)
```php
// All queries automatically filtered
protected static function booted()
{
    static::addGlobalScope(new CurrentCompanyScope);
}

// Set session company
session(['current_company_id' => $employee->company_id]);
```

### Example with Scope
```php
// ❌ Without scope (error)
Employee::find(49);

// ✅ With scope (auto-filtered)
session(['current_company_id' => 6]);
Employee::find(49); // Returns only if company_id = 6
```

---

## 📊 Status Enums

### Leave Request Status
```
- pending    → في الانتظار
- approved   → موافق عليها
- rejected   → مرفوضة
- cancelled  → ملغاة
```

### Attendance Session Type
```
- regular    → عادية
- overtime   → إضافية
- break      → استراحة
```

### Message Type
```
- text       → نص
- image      → صورة
- file       → ملف
- voice      → رسالة صوتية
```

---

## 📈 Performance Tips

### Indexes
```sql
-- Most important indexes
CREATE INDEX idx_attendances_emp_date ON attendances(employee_id, date);
CREATE INDEX idx_sessions_attendance ON attendance_sessions(attendance_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_leave_requests_emp_status ON leave_requests(employee_id, status);
```

### Caching Strategy
```php
// Cache vacation balances (rarely change)
Cache::remember("vacation_balance_{$employeeId}_{$year}", 3600, function() {
    // Query...
});

// Cache today's attendance (refresh frequently)
Cache::remember("attendance_today_{$employeeId}", 300, function() {
    // Query...
});
```

---

## 🚀 API Endpoints Summary

### Base URL
```
Production: https://erp1.bdcbiz.com/api/v1
Local Dev:  http://localhost:8000/api/v1
```

### Headers
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
```

### Key Endpoints
```
POST   /auth/login                          # Login
GET    /dashboard/stats                     # Dashboard data
GET    /employee/attendance/status          # Today status
POST   /employee/attendance/check-in        # Check-in
POST   /employee/attendance/check-out       # Check-out
GET    /employee/attendance/sessions        # Today sessions
GET    /employee/leave/types                # Vacation types
GET    /employee/leave/balance              # Current balance
POST   /employee/leave/request              # Submit request
GET    /employee/leave/history              # History
GET    /chat/conversations                  # Conversations (To Be Implemented)
```

---

## 💾 Backup & Migration

### Backup Tables (Priority Order)
```
1. employees             → Critical
2. attendances           → Critical
3. attendance_sessions   → Critical
4. leave_requests        → High
5. employee_vacation_balances → High
6. messages              → Medium
7. conversations         → Medium
8. companies             → Low (rarely changes)
9. departments           → Low
10. branches             → Low
```

### Migration Strategy
```bash
# Export schema
mysqldump -u root -p --no-data erp1 > schema.sql

# Export data (with company filter)
mysqldump -u root -p erp1 employees \
  --where="company_id=6" > employees_company_6.sql

# Import to new environment
mysql -u root -p erp1 < schema.sql
mysql -u root -p erp1 < employees_company_6.sql
```

---

## 🔍 Troubleshooting

### Common Issues

1. **CurrentCompanyScope Error**
```php
// Problem: No company_id in session
// Solution:
session(['current_company_id' => $employee->company_id]);
```

2. **Attendance Sessions Not Showing**
```sql
-- Check if sessions exist
SELECT * FROM attendance_sessions
WHERE attendance_id = 123;

-- Check if attendance exists
SELECT * FROM attendances
WHERE employee_id = 49 AND date = CURDATE();
```

3. **Leave Balance Not Updating**
```php
// After approving leave request, deduct from balance
$balance->used_days += $request->total_days;
$balance->save();
```

---

## 📊 Data Integrity Checks

```sql
-- Check orphaned sessions (no parent attendance)
SELECT s.* FROM attendance_sessions s
LEFT JOIN attendances a ON s.attendance_id = a.id
WHERE a.id IS NULL;

-- Check invalid employee references
SELECT e.* FROM employees e
WHERE e.company_id NOT IN (SELECT id FROM companies);

-- Check balance consistency
SELECT evb.*,
       (evb.total_days - evb.used_days) as calculated_balance
FROM employee_vacation_balances evb
WHERE evb.balance != (evb.total_days - evb.used_days);
```

---

**Quick Access Files:**
- 📄 Full ERD: `DATABASE_ERD.md`
- 🎨 Visual Diagrams: `DATABASE_ERD_DIAGRAM.md`
- ⚡ This Guide: `DATABASE_QUICK_REFERENCE.md`

**Generated:** 2025-11-13
**Version:** 2.3.0

