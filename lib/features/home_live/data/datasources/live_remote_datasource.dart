import 'package:PiliPlus/features/home_live/domain/entities/live_area_result.dart';
import 'package:PiliPlus/features/home_live/domain/entities/live_feed_result.dart';
import 'package:PiliPlus/features/home_live/domain/entities/live_stream.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_feed_index/card_data_list_item.dart';
import 'package:PiliPlus/models/live/live_feed_index/card_list.dart';

/// 直播远程数据源
class LiveRemoteDataSource {
  /// 从远程获取直播Feed
  Future<LoadingState<LiveFeedResult>> fetchLiveFeed({
    required int pn,
    bool moduleSelect = false,
  }) async {
    final response = await LiveHttp.liveFeedIndex(
      pn: pn,
      moduleSelect: moduleSelect,
    );

    return switch (response) {
      Success(:final response) => Success(_convertToLiveFeedResult(response)),
      Error(:final errMsg) => Error(errMsg),
      _ => const Error('Unknown error'),
    };
  }

  /// 从远程获取分区直播列表
  Future<LoadingState<LiveAreaResult>> fetchLiveAreaList({
    required int pn,
    int? areaId,
    int? parentAreaId,
    String? sortType,
  }) async {
    final response = await LiveHttp.liveSecondList(
      pn: pn,
      areaId: areaId,
      parentAreaId: parentAreaId,
      sortType: sortType,
    );

    return switch (response) {
      Success(:final response) => Success(_convertToLiveAreaResult(response)),
      Error(:final errMsg) => Error(errMsg),
      _ => const Error('Unknown error'),
    };
  }

  /// 转换为 LiveFeedResult
  LiveFeedResult _convertToLiveFeedResult(dynamic data) {
    final List<LiveStream> streams = [];

    // 处理 cardList，包含 LiveCardList 对象
    if (data.cardList != null) {
      for (final item in data.cardList) {
        if (item is LiveCardList) {
          // LiveCardList 类型
          final smallCardV1 = item.cardData?.smallCardV1;
          if (smallCardV1 != null) {
            streams.add(LiveStream.fromCardLiveItem(smallCardV1));
          }
        } else if (item is CardLiveItem) {
          // CardLiveItem 类型
          streams.add(LiveStream.fromCardLiveItem(item));
        }
      }
    }

    final followingData = data.followItem?.cardData?.myIdolV1;
    final followingItems = followingData?.list;
    final followingCount = followingData?.extraInfo?.totalCount;

    final areaItems = data.areaItem?.cardData?.areaEntranceV3?.list;

    return LiveFeedResult(
      streams: streams,
      hasMore: data.hasMore == 1,
      followingItems: followingItems,
      followingCount: followingCount,
      areaItems: areaItems,
    );
  }

  /// 转换为 LiveAreaResult
  LiveAreaResult _convertToLiveAreaResult(dynamic data) {
    final List<LiveStream> streams = [];

    // 处理 cardList，这里直接是 CardLiveItem 列表
    if (data.cardList != null) {
      for (final item in data.cardList) {
        if (item is CardLiveItem) {
          streams.add(LiveStream.fromCardLiveItem(item));
        }
      }
    }

    return LiveAreaResult(
      streams: streams,
      totalCount: data.count,
      sortTags: data.newTags,
      currentSortType: null,
    );
  }
}
