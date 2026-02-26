import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/models/live/live_dm_block/shield_user_list.dart';
import 'package:PiliPlus/features/live_dm_block/domain/repositories/live_dm_block_repository.dart';

/// Remote datasource for live danmaku block
class LiveDmBlockRemoteDatasource implements LiveDmBlockRepository {
  const LiveDmBlockRemoteDatasource();

  @override
  Future<LiveDmBlockData> getLiveDmBlockSettings(String roomId) async {
    final res = await LiveHttp.getLiveInfoByUser(roomId);
    if (res case Success(:final response)) {
      final shieldRules = response?.shieldRules;
      final keywords = response?.keywordList ?? [];
      final users = response?.shieldUserList ?? [];

      return LiveDmBlockData(
        level: shieldRules?.level ?? 0,
        rank: shieldRules?.rank ?? 0,
        verify: shieldRules?.verify ?? 0,
        keywordList: keywords,
        shieldUserList: users,
      );
    }
    // Return empty data on error
    return const LiveDmBlockData(
      level: 0,
      rank: 0,
      verify: 0,
      keywordList: [],
      shieldUserList: [],
    );
  }

  @override
  Future<bool> setSilent({
    required String type,
    required int level,
    required String roomId,
  }) async {
    final res = await LiveHttp.liveSetSilent(type: type, level: level);
    return res.isSuccess;
  }

  @override
  Future<bool> setEnable({
    required bool enable,
    required String roomId,
  }) async {
    // This is handled by multiple setSilent calls
    // The implementation will be in the use case or controller
    return true;
  }

  @override
  Future<bool> addShieldItem({
    required bool isKeyword,
    required String value,
    required String roomId,
  }) async {
    if (isKeyword) {
      final res = await LiveHttp.addShieldKeyword(keyword: value);
      return res.isSuccess;
    } else {
      final res = await LiveHttp.liveShieldUser(
        uid: value,
        roomid: roomId,
        type: 1,
      );
      return res.isSuccess;
    }
  }

  @override
  Future<bool> removeShieldItem({
    required int index,
    required Object item,
    required String roomId,
  }) async {
    if (item is ShieldUserList) {
      final res = await LiveHttp.liveShieldUser(
        uid: item.uid!,
        roomid: roomId,
        type: 0,
      );
      return res.isSuccess;
    } else if (item is String) {
      final res = await LiveHttp.delShieldKeyword(keyword: item);
      return res.isSuccess;
    }
    return false;
  }
}
