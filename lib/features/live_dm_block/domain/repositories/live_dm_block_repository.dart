import 'package:PiliPlus/models/live/live_dm_block/shield_user_list.dart';

/// Live DM block repository interface
abstract interface class LiveDmBlockRepository {
  /// Get live DM block settings
  Future<LiveDmBlockData> getLiveDmBlockSettings(String roomId);

  /// Set silent level for DM type
  Future<bool> setSilent({
    required String type,
    required int level,
    required String roomId,
  });

  /// Enable/disable DM blocking
  Future<bool> setEnable({
    required bool enable,
    required String roomId,
  });

  /// Add shield keyword or user
  Future<bool> addShieldItem({
    required bool isKeyword,
    required String value,
    required String roomId,
  });

  /// Remove shield item
  Future<bool> removeShieldItem({
    required int index,
    required Object item,
    required String roomId,
  });
}

/// Live DM block data
class LiveDmBlockData {
  final int level;
  final int rank;
  final int verify;
  final List<String> keywordList;
  final List<ShieldUserList> shieldUserList;

  const LiveDmBlockData({
    required this.level,
    required this.rank,
    required this.verify,
    required this.keywordList,
    required this.shieldUserList,
  });
}
