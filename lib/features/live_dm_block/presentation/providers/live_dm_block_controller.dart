import 'package:flutter/material.dart';
import 'package:PiliPlus/models/common/live/live_dm_silent_type.dart';
import 'package:PiliPlus/models/live/live_dm_block/shield_user_list.dart';
import 'package:PiliPlus/features/live_dm_block/domain/repositories/live_dm_block_repository.dart';
import 'package:PiliPlus/features/live_dm_block/domain/entities/live_dm_block_state.dart';

/// Controller for live danmaku block page (Clean Architecture with Riverpod)
///
/// Manages danmaku shield settings for live rooms:
/// - Shield levels (level, rank, verify)
/// - Shield keywords
/// - Shielded users
/// - Enable/disable all shields
class LiveDmBlockController extends ChangeNotifier {
  LiveDmBlockController({
    required this.roomId,
    required LiveDmBlockRepository repository,
  })  : _repository = repository,
        _state = const LiveDmBlockState() {
    queryData();
  }

  final String roomId;
  final LiveDmBlockRepository _repository;

  LiveDmBlockState _state;
  LiveDmBlockState get state => _state;

  void _updateState(LiveDmBlockState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query live DM block settings
  Future<void> queryData() async {
    final data = await _repository.getLiveDmBlockSettings(roomId);
    _updateState(LiveDmBlockState(
      level: data.level,
      rank: data.rank,
      verify: data.verify,
      isEnable: data.level != 0 || data.rank != 0 || data.verify != 0,
      keywordList: data.keywordList,
      shieldUserList: data.shieldUserList,
    ));
  }

  /// Set silent level for a specific type
  Future<bool> setSilent(LiveDmSilentType type, int level) async {
    final success = await _repository.setSilent(
      type: type.name,
      level: level,
      roomId: roomId,
    );

    if (success) {
      // Update local state
      switch (type) {
        case LiveDmSilentType.level:
          _updateState(_state.copyWith(level: level));
        case LiveDmSilentType.rank:
          _updateState(_state.copyWith(rank: level));
        case LiveDmSilentType.verify:
          _updateState(_state.copyWith(verify: level));
      }
      _updateIsEnabled();
    }
    return success;
  }

  /// Enable or disable all DM shields
  Future<void> setEnable(bool enable) async {
    if (enable == _state.isEnable) return;

    if (enable) {
      // Enable rank and verify shields
      final results = await Future.wait([
        _repository.setSilent(type: LiveDmSilentType.rank.name, level: 1, roomId: roomId),
        _repository.setSilent(type: LiveDmSilentType.verify.name, level: 1, roomId: roomId),
      ]);
      if (results.any((r) => r)) {
        _updateState(_state.copyWith(
          rank: 1,
          verify: 1,
          isEnable: true,
        ));
      }
    } else {
      // Disable all shields
      final results = await Future.wait([
        for (final type in LiveDmSilentType.values)
          _repository.setSilent(type: type.name, level: 0, roomId: roomId),
      ]);
      if (results.every((r) => r)) {
        _updateState(_state.copyWith(
          level: 0,
          rank: 0,
          verify: 0,
          isEnable: false,
        ));
      }
    }
  }

  /// Add shield keyword or user
  Future<bool> addShieldItem(bool isKeyword, String value) async {
    final success = await _repository.addShieldItem(
      isKeyword: isKeyword,
      value: value,
      roomId: roomId,
    );

    if (success) {
      if (isKeyword) {
        final newList = List<String>.from(_state.keywordList);
        newList.insert(0, value);
        _updateState(_state.copyWith(keywordList: newList));
      } else {
        // User was added, need to refresh data to get the ShieldUserList object
        await queryData();
      }
    }
    return success;
  }

  /// Remove shield item (keyword or user)
  Future<bool> removeShieldItem(int index, Object item) async {
    final success = await _repository.removeShieldItem(
      index: index,
      item: item,
      roomId: roomId,
    );

    if (success) {
      if (item is ShieldUserList) {
        final newList = List<ShieldUserList>.from(_state.shieldUserList);
        newList.removeAt(index);
        _updateState(_state.copyWith(shieldUserList: newList));
      } else if (item is String) {
        final newList = List<String>.from(_state.keywordList);
        newList.removeAt(index);
        _updateState(_state.copyWith(keywordList: newList));
      }
    }
    return success;
  }

  void _updateIsEnabled() {
    _updateState(_state.copyWith(
      isEnable: _state.level != 0 || _state.rank != 0 || _state.verify != 0,
    ));
  }
}
