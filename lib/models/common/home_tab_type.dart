import 'package:PiliPlus/features/home_hot/presentation/pages/hot_page.dart';
import 'package:PiliPlus/features/home_live/presentation/pages/live_page.dart';
import 'package:PiliPlus/features/home_rcmd/presentation/pages/rcmd_page.dart';
import 'package:PiliPlus/features/home_zone/view_v2.dart';
import 'package:PiliPlus/features/pgc/pgc.dart';
import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:flutter/material.dart';

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

  Widget get page => switch (this) {
    HomeTabType.live => const LivePage(),
    HomeTabType.rcmd => const RcmdPage(),
    HomeTabType.hot => const HotPage(),
    HomeTabType.rank => const RankPageV2(),
    HomeTabType.bangumi => const PgcPage(tabType: HomeTabType.bangumi),
    HomeTabType.cinema => const PgcPage(tabType: HomeTabType.cinema),
  };
}
