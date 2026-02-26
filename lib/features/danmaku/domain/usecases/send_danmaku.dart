import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku/domain/entities/danmaku.dart';
import 'package:PiliPlus/features/danmaku/domain/repositories/danmaku_repository.dart';

/// Send danmaku use case
class SendDanmaku {
  final DanmakuRepository repository;

  const SendDanmaku(this.repository);

  Future<LoadingState<DanmakuSendResultEntity>> call({
    required int oid,
    required DanmakuEntity danmaku,
    required String bvid,
    int? checkboxType,
  }) {
    return repository.sendDanmaku(
      oid: oid,
      danmaku: danmaku,
      bvid: bvid,
      checkboxType: checkboxType,
    );
  }
}
