import 'package:PiliPlus/features/setting/presentation/pages/models/model.dart';

import 'package:PiliPlus/features/setting/presentation/pages/models/model.dart';

/// Settings search state entity
class SettingsSearchStateEntity {
  final String query;
  final List<SettingsModel> results;

  const SettingsSearchStateEntity({
    this.query = '',
    this.results = const [],
  });

  /// Create initial state
  factory SettingsSearchStateEntity.initial() {
    return const SettingsSearchStateEntity();
  }

  /// Search settings by query
  SettingsSearchStateEntity search(
    String query,
    List<SettingsModel> allSettings,
  ) {
    if (query.isEmpty) {
      return const SettingsSearchStateEntity();
    }

    final lowerQuery = query.toLowerCase();
    final filtered = allSettings.where(
      (item) =>
          item.effectiveTitle.toLowerCase().contains(lowerQuery) ||
          item.effectiveSubtitle?.toLowerCase().contains(lowerQuery) == true,
    ).toList();

    return SettingsSearchStateEntity(
      query: query,
      results: filtered,
    );
  }

  /// Clear search
  SettingsSearchStateEntity clear() {
    return const SettingsSearchStateEntity();
  }

  /// Check if has results
  bool get hasResults => results.isNotEmpty;

  /// Get results count
  int get count => results.length;

  @override
  String toString() =>
      'SettingsSearchStateEntity(query: $query, count: ${results.length})';
}
