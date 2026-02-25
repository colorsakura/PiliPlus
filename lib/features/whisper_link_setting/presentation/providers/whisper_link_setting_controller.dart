import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/im_user_infos/datum.dart';
import 'package:PiliPlus/models/msg/msg_dnd/uid_setting.dart';
import 'package:PiliPlus/models/msg/session_ss/data.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show SessionId, PrivateId;
import 'package:PiliPlus/features/whisper_link_setting/domain/repositories/whisper_link_setting_repository.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:fixnum/fixnum.dart';

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

/// Controller for whisper link settings
class WhisperLinkSettingController extends ChangeNotifier {
  WhisperLinkSettingController({
    required this.talkerUid,
    required WhisperLinkSettingRepository repository,
  }) : _repository = repository,
       _state = WhisperLinkSettingState(
         userState: LoadingState.loading(),
         sessionSs: LoadingState.loading(),
         msgDnd: LoadingState.loading(),
       ) {
    // Session ID for gRPC calls
    _sessionId = SessionId(
      privateId: PrivateId(talkerUid: Int64(talkerUid)),
    );
  }

  final int talkerUid;
  final WhisperLinkSettingRepository _repository;
  WhisperLinkSettingState _state;
  late final SessionId _sessionId;

  WhisperLinkSettingState get state => _state;

  void _updateState(WhisperLinkSettingState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Initialize controller - load all data
  void initialize() {
    getUserInfo();
    getSessionSs();
    getMsgDnd();
    getIsPinned();
  }

  /// Get user info
  Future<void> getUserInfo() async {
    final result = await _repository.getUserInfo(talkerUid.toString());
    _updateState(_state.copyWith(userState: result));
  }

  /// Get session settings
  Future<void> getSessionSs() async {
    final result = await _repository.getSessionSs(talkerUid);
    _updateState(_state.copyWith(sessionSs: result));
  }

  /// Get message DND settings
  Future<void> getMsgDnd() async {
    final result = await _repository.getMsgDnd(talkerUid);
    _updateState(_state.copyWith(msgDnd: result));
  }

  /// Get pinned status
  Future<void> getIsPinned() async {
    final result = await _repository.sessionUpdate(_sessionId);
    if (result case Success(:final response)) {
      _updateState(_state.copyWith(isPinned: response.session.isPinned));
    }
  }

  /// Set push notification setting
  Future<void> setPush(bool isPush) async {
    final setting = isPush ? 1 : 0;
    final result = await _repository.setPushSs(
      setting: setting,
      talkerUid: talkerUid,
    );
    if (result.isSuccess && _state.sessionSs is Success) {
      final currentResponse = (_state.sessionSs as Success).response;
      _updateState(
        _state.copyWith(
          sessionSs: Success(currentResponse.copyWith(pushSetting: setting)),
        ),
      );
    }
  }

  /// Toggle pin status
  Future<void> setPin() async {
    final result = _state.isPinned
        ? await _repository.unpinSession(_sessionId)
        : await _repository.pinSession(_sessionId);
    if (result.isSuccess) {
      _updateState(_state.copyWith(isPinned: !_state.isPinned));
    }
  }

  /// Set mute setting
  Future<void> setMute(bool isMuted) async {
    final setting = isMuted ? 0 : 1;
    final result = await _repository.setMsgDnd(
      uid: Accounts.main.mid,
      setting: setting,
      dndUid: talkerUid,
    );
    if (result.isSuccess && _state.msgDnd is Success) {
      final currentList = (_state.msgDnd as Success).response;
      if (currentList != null && currentList.isNotEmpty) {
        final updatedList = List<UidSetting>.from(currentList);
        // Note: UidSetting doesn't have copyWith, so we create new instance
        updatedList[0] = UidSetting(
          setting: setting,
          // Copy other fields as needed
        );
        _updateState(_state.copyWith(msgDnd: Success(updatedList)));
      }
    }
  }

  /// Block user
  Future<void> blockUser() async {
    final result = await _repository.relationMod(
      mid: talkerUid,
      act: 5,
      reSrc: 11,
    );
    if (result.isSuccess && _state.sessionSs is Success) {
      final currentResponse = (_state.sessionSs as Success).response;
      _updateState(
        _state.copyWith(
          sessionSs: Success(currentResponse.copyWith(followStatus: 128)),
        ),
      );
    }
  }

  /// Unblock user
  Future<void> unblockUser() async {
    final result = await _repository.relationMod(
      mid: talkerUid,
      act: 6,
      reSrc: 11,
    );
    if (result.isSuccess && _state.sessionSs is Success) {
      final currentResponse = (_state.sessionSs as Success).response;
      _updateState(
        _state.copyWith(
          sessionSs: Success(currentResponse.copyWith(followStatus: null)),
        ),
      );
    }
  }

  /// Get user name for reporting
  String? get userName {
    if (_state.userState case Success(:final response)) {
      return response?.firstOrNull?.name;
    }
    return null;
  }
}
