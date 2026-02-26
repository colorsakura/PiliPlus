import 'package:PiliPlus/models/live/live_dm_block/shield_user_list.dart';

/// Live DM block state
class LiveDmBlockState {
  final int level;
  final int rank;
  final int verify;
  final bool isEnable;
  final List<String> keywordList;
  final List<ShieldUserList> shieldUserList;

  const LiveDmBlockState({
    this.level = 0,
    this.rank = 0,
    this.verify = 0,
    this.isEnable = false,
    this.keywordList = const [],
    this.shieldUserList = const [],
  });

  LiveDmBlockState copyWith({
    int? level,
    int? rank,
    int? verify,
    bool? isEnable,
    List<String>? keywordList,
    List<ShieldUserList>? shieldUserList,
  }) {
    return LiveDmBlockState(
      level: level ?? this.level,
      rank: rank ?? this.rank,
      verify: verify ?? this.verify,
      isEnable: isEnable ?? this.isEnable,
      keywordList: keywordList ?? this.keywordList,
      shieldUserList: shieldUserList ?? this.shieldUserList,
    );
  }

  /// Check if DM blocking is enabled
  bool get isBlockingEnabled => level != 0 || rank != 0 || verify != 0;
}
