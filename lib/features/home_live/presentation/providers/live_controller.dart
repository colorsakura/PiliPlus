import 'package:PiliPlus/features/home_live/domain/entities/live_stream.dart';
import 'package:PiliPlus/features/home_live/domain/usecases/fetch_live_area_list.dart';
import 'package:PiliPlus/features/home_live/domain/usecases/fetch_live_feed.dart';
import 'package:PiliPlus/features/home_live/presentation/providers/live_providers.dart';
import 'package:PiliPlus/models/live/live_feed_index/card_data_list_item.dart';
import 'package:PiliPlus/models/live/live_second_list/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 直播状态
class LiveControllerState {
  /// 直播流列表
  final List<LiveStream> streams;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? errorMessage;

  /// 是否到达末尾
  final bool isEnd;

  /// 当前页码
  final int currentPage;

  /// 当前分区索引 (0=推荐, 1+=分区)
  final int areaIndex;

  /// 当前分区ID
  final int? areaId;

  /// 当前父分区ID
  final int? parentAreaId;

  /// 当前排序标签索引
  final int tagIndex;

  /// 排序标签列表
  final List<LiveSecondTag>? sortTags;

  /// 当前排序类型
  final String? sortType;

  /// 关注的直播主播列表
  final List<CardLiveItem>? followingItems;

  /// 关注总数
  final int? followingCount;

  /// 分区入口列表
  final List<CardLiveItem>? areaItems;

  const LiveControllerState({
    this.streams = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isEnd = false,
    this.currentPage = 1,
    this.areaIndex = 0,
    this.areaId,
    this.parentAreaId,
    this.tagIndex = 0,
    this.sortTags,
    this.sortType,
    this.followingItems,
    this.followingCount,
    this.areaItems,
  });

  /// 复制并更新
  LiveControllerState copyWith({
    List<LiveStream>? streams,
    bool? isLoading,
    String? errorMessage,
    bool? isEnd,
    int? currentPage,
    int? areaIndex,
    int? areaId,
    int? parentAreaId,
    int? tagIndex,
    List<LiveSecondTag>? sortTags,
    String? sortType,
    List<CardLiveItem>? followingItems,
    int? followingCount,
    List<CardLiveItem>? areaItems,
  }) {
    return LiveControllerState(
      streams: streams ?? this.streams,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      areaIndex: areaIndex ?? this.areaIndex,
      areaId: areaId ?? this.areaId,
      parentAreaId: parentAreaId ?? this.parentAreaId,
      tagIndex: tagIndex ?? this.tagIndex,
      sortTags: sortTags ?? this.sortTags,
      sortType: sortType ?? this.sortType,
      followingItems: followingItems ?? this.followingItems,
      followingCount: followingCount ?? this.followingCount,
      areaItems: areaItems ?? this.areaItems,
    );
  }
}

/// 直播Controller
class LiveController extends Notifier<LiveControllerState> {
  late final FetchLiveFeedUseCase _fetchFeedUseCase;
  late final FetchLiveAreaListUseCase _fetchAreaListUseCase;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  @override
  LiveControllerState build() {
    _fetchFeedUseCase = ref.read(fetchLiveFeedUseCaseProvider);
    _fetchAreaListUseCase = ref.read(fetchLiveAreaListUseCaseProvider);

    // 监听滚动位置，实现加载更多
    scrollController.addListener(_onScroll);

    ref.onDispose(() {
      scrollController.removeListener(_onScroll);
      scrollController.dispose();
    });

    return const LiveControllerState(isLoading: true);
  }

