import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/live/data/datasources/live_remote_datasource.dart';
import 'package:PiliPlus/features/live/domain/repositories/live_repository.dart';

/// Live repository implementation
class LiveRepositoryImpl implements LiveRepository {
  final LiveRemoteDataSource remoteDataSource;

  const LiveRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<void>> sendLiveDanmaku({
    required Object roomId,
    required Object msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  }) async {
    try {
      await remoteDataSource.sendLiveMsg(
        roomId: roomId,
        msg: msg,
        dmType: dmType,
        emoticonOptions: emoticonOptions,
        replyMid: replyMid,
        replayDmid: replayDmid,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Error(e.message ?? '发送弹幕失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> getLiveRoomInfo({
    required Object roomId,
    Object? qn,
    bool onlyAudio = false,
  }) async {
    try {
      final data = await remoteDataSource.liveRoomInfo(
        roomId: roomId,
        qn: qn,
        onlyAudio: onlyAudio,
      );
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message ?? '获取直播间信息失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> getLiveRoomInfoH5({
    required Object roomId,
  }) async {
    try {
      final data = await remoteDataSource.liveRoomInfoH5(roomId: roomId);
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message ?? '获取直播间信息失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<List<dynamic>?>> getLiveRoomDanmakuPrefetch({
    required Object roomId,
  }) async {
    try {
      final data = await remoteDataSource.liveRoomDmPrefetch(roomId: roomId);
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message ?? '获取弹幕预取失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }
}
