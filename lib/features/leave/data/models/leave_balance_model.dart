import 'package:equatable/equatable.dart';

/// Leave Balance Model
///
/// Represents leave balance for a specific vacation type
class LeaveBalanceModel extends Equatable {
  final int id;
  final String name;
  final int totalBalance;
  final int usedDays;
  final int remainingDays;
  final bool isAvailable;

  const LeaveBalanceModel({
    required this.id,
    required this.name,
    required this.totalBalance,
    required this.usedDays,
    required this.remainingDays,
    required this.isAvailable,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      totalBalance: json['total_balance'] as int,
      usedDays: json['used_days'] as int,
      remainingDays: json['remaining_days'] as int,
      isAvailable: json['is_available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_balance': totalBalance,
      'used_days': usedDays,
      'remaining_days': remainingDays,
      'is_available': isAvailable,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        totalBalance,
        usedDays,
        remainingDays,
        isAvailable,
      ];

  /// Helper getters
  String get totalBalanceFormatted => '$totalBalance days';
  String get usedDaysFormatted => '$usedDays days';
  String get remainingDaysFormatted => '$remainingDays days';

  double get usagePercentage {
    if (totalBalance == 0) return 0;
    return (usedDays / totalBalance * 100).clamp(0, 100);
  }

  // Aliases for UI compatibility
  String get vacationTypeName => name;
  int get total => totalBalance;
  int get used => usedDays;
  int get remaining => remainingDays;
  String? get description => null; // Not provided by API

  int get remainingPercentage {
    if (totalBalance == 0) return 0;
    return ((remainingDays / totalBalance) * 100).round().clamp(0, 100);
  }

  String get availabilityInfo {
    if (isAvailable) {
      return 'Available';
    } else {
      return 'Not available';
    }
  }
}

/// Leave Balance Response Model
///
/// Wrapper for leave balance API response
class LeaveBalanceResponseModel extends Equatable {
  final List<LeaveBalanceModel> balances;
  final int totalRemaining;
  final int year;

  const LeaveBalanceResponseModel({
    required this.balances,
    required this.totalRemaining,
    required this.year,
  });

  factory LeaveBalanceResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    // Handle null or missing balances data
    final balancesData = data['balances'];
    final List<LeaveBalanceModel> balancesList = [];

    if (balancesData != null && balancesData is List) {
      for (var item in balancesData) {
        try {
          balancesList.add(LeaveBalanceModel.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          // Skip invalid items
          continue;
        }
      }
    }

    return LeaveBalanceResponseModel(
      balances: balancesList,
      totalRemaining: data['total_remaining'] as int? ?? 0,
      year: data['year'] as int? ?? DateTime.now().year,
    );
  }

  @override
  List<Object?> get props => [balances, totalRemaining, year];

  /// Get available balances only
  List<LeaveBalanceModel> get availableBalances =>
      balances.where((b) => b.isAvailable).toList();
}
