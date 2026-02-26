import 'package:PiliPlus/features/setting/presentation/pages/models/model.dart';
import 'package:PiliPlus/features/settings_search/data/datasources/settings_search_memory_datasource.dart';
import 'package:PiliPlus/features/settings_search/domain/entities/settings_search_state_entity.dart';
import 'package:PiliPlus/features/settings_search/domain/repositories/settings_search_repository.dart';

/// Settings search repository implementation
class SettingsSearchRepositoryImpl implements SettingsSearchRepository {
  final SettingsSearchMemoryDataSource memoryDataSource;

  const SettingsSearchRepositoryImpl({
    required this.memoryDataSource,
  });

  @override
  SettingsSearchStateEntity getState() {
    return memoryDataSource.getState();
  }

  @override
  SettingsSearchStateEntity search(
    String query,
    List<SettingsModel> allSettings,
  ) {
    final currentState = getState();
    final newState = currentState.search(query, allSettings);
    memoryDataSource.updateState(newState);
    return newState;
  }

  @override
  SettingsSearchStateEntity clear() {
    final newState = const SettingsSearchStateEntity();
    memoryDataSource.updateState(newState);
    return newState;
  }
}
