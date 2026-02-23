import 'package:PiliPlus/features/home_live/domain/entities/live_area_result.dart';
import 'package:PiliPlus/features/home_live/domain/repositories/live_repository.dart';

/// 获取直播分区列表用例
class FetchLiveAreaListUseCase {
  final LiveRepository _repository;

  const FetchLiveAreaListUseCase(this._repository);

  /// 执行用例：获取指定分区的直播列表
  ///
  /// [pn] 页码
  /// [areaId] 分区ID
  /// [parentAreaId] 父分区ID
  /// [sortType] 排序类型
  Future<LiveAreaResult> call({
    required int pn,
    int? areaId,
    int? parentAreaId,
    String? sortType,
  }) {
    return _repository.getLiveAreaList(
      pn: pn,
      areaId: areaId,
      parentAreaId: parentAreaId,
      sortType: sortType,
    );
  }
}
