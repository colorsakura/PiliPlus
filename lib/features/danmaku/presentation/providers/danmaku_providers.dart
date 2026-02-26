import 'package:PiliPlus/features/danmaku/data/datasources/danmaku_remote_datasource.dart' as impl;
import 'package:PiliPlus/features/danmaku/data/datasources/danmaku_remote_datasource_interface.dart';
import 'package:PiliPlus/features/danmaku/data/repositories/danmaku_repository_impl.dart';
import 'package:PiliPlus/features/danmaku/domain/repositories/danmaku_repository.dart';
import 'package:PiliPlus/features/danmaku/domain/usecases/send_danmaku.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Danmaku remote data source provider
final danmakuRemoteDataSourceProvider = Provider<DanmakuRemoteDataSource>((ref) {
  return _DanmakuRemoteDataSourceAdapter();
});

/// Danmaku repository provider
final danmakuRepositoryProvider = Provider<DanmakuRepository>((ref) {
  final remoteDataSource = ref.watch(danmakuRemoteDataSourceProvider);
  return DanmakuRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Send danmaku use case provider
final sendDanmakuUseCaseProvider = Provider<SendDanmaku>((ref) {
  final repository = ref.watch(danmakuRepositoryProvider);
  return SendDanmaku(repository);
});

/// Adapter to use existing DanmakuRemoteDataSource
class _DanmakuRemoteDataSourceAdapter implements DanmakuRemoteDataSource {
  final impl.DanmakuRemoteDataSource _dataSource = impl.DanmakuRemoteDataSource();

  @override
  Future<Map<String, dynamic>> shootDanmaku({
    int type = 1,
    required int oid,
    required String msg,
    int mode = 1,
    required String bvid,
    int? progress,
    int? color,
    int? fontSize,
    int? pool,
    bool colorful = false,
    int? checkboxType,
  }) async {
    return _dataSource.shootDanmaku(
      type: type,
      oid: oid,
      msg: msg,
      mode: mode,
      bvid: bvid,
      progress: progress,
      color: color,
      fontSize: fontSize,
      pool: pool,
      colorful: colorful,
      checkboxType: checkboxType,
    );
  }
}
