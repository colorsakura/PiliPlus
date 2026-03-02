import 'dart:math';
import 'package:PiliPlus/utils/toast_utils.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/member/tab_type.dart';
import 'package:PiliPlus/models/space/space/data.dart';
import 'package:PiliPlus/models/space/space/live.dart';
import 'package:PiliPlus/models/space/space/setting.dart';
import 'package:PiliPlus/models/space/space/tab2.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    show ExtendedNestedScrollViewState;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_controller_v2.g.dart';

/// State for member page
class MemberState {
  final LoadingState<SpaceData?> loadingState;
  final String? username;
  final int? isFollowed;
  final int relation;
  final SpaceSetting? spaceSetting;
  final List<SpaceTab2>? tab2;
  final List<Tab>? tabs;
  final int contributeInitialIndex;
  final bool? hasSeasonOrSeries;
  final Live? live;
  final int? silence;
  final bool isLoading;

  const MemberState({
    required this.loadingState,
    this.username,
    this.isFollowed,
    this.relation = 0,
    this.spaceSetting,
    this.tab2,
    this.tabs,
    this.contributeInitialIndex = 0,
    this.hasSeasonOrSeries,
    this.live,
    this.silence,
    this.isLoading = false,
  });

  factory MemberState.initial() {
    return MemberState(
      loadingState: LoadingState.loading(),
    );
  }

