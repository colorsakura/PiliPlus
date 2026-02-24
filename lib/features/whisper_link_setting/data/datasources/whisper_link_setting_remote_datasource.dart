import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/msg/im_user_infos/datum.dart';
import 'package:PiliPlus/models/msg/msg_dnd/uid_setting.dart';
import 'package:PiliPlus/models/msg/session_ss/data.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show SessionId, SessionUpdateReply;
import 'package:PiliPlus/grpc/im.dart';
import 'package:PiliPlus/features/whisper_link_setting/domain/repositories/whisper_link_setting_repository.dart';

/// Remote datasource for whisper link settings
class WhisperLinkSettingRemoteDatasource
    implements WhisperLinkSettingRepository {
  const WhisperLinkSettingRemoteDatasource();

  @override
  Future<LoadingState<List<ImUserInfosData>?>> getUserInfo(String uids) =>
      MsgHttp.imUserInfos(uids: uids);

  @override
  Future<LoadingState<SessionSsData>> getSessionSs(int talkerUid) =>
      MsgHttp.getSessionSs(talkerUid: talkerUid);

  @override
  Future<LoadingState<List<UidSetting>?>> getMsgDnd(int uidsStr) =>
      MsgHttp.getMsgDnd(uidsStr: uidsStr);

  @override
  Future<LoadingState<void>> setPushSs({
    required int setting,
    required int talkerUid,
  }) =>
      MsgHttp.setPushSs(
        setting: setting,
        talkerUid: talkerUid,
      );

  @override
  Future<LoadingState<SessionUpdateReply>> sessionUpdate(SessionId sessionId) =>
      ImGrpc.sessionUpdate(sessionId: sessionId);

  @override
  Future<LoadingState<void>> pinSession(SessionId sessionId) =>
      ImGrpc.pinSession(sessionId: sessionId);

  @override
  Future<LoadingState<void>> unpinSession(SessionId sessionId) =>
      ImGrpc.unpinSession(sessionId: sessionId);

  @override
  Future<LoadingState<void>> setMsgDnd({
    required int uid,
    required int setting,
    required int dndUid,
  }) =>
      MsgHttp.setMsgDnd(
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
      VideoHttp.relationMod(
        mid: mid,
        act: act,
        reSrc: reSrc,
      );
}
