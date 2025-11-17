import 'package:equatable/equatable.dart';

/// Employees State
///
/// Represents different states of employees list for chat
abstract class EmployeesState extends Equatable {
  const EmployeesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EmployeesInitial extends EmployeesState {
  const EmployeesInitial();
}

/// Loading employees
class EmployeesLoading extends EmployeesState {
  const EmployeesLoading();
}

/// Employees loaded successfully
class EmployeesLoaded extends EmployeesState {
  final List<Map<String, dynamic>> employees;
  final List<Map<String, dynamic>> filteredEmployees;

  const EmployeesLoaded({
    required this.employees,
    required this.filteredEmployees,
  });

  @override
  List<Object?> get props => [employees, filteredEmployees];

  /// Copy with method for filtering
  EmployeesLoaded copyWith({
    List<Map<String, dynamic>>? employees,
    List<Map<String, dynamic>>? filteredEmployees,
  }) {
    return EmployeesLoaded(
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
    );
  }
}

/// Error loading employees
class EmployeesError extends EmployeesState {
  final String message;

  const EmployeesError(this.message);

  @override
  List<Object?> get props => [message];
}
