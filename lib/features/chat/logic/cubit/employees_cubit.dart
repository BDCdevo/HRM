import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/chat_repository.dart';
import 'employees_state.dart';

/// Employees Cubit
///
/// Manages employees list state for starting new conversations
class EmployeesCubit extends Cubit<EmployeesState> {
  final ChatRepository _repository;
  List<Map<String, dynamic>> _allEmployees = [];

  EmployeesCubit(this._repository) : super(const EmployeesInitial());

  /// Fetch Employees
  ///
  /// Loads all employees in a specific company
  Future<void> fetchEmployees(int companyId) async {
    try {
      emit(const EmployeesLoading());

      final employees = await _repository.getUsers(companyId);

      _allEmployees = employees;
      emit(EmployeesLoaded(
        employees: employees,
        filteredEmployees: employees,
      ));
    } catch (e) {
      print('❌ EmployeesCubit - Fetch Employees Error: $e');
      emit(EmployeesError(e.toString()));
    }
  }

  /// Search Employees
  ///
  /// Filters employees list based on search query
  /// Client-side filtering for instant results
  void searchEmployees(String query) {
    if (state is! EmployeesLoaded) return;

    final currentState = state as EmployeesLoaded;

    if (query.isEmpty) {
      // Show all employees if query is empty
      emit(currentState.copyWith(filteredEmployees: _allEmployees));
      return;
    }

    // Filter by name or email (case-insensitive)
    final filtered = _allEmployees.where((employee) {
      final name = (employee['name'] as String? ?? '').toLowerCase();
      final email = (employee['email'] as String? ?? '').toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || email.contains(searchQuery);
    }).toList();

    emit(currentState.copyWith(filteredEmployees: filtered));
  }

  /// Reset to initial state
  void reset() {
    _allEmployees = [];
    emit(const EmployeesInitial());
  }

  /// Get all employees
  List<Map<String, dynamic>> get allEmployees => _allEmployees;
}
