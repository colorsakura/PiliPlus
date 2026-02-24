import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/im_user_infos/datum.dart';
import 'package:PiliPlus/models/msg/msg_dnd/uid_setting.dart';
import 'package:PiliPlus/models/msg/session_ss/data.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';

/// Repository for whisper link settings
abstract class WhisperLinkSettingRepository {
  /// Get user info
  Future<LoadingState<List<ImUserInfosData>?>> getUserInfo(String uids);

  /// Get session settings
  Future<LoadingState<SessionSsData>> getSessionSs(int talkerUid);

  /// Get message DND (do not disturb) settings
  Future<LoadingState<List<UidSetting>?>> getMsgDnd(int uidsStr);

  /// Set push notification setting
  Future<LoadingState<void>> setPushSs({
    required int setting,
    required int talkerUid,
  });

  /// Get/update session (for pin status)
  Future<LoadingState<SessionUpdateReply>> sessionUpdate(SessionId sessionId);

  /// Pin session
  Future<LoadingState<void>> pinSession(SessionId sessionId);

  /// Unpin session
  Future<LoadingState<void>> unpinSession(SessionId sessionId);

  /// Set message DND setting
  Future<LoadingState<void>> setMsgDnd({
    required int uid,
    required int setting,
    required int dndUid,
  });

  /// Modify relation (block/unblock)
  Future<LoadingState<void>> relationMod({
    required int mid,
    required int act,
    required int reSrc,
  });
}
