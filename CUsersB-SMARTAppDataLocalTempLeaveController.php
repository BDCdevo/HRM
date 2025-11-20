<?php

namespace App\Http\Controllers\Api\V1\Employee;

use App\Http\Controllers\Controller;
use App\Http\Responses\DataResponse;
use App\Http\Responses\ErrorResponse;
use App\Models\Hrm\Employee;
use App\Models\Hrm\Request;
use App\Models\Hrm\VacationType;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request as HttpRequest;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Symfony\Component\HttpFoundation\Response;

class LeaveController extends Controller
{
    /**
     * Get Available Vacation Types
     *
     * Returns vacation types that are active and available for the authenticated employee
     */
    public function getVacationTypes(): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return (new ErrorResponse('Unauthorized', [], Response::HTTP_UNAUTHORIZED))->toJson();
            }

            $employee = Employee::find($user->id);

            if (!$employee) {
                return (new ErrorResponse('Employee record not found', [], Response::HTTP_NOT_FOUND))->toJson();
            }

            // Get all active vacation types
            $vacationTypes = VacationType::where('status', true)
                ->orderBy('name')
                ->get();

            // Transform vacation types with availability info
            $data = $vacationTypes->map(function ($vacationType) use ($employee) {
                $isAvailable = $vacationType->isAvailableForEmployee($employee);

                return [
                    'id' => $vacationType->id,
                    'name' => $vacationType->name,
                    'description' => $vacationType->description,
                    'balance' => $vacationType->balance,
                    'unlock_after_months' => $vacationType->unlock_after_months,
                    'required_days_before' => $vacationType->required_days_before,
                    'requires_approval' => $vacationType->requires_approval,
                    'is_available' => $isAvailable,
                ];
            });

            return (new DataResponse($data))->toJson();
        } catch (\Throwable $exception) {
            Log::error(__METHOD__ . ': ' . $exception->getMessage(), ['exception' => $exception]);
            return (new ErrorResponse(__('something_went_wrong')))->toJson();
        }
    }

    /**
     * Apply for Leave
     *
     * Creates a new vacation request
     */
    public function applyLeave(HttpRequest $request): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return (new ErrorResponse('Unauthorized', [], Response::HTTP_UNAUTHORIZED))->toJson();
            }

            // Validate request
            $validator = Validator::make($request->all(), [
                'vacation_type_id' => 'required|exists:vacation_types,id',
                'start_date' => 'required|date|after_or_equal:today',
                'end_date' => 'required|date|after_or_equal:start_date',
                'reason' => 'required|string|max:500',
            ]);

            if ($validator->fails()) {
                return (new ErrorResponse('Validation failed', $validator->errors()->toArray(), Response::HTTP_UNPROCESSABLE_ENTITY))->toJson();
            }

            // Set company_id in session for CurrentCompanyScope
            $employee = Employee::withoutGlobalScopes()->find($user->id);
            if ($employee && $employee->company_id) {
                session(['current_company_id' => $employee->company_id]);}

            $employee = Employee::find($user->id);if (!$employee) {
                Log::error('ApplyLeave: Employee not found');
                return (new ErrorResponse('Employee record not found', [], Response::HTTP_NOT_FOUND))->toJson();
            }

            // Get vacation type
            $vacationType = VacationType::find($request->vacation_type_id);if (!$vacationType || !$vacationType->status) {
                Log::error('ApplyLeave: Vacation type not available or inactive');
                return (new ErrorResponse('Vacation type not available', [], Response::HTTP_BAD_REQUEST))->toJson();
            }

            // Calculate total days
            $startDate = \Carbon\Carbon::parse($request->start_date);
            $endDate = \Carbon\Carbon::parse($request->end_date);
            $totalDays = $startDate->diffInDays($endDate) + 1;// Create leave request$leaveRequest = new Request([
                'employee_id' => $user->id,
                'request_type' => 'vacation',
                'requestable_id' => $vacationType->id,
                'requestable_type' => VacationType::class,
                'status' => 'pending',
                'reason' => $request->reason,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'total_days' => $totalDays,
                'request_date' => now(),
            ]);
            
            // Explicitly set company_id after object creation
            $leaveRequest->company_id = $employee->company_id;
            
            Log::info('ApplyLeave: Request object created', ['company_id_in_object' => $leaveRequest->company_id, 'all_attributes' => $leaveRequest->getAttributes()]);

            // Validate the request$validationErrors = $leaveRequest->validateRequest();if (!empty($validationErrors)) {
                Log::error('ApplyLeave: Validation failed', ['errors' => $validationErrors]);
                return (new ErrorResponse('Leave request validation failed', [
                    'errors' => $validationErrors,
                ], Response::HTTP_BAD_REQUEST))->toJson();
            }

            Log::info('ApplyLeave: Before save', ['company_id_before_save' => $leaveRequest->company_id, 'attributes_before_save' => $leaveRequest->getAttributes()]);$leaveRequest->save();
            Log::info('ApplyLeave: After save', ['id' => $leaveRequest->id, 'company_id_after_save' => $leaveRequest->company_id, 'attributes_after_save' => $leaveRequest->getAttributes()]);

            $data = [
                'id' => $leaveRequest->id,
                'vacation_type' => $vacationType->name,
                'start_date' => $leaveRequest->start_date->format('Y-m-d'),
                'end_date' => $leaveRequest->end_date->format('Y-m-d'),
                'total_days' => $leaveRequest->total_days,
                'status' => $leaveRequest->status,
                'reason' => $leaveRequest->reason,
                'request_date' => $leaveRequest->request_date->format('Y-m-d'),
                'message' => 'Leave request submitted successfully',
            ];

            return (new DataResponse($data, 'Leave request submitted successfully'))->toJson();
        } catch (\Throwable $exception) {
            app('custom.logger')->error(__METHOD__, $exception);
            return (new ErrorResponse(__('something_went_wrong')))->toJson();
        }
    }

    /**
     * Get Leave History
     *
     * Retrieves paginated leave request history for the authenticated user
     */
    public function getHistory(): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return (new ErrorResponse('Unauthorized', [], Response::HTTP_UNAUTHORIZED))->toJson();
            }

            // Get pagination parameters from request
            $perPage = request()->get('per_page', 15);
            $status = request()->get('status'); // Optional filter by status

            // Query leave requests
            $query = Request::where('employee_id', $user->id)
                ->where('request_type', 'vacation')
                ->with('requestable') // Load vacation type
                ->orderBy('request_date', 'desc');

            // Apply status filter if provided
            if ($status && in_array($status, ['pending', 'approved', 'rejected', 'cancelled'])) {
                $query->where('status', $status);
            }

            $leaveRequests = $query->paginate($perPage);

            // Transform the data
            $transformedData = $leaveRequests->getCollection()->map(function ($leave) {
                return [
                    'id' => $leave->id,
                    'vacation_type' => $leave->requestable ? [
                        'id' => $leave->requestable->id,
                        'name' => $leave->requestable->name,
                    ] : null,
                    'start_date' => $leave->start_date ? $leave->start_date->format('Y-m-d') : null,
                    'end_date' => $leave->end_date ? $leave->end_date->format('Y-m-d') : null,
                    'total_days' => $leave->total_days,
                    'status' => $leave->status,
                    'reason' => $leave->reason,
                    'admin_notes' => $leave->admin_notes,
                    'request_date' => $leave->request_date ? $leave->request_date->format('Y-m-d') : null,
                    'approved_at' => $leave->approved_at ? $leave->approved_at->format('Y-m-d H:i:s') : null,
                    'approver_name' => $leave->approver_name,
                    'can_cancel' => $leave->canBeCancelled(),
                ];
            });

            $data = [
                'data' => $transformedData,
                'current_page' => $leaveRequests->currentPage(),
                'last_page' => $leaveRequests->lastPage(),
                'per_page' => $leaveRequests->perPage(),
                'total' => $leaveRequests->total(),
            ];

            return (new DataResponse($data))->toJson();
        } catch (\Throwable $exception) {
            Log::error(__METHOD__ . ': ' . $exception->getMessage(), ['exception' => $exception]);
            return (new ErrorResponse(__('something_went_wrong')))->toJson();
        }
    }

    /**
     * Get Leave Balance
     *
     * Returns leave balance statistics for all vacation types
     */
    public function getBalance(): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return (new ErrorResponse('Unauthorized', [], Response::HTTP_UNAUTHORIZED))->toJson();
            }

            $employee = Employee::find($user->id);

            if (!$employee) {
                return (new ErrorResponse('Employee record not found', [], Response::HTTP_NOT_FOUND))->toJson();
            }

            // Get current year approved vacation days by vacation type
            $currentYear = now()->year;

            $usedDays = Request::where('employee_id', $user->id)
                ->where('request_type', 'vacation')
                ->where('requestable_type', VacationType::class)
                ->where('status', 'approved')
                ->whereYear('start_date', $currentYear)
                ->selectRaw('requestable_id, SUM(total_days) as used_days')
                ->groupBy('requestable_id')
                ->pluck('used_days', 'requestable_id');

            // Get all active vacation types
            $vacationTypes = VacationType::where('status', true)->get();

            $balances = $vacationTypes->map(function ($vacationType) use ($usedDays, $employee) {
                $used = $usedDays[$vacationType->id] ?? 0;
                $remaining = max(0, $vacationType->balance - $used);
                $isAvailable = $vacationType->isAvailableForEmployee($employee);

                return [
                    'id' => $vacationType->id,
                    'name' => $vacationType->name,
                    'total_balance' => $vacationType->balance,
                    'used_days' => (int) $used,
                    'remaining_days' => (int) $remaining,
                    'is_available' => $isAvailable,
                ];
            });

            // Calculate total remaining days
            $totalRemaining = $balances->where('is_available', true)->sum('remaining_days');

            $data = [
                'balances' => $balances,
                'total_remaining' => $totalRemaining,
                'year' => $currentYear,
            ];

            return (new DataResponse($data))->toJson();
        } catch (\Throwable $exception) {
            Log::error(__METHOD__ . ': ' . $exception->getMessage(), ['exception' => $exception]);
            return (new ErrorResponse(__('something_went_wrong')))->toJson();
        }
    }

    /**
     * Cancel Leave Request
     *
     * Cancels a pending or approved leave request
     */
    public function cancelLeave(string $id): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return (new ErrorResponse('Unauthorized', [], Response::HTTP_UNAUTHORIZED))->toJson();
            }

            // Find the leave request
            $leaveRequest = Request::where('id', $id)
                ->where('employee_id', $user->id)
                ->where('request_type', 'vacation')
                ->first();

            if (!$leaveRequest) {
                return (new ErrorResponse('Leave request not found', [], Response::HTTP_NOT_FOUND))->toJson();
            }

            // Check if can be cancelled
            if (!$leaveRequest->canBeCancelled()) {
                return (new ErrorResponse('This leave request cannot be cancelled', [], Response::HTTP_BAD_REQUEST))->toJson();
            }

            // Update status to cancelled
            $leaveRequest->status = 'cancelled';
            $leaveRequest->save();

            $data = [
                'id' => $leaveRequest->id,
                'status' => $leaveRequest->status,
                'message' => 'Leave request cancelled successfully',
            ];

            return (new DataResponse($data, 'Leave request cancelled successfully'))->toJson();
        } catch (\Throwable $exception) {
            app('custom.logger')->error(__METHOD__, $exception);
            return (new ErrorResponse(__('something_went_wrong')))->toJson();
        }
    }

    /**
     * Get Leave Request Details
     *
     * Returns detailed information about a specific leave request
     */
    public function getLeaveDetails(string $id): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return (new ErrorResponse('Unauthorized', [], Response::HTTP_UNAUTHORIZED))->toJson();
            }

            // Find the leave request
            $leaveRequest = Request::where('id', $id)
                ->where('employee_id', $user->id)
                ->where('request_type', 'vacation')
                ->with('requestable')
                ->first();

            if (!$leaveRequest) {
                return (new ErrorResponse('Leave request not found', [], Response::HTTP_NOT_FOUND))->toJson();
            }

            $data = [
                'id' => $leaveRequest->id,
                'vacation_type' => $leaveRequest->requestable ? [
                    'id' => $leaveRequest->requestable->id,
                    'name' => $leaveRequest->requestable->name,
                    'description' => $leaveRequest->requestable->description,
                ] : null,
                'start_date' => $leaveRequest->start_date ? $leaveRequest->start_date->format('Y-m-d') : null,
                'end_date' => $leaveRequest->end_date ? $leaveRequest->end_date->format('Y-m-d') : null,
                'total_days' => $leaveRequest->total_days,
                'status' => $leaveRequest->status,
                'reason' => $leaveRequest->reason,
                'admin_notes' => $leaveRequest->admin_notes,
                'request_date' => $leaveRequest->request_date ? $leaveRequest->request_date->format('Y-m-d') : null,
                'approved_at' => $leaveRequest->approved_at ? $leaveRequest->approved_at->format('Y-m-d H:i:s') : null,
                'approver_name' => $leaveRequest->approver_name,
                'can_cancel' => $leaveRequest->canBeCancelled(),
            ];

            return (new DataResponse($data))->toJson();
        } catch (\Throwable $exception) {
            Log::error(__METHOD__ . ': ' . $exception->getMessage(), ['exception' => $exception]);
            return (new ErrorResponse(__('something_went_wrong')))->toJson();
        }
    }
}