  MemberState copyWith({
    LoadingState<SpaceData?>? loadingState,
    String? username,
    int? isFollowed,
    int? relation,
    SpaceSetting? spaceSetting,
    List<SpaceTab2>? tab2,
    List<Tab>? tabs,
    int? contributeInitialIndex,
    bool? hasSeasonOrSeries,
    Live? live,
    int? silence,
    bool? isLoading,
  }) {
    return MemberState(
      loadingState: loadingState ?? this.loadingState,
      username: username ?? this.username,
      isFollowed: isFollowed ?? this.isFollowed,
      relation: relation ?? this.relation,
      spaceSetting: spaceSetting ?? this.spaceSetting,
      tab2: tab2 ?? this.tab2,
      tabs: tabs ?? this.tabs,
      contributeInitialIndex:
          contributeInitialIndex ?? this.contributeInitialIndex,
      hasSeasonOrSeries: hasSeasonOrSeries ?? this.hasSeasonOrSeries,
      live: live ?? this.live,
      silence: silence ?? this.silence,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller for member page functionality (Riverpod version)
///
/// Manages member space information, follow status, and user interactions.
@riverpod
class MemberController extends _$MemberController {
  late final int mid;
  late final String? fromViewAid;
  final account = Accounts.main;
  final key = GlobalKey<ExtendedNestedScrollViewState>();

  @override
  MemberState build(int mid, {String? fromViewAid}) {
    this.mid = mid;
    this.fromViewAid = fromViewAid;

    // Initialize data
    Future.microtask(() => queryData());

    return MemberState.initial();
  }

  Future<void> queryData([bool isRefresh = true]) async {
    state = state.copyWith(isLoading: true);

    final res = await MemberHttp.space(
      mid: mid,
      fromViewAid: fromViewAid,
    );

    if (res case Success(:final response)) {
      _handleSuccessResponse(response);
    } else {
      _handleError(res is Error ? res.errMsg : null);
    }

    state = state.copyWith(isLoading: false);
  }

  void _handleSuccessResponse(SpaceData data) {
    final username = data.card?.name ?? '';
    final isFollowed = data.card?.relation?.isFollowed;
    final relation = data.relation == -1
        ? 128
        : data.card?.relation?.isFollow == 1
        ? data.relSpecial == 1
              ? -10
              : data.card?.relation?.status ?? 2
        : 0;

    final tab2 = data.tab2;
    final live = data.live;
    final silence = data.card?.silence;

    bool? hasSeasonOrSeries;
    if ((data.ugcSeason?.count != null && data.ugcSeason?.count != 0) ||
        data.series?.item?.isNotEmpty == true) {
      hasSeasonOrSeries = true;
    }

    final filteredTab2 = List<SpaceTab2>.from(tab2 ?? []);
    filteredTab2.retainWhere((item) => MemberTabType.contains(item.param!));

    if (filteredTab2.isNotEmpty) {
      if (data.hasItem != true && filteredTab2.first.param == 'home') {
        filteredTab2.removeAt(0);
      }

      if (filteredTab2.isNotEmpty) {
        int initialIndex = -1;
        final memberTab = Pref.memberTab;
        if (memberTab != MemberTabType.def) {
          initialIndex = filteredTab2.indexWhere((item) {
            return item.param == memberTab.name;
          });
        }
        if (initialIndex == -1) {
          var defaultTab = data.defaultTab;
          if (defaultTab == 'video') {
            defaultTab = 'contribute';
          }
          initialIndex = filteredTab2.indexWhere((item) {
            return item.param == defaultTab;
          });
        }

        final tabs = filteredTab2
            .map((item) => Tab(text: item.title ?? ''))
            .toList();
        final contributeInitialIndex = max(0, initialIndex);

        state = state.copyWith(
          loadingState: Success(data),
          username: username,
          isFollowed: isFollowed,
          relation: relation,
          tab2: filteredTab2,
          live: live,
          silence: silence,
          hasSeasonOrSeries: hasSeasonOrSeries,
          tabs: tabs,
          contributeInitialIndex: contributeInitialIndex,
          spaceSetting: mid == account.mid ? data.setting : null,
        );
        return;
      }
    }

    state = state.copyWith(
      loadingState: Success(data),
      username: username,
      isFollowed: isFollowed,
      relation: relation,
      tab2: filteredTab2,
      live: live,
      silence: silence,
      hasSeasonOrSeries: hasSeasonOrSeries,
      spaceSetting: mid == account.mid ? data.setting : null,
    );
  }

  void _handleError(String? errMsg) {
    final fallbackTab2 = const [
      SpaceTab2(title: '动态', param: 'dynamic'),
      SpaceTab2(
        title: '投稿',
        param: 'contribute',
        items: [SpaceTab2Item(title: '视频', param: 'video')],
      ),
      SpaceTab2(title: '收藏', param: 'favorite'),
      SpaceTab2(title: '追番', param: 'bangumi'),
    ];
    final tabs = fallbackTab2.map((item) => Tab(text: item.title)).toList();

    state = state.copyWith(
      loadingState: Error(errMsg ?? '加载失败'),
      username: errMsg,
      tab2: fallbackTab2,
      tabs: tabs,
    );
  }

  Future<void> onReload() => queryData();

  bool get isFollow => state.relation != 0 && state.relation != 128;

  void blockUser(BuildContext context) {
    if (!account.isLogin) {
      ToastUtils.showToast('账号未登录');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(state.relation != 128 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '点错了',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _onBlock();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void shareUser() {
    Utils.shareText('https://space.bilibili.com/$mid');
  }

  Future<void> _onBlock() async {
    final isBlocked = state.relation == 128;
    final res = await VideoHttp.relationMod(
      mid: mid,
      act: isBlocked ? 6 : 5,
      reSrc: 11,
    );
    if (res.isSuccess) {
      state = state.copyWith(relation: isBlocked ? 0 : 128);
    }
  }

  void onFollow(BuildContext context) {
    if (mid == account.mid) {
      Navigator.pushNamed(context, '/editProfile');
    } else if (state.relation == 128) {
      _onBlock();
    } else {
      if (!account.isLogin) {
        ToastUtils.showToast('账号未登录');
        return;
      }
      RequestUtils.actionRelationMod(
        context: context,
        mid: mid,
        isFollow: isFollow,
        afterMod: (attribute) {
          state = state.copyWith(relation: attribute);
        },
      );
    }
  }

  Future<void> onRemoveFan() async {
    final res = await VideoHttp.relationMod(mid: mid, act: 7, reSrc: 11);
    if (res.isSuccess) {
      final newRelation = state.relation == 4 ? 2 : state.relation;
      state = state.copyWith(isFollowed: null, relation: newRelation);
      ToastUtils.showToast('移除成功');
    } else {
      res.toast();
    }
  }

  void onTapTab(int value) {
    if (key.currentState?.outerController.hasClients == true) {
      key.currentState!.outerController.animateTo(
        key.currentState!.outerController.offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> vipExpAdd() async {
    final res = await UserHttp.vipExpAdd();
    if (res.isSuccess) {
      ToastUtils.showToast('领取成功');
    } else {
      res.toast();
    }
  }
}
