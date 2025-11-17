# HRM System - Visual ERD Diagram

## 📊 Entity Relationship Diagram (Mermaid)

```mermaid
erDiagram
    %% Core Entities
    COMPANIES ||--o{ DEPARTMENTS : "has"
    COMPANIES ||--o{ BRANCHES : "has"
    COMPANIES ||--o{ EMPLOYEES : "employs"
    COMPANIES ||--o{ WORK_PLANS : "defines"
    COMPANIES ||--o{ VACATION_TYPES : "offers"

    %% Employee Relationships
    DEPARTMENTS ||--o{ EMPLOYEES : "contains"
    BRANCHES ||--o{ EMPLOYEES : "located_at"
    WORK_PLANS ||--o{ EMPLOYEES : "assigned_to"
    EMPLOYEES ||--o{ ATTENDANCES : "records"
    EMPLOYEES ||--o{ LEAVE_REQUESTS : "submits"
    EMPLOYEES ||--o{ EMPLOYEE_VACATION_BALANCES : "has"
    EMPLOYEES ||--o{ MESSAGES : "sends"
    EMPLOYEES ||--o{ CONVERSATIONS : "participates"

    %% Attendance Module
    ATTENDANCES ||--o{ ATTENDANCE_SESSIONS : "contains"
    WORK_PLANS ||--o{ ATTENDANCES : "governs"
    BRANCHES ||--o{ ATTENDANCES : "location"

    %% Leave Management
    VACATION_TYPES ||--o{ EMPLOYEE_VACATION_BALANCES : "applies_to"
    VACATION_TYPES ||--o{ LEAVE_REQUESTS : "type_of"

    %% Chat Module
    CONVERSATIONS ||--o{ MESSAGES : "contains"

    %% Entity Definitions
    COMPANIES {
        int id PK
        string name
        string code UK
        string email
        string phone
        text address
        string logo
        boolean is_active
        json settings
        timestamp created_at
        timestamp updated_at
    }

    DEPARTMENTS {
        int id PK
        int company_id FK
        string name
        string code
        text description
        int manager_id FK
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    BRANCHES {
        int id PK
        int company_id FK
        string name
        string code
        text address
        decimal latitude
        decimal longitude
        int radius "meters"
        string phone
        string email
        int employees_count
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    WORK_PLANS {
        int id PK
        int company_id FK
        string name
        time start_time
        time end_time
        string schedule
        int permission_minutes
        boolean late_detection_enabled
        int weekly_hours
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    EMPLOYEES {
        int id PK
        int company_id FK
        int department_id FK
        int branch_id FK
        int work_plan_id FK
        string employee_id UK
        string first_name
        string last_name
        string email UK
        string phone
        string password
        string position_name
        date hire_date
        date birth_date
        string national_id
        text address
        int image_id FK
        boolean is_active
        timestamp email_verified_at
        json roles
        json permissions
        timestamp created_at
        timestamp updated_at
    }

    ATTENDANCES {
        int id PK
        int employee_id FK
        int work_plan_id FK
        int branch_id FK
        date date UK
        time check_in_time
        time check_out_time
        decimal working_hours
        decimal missing_hours
        int late_minutes
        text late_reason
        boolean has_late_reason
        text notes
        boolean is_manual
        timestamp created_at
        timestamp updated_at
    }

    ATTENDANCE_SESSIONS {
        int id PK
        int attendance_id FK
        date date
        time check_in_time
        time check_out_time
        decimal duration_hours
        string duration_label
        enum session_type
        text notes
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    VACATION_TYPES {
        int id PK
        int company_id FK
        string name
        text description
        int unlock_after_months
        int required_days_before
        boolean requires_approval
        boolean is_paid
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    EMPLOYEE_VACATION_BALANCES {
        int id PK
        int employee_id FK
        int vacation_type_id FK
        int total_days
        int used_days
        int balance
        int year
        boolean is_available
        timestamp created_at
        timestamp updated_at
    }

    LEAVE_REQUESTS {
        int id PK
        int employee_id FK
        int vacation_type_id FK
        int approver_id FK
        date start_date
        date end_date
        int total_days
        text reason
        enum status
        text admin_notes
        timestamp request_date
        timestamp approved_at
        boolean can_cancel
        timestamp created_at
        timestamp updated_at
    }

    CONVERSATIONS {
        int id PK
        int user1_id FK
        int user2_id FK
        int last_message_id FK
        timestamp created_at
        timestamp updated_at
    }

    MESSAGES {
        int id PK
        int conversation_id FK
        int sender_id FK
        int receiver_id FK
        text message
        enum message_type
        string attachment_url
        boolean is_read
        timestamp read_at
        timestamp created_at
        timestamp updated_at
    }
```

---

## 📊 Simplified Module View

```mermaid
graph TB
    subgraph "Core Module"
        A[Companies] --> B[Departments]
        A --> C[Branches]
        A --> D[Work Plans]
        B --> E[Employees]
        C --> E
        D --> E
    end

    subgraph "Attendance Module"
        E --> F[Attendances]
        F --> G[Attendance Sessions]
        D --> F
        C --> F
    end

    subgraph "Leave Management"
        A --> H[Vacation Types]
        H --> I[Employee Vacation Balances]
        H --> J[Leave Requests]
        E --> I
        E --> J
    end

    subgraph "Chat Module"
        E --> K[Conversations]
        K --> L[Messages]
        E --> L
    end

    style A fill:#e1f5ff
    style E fill:#fff9c4
    style F fill:#c8e6c9
    style H fill:#ffccbc
    style K fill:#f8bbd0
```