  /// 滚动监听
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    // 当滚动到距离底部 200 像素时触发加载更多
    if (maxScroll - currentScroll < 200 &&
        !state.isLoading &&
        !state.isEnd &&
        state.streams.isNotEmpty) {
      onLoadMore();
    }
  }

  /// 初始化并加载数据
  Future<void> initialize() async {
    // 发起网络请求更新数据
    fetchLive(isRefresh: true);
  }

  /// 获取直播数据
  Future<void> fetchLive({bool isRefresh = true}) async {
    // 防止重复加载
    if (state.isLoading && state.streams.isNotEmpty) return;
    // 防止加载更多时已经到达末尾
    if (!isRefresh && state.isEnd) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      if (state.areaIndex == 0) {
        // 获取推荐直播，不获取模块信息
        await _fetchFeed(isRefresh);
      } else {
        // 获取分区直播
        await _fetchAreaList(isRefresh);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 获取推荐直播
  Future<void> _fetchFeed(bool isRefresh) async {
    final page = isRefresh ? 1 : state.currentPage;

    final result = await _fetchFeedUseCase(
      pn: page,
      moduleSelect: false, // 不获取模块信息，只获取直播列表
    );

    if (isRefresh) {
      state = state.copyWith(
        streams: result.streams,
        isEnd: !result.hasMore,
        currentPage: 1,
        isLoading: false,
        // 保留已有的模块信息，不被null覆盖
        followingItems: result.followingItems ?? state.followingItems,
        followingCount: result.followingCount ?? state.followingCount,
        areaItems: result.areaItems ?? state.areaItems,
      );
    } else {
      if (result.streams.isEmpty) {
        state = state.copyWith(isEnd: true, isLoading: false);
        return;
      }

      final mergedStreams = [...state.streams, ...result.streams];
      state = state.copyWith(
        streams: mergedStreams,
        isEnd: !result.hasMore,
        isLoading: false,
      );
    }

    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  /// 获取分区直播
  Future<void> _fetchAreaList(bool isRefresh) async {
    final page = isRefresh ? 1 : state.currentPage;

    final result = await _fetchAreaListUseCase(
      pn: page,
      areaId: state.areaId,
      parentAreaId: state.parentAreaId,
      sortType: state.sortType,
    );

    if (isRefresh) {
      state = state.copyWith(
        streams: result.streams,
        isEnd: result.isEnd,
        currentPage: 1,
        isLoading: false,
        sortTags: result.sortTags,
      );
    } else {
      if (result.streams.isEmpty) {
        state = state.copyWith(isEnd: true, isLoading: false);
        return;
      }

      final mergedStreams = [...state.streams, ...result.streams];
      state = state.copyWith(
        streams: mergedStreams,
        isEnd: result.isEnd,
        isLoading: false,
      );
    }

    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  /// 选择分区
  void selectArea(int index, CardLiveItem? item) {
    if (state.isLoading) return;
    if (index == state.areaIndex) return;

    state = state.copyWith(
      areaIndex: index,
      tagIndex: 0,
      sortTags: null,
      sortType: null,
      areaId: item?.areaV2Id,
      parentAreaId: item?.areaV2ParentId,
      isEnd: false,
      currentPage: 1,
      streams: [],
    );

    fetchLive(isRefresh: true);
  }

  /// 选择排序标签
  void selectTag(int index, String? sortType) {
    if (state.isLoading) return;

    state = state.copyWith(
      tagIndex: index,
      sortType: sortType,
      isEnd: false,
      currentPage: 1,
      streams: [],
    );

    fetchLive(isRefresh: true);
  }

  /// 刷新
  Future<void> onRefresh() => fetchLive(isRefresh: true);

  /// 加载更多
  Future<void> onLoadMore() => fetchLive(isRefresh: false);

  /// 重新加载
  Future<void> onReload() async {
    state = const LiveControllerState(isLoading: true);
    await onRefresh();
  }

  /// 获取顶部模块信息（关注和分区入口）
  Future<void> fetchTopModules() async {
    try {
      final result = await _fetchFeedUseCase(
        pn: 1,
        moduleSelect: true,
      );

      // 如果当前不在推荐tab，尝试找到对应的分区索引
      // 如果在推荐tab (areaIndex == 0)，保持不变
      int? foundAreaIndex;
      if (state.areaIndex != 0 &&
          state.areaId != null &&
          result.areaItems != null) {
        final idx = result.areaItems!.indexWhere(
          (e) =>
              e.areaV2Id == state.areaId &&
              e.areaV2ParentId == state.parentAreaId,
        );
        if (idx >= 0) {
          foundAreaIndex = idx + 1;
        }
      }

      state = state.copyWith(
        followingItems: result.followingItems,
        followingCount: result.followingCount,
        areaItems: result.areaItems,
        // 只在找到匹配分区时更新 areaIndex
        areaIndex: foundAreaIndex ?? state.areaIndex,
      );
    } catch (_) {
      // 忽略错误，保持原有状态
    }
  }
}
