#!/bin/bash

# Test Late Reason Feature for Employee
# Usage: ./test_late_reason_employee.sh HanYoussef@bdcbiz.com

EMAIL="${1:-HanYoussef@bdcbiz.com}"

echo "=========================================="
echo "🔍 Testing Late Reason Feature"
echo "📧 Employee Email: $EMAIL"
echo "=========================================="
echo ""

# Connect to server and check employee data
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no root@31.97.46.103 <<EOF

cd /var/www/erp1

echo "1️⃣ Checking Employee Data..."
echo "==============================="

php artisan tinker --execute="
\$employee = App\\Models\\Hrm\\Employee::where('email', '$EMAIL')->first();
if (!\$employee) {
    echo '❌ Employee not found!\n';
    exit(1);
}

echo '✅ Employee Found:\n';
echo '   - ID: ' . \$employee->id . '\n';
echo '   - Name: ' . \$employee->name . '\n';
echo '   - Email: ' . \$employee->email . '\n';
echo '   - Work Plan ID: ' . (\$employee->work_plan_id ?? 'NULL') . '\n';
echo '\n';

if (!\$employee->work_plan_id) {
    echo '❌ No work plan assigned!\n';
    echo '   Solution: Assign a work plan to this employee.\n';
    exit(1);
}

echo '2️⃣ Checking Work Plan...\n';
echo '==============================\n';

\$workPlan = \$employee->workPlan;
if (!\$workPlan) {
    echo '❌ Work plan not found!\n';
    exit(1);
}

echo '✅ Work Plan Found:\n';
echo '   - ID: ' . \$workPlan->id . '\n';
echo '   - Name: ' . \$workPlan->name . '\n';
echo '   - Start Time: ' . (\$workPlan->start_time ?? 'NULL') . '\n';
echo '   - End Time: ' . (\$workPlan->end_time ?? 'NULL') . '\n';
echo '   - Permission Minutes: ' . \$workPlan->permission_minutes . '\n';
echo '\n';

if (!\$workPlan->start_time) {
    echo '❌ Work plan has no start time!\n';
    echo '   Solution: Set a start time for this work plan.\n';
    exit(1);
}

echo '3️⃣ Checking Today'\''s Attendance...\n';
echo '==============================\n';

\$attendance = App\\Models\\Hrm\\Attendance::where('employee_id', \$employee->id)
    ->whereDate('date', today())
    ->first();

if (!\$attendance) {
    echo '✅ No attendance record today (fresh start)\n';
    echo '   - has_late_reason: false (will show bottom sheet if late)\n';
} else {
    echo '✅ Attendance Record Found:\n';
    echo '   - ID: ' . \$attendance->id . '\n';
    echo '   - Date: ' . \$attendance->date . '\n';
    echo '   - Check In: ' . (\$attendance->check_in_time ?? 'NULL') . '\n';
    echo '   - Check Out: ' . (\$attendance->check_out_time ?? 'NULL') . '\n';
    echo '   - Notes (late reason): ' . (\$attendance->notes ? '\"' . \$attendance->notes . '\"' : 'NULL') . '\n';
    echo '   - has_late_reason: ' . (empty(\$attendance->notes) ? 'false' : 'true') . '\n';

    if (!empty(\$attendance->notes)) {
        echo '\n';
        echo '⚠️ Employee already provided late reason today!\n';
        echo '   Bottom sheet will NOT show (expected behavior).\n';
        echo '\n';
        echo '   To test again, clear the notes:\n';
        echo '   UPDATE attendances SET notes = NULL WHERE id = ' . \$attendance->id . ';\n';
    }
}

echo '\n';
echo '4️⃣ Checking Current Time vs Start Time...\n';
echo '==============================\n';

\$now = now();
\$startTime = \Carbon\Carbon::parse(\$workPlan->start_time);
\$graceMinutes = \$workPlan->permission_minutes;

echo '   - Current Time: ' . \$now->format('H:i:s') . '\n';
echo '   - Work Start Time: ' . \$startTime->format('H:i:s') . '\n';
echo '   - Grace Period: ' . \$graceMinutes . ' minutes\n';
echo '   - Latest On-Time: ' . \$startTime->addMinutes(\$graceMinutes)->format('H:i:s') . '\n';

\$startTimeWithGrace = \Carbon\Carbon::parse(\$workPlan->start_time)->addMinutes(\$graceMinutes);

if (\$now->gt(\$startTimeWithGrace)) {
    \$minutesLate = \$now->diffInMinutes(\$startTimeWithGrace);
    echo '\n';
    echo '✅ Employee IS LATE by ' . \$minutesLate . ' minutes\n';
    echo '   Bottom sheet SHOULD show (if no late reason provided today)\n';
} else {
    \$minutesEarly = \$startTimeWithGrace->diffInMinutes(\$now);
    echo '\n';
    echo '❌ Employee is NOT late (early by ' . \$minutesEarly . ' minutes)\n';
    echo '   Bottom sheet will NOT show (not late yet)\n';
}

echo '\n';
echo '========================================\n';
echo '5️⃣ Summary:\n';
echo '========================================\n';

\$hasWorkPlan = \$employee->work_plan_id ? true : false;
\$hasStartTime = \$workPlan && \$workPlan->start_time ? true : false;
\$isLate = \$now->gt(\$startTimeWithGrace);
\$hasLateReason = \$attendance && !empty(\$attendance->notes);

echo '   ✅ Has Work Plan: ' . (\$hasWorkPlan ? 'YES' : 'NO') . '\n';
echo '   ✅ Has Start Time: ' . (\$hasStartTime ? 'YES' : 'NO') . '\n';
echo '   ✅ Is Late Now: ' . (\$isLate ? 'YES' : 'NO') . '\n';
echo '   ✅ Has Late Reason: ' . (\$hasLateReason ? 'YES' : 'NO') . '\n';
echo '\n';

if (\$hasWorkPlan && \$hasStartTime && \$isLate && !\$hasLateReason) {
    echo '🎯 RESULT: Bottom sheet SHOULD show ✅\n';
} else {
    echo '🎯 RESULT: Bottom sheet will NOT show\n';
    echo '\n';
    echo 'Reasons:\n';
    if (!\$hasWorkPlan) echo '   ❌ No work plan assigned\n';
    if (!\$hasStartTime) echo '   ❌ Work plan has no start time\n';
    if (!\$isLate) echo '   ❌ Employee is not late yet\n';
    if (\$hasLateReason) echo '   ❌ Employee already provided late reason today\n';
}

echo '\n';
"

echo ""
echo "=========================================="
echo "✅ Test Complete!"
echo "=========================================="

EOF
