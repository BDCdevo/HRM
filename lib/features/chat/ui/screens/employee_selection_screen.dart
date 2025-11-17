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
import 'group_creation_screen.dart';

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

  // Multi-select mode for group creation
  bool _isMultiSelectMode = false;
  final Set<int> _selectedEmployeeIds = {};
  final Map<int, String> _selectedEmployeeNames = {};

  // Search mode
  bool _isSearchMode = false;

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

  /// Toggle multi-select mode
  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedEmployeeIds.clear();
        _selectedEmployeeNames.clear();
      }
    });
  }

  /// Toggle employee selection
  void _toggleEmployeeSelection(int id, String name) {
    setState(() {
      if (_selectedEmployeeIds.contains(id)) {
        _selectedEmployeeIds.remove(id);
        _selectedEmployeeNames.remove(id);
      } else {
        _selectedEmployeeIds.add(id);
        _selectedEmployeeNames[id] = name;
      }
    });
  }

  /// Navigate to group creation screen
  void _navigateToGroupCreation() {
    if (_selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one employee'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to Group Creation Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupCreationScreen(
          companyId: widget.companyId,
          currentUserId: widget.currentUserId,
          selectedEmployeeIds: _selectedEmployeeIds.toList(),
          selectedEmployeeNames: Map<int, String>.from(_selectedEmployeeNames),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: _buildAppBar(isDark),
      floatingActionButton: _isMultiSelectMode && _selectedEmployeeIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToGroupCreation,
              backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
              icon: const Icon(Icons.arrow_forward, color: AppColors.white),
              label: Text(
                'Next',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
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
                  isGroupChat: false, // Private chat
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
              // Directly show body without search bar and results count
              return _buildBody(employeesState, chatState, isDark);
            },
          );
        },
      ),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar(bool isDark) {
    // If in search mode, show search TextField in AppBar
    if (_isSearchMode) {
      return AppBar(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            setState(() {
              _isSearchMode = false;
              _searchController.clear();
            });
            // Clear search in cubit
            context.read<EmployeesCubit>().searchEmployees('');
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(
              color: AppColors.white.withOpacity(0.65),
              fontSize: 17,
            ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            setState(() {}); // Rebuild to show/hide clear button
            context.read<EmployeesCubit>().searchEmployees(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.white),
              onPressed: () {
                _searchController.clear();
                setState(() {});
                context.read<EmployeesCubit>().searchEmployees('');
              },
            ),
        ],
      );
    }

    // Normal AppBar
    return AppBar(
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          _isMultiSelectMode ? Icons.close : Icons.arrow_back,
          color: AppColors.white,
        ),
        onPressed: () {
          if (_isMultiSelectMode) {
            _toggleMultiSelectMode();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isMultiSelectMode
                ? 'Add Group Members'
                : 'New Chat',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _isMultiSelectMode
                ? '${_selectedEmployeeIds.length} selected'
                : 'Select a contact',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        // Search icon
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.white),
          onPressed: () {
            setState(() {
              _isSearchMode = true;
            });
          },
        ),
        const SizedBox(width: 4),
      ],
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
        itemCount: _isMultiSelectMode ? employees.length : employees.length + 1,
        itemBuilder: (context, index) {
          // Show "New Group" option at top (only in normal mode)
          if (!_isMultiSelectMode && index == 0) {
            return _buildNewGroupTile(isDark);
          }

          // Adjust index for employees when "New Group" is shown
          final employeeIndex = _isMultiSelectMode ? index : index - 1;
          final employee = employees[employeeIndex];
          return _buildEmployeeCard(employee, isDark);
        },
      ),
    );
  }

  /// Build "New Group" Tile (WhatsApp Style)
  Widget _buildNewGroupTile(bool isDark) {
    return Column(
      children: [
        InkWell(
          onTap: _toggleMultiSelectMode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
            ),
            child: Row(
              children: [
                // Group Icon with circular background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkAccent : AppColors.accent),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.group,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // "New Group" Text
                Expanded(
                  child: Text(
                    'New group',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Divider
        Divider(
          height: 1,
          thickness: 1,
          color: (isDark ? AppColors.darkBorder : AppColors.border)
              .withOpacity(0.3),
        ),
      ],
    );
  }

  /// Build Employee Card
  Widget _buildEmployeeCard(Map<String, dynamic> employee, bool isDark) {
    final name = employee['name'] as String? ?? 'Unknown';
    final email = employee['email'] as String? ?? '';
    final id = employee['id'] as int;
    final isSelected = _selectedEmployeeIds.contains(id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_isMultiSelectMode) {
            _toggleEmployeeSelection(id, name);
          } else {
            _startConversation(id, name);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isMultiSelectMode && isSelected
                ? (isDark ? AppColors.darkAccent : AppColors.accent)
                    .withOpacity(0.1)
                : (isDark ? AppColors.darkCard : AppColors.white),
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
              // Checkbox (multi-select mode only)
              if (_isMultiSelectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleEmployeeSelection(id, name),
                    activeColor: isDark ? AppColors.darkAccent : AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

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
                      color: isSelected && _isMultiSelectMode
                          ? (isDark ? AppColors.darkAccent : AppColors.accent)
                          : (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withOpacity(0.2),
                      width: isSelected && _isMultiSelectMode ? 3 : 2,
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

              // Start chat icon (single mode) or selected indicator (multi mode)
              if (!_isMultiSelectMode)
                Icon(
                  Icons.chat_bubble_outline,
                  color: (isDark ? AppColors.darkAccent : AppColors.accent)
                      .withOpacity(0.6),
                  size: 22,
                ),
              if (_isMultiSelectMode && isSelected)
                Icon(
                  Icons.check_circle,
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                  size: 24,
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
