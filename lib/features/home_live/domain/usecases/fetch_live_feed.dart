import 'package:PiliPlus/features/home_live/domain/entities/live_feed_result.dart';
import 'package:PiliPlus/features/home_live/domain/repositories/live_repository.dart';

/// 获取直播Feed用例
class FetchLiveFeedUseCase {
  final LiveRepository _repository;

  const FetchLiveFeedUseCase(this._repository);

  /// 执行用例：获取直播Feed
  ///
  /// [pn] 页码
  /// [moduleSelect] 是否获取模块信息
  Future<LiveFeedResult> call({
    required int pn,
    bool moduleSelect = false,
  }) {
    return _repository.getLiveFeed(
      pn: pn,
      moduleSelect: moduleSelect,
    );
  }
}
