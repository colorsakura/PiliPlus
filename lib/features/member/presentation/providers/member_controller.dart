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
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'member_state.dart';

class MemberController extends ChangeNotifier {
  MemberController({
    required this.mid,
    required this.ref,
    String? fromViewAid,
  }) : _fromViewAid = fromViewAid {
    _init();
  }

  final int mid;
  final Ref ref;
  final String? _fromViewAid;

  MemberState _state = MemberState.initial();
  MemberState get state => _state;

  final account = Accounts.main;

  final key = GlobalKey<ExtendedNestedScrollViewState>();

  void _updateState(MemberState newState) {
    _state = newState;
    notifyListeners();
  }

  void _init() {
    queryData();
  }

  Future<void> queryData([bool isRefresh = true]) async {
    _updateState(_state.copyWith(isLoading: true));

    final res = await MemberHttp.space(
      mid: mid,
      fromViewAid: _fromViewAid,
    );

    if (res case Success(:final response)) {
      _handleSuccessResponse(response);
    } else {
      _handleError(res is Error ? res.errMsg : null);
    }

    _updateState(_state.copyWith(isLoading: false));
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

        _updateState(
          _state.copyWith(
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
          ),
        );
        return;
      }
    }

    _updateState(
      _state.copyWith(
        loadingState: Success(data),
        username: username,
        isFollowed: isFollowed,
        relation: relation,
        tab2: filteredTab2,
        live: live,
        silence: silence,
        hasSeasonOrSeries: hasSeasonOrSeries,
        spaceSetting: mid == account.mid ? data.setting : null,
      ),
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

    _updateState(
      _state.copyWith(
        loadingState: Error(errMsg ?? '加载失败'),
        username: errMsg,
        tab2: fallbackTab2,
        tabs: tabs,
      ),
    );
  }

  Future<void> onReload() => queryData();

  bool get isFollow => _state.relation != 0 && _state.relation != 128;

  void blockUser(BuildContext context) {
    if (!account.isLogin) {
      ToastUtils.showToast('账号未登录');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(_state.relation != 128 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
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
    final isBlocked = _state.relation == 128;
    final res = await VideoHttp.relationMod(
      mid: mid,
      act: isBlocked ? 6 : 5,
      reSrc: 11,
    );
    if (res.isSuccess) {
      _updateState(_state.copyWith(relation: isBlocked ? 0 : 128));
    }
  }

  void onFollow(BuildContext context) {
    if (mid == account.mid) {
      Navigator.pushNamed(context, '/editProfile');
    } else if (_state.relation == 128) {
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
          _updateState(_state.copyWith(relation: attribute));
        },
      );
    }
  }

  Future<void> onRemoveFan() async {
    final res = await VideoHttp.relationMod(mid: mid, act: 7, reSrc: 11);
    if (res.isSuccess) {
      final newRelation = _state.relation == 4 ? 2 : _state.relation;
      _updateState(
        _state.copyWith(isFollowed: null, relation: newRelation),
      );
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
