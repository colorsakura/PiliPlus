import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku/domain/entities/danmaku.dart';

/// Danmaku repository interface
abstract class DanmakuRepository {
  /// Send danmaku
  Future<LoadingState<DanmakuSendResultEntity>> sendDanmaku({
    required int oid,
    required DanmakuEntity danmaku,
    required String bvid,
    int? checkboxType,
  });
}
