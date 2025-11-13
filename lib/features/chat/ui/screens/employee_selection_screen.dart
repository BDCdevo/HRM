import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import 'chat_room_screen.dart';

/// Employee Selection Screen
///
/// Select an employee to start a new chat - Enhanced version
class EmployeeSelectionScreen extends StatefulWidget {
  const EmployeeSelectionScreen({super.key});

  @override
  State<EmployeeSelectionScreen> createState() =>
      _EmployeeSelectionScreenState();
}

class _EmployeeSelectionScreenState extends State<EmployeeSelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Results Count
          _buildResultsCount(),

          // Employees List
          Expanded(child: _buildEmployeesList()),
        ],
      ),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Chat',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Select a contact',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Search Bar
  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? (isDark ? AppColors.darkAccent : AppColors.accent)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or department...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Results Count
  Widget _buildResultsCount() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mockEmployees = _getMockEmployees();
    final filteredEmployees = _getFilteredEmployees(mockEmployees);

    if (_searchQuery.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 18,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              '${mockEmployees.length} employees available',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            filteredEmployees.isEmpty
                ? Icons.search_off
                : Icons.filter_list,
            size: 18,
            color: filteredEmployees.isEmpty
                ? AppColors.error
                : (isDark ? AppColors.darkAccent : AppColors.accent),
          ),
          const SizedBox(width: 8),
          Text(
            filteredEmployees.isEmpty
                ? 'No results found'
                : '${filteredEmployees.length} result${filteredEmployees.length > 1 ? 's' : ''} found',
            style: AppTextStyles.bodySmall.copyWith(
              color: filteredEmployees.isEmpty
                  ? AppColors.error
                  : (isDark ? AppColors.darkAccent : AppColors.accent),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Get Filtered Employees
  List<Map<String, String>> _getFilteredEmployees(
      List<Map<String, String>> employees) {
    if (_searchQuery.isEmpty) return employees;

    return employees
        .where(
          (emp) =>
              emp['name']!.toLowerCase().contains(_searchQuery) ||
              emp['department']!.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  /// Build Employees List
  Widget _buildEmployeesList() {
    final mockEmployees = _getMockEmployees();
    final filteredEmployees = _getFilteredEmployees(mockEmployees);

    if (filteredEmployees.isEmpty) {
      return _buildEmptyState();
    }

    // Group by department
    final groupedEmployees = <String, List<Map<String, String>>>{};
    for (var emp in filteredEmployees) {
      final dept = emp['department']!;
      groupedEmployees.putIfAbsent(dept, () => []);
      groupedEmployees[dept]!.add(emp);
    }

    return FadeTransition(
      opacity: _animationController,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: groupedEmployees.length,
        itemBuilder: (context, index) {
          final department = groupedEmployees.keys.elementAt(index);
          final employees = groupedEmployees[department]!;
          return _buildDepartmentSection(department, employees);
        },
      ),
    );
  }

  /// Build Department Section
  Widget _buildDepartmentSection(
      String department, List<Map<String, String>> employees) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Department Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                department,
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkAccent : AppColors.accent)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${employees.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkAccent : AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Employees in this department
        ...employees.map((emp) => _buildEmployeeCard(emp)).toList(),
      ],
    );
  }

  /// Build Employee Card
  Widget _buildEmployeeCard(Map<String, String> employee) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to chat room with this employee
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                conversationId: DateTime.now().millisecondsSinceEpoch,
                participantName: employee['name']!,
                participantAvatar: null,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            border: Border(
              bottom: BorderSide(
                color: (isDark ? AppColors.darkBorder : AppColors.border)
                    .withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  Hero(
                    tag: 'avatar_${employee['name']}',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary)
                                .withOpacity(0.15),
                            (isDark ? AppColors.darkAccent : AppColors.accent)
                                .withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary)
                              .withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          employee['name']!
                              .split(' ')
                              .take(2)
                              .map((n) => n[0])
                              .join()
                              .toUpperCase(),
                          style: AppTextStyles.titleLarge.copyWith(
                            color:
                                isDark ? AppColors.darkPrimary : AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Online indicator
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkCard : AppColors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee['name']!,
                      style: AppTextStyles.titleMedium.copyWith(
                        color:
                            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business_center,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            employee['department']!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Start chat icon
              Icon(
                Icons.chat_bubble_outline,
                color: (isDark ? AppColors.darkAccent : AppColors.accent)
                    .withOpacity(0.6),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkAccent : AppColors.accent)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search,
              size: 60,
              color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                  .withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No employees found',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Try searching with a different name or department',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear search'),
              style: TextButton.styleFrom(
                foregroundColor:
                    isDark ? AppColors.darkAccent : AppColors.accent,
              ),
            ),
        ],
      ),
    );
  }

  /// Get Mock Employees (for testing UI)
  List<Map<String, String>> _getMockEmployees() {
    return [
      {'name': 'Ahmed Abbas', 'department': 'Development'},
      {'name': 'Ibrahim Abusham', 'department': 'Development'},
      {'name': 'Khaled Mohamed', 'department': 'Development'},
      {'name': 'Mohamed Ali', 'department': 'HR'},
      {'name': 'Laila Hassan', 'department': 'HR'},
      {'name': 'Sara Ahmed', 'department': 'Sales'},
      {'name': 'Youssef Ibrahim', 'department': 'Sales'},
      {'name': 'Omar Hassan', 'department': 'Marketing'},
      {'name': 'Nadia Saleh', 'department': 'Marketing'},
      {'name': 'Fatma Mahmoud', 'department': 'Finance'},
      {'name': 'Ali Said', 'department': 'Operations'},
      {'name': 'Nour Khaled', 'department': 'Customer Service'},
      {'name': 'Hana Fouad', 'department': 'Customer Service'},
    ];
  }
}
