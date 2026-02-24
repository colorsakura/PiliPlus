import 'package:PiliPlus/features/live_dm_block/domain/repositories/live_dm_block_repository.dart';
import 'package:PiliPlus/features/live_dm_block/data/datasources/live_dm_block_remote_datasource.dart';

/// Repository implementation for live danmaku block
class LiveDmBlockRepositoryImpl implements LiveDmBlockRepository {
  const LiveDmBlockRepositoryImpl(this._datasource);

  final LiveDmBlockRemoteDatasource _datasource;

  @override
  Future<LiveDmBlockData> getLiveDmBlockSettings(String roomId) =>
      _datasource.getLiveDmBlockSettings(roomId);

  @override
  Future<bool> setSilent({
    required String type,
    required int level,
    required String roomId,
  }) =>
      _datasource.setSilent(type: type, level: level, roomId: roomId);

  @override
  Future<bool> setEnable({
    required bool enable,
    required String roomId,
  }) =>
      _datasource.setEnable(enable: enable, roomId: roomId);

  @override
  Future<bool> addShieldItem({
    required bool isKeyword,
    required String value,
    required String roomId,
  }) =>
      _datasource.addShieldItem(
        isKeyword: isKeyword,
        value: value,
        roomId: roomId,
      );

  @override
  Future<bool> removeShieldItem({
    required int index,
    required Object item,
    required String roomId,
  }) =>
      _datasource.removeShieldItem(
        index: index,
        item: item,
        roomId: roomId,
      );
}
