import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/shell/data/datasources/message_remote_datasource.dart';
import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/features/shell/domain/repositories/message_repository.dart';

/// 消息仓库实现
class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource _remoteDataSource;

  MessageRepositoryImpl({
    required MessageRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<UnreadMessage> getUnreadMessage() async {
    final msgUnReadTypes = Pref.msgUnReadTypeV2;
    final count = await _remoteDataSource.getAllUnreadCount(msgUnReadTypes);
    return UnreadMessage.fromCount(count);
  }

  @override
  Future<int> getMsgUnread() {
    final msgUnReadTypes = Pref.msgUnReadTypeV2;
    return _remoteDataSource.getMsgUnread(msgUnReadTypes);
  }

  @override
  Future<int> getMsgFeedUnread() {
    final msgUnReadTypes = Pref.msgUnReadTypeV2;
    return _remoteDataSource.getMsgFeedUnread(msgUnReadTypes);
  }

  @override
  Future<bool> shouldCheckUnread(int lastCheckTime, int period) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastCheckTime) >= period;
  }
}
