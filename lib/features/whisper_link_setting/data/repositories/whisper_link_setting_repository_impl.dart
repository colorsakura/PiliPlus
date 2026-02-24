import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/im_user_infos/datum.dart';
import 'package:PiliPlus/models/msg/msg_dnd/uid_setting.dart';
import 'package:PiliPlus/models/msg/session_ss/data.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show SessionId, SessionUpdateReply;
import 'package:PiliPlus/features/whisper_link_setting/domain/repositories/whisper_link_setting_repository.dart';
import 'package:PiliPlus/features/whisper_link_setting/data/datasources/whisper_link_setting_remote_datasource.dart';

/// Repository implementation for whisper link settings
class WhisperLinkSettingRepositoryImpl
    implements WhisperLinkSettingRepository {
  const WhisperLinkSettingRepositoryImpl(this._remoteDatasource);

  final WhisperLinkSettingRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<ImUserInfosData>?>> getUserInfo(String uids) =>
      _remoteDatasource.getUserInfo(uids);

  @override
  Future<LoadingState<SessionSsData>> getSessionSs(int talkerUid) =>
      _remoteDatasource.getSessionSs(talkerUid);

  @override
  Future<LoadingState<List<UidSetting>?>> getMsgDnd(int uidsStr) =>
      _remoteDatasource.getMsgDnd(uidsStr);

  @override
  Future<LoadingState<void>> setPushSs({
    required int setting,
    required int talkerUid,
  }) =>
      _remoteDatasource.setPushSs(
        setting: setting,
        talkerUid: talkerUid,
      );

  @override
  Future<LoadingState<SessionUpdateReply>> sessionUpdate(SessionId sessionId) =>
      _remoteDatasource.sessionUpdate(sessionId);

  @override
  Future<LoadingState<void>> pinSession(SessionId sessionId) =>
      _remoteDatasource.pinSession(sessionId);

  @override
  Future<LoadingState<void>> unpinSession(SessionId sessionId) =>
      _remoteDatasource.unpinSession(sessionId);

  @override
  Future<LoadingState<void>> setMsgDnd({
    required int uid,
    required int setting,
    required int dndUid,
  }) =>
      _remoteDatasource.setMsgDnd(
        uid: uid,
        setting: setting,
        dndUid: dndUid,
      );

  @override
  Future<LoadingState<void>> relationMod({
    required int mid,
    required int act,
    required int reSrc,
  }) =>
      _remoteDatasource.relationMod(
        mid: mid,
        act: act,
        reSrc: reSrc,
      );
}
