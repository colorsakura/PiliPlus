/// 滚动控制器 Mixin
///
/// 为控制器提供滚动相关的功能
library;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 滚动控制器 Mixin
///
/// 提供分页加载、滚动监听等功能
mixin ScrollControllerMixin on ChangeNotifier {
  late final ScrollController scrollController = ScrollController()
    ..addListener(_onScroll);

  /// 每页数据量
  int get pageSize => 20;

  /// 是否正在加载
  bool _isLoading = false;

  /// 是否没有更多数据
  bool _hasNoMore = false;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 是否没有更多数据
  bool get hasNoMore => _hasNoMore;

  /// 监听滚动事件
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    if (position is ScrollMetrics) {
      // 当滚动到距离底部 200 像素时触发加载
      if (position.pixels >= position.maxScrollExtent - 200) {
        onLoadMore();
      }
    }
  }

  /// 加载更多数据
  ///
  /// 子类需要实现此方法来加载数据
  void onLoadMore();

  /// 开始加载
  void startLoading() {
    _isLoading = true;
    _hasNoMore = false;
    notifyListeners();
  }

  /// 结束加载
  ///
  /// [hasNoMore] - 是否没有更多数据
  void endLoading({bool hasNoMore = false}) {
    _isLoading = false;
    _hasNoMore = hasNoMore;
    notifyListeners();
  }

  /// 重置加载状态
  void resetLoadingState() {
    _isLoading = false;
    _hasNoMore = false;
    notifyListeners();
  }

  /// 滚动到顶部
  void scrollToTop({Duration duration = const Duration(milliseconds: 300)}) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: duration,
        curve: Curves.easeInOut,
      );
    }
  }

  /// 滚动到底部
  void scrollToBottom({Duration duration = const Duration(milliseconds: 300)}) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: duration,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
