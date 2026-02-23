import 'package:PiliPlus/features/home_live/domain/entities/live_area_result.dart';
import 'package:PiliPlus/features/home_live/domain/entities/live_feed_result.dart';

/// 直播仓库接口
abstract class LiveRepository {
  /// 获取直播Feed（首页推荐直播）
  ///
  /// [pn] 页码
  /// [moduleSelect] 是否获取模块信息（关注列表、分区入口）
  Future<LiveFeedResult> getLiveFeed({
    required int pn,
    bool moduleSelect = false,
  });

  /// 获取指定分区的直播列表
  ///
  /// [pn] 页码
  /// [areaId] 分区ID
  /// [parentAreaId] 父分区ID
  /// [sortType] 排序类型
  Future<LiveAreaResult> getLiveAreaList({
    required int pn,
    int? areaId,
    int? parentAreaId,
    String? sortType,
  });
}
