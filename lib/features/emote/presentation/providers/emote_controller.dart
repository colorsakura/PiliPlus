import 'package:PiliPlus/features/emote/domain/usecases/get_emote_packages.dart';
import 'package:PiliPlus/features/emote/presentation/providers/emote_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/emote/package.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// 表情页面状态
class EmoteState {
  /// 加载状态
  final LoadingState<List<Package>?> loadingState;

  /// Tab控制器(用于表情包分类)
  final TabController? tabController;

  const EmoteState({
    required this.loadingState,
    this.tabController,
  });

  /// 复制并更新状态
  EmoteState copyWith({
    LoadingState<List<Package>?>? loadingState,
    TabController? tabController,
  }) {
    return EmoteState(
      loadingState: loadingState ?? this.loadingState,
      tabController: tabController ?? this.tabController,
    );
  }
}

/// 表情Controller
///
/// 使用Riverpod管理表情页面的状态
class EmoteController extends Notifier<EmoteState> {
  late final GetEmotePackagesUseCase _getEmotePackagesUseCase;
  TickerProvider? _vsync;

  /// 设置TickerProvider用于创建TabController
  void setTickerProvider(TickerProvider vsync) {
    _vsync = vsync;
  }

  @override
  EmoteState build() {
    _getEmotePackagesUseCase = ref.read(getEmotePackagesUseCaseProvider);
    return EmoteState(
      loadingState: LoadingState.loading(),
    );
  }

  /// 获取表情包列表
  Future<void> fetchEmotePackages({String business = 'reply'}) async {
    state = state.copyWith(loadingState: LoadingState.loading());
    final result = await _getEmotePackagesUseCase.call(business: business);

    // 如果成功且包含数据,创建TabController
    if (result case Success(:final response)) {
      if (response != null &&
          response.isNotEmpty &&
          _vsync != null &&
          state.tabController == null) {
        final tabController = TabController(
          length: response.length,
          vsync: _vsync!,
        );
        state = state.copyWith(
          loadingState: result,
          tabController: tabController,
        );
        return;
      }
    }

    state = state.copyWith(loadingState: result);
  }

  /// 重新加载数据
  void onReload() {
    fetchEmotePackages();
  }
}
