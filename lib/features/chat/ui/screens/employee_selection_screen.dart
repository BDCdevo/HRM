import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/networking/dio_client.dart';
import '../../data/repo/chat_repository.dart';
import '../../logic/cubit/employees_cubit.dart';
import '../../logic/cubit/employees_state.dart';
import '../../logic/cubit/chat_cubit.dart';
import '../../logic/cubit/chat_state.dart';
import 'chat_room_screen.dart';

/// Employee Selection Screen
///
/// Select an employee to start a new chat
class EmployeeSelectionScreen extends StatelessWidget {
  final int companyId;
  final int currentUserId;

  const EmployeeSelectionScreen({
    super.key,
    required this.companyId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              EmployeesCubit(ChatRepository())
                ..fetchEmployees(companyId),
        ),
        BlocProvider(
          create: (context) => ChatCubit(ChatRepository()),
        ),
      ],
      child: _EmployeeSelectionView(
        companyId: companyId,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _EmployeeSelectionView extends StatefulWidget {
  final int companyId;
  final int currentUserId;

  const _EmployeeSelectionView({
    required this.companyId,
    required this.currentUserId,
  });

  @override
  State<_EmployeeSelectionView> createState() => _EmployeeSelectionViewState();
}

class _EmployeeSelectionViewState extends State<_EmployeeSelectionView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
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
      appBar: _buildAppBar(isDark),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ConversationCreated) {
            // Navigate to chat room after creating conversation
            // Use pop then push instead of pushReplacement to avoid overlay issues
            Navigator.of(context).pop(); // Close employee selection screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  conversationId: state.conversationId,
                  participantName: 'Chat', // Will be updated from conversation data
                  companyId: widget.companyId,
                  currentUserId: widget.currentUserId,
                ),
              ),
            );
          }

          if (state is ConversationCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, chatState) {
          return BlocBuilder<EmployeesCubit, EmployeesState>(
            builder: (context, employeesState) {
              return Column(
                children: [
                  // Search Bar
                  _buildSearchBar(isDark),

                  // Results Count
                  _buildResultsCount(employeesState, isDark),

                  // Employees List
                  Expanded(
                    child: _buildBody(employeesState, chatState, isDark),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar(bool isDark) {
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
  Widget _buildSearchBar(bool isDark) {
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
                  color: _searchController.text.isNotEmpty
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
                        setState(() {});
                        context.read<EmployeesCubit>().searchEmployees(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
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
                  if (_searchController.text.isNotEmpty)
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
                        });
                        context.read<EmployeesCubit>().searchEmployees('');
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
  Widget _buildResultsCount(EmployeesState state, bool isDark) {
    if (state is! EmployeesLoaded) {
      return const SizedBox.shrink();
    }

    final filteredCount = state.filteredEmployees.length;
    final totalCount = state.employees.length;
    final searchQuery = _searchController.text;

    if (searchQuery.isEmpty) {
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
              '$totalCount employees available',
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
            filteredCount == 0 ? Icons.search_off : Icons.filter_list,
            size: 18,
            color: filteredCount == 0
                ? AppColors.error
                : (isDark ? AppColors.darkAccent : AppColors.accent),
          ),
          const SizedBox(width: 8),
          Text(
            filteredCount == 0
                ? 'No results found'
                : '$filteredCount result${filteredCount > 1 ? 's' : ''} found',
            style: AppTextStyles.bodySmall.copyWith(
              color: filteredCount == 0
                  ? AppColors.error
                  : (isDark ? AppColors.darkAccent : AppColors.accent),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Body
  Widget _buildBody(EmployeesState employeesState, ChatState chatState, bool isDark) {
    if (employeesState is EmployeesLoading || chatState is ConversationCreating) {
      return _buildLoadingState(isDark);
    }

    if (employeesState is EmployeesError) {
      return _buildErrorState(employeesState.message, isDark);
    }

    if (employeesState is EmployeesLoaded) {
      if (employeesState.filteredEmployees.isEmpty) {
        return _buildEmptyState(isDark);
      }
      return _buildEmployeesList(employeesState.filteredEmployees, isDark);
    }

    return const SizedBox.shrink();
  }

  /// Build Loading State
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.darkAccent : AppColors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading employees...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Error State
  Widget _buildErrorState(String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load employees',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<EmployeesCubit>().fetchEmployees(widget.companyId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState(bool isDark) {
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
              'Try searching with a different name or email',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchController.text.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
                context.read<EmployeesCubit>().searchEmployees('');
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

  /// Build Employees List
  Widget _buildEmployeesList(List<Map<String, dynamic>> employees, bool isDark) {
    return FadeTransition(
      opacity: _animationController,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return _buildEmployeeCard(employee, isDark);
        },
      ),
    );
  }

  /// Build Employee Card
  Widget _buildEmployeeCard(Map<String, dynamic> employee, bool isDark) {
    final name = employee['name'] as String? ?? 'Unknown';
    final email = employee['email'] as String? ?? '';
    final id = employee['id'] as int;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startConversation(id, name),
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
              // Avatar
              Hero(
                tag: 'avatar_$name',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        (isDark ? AppColors.darkPrimary : AppColors.primary)
                            .withOpacity(0.15),
                        (isDark ? AppColors.darkAccent : AppColors.accent)
                            .withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color:
                          (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name.split(' ').take(2).map((n) => n.isNotEmpty ? n[0] : '').join().toUpperCase(),
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

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
                          Icons.email,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email,
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

  /// Start Conversation
  void _startConversation(int userId, String userName) {
    // Create conversation
    context.read<ChatCubit>().createConversation(
          companyId: widget.companyId,
          userIds: [userId],
        );
  }
}
