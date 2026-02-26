import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku/data/datasources/danmaku_remote_datasource_interface.dart';
import 'package:PiliPlus/features/danmaku/domain/entities/danmaku.dart';
import 'package:PiliPlus/features/danmaku/domain/repositories/danmaku_repository.dart';

/// Danmaku repository implementation
class DanmakuRepositoryImpl implements DanmakuRepository {
  final DanmakuRemoteDataSource remoteDataSource;

  const DanmakuRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<DanmakuSendResultEntity>> sendDanmaku({
    required int oid,
    required DanmakuEntity danmaku,
    required String bvid,
    int? checkboxType,
  }) async {
    try {
      final rawData = await remoteDataSource.shootDanmaku(
        type: 1,
        oid: oid,
        msg: danmaku.content,
        mode: danmaku.mode,
        bvid: bvid,
        progress: danmaku.progress,
        color: danmaku.color,
        fontSize: danmaku.fontSize,
        pool: danmaku.pool,
        colorful: danmaku.isColorful ?? false,
        checkboxType: checkboxType,
      );

      return Success(
        DanmakuSendResultEntity(
          success: true,
          message: rawData['message'] as String?,
          danmakuId: rawData['danmaku_id']?.toString(),
        ),
      );
    } catch (e) {
      return Error(e.toString());
    }
  }
}
