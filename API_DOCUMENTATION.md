# 📚 API Documentation - FilamentHRM System

**Version:** 1.0
**Base URL:** `http://localhost:8000/api/v1`
**Authentication:** Laravel Sanctum (Bearer Token)

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Authentication](#authentication)
3. [Response Format](#response-format)
4. [Error Handling](#error-handling)
5. [Rate Limiting](#rate-limiting)
6. [Endpoints](#endpoints)
   - [Authentication](#auth-endpoints)
   - [User Profile](#profile-endpoints)
   - [Departments](#department-endpoints)
   - [Employee Attendance](#attendance-endpoints)
7. [Status Codes](#status-codes)
8. [Examples](#examples)

---

## 🔰 Introduction

FilamentHRM API provides a comprehensive RESTful interface for managing human resources operations including employee management, attendance tracking, leave requests, recruitment, and more.

### Key Features
- 🔐 Secure authentication with Laravel Sanctum
- 📊 Structured JSON responses
- 🚦 Rate limiting protection
- 🌍 Multi-language support (Arabic/English)
- 📱 Mobile-friendly endpoints

---

## 🔐 Authentication

### Authentication Flow

The API uses **Laravel Sanctum** for token-based authentication.

#### 1. Login to get Access Token
#### 2. Include token in subsequent requests:
```
Authorization: Bearer {your_access_token}
```

#### Guards Available:
- `api` - For general API users
- `employee` - For employee panel
- `admin` - For admin panel

---

## 📬 Response Format

### Success Response

```json
{
    "data": {
        // Response data here
    },
    "message": "Success message",
    "status": 200
}
```

### Error Response

```json
{
    "message": "Error message",
    "errors": {
        "field_name": [
            "Validation error message"
        ]
    },
    "status": 422
}
```

### Paginated Response

```json
{
    "data": [...],
    "meta": {
        "current_page": 1,
        "total": 100,
        "per_page": 15,
        "last_page": 7
    },
    "links": {
        "first": "...",
        "last": "...",
        "prev": null,
        "next": "..."
    }
}
```

---

## ⚠️ Error Handling

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid request data |
| 401 | Unauthorized - Missing or invalid authentication |
| 403 | Forbidden - Authenticated but not authorized |
| 404 | Not Found - Resource doesn't exist |
| 422 | Unprocessable Entity - Validation failed |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server-side error |

---

## 🚦 Rate Limiting

### Rate Limit Groups

| Limiter | Limit | Duration |
|---------|-------|----------|
| `global` | 1000 requests | Per minute |
| `auth` | 10 requests | Per minute |
| `otp` | 5 requests | Per minute |
| `upload` | 10 requests | Per minute |
| `post_data` | 5 requests | Per minute |
| `job_application` | Custom | Per application |

### Rate Limit Headers

```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 9
Retry-After: 60
```

---

## 📡 Endpoints

<a name="auth-endpoints"></a>
## 🔑 Authentication Endpoints

### 1. Login

**Endpoint:** `POST /api/v1/auth/login`
**Rate Limit:** `throttle:auth` (10/min)
**Authentication:** Not Required

#### Request Body

```json
{
    "identifier": "user@example.com",  // Email or username
    "password": "password123"
}
```

#### Validation Rules

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| identifier | string | Yes | Email or username (3-30 chars) |
| password | string | Yes | Min 8 characters |

#### Success Response (200)

```json
{
    "data": {
        "id": 1,
        "first_name": "John",
        "last_name": "Doe",
        "username": "johndoe",
        "email": "john@example.com",
        "bio": "Software Developer",
        "is_verified": true,
        "complete_profile_step": 5,
        "is_completed_profile": true,
        "birthdate": "01-01-1990",
        "user_type": "user",
        "access_token": "1|abc123xyz...",
        "image": {
            "id": 1,
            "url": "https://...",
            "file_name": "avatar.jpg",
            "mime_type": "image/jpeg",
            "size": 102400
        },
        "nationality_id": 1,
        "experience_years": 5,
        "available_balance": 150.50
    },
    "status": 200
}
```

#### Error Responses

**401 - Invalid Credentials**
```json
{
    "message": "Invalid credentials",
    "errors": [],
    "status": 401
}
```

**422 - Validation Error**
```json
{
    "message": "The given data was invalid",
    "errors": {
        "identifier": ["The identifier field is required."],
        "password": ["The password must be at least 8 characters."]
    },
    "status": 422
}
```

---

### 2. Logout

**Endpoint:** `POST /api/v1/auth/logout`
**Authentication:** Required
**Headers:** `Authorization: Bearer {token}`

#### Request Body

No body required

#### Success Response (200)

```json
{
    "data": null,
    "message": "Logged out successfully",
    "status": 200
}
```

---

### 3. Reset Password

**Endpoint:** `POST /api/v1/auth/reset-password`
**Rate Limit:** `throttle:auth` (10/min)
**Authentication:** Not Required

#### Request Body

```json
{
    "email": "user@example.com",
    "token": "reset_token_here",
    "password": "newpassword123",
    "password_confirmation": "newpassword123"
}
```

#### Validation Rules

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| email | string | Yes | Valid email |
| token | string | Yes | Valid reset token |
| password | string | Yes | Min 8 chars, confirmed |
| password_confirmation | string | Yes | Must match password |

#### Success Response (200)

```json
{
    "data": null,
    "message": "Password reset successfully",
    "status": 200
}
```

---

### 4. Check User

**Endpoint:** `POST /api/v1/auth/check-user`
**Rate Limit:** `throttle:auth` (10/min)
**Authentication:** Not Required

Verify if user exists and create verification token.

#### Request Body

```json
{
    "identifier": "user@example.com"  // Email or username
}
```

#### Success Response (200)

```json
{
    "data": {
        "token": "verification_token_here"
    },
    "message": "User verification token created successfully",
    "status": 200
}
```

---

### 5. Send OTP

**Endpoint:** `POST /api/v1/auth/send-otp`
**Rate Limit:** `throttle:otp` (5/min)
**Authentication:** Not Required

Send One-Time Password to user's email or phone.

#### Request Body

```json
{
    "identifier": "user@example.com",  // Email or phone
    "type": "email"  // "email" or "sms"
}
```

#### Success Response (200)

```json
{
    "data": {
        "sent": true,
        "expires_at": "2025-11-02T12:00:00Z"
    },
    "message": "OTP sent successfully",
    "status": 200
}
```

---

### 6. Verify OTP

**Endpoint:** `POST /api/v1/auth/verify-otp`
**Rate Limit:** `throttle:otp` (5/min)
**Authentication:** Not Required

#### Request Body

```json
{
    "identifier": "user@example.com",
    "otp": "123456"
}
```

#### Success Response (200)

```json
{
    "data": {
        "verified": true,
        "token": "access_token_here"
    },
    "message": "OTP verified successfully",
    "status": 200
}
```

---

<a name="profile-endpoints"></a>
## 👤 User Profile Endpoints

### 1. Get Profile

**Endpoint:** `GET /api/v1/profile`
**Authentication:** Required
**Headers:** `Authorization: Bearer {token}`

#### Success Response (200)

```json
{
    "data": {
        "id": 1,
        "first_name": "John",
        "last_name": "Doe",
        "username": "johndoe",
        "email": "john@example.com",
        "bio": "Software Developer",
        "is_verified": true,
        "complete_profile_step": 5,
        "is_completed_profile": true,
        "birthdate": "01-01-1990",
        "user_type": "user",
        "image": {
            "url": "https://...",
            "file_name": "avatar.jpg"
        },
        "nationality_id": 1,
        "experience_years": 5,
        "available_balance": 150.50
    },
    "status": 200
}
```

---

### 2. Update Profile

**Endpoint:** `PUT /api/v1/profile`
**Authentication:** Required
**Rate Limit:** `throttle:post_data` (5/min)

#### Request Body

```json
{
    "first_name": "John",
    "last_name": "Doe",
    "username": "johndoe",
    "bio": "Senior Software Developer",
    "birthdate": "1990-01-01",
    "nationality_id": 1,
    "experience_years": 6
}
```

#### Validation Rules

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| first_name | string | No | Max 255 chars |
| last_name | string | No | Max 255 chars |
| username | string | No | Unique, alphanumeric, 3-30 chars |
| bio | string | No | Max 500 chars |
| birthdate | date | No | Valid date, Y-m-d format |
| nationality_id | integer | No | Exists in nationalities table |
| experience_years | integer | No | Min 0, max 50 |

#### Success Response (200)

```json
{
    "data": {
        // Updated profile data
    },
    "message": "Profile updated successfully",
    "status": 200
}
```

---

### 3. Change Password

**Endpoint:** `POST /api/v1/profile/change-password`
**Authentication:** Required
**Rate Limit:** `throttle:post_data` (5/min)

#### Request Body

```json
{
    "current_password": "oldpassword123",
    "password": "newpassword123",
    "password_confirmation": "newpassword123"
}
```

#### Validation Rules

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| current_password | string | Yes | Must match current |
| password | string | Yes | Min 8 chars, confirmed |
| password_confirmation | string | Yes | Must match password |

#### Success Response (200)

```json
{
    "data": null,
    "message": "Password updated successfully",
    "status": 200
}
```

#### Error Response (400)

```json
{
    "message": "Current password is incorrect",
    "errors": [],
    "status": 400
}
```

---

### 4. Delete Account

**Endpoint:** `DELETE /api/v1/profile`
**Authentication:** Required

#### Success Response (200)

```json
{
    "data": null,
    "message": "Account deleted successfully",
    "status": 200
}
```

---

<a name="department-endpoints"></a>
## 🏢 Department Endpoints

### 1. List Departments

**Endpoint:** `GET /api/v1/departments`
**Authentication:** Not Required

Retrieve all active departments.

#### Query Parameters

None

#### Success Response (200)

```json
{
    "data": [
        {
            "id": 1,
            "name": "Engineering"
        },
        {
            "id": 2,
            "name": "Human Resources"
        },
        {
            "id": 3,
            "name": "Sales & Marketing"
        }
    ],
    "status": 200
}
```

---

### 2. Get Department Positions

**Endpoint:** `GET /api/v1/departments/{departmentId}/positions`
**Authentication:** Not Required

Retrieve all active positions within a specific department.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| departmentId | integer | Department ID |

#### Success Response (200)

```json
{
    "data": [
        {
            "id": 1,
            "name": "Software Engineer"
        },
        {
            "id": 2,
            "name": "Senior Developer"
        },
        {
            "id": 3,
            "name": "Team Lead"
        }
    ],
    "status": 200
}
```

#### Error Response (404)

```json
{
    "message": "Department not found",
    "errors": [],
    "status": 404
}
```

---

<a name="attendance-endpoints"></a>
## ⏰ Employee Attendance Endpoints

### 1. Get Real-time Attendance Duration

**Endpoint:** `GET /employee/attendance/duration`
**Authentication:** Required (Employee Guard)
**Headers:** `Authorization: Bearer {employee_token}`

Get real-time working duration for currently checked-in employee.

#### Success Response (200)

```json
{
    "data": {
        "is_checked_in": true,
        "check_in_time": "2025-11-02 09:00:00",
        "current_duration": "3:45:30",
        "duration_seconds": 13530,
        "work_plan": {
            "name": "Standard Office Hours",
            "start_time": "09:00",
            "end_time": "17:00",
            "expected_duration": "8:00:00"
        }
    },
    "status": 200
}
```

**When Not Checked In:**

```json
{
    "data": {
        "is_checked_in": false,
        "last_checkout": "2025-11-01 17:30:00",
        "total_hours_yesterday": "8:15:00"
    },
    "status": 200
}
```

---

## 📊 Common Endpoints

### 1. Upload File

**Endpoint:** `POST /api/v1/upload`
**Authentication:** Required
**Rate Limit:** `throttle:upload` (10/min)
**Content-Type:** `multipart/form-data`

#### Request Body (Form Data)

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| file | file | Yes | Max 10MB, Types: jpg,png,pdf,doc,docx |
| type | string | No | File category/type identifier |

#### Success Response (200)

```json
{
    "data": {
        "id": 123,
        "url": "https://storage.../files/document.pdf",
        "file_name": "document.pdf",
        "mime_type": "application/pdf",
        "size": 204800,
        "uploaded_at": "2025-11-02T12:30:00Z"
    },
    "message": "File uploaded successfully",
    "status": 200
}
```

---

### 2. Get Configuration

**Endpoint:** `GET /api/v1/configurations`
**Authentication:** Not Required

Get application configurations and settings.

#### Success Response (200)

```json
{
    "data": {
        "app_name": "FilamentHRM",
        "version": "1.0.0",
        "supported_languages": ["en", "ar"],
        "default_language": "en",
        "features": {
            "otp_enabled": true,
            "social_login_enabled": true,
            "recaptcha_enabled": true
        },
        "contact": {
            "email": "support@example.com",
            "phone": "+1234567890"
        }
    },
    "status": 200
}
```

---

### 3. Update Device Token (FCM)

**Endpoint:** `PUT /api/v1/device-token`
**Authentication:** Required

Update Firebase Cloud Messaging token for push notifications.

#### Request Body

```json
{
    "device_token": "fcm_token_here",
    "device_type": "android"  // "android" or "ios"
}
```

#### Success Response (200)

```json
{
    "data": null,
    "message": "Device token updated successfully",
    "status": 200
}
```

---

### 4. Get Notifications

**Endpoint:** `GET /api/v1/notifications`
**Authentication:** Required

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 1 | Page number |
| limit | integer | 15 | Items per page |
| unread_only | boolean | false | Show only unread |

#### Success Response (200)

```json
{
    "data": [
        {
            "id": "uuid-here",
            "type": "leave_approved",
            "title": "Leave Request Approved",
            "message": "Your leave request for Dec 20-25 has been approved",
            "data": {
                "request_id": 123,
                "start_date": "2025-12-20",
                "end_date": "2025-12-25"
            },
            "read_at": null,
            "created_at": "2025-11-02T10:30:00Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "total": 50,
        "unread_count": 12
    }
}
```

---

### 5. Contact Us

**Endpoint:** `POST /api/v1/contact-us`
**Authentication:** Not Required
**Rate Limit:** `throttle:post_data` (5/min)

#### Request Body

```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "subject": "General Inquiry",
    "message": "I would like to know more about your services..."
}
```

#### Validation Rules

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | Yes | Max 255 chars |
| email | string | Yes | Valid email |
| subject | string | Yes | Max 255 chars |
| message | string | Yes | Min 10 chars, max 1000 |

#### Success Response (201)

```json
{
    "data": {
        "id": 1,
        "reference_number": "CNT-2025-001",
        "status": "pending"
    },
    "message": "Your message has been sent successfully",
    "status": 201
}
```

---

## 🎨 Advanced Features

### Media Resource Format

All media/file fields return consistent format:

```json
{
    "id": 1,
    "url": "https://storage.../path/file.jpg",
    "file_name": "file.jpg",
    "mime_type": "image/jpeg",
    "size": 102400,
    "collection_name": "avatar",
    "conversions": {
        "thumb": "https://storage.../path/file-thumb.jpg",
        "medium": "https://storage.../path/file-medium.jpg"
    }
}
```

---

## 📚 Pagination

All list endpoints support pagination with these parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 1 | Page number |
| limit | integer | 15 | Items per page (max: 100) |
| sort_by | string | created_at | Field to sort by |
| sort_order | string | desc | asc or desc |

**Example:**
```
GET /api/v1/departments?page=2&limit=20&sort_by=name&sort_order=asc
```

---

## 🔍 Filtering & Search

Many endpoints support search and filtering:

| Parameter | Type | Description |
|-----------|------|-------------|
| search | string | Search term |
| filters | object | Field-specific filters |

**Example:**
```
GET /api/v1/employees?search=john&filters[department_id]=1&filters[status]=active
```

---

## 💡 Best Practices

### 1. Always Include Headers

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
Accept-Language: en
```

### 2. Handle Errors Gracefully

```javascript
try {
    const response = await fetch('/api/v1/profile', {
        headers: {
            'Authorization': `Bearer ${token}`,
            'Accept': 'application/json'
        }
    });

    const data = await response.json();

    if (!response.ok) {
        // Handle error
        console.error(data.message, data.errors);
    }
} catch (error) {
    // Handle network error
}
```

### 3. Respect Rate Limits

Monitor response headers and implement exponential backoff when rate limited.

### 4. Cache When Possible

Static data like departments, positions can be cached client-side.

### 5. Use Pagination

Don't fetch all records at once. Use pagination for better performance.

---

## 🛠️ Testing the API

### Using cURL

```bash
# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"identifier":"user@example.com","password":"password123"}'

# Get Profile (with token)
curl -X GET http://localhost:8000/api/v1/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"

# Get Departments
curl -X GET http://localhost:8000/api/v1/departments \
  -H "Accept: application/json"
```

### Using Postman

1. Import environment with base_url: `http://localhost:8000/api/v1`
2. Create collection for each endpoint group
3. Use collection variables for tokens
4. Add pre-request scripts for authentication

### Using JavaScript/Axios

```javascript
import axios from 'axios';

const api = axios.create({
    baseURL: 'http://localhost:8000/api/v1',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
});

// Add token to requests
api.interceptors.request.use(config => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Login
const login = async (email, password) => {
    const response = await api.post('/auth/login', {
        identifier: email,
        password
    });
    return response.data;
};

// Get Profile
const getProfile = async () => {
    const response = await api.get('/profile');
    return response.data;
};
```

---

## 🔐 Security Considerations

1. **Always use HTTPS** in production
2. **Never expose tokens** in URLs or logs
3. **Validate all input** on client-side before sending
4. **Store tokens securely** (never in localStorage for sensitive apps)
5. **Implement token refresh** for long-lived sessions
6. **Monitor for suspicious activity** using rate limiters
7. **Use environment variables** for API endpoints

---

## 🌍 Internationalization

The API supports multiple languages. Include the Accept-Language header:

```http
Accept-Language: en
```

Or

```http
Accept-Language: ar
```

All error messages and user-facing text will be returned in the requested language.

---

## 📞 Support

For API issues or questions:
- **Email:** support@filamenthrm.com
- **Documentation:** https://docs.filamenthrm.com
- **GitHub:** https://github.com/hazem-hammad/filament-hrm

---

## 📝 Changelog

### Version 1.0 (Current)
- Initial API release
- Authentication endpoints
- Profile management
- Department management
- Basic attendance tracking
- File upload support
- Notification system

---

**Last Updated:** November 2, 2025
**API Version:** v1
**Documentation Version:** 1.0
