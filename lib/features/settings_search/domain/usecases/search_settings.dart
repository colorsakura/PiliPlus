import 'package:PiliPlus/features/settings_search/domain/entities/settings_search_state_entity.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/model.dart';
import 'package:PiliPlus/features/settings_search/domain/repositories/settings_search_repository.dart';

/// Search settings use case
class SearchSettings {
  final SettingsSearchRepository repository;

  const SearchSettings(this.repository);

  /// Perform search
  SettingsSearchStateEntity call(
    String query,
    List<SettingsModel> allSettings,
  ) {
    return repository.search(query, allSettings);
  }

  /// Clear search
  SettingsSearchStateEntity clear() {
    return repository.clear();
  }

  /// Get current state
  SettingsSearchStateEntity getState() {
    return repository.getState();
  }
}