---

## 🔄 Data Flow Diagrams

### Attendance Check-in Flow
```mermaid
sequenceDiagram
    participant E as Employee (Mobile)
    participant A as API
    participant D as Database
    participant G as GPS Service

    E->>G: Get Current Location
    G-->>E: Return GPS Coordinates
    E->>A: POST /attendance/check-in (lat, lon)
    A->>D: Verify Branch Geofence
    D-->>A: Branch Valid
    A->>D: Check Existing Attendance
    alt First Check-in Today
        A->>D: Create Attendance Record
        A->>D: Create Session #1
    else Has Checked Out
        A->>D: Create Session #2
    end
    D-->>A: Success
    A-->>E: Check-in Successful
```

### Leave Request Flow
```mermaid
sequenceDiagram
    participant E as Employee
    participant A as API
    participant D as Database
    participant M as Manager/HR

    E->>A: POST /leave/request
    A->>D: Check Vacation Balance
    alt Balance Available
        D-->>A: Balance OK
        A->>D: Create Leave Request (status: pending)
        D-->>A: Success
        A->>M: Send Notification
        A-->>E: Request Submitted
    else No Balance
        D-->>A: Insufficient Balance
        A-->>E: Error: No Balance
    end

    M->>A: POST /leave/approve/{id}
    A->>D: Update Status (approved)
    A->>D: Deduct from Balance
    D-->>A: Success
    A->>E: Send Notification
    A-->>M: Approval Confirmed
```

---

## 📈 Database Statistics

### Table Sizes (Estimated)

| Table | Typical Row Count | Growth Rate | Index Count |
|-------|------------------|-------------|-------------|
| companies | 1-100 | Low | 1 (PK) |
| departments | 10-500 | Low | 2 (PK, FK) |
| branches | 5-200 | Low | 3 (PK, FK, GPS) |
| employees | 50-10,000 | Medium | 5 (PK, 4 FK, email) |
| attendances | 50k-1M+ | High (daily) | 4 (PK, 2 FK, date) |
| attendance_sessions | 100k-2M+ | High (daily) | 3 (PK, FK, date) |
| leave_requests | 5k-100k | Medium | 3 (PK, 2 FK) |
| messages | 10k-500k | High | 4 (PK, 2 FK, conv) |

---

## 🔐 Security Model

```mermaid
graph LR
    A[User Login] --> B{Auth Guard}
    B -->|Employee| C[Employee Token]
    B -->|Admin| D[Admin Token]
    C --> E[Company Scope]
    D --> E
    E --> F{CurrentCompanyScope}
    F --> G[Filter by company_id]
    G --> H[Query Results]
```

**Key Security Features:**
- ✅ Global Scope: All queries auto-filtered by `company_id`
- ✅ JWT Tokens: Stored securely in `flutter_secure_storage`
- ✅ Password Hashing: bcrypt
- ✅ API Rate Limiting
- ✅ CORS Protection
- ✅ Input Validation

---

## 📊 Performance Optimizations

### Indexes Strategy
```sql
-- High-traffic queries
CREATE INDEX idx_att_emp_date ON attendances(employee_id, date);
CREATE INDEX idx_att_sess_date ON attendance_sessions(attendance_id, date);
CREATE INDEX idx_msg_conv_time ON messages(conversation_id, created_at);
CREATE INDEX idx_leave_emp_status ON leave_requests(employee_id, status);

-- Geofencing queries
CREATE SPATIAL INDEX idx_branch_location ON branches(latitude, longitude);
```

### Caching Strategy
- **Employee Data**: Cache for 1 hour
- **Attendance Today**: Cache for 5 minutes
- **Vacation Balances**: Cache for 30 minutes
- **Work Plans**: Cache for 24 hours

---

## 🎯 API Endpoints Summary

### Authentication
- `POST /api/v1/auth/login` - Employee login
- `POST /api/v1/auth/admin/login` - Admin login
- `POST /api/v1/auth/logout` - Logout

### Attendance
- `GET /api/v1/employee/attendance/status` - Today's status
- `POST /api/v1/employee/attendance/check-in` - Check-in
- `POST /api/v1/employee/attendance/check-out` - Check-out
- `GET /api/v1/employee/attendance/sessions` - Today's sessions
- `GET /api/v1/employee/attendance/history` - History

### Leave Management
- `GET /api/v1/employee/leave/types` - Available vacation types
- `GET /api/v1/employee/leave/balance` - Current balance
- `POST /api/v1/employee/leave/request` - Submit leave request
- `GET /api/v1/employee/leave/history` - Request history
- `DELETE /api/v1/employee/leave/{id}` - Cancel request

### Chat (To Be Implemented)
- `GET /api/v1/chat/conversations` - Get conversations
- `POST /api/v1/chat/conversations` - Start new conversation
- `GET /api/v1/chat/conversations/{id}/messages` - Get messages
- `POST /api/v1/chat/conversations/{id}/messages` - Send message
- `PUT /api/v1/chat/conversations/{id}/read` - Mark as read

---

**Generated by:** Claude Code
**Date:** 2025-11-13
**Version:** 2.3.0

