import 'package:PiliPlus/features/settings_search/domain/entities/settings_search_state_entity.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/model.dart';

/// Settings search repository interface
abstract class SettingsSearchRepository {
  /// Get current search state
  SettingsSearchStateEntity getState();

  /// Perform search
  SettingsSearchStateEntity search(
    String query,
    List<SettingsModel> allSettings,
  );

  /// Clear search
  SettingsSearchStateEntity clear();
}
