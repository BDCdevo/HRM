# 🧪 Chat Feature - Testing Instructions

**Date:** 2025-11-16
**Version:** 1.0.0

---

## 📋 Pre-Testing Checklist

### ✅ **Environment Setup:**
- [x] Backend API is running (Production: `https://erp1.bdcbiz.com`)
- [x] App configured for production (`baseUrlProduction`)
- [x] Device/Emulator ready
- [x] Internet connection available

### ✅ **Test Credentials:**
```
Email: Ahmed@bdcbiz.com
Password: password
Company ID: 6 (BDC)
User ID: 10
```

---

## 🚀 How to Access Chat Test Screen

### **Method 1: Via Test Screen (Recommended)**

1. **Login** to the app with test credentials
2. **Navigate** to test screen using one of these methods:
   - From code: `Navigator.pushNamed(context, AppRouter.chatTest)`
   - Add temporary button in More screen
   - Use debug menu

### **Method 2: Direct Navigation (For Testing)**

Add this temporary button to any screen:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, AppRouter.chatTest);
  },
  child: Text('Test Chat'),
)
```

---

## 🧪 Testing Scenarios

### **Scenario 1: View Conversations List** ✅

**Steps:**
1. Open Chat Test Screen
2. Tap "Open Chat" button
3. Wait for conversations to load

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Conversations list loads from API
- ✅ Each conversation shows:
  - Participant name
  - Last message preview
  - Timestamp
  - Unread count (if any)
- ✅ Pull-to-refresh works
- ✅ FAB button visible at bottom right

**If Empty:**
- ✅ "No conversations yet" message appears
- ✅ FAB button still visible

**If Error:**
- ✅ Error message appears with details
- ✅ Retry button available
- ✅ Error snackbar shows

---

### **Scenario 2: Create New Conversation** ✅

**Steps:**
1. From Chat List, tap FAB (+ button)
2. Employee Selection Screen appears
3. Wait for employees list to load
4. Use search bar to find employee
5. Tap on an employee

**Expected Results:**
- ✅ Loading indicator during fetch
- ✅ Employees list appears (all users from company)
- ✅ Search works instantly (client-side)
- ✅ Results count updates dynamically
- ✅ Tapping employee creates conversation
- ✅ Auto-navigates to Chat Room
- ✅ If conversation exists, opens existing one

**Test Search:**
- Search by name (e.g., "Ahmed")
- Search by email
- Clear search button works
- Empty results show "No employees found"

---

### **Scenario 3: Send Text Message** ✅

**Steps:**
1. Open any conversation (or create new one)
2. Type message in input field
3. Tap send button

**Expected Results:**
- ✅ Message appears in chat immediately
- ✅ Input field clears after sending
- ✅ Auto-scrolls to bottom
- ✅ Send button shows loading indicator while sending
- ✅ Message bubble shows on right side (sent by me)
- ✅ Timestamp appears below message
- ✅ Read receipt shows (✓ or ✓✓)

**If Error:**
- ✅ Error snackbar appears
- ✅ Message can be retried
- ✅ Input field keeps text

---

### **Scenario 4: Send Image** ✅

**Steps:**
1. Open any conversation
2. Tap camera icon OR attachment icon
3. Select/take photo
4. Wait for upload

**Expected Results:**
- ✅ Camera opens for camera icon
- ✅ Gallery opens for attachment icon
- ✅ Image preview (if supported)
- ✅ Loading indicator during upload
- ✅ Image appears in chat after upload
- ✅ Tap image to view full size (if implemented)

**If Error:**
- ✅ Permission error handled
- ✅ Upload error shown in snackbar
- ✅ Can retry

---

### **Scenario 5: Receive Messages** ⚠️

**Note:** Requires another user or backend testing tool

**Steps:**
1. Open conversation
2. Have another user send message from different device/browser
3. Pull-to-refresh to check

**Expected Results:**
- ✅ New messages appear after refresh
- ✅ Message bubble shows on left side (received)
- ✅ Sender name appears above message
- ✅ Unread count updates in conversation list

**Future:** Real-time updates via WebSocket

---

### **Scenario 6: Error Handling** ✅

**Test Cases:**

**6.1 Network Error:**
- Turn off internet
- Try to load conversations
- Expected: Error message with retry button

**6.2 API Error:**
- Invalid company ID
- Expected: Error message with details

**6.3 Empty States:**
- No conversations: "No conversations yet"
- No messages: "No messages yet"
- No employees: Should not happen (all companies have users)

**6.4 Loading States:**
- All operations show loading indicators
- User cannot interact during loading

---

## 📊 Test Results Template

### **Test Date:** _____________

| Scenario | Status | Notes |
|----------|--------|-------|
| 1. View Conversations | ⬜ Pass / ⬜ Fail | |
| 2. Create Conversation | ⬜ Pass / ⬜ Fail | |
| 3. Send Text Message | ⬜ Pass / ⬜ Fail | |
| 4. Send Image | ⬜ Pass / ⬜ Fail | |
| 5. Receive Messages | ⬜ Pass / ⬜ Fail | |
| 6. Error Handling | ⬜ Pass / ⬜ Fail | |
| **Overall** | ⬜ Pass / ⬜ Fail | |

---

## 🐛 Common Issues & Solutions

### **Issue 1: "Unauthenticated" Error**
**Solution:** Make sure you're logged in with valid credentials

### **Issue 2: Empty Conversations List**
**Solution:** This is normal if no conversations exist yet. Create one using FAB button.

### **Issue 3: Cannot Send Message**
**Solution:**
- Check internet connection
- Verify conversation was created successfully
- Check logs for error details

### **Issue 4: Images Not Uploading**
**Solution:**
- Check storage permissions
- Ensure image size < 10MB
- Check backend storage configuration

### **Issue 5: CompanyID Error**
**Solution:**
- Verify user's company_id from login response
- Check API_DOCUMENTATION.md for required parameters

---

## 📱 Device/Platform Specific Tests

### **Android:**
- ✅ Test on emulator (API 30+)
- ✅ Test on real device
- ✅ Test camera permissions
- ✅ Test storage permissions
- ✅ Test dark mode

### **iOS (Future):**
- ⬜ Test on simulator
- ⬜ Test on real device
- ⬜ Test permissions

### **Web (Future):**
- ⬜ Test file upload
- ⬜ Test on different browsers

---

## 🔍 Debug Mode Testing

### **Enable Debug Logging:**

All repositories and cubits have debug print statements:

```
✅ ChatCubit - Fetch Conversations Error: [error details]
✅ Get Conversations Response Status: 200
✅ Send Message Response: [response data]
```

**To view logs:**
- Run app in debug mode
- Check console/logcat for print statements
- Filter by "✅" or "❌" for quick debugging

---

## 📊 Performance Testing

### **Metrics to Monitor:**

1. **Load Time:**
   - Conversations list: < 2 seconds
   - Messages list: < 1 second
   - Employee list: < 2 seconds

2. **Send Message:**
   - Text message: < 1 second
   - Image upload: < 3 seconds (depends on size)

3. **UI Responsiveness:**
   - No lag during scrolling
   - Smooth animations
   - Instant search results

---

## ✅ Production Readiness Checklist

Before deploying to production:

- [ ] All test scenarios pass
- [ ] No console errors
- [ ] Performance acceptable
- [ ] Dark mode works correctly
- [ ] Permissions handled properly
- [ ] Error messages are user-friendly
- [ ] Loading states are clear
- [ ] Empty states are informative
- [ ] Back navigation works correctly
- [ ] Notifications tested (if implemented)

---

## 🚀 Quick Test Script

**5-Minute Quick Test:**

1. ✅ Login with test credentials
2. ✅ Navigate to Chat Test Screen
3. ✅ Tap "Open Chat"
4. ✅ Tap FAB to create conversation
5. ✅ Select an employee
6. ✅ Send a text message
7. ✅ Send an image
8. ✅ Pull-to-refresh
9. ✅ Navigate back
10. ✅ Verify conversation appears in list

**Expected Time:** ~5 minutes
**Expected Result:** All steps complete without errors

---

## 📝 Feedback & Bug Reports

### **Report Template:**

```
**Bug Title:** [Short description]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Screenshots/Logs:**
[Attach if available]

**Environment:**
- Device: [e.g., Samsung Galaxy S21]
- Android Version: [e.g., Android 12]
- App Version: [e.g., 1.0.0]
- Network: [WiFi / Mobile Data]
```

---

## 🎯 Next Steps After Testing

1. **If All Tests Pass:**
   - ✅ Add chat to main navigation
   - ✅ Deploy to production
   - ✅ Monitor for issues
   - ✅ Gather user feedback

2. **If Tests Fail:**
   - ❌ Document issues
   - ❌ Fix bugs
   - ❌ Re-test
   - ❌ Update code as needed

---

**Happy Testing!** 🧪🎉

---

**Last Updated:** 2025-11-16
**Prepared By:** Claude Code
