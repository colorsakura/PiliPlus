import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';
import 'package:PiliPlus/models/msg/msg_like/data.dart';
import 'package:PiliPlus/models/msg/msg_reply/data.dart';
import 'package:PiliPlus/models/msgfeed_unread/data.dart';
import 'package:PiliPlus/models/single_unread/data.dart';
import 'package:PiliPlus/features/msg/data/datasources/msg_remote_datasource.dart';
import 'package:PiliPlus/features/msg/domain/repositories/msg_repository.dart';

/// Message repository implementation
class MsgRepositoryImpl implements MsgRepository {
  final MsgRemoteDataSource remoteDataSource;

  const MsgRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<MsgReplyData>> getReplyMessages({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      final data = await remoteDataSource.msgFeedReplyMe(
        cursor: cursor,
        cursorTime: cursorTime,
      );
      return Success(data);
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<MsgAtData>> getAtMessages({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      final data = await remoteDataSource.msgFeedAtMe(
        cursor: cursor,
        cursorTime: cursorTime,
      );
      return Success(data);
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<MsgLikeData>> getLikeMessages({
    int? cursor,
    int? cursorTime,
  }) async {
    try {
      final data = await remoteDataSource.msgFeedLikeMe(
        cursor: cursor,
        cursorTime: cursorTime,
      );
      return Success(data);
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<MsgFeedUnreadData>> getMsgFeedUnread() async {
    try {
      final data = await remoteDataSource.msgFeedUnread();
      return Success(data);
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<SingleUnreadData>> getSingleUnread() async {
    try {
      final data = await remoteDataSource.msgUnread();
      return Success(data);
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }
}
