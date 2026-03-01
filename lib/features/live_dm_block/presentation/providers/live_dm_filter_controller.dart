import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/models/common/live/live_dm_silent_type.dart';
import 'package:PiliPlus/models/live/live_dm_block/shield_user_list.dart';
import 'package:PiliPlus/features/live_dm_block/domain/repositories/live_dm_block_repository.dart';
import 'package:PiliPlus/features/live_dm_block/domain/entities/live_dm_block_state.dart';
import 'package:PiliPlus/features/live_dm_block/presentation/providers/live_dm_block_providers.dart';

part 'live_dm_filter_controller.g.dart';

/// Controller for live danmaku block page (Riverpod version with family)
///
/// Manages danmaku shield settings for live rooms:
/// - Shield levels (level, rank, verify)
/// - Shield keywords
/// - Shielded users
/// - Enable/disable all shields
@riverpod
class LiveDmFilterController extends _$LiveDmFilterController {
  @override
  LiveDmBlockState build(String roomId) {
    // Fetch data on initialization
    queryData(roomId);
    return const LiveDmBlockState();
  }

  /// Query live DM block settings
  Future<void> queryData(String roomId) async {
    final repository = ref.read(liveDmBlockRepositoryProvider);
    final data = await repository.getLiveDmBlockSettings(roomId);

    state = LiveDmBlockState(
      level: data.level,
      rank: data.rank,
      verify: data.verify,
      isEnable: data.level != 0 || data.rank != 0 || data.verify != 0,
      keywordList: data.keywordList,
      shieldUserList: data.shieldUserList,
    );
  }

  /// Set silent level for a specific type
  Future<bool> setSilent(String roomId, LiveDmSilentType type, int level) async {
    final repository = ref.read(liveDmBlockRepositoryProvider);
    final success = await repository.setSilent(
      type: type.name,
      level: level,
      roomId: roomId,
    );

    if (success) {
      // Update local state
      switch (type) {
        case LiveDmSilentType.level:
          state = state.copyWith(level: level);
        case LiveDmSilentType.rank:
          state = state.copyWith(rank: level);
        case LiveDmSilentType.verify:
          state = state.copyWith(verify: level);
      }
      _updateIsEnabled();
    }
    return success;
  }

  /// Enable or disable all DM shields
  Future<void> setEnable(String roomId, bool enable) async {
    final repository = ref.read(liveDmBlockRepositoryProvider);

    if (enable == state.isEnable) return;

    if (enable) {
      // Enable rank and verify shields
      final results = await Future.wait([
        repository.setSilent(
          type: LiveDmSilentType.rank.name,
          level: 1,
          roomId: roomId,
        ),
        repository.setSilent(
          type: LiveDmSilentType.verify.name,
          level: 1,
          roomId: roomId,
        ),
      ]);
      if (results.any((r) => r)) {
        state = state.copyWith(
          rank: 1,
          verify: 1,
          isEnable: true,
        );
      }
    } else {
      // Disable all shields
      final results = await Future.wait([
        for (final type in LiveDmSilentType.values)
          repository.setSilent(type: type.name, level: 0, roomId: roomId),
      ]);
      if (results.every((r) => r)) {
        state = state.copyWith(
          level: 0,
          rank: 0,
          verify: 0,
          isEnable: false,
        );
      }
    }
  }

  /// Add shield keyword or user
  Future<bool> addShieldItem(String roomId, bool isKeyword, String value) async {
    final repository = ref.read(liveDmBlockRepositoryProvider);
    final success = await repository.addShieldItem(
      isKeyword: isKeyword,
      value: value,
      roomId: roomId,
    );

    if (success) {
      if (isKeyword) {
        final newList = List<String>.from(state.keywordList);
        newList.insert(0, value);
        state = state.copyWith(keywordList: newList);
      } else {
        // User was added, need to refresh data to get the ShieldUserList object
        await queryData(roomId);
      }
    }
    return success;
  }

  /// Remove shield item (keyword or user)
  Future<bool> removeShieldItem(String roomId, int index, Object item) async {
    final repository = ref.read(liveDmBlockRepositoryProvider);
    final success = await repository.removeShieldItem(
      index: index,
      item: item,
      roomId: roomId,
    );

    if (success) {
      if (item is ShieldUserList) {
        final newList = List<ShieldUserList>.from(state.shieldUserList);
        newList.removeAt(index);
        state = state.copyWith(shieldUserList: newList);
      } else if (item is String) {
        final newList = List<String>.from(state.keywordList);
        newList.removeAt(index);
        state = state.copyWith(keywordList: newList);
      }
    }
    return success;
  }

  void _updateIsEnabled() {
    state = state.copyWith(
      isEnable: state.level != 0 || state.rank != 0 || state.verify != 0,
    );
  }
}
