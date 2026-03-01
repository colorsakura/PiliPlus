import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/whisper_link_setting/domain/repositories/whisper_link_setting_repository.dart';
import 'package:PiliPlus/features/whisper_link_setting/presentation/providers/whisper_link_setting_providers.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show SessionId, PrivateId;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/im_user_infos/datum.dart';
import 'package:PiliPlus/models/msg/msg_dnd/uid_setting.dart';
import 'package:PiliPlus/models/msg/session_ss/data.dart';
import 'package:PiliPlus/utils/accounts.dart';

part 'whisper_link_setting_controller_v2.g.dart';

/// State for whisper link settings
class WhisperLinkSettingState {
  const WhisperLinkSettingState({
    required this.userState,
    required this.sessionSs,
    required this.msgDnd,
    this.isPinned = false,
  });

  final LoadingState<List<ImUserInfosData>?> userState;
  final LoadingState<SessionSsData> sessionSs;
  final LoadingState<List<UidSetting>?> msgDnd;
  final bool isPinned;

  WhisperLinkSettingState copyWith({
    LoadingState<List<ImUserInfosData>?>? userState,
    LoadingState<SessionSsData>? sessionSs,
    LoadingState<List<UidSetting>?>? msgDnd,
    bool? isPinned,
  }) {
    return WhisperLinkSettingState(
      userState: userState ?? this.userState,
      sessionSs: sessionSs ?? this.sessionSs,
      msgDnd: msgDnd ?? this.msgDnd,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

/// Controller for whisper link settings (Riverpod version)
@riverpod
class WhisperLinkSettingController extends _$WhisperLinkSettingController {
  @override
  WhisperLinkSettingState build(int talkerUid) {
    // Session ID for gRPC calls
    _sessionId = SessionId(
      privateId: PrivateId(talkerUid: Int64(talkerUid)),
    );

    // Initialize controller - load all data
    initialize();

    return WhisperLinkSettingState(
      userState: LoadingState.loading(),
      sessionSs: LoadingState.loading(),
      msgDnd: LoadingState.loading(),
    );
  }

  late SessionId _sessionId;

  /// Initialize controller - load all data
  void initialize() {
    getUserInfo();
    getSessionSs();
    getMsgDnd();
    getIsPinned();
  }

  /// Get user info
  Future<void> getUserInfo() async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final result = await repository.getUserInfo(talkerUid.toString());
    state = state.copyWith(userState: result);
  }

  /// Get session settings
  Future<void> getSessionSs() async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final result = await repository.getSessionSs(talkerUid);
    state = state.copyWith(sessionSs: result);
  }

  /// Get message DND settings
  Future<void> getMsgDnd() async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final result = await repository.getMsgDnd(talkerUid);
    state = state.copyWith(msgDnd: result);
  }

  /// Get pinned status
  Future<void> getIsPinned() async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final result = await repository.sessionUpdate(_sessionId);
    if (result case Success(:final response)) {
      state = state.copyWith(isPinned: response.session.isPinned);
    }
  }

  /// Set push notification setting
  Future<void> setPush(bool isPush) async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final setting = isPush ? 1 : 0;
    final result = await repository.setPushSs(
      setting: setting,
      talkerUid: talkerUid,
    );
    if (result.isSuccess && state.sessionSs is Success) {
      final currentResponse = (state.sessionSs as Success).response;
      state = state.copyWith(
        sessionSs: Success(currentResponse.copyWith(pushSetting: setting)),
      );
    }
  }

  /// Toggle pin status
  Future<void> setPin() async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final result = state.isPinned
        ? await repository.unpinSession(_sessionId)
        : await repository.pinSession(_sessionId);
    if (result.isSuccess) {
      state = state.copyWith(isPinned: !state.isPinned);
    }
  }

  /// Set mute setting
  Future<void> setMute(bool isMuted) async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final setting = isMuted ? 0 : 1;
    final result = await repository.setMsgDnd(
      uid: Accounts.main.mid,
      setting: setting,
      dndUid: talkerUid,
    );
    if (result.isSuccess && state.msgDnd is Success) {
      final currentList = (state.msgDnd as Success).response;
      if (currentList != null && currentList.isNotEmpty) {
        final updatedList = List<UidSetting>.from(currentList);
        // Note: UidSetting doesn't have copyWith, so we create new instance
        updatedList[0] = UidSetting(
          setting: setting,
          // Copy other fields as needed
        );
        state = state.copyWith(msgDnd: Success(updatedList));
      }
    }
  }

  /// Block user
  Future<void> blockUser() async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final result = await repository.relationMod(
      mid: talkerUid,
      act: 5,
      reSrc: 11,
    );
    if (result.isSuccess && state.sessionSs is Success) {
      final currentResponse = (state.sessionSs as Success).response;
      state = state.copyWith(
        sessionSs: Success(currentResponse.copyWith(followStatus: 128)),
      );
    }
  }

  /// Unblock user
  Future<void> unblockUser() async {
    final repository = ref.read(whisperLinkSettingRepositoryProvider);
    final result = await repository.relationMod(
      mid: talkerUid,
      act: 6,
      reSrc: 11,
    );
    if (result.isSuccess && state.sessionSs is Success) {
      final currentResponse = (state.sessionSs as Success).response;
      state = state.copyWith(
        sessionSs: Success(currentResponse.copyWith(followStatus: null)),
      );
    }
  }

  /// Get user name for reporting
  String? get userName {
    if (state.userState case Success(:final response)) {
      return response?.firstOrNull?.name;
    }
    return null;
  }
}
