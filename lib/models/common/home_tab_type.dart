import 'package:PiliPlus/features/home_hot/presentation/pages/hot_page.dart';
import 'package:PiliPlus/features/home_live/presentation/pages/live_page.dart';
import 'package:PiliPlus/features/home_rcmd/presentation/pages/rcmd_page.dart';
import 'package:PiliPlus/features/home_zone/controller.dart';
import 'package:PiliPlus/features/home_zone/view_v2.dart';
import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:PiliPlus/features/common/presentation/pages/common_controller.dart';
import 'package:PiliPlus/features/pgc/presentation/pages/pgc_controller.dart';
import 'package:PiliPlus/features/pgc/pgc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Riverpod 页面的 ScrollOrRefreshMixin 代理
/// 用于兼容旧的 HomeController 架构
class _RiverpodScrollOrRefreshProxy with ScrollOrRefreshMixin {
  _RiverpodScrollOrRefreshProxy();

  @override
  final ScrollController scrollController = ScrollController();

  @override
  Future<void> onRefresh() async {
    // Riverpod 页面自己处理刷新逻辑
    // 这个代理只是为了满足类型要求
  }

  void dispose() {
    scrollController.dispose();
  }
}

enum HomeTabType implements EnumWithLabel {
  live('直播'),
  rcmd('推荐'),
  hot('热门'),
  rank('分区'),
  bangumi('番剧'),
  cinema('影视')
  ;

  @override
  final String label;
  const HomeTabType(this.label);

  // 为 Riverpod 页面创建代理的缓存
  static final Map<HomeTabType, _RiverpodScrollOrRefreshProxy>
  _riverpodProxies = {};

  ScrollOrRefreshMixin Function() get ctr => switch (this) {
    HomeTabType.live => () => _riverpodProxies.putIfAbsent(
      HomeTabType.live,
      _RiverpodScrollOrRefreshProxy.new,
    ),
    HomeTabType.rcmd => () => _riverpodProxies.putIfAbsent(
      HomeTabType.rcmd,
      _RiverpodScrollOrRefreshProxy.new,
    ),
    HomeTabType.hot => () => _riverpodProxies.putIfAbsent(
      HomeTabType.hot,
      _RiverpodScrollOrRefreshProxy.new,
    ),
    HomeTabType.rank => Get.find<RankController>,
    HomeTabType.bangumi ||
    HomeTabType.cinema => () => Get.find<PgcController>(tag: name),
  };

  Widget get page => switch (this) {
    HomeTabType.live => const LivePage(),
    HomeTabType.rcmd => const RcmdPage(),
    HomeTabType.hot => const HotPage(),
    HomeTabType.rank => const RankPageV2(),
    HomeTabType.bangumi => const PgcPage(tabType: HomeTabType.bangumi),
    HomeTabType.cinema => const PgcPage(tabType: HomeTabType.cinema),
  };
}
