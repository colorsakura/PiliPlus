import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub/list.dart';
import 'package:PiliPlus/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:PiliPlus/features/subscription/presentation/providers/subscription_controller.dart';
import 'package:PiliPlus/features/subscription/presentation/widgets/item.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

/// Subscription page - V2 with Riverpod
class SubscriptionPageV2 extends ConsumerStatefulWidget {
  const SubscriptionPageV2({super.key});

  @override
  ConsumerState<SubscriptionPageV2> createState() => _SubscriptionPageV2State();
}

class _SubscriptionPageV2State extends ConsumerState<SubscriptionPageV2> {
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 0,
    childAspectRatio: (16 / 9) * 2.2,
  );

  Widget get gridSkeleton => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (_, _) => const VideoCardHSkeleton(),
    itemCount: 10,
  );
  late final SubscriptionController _controller;
  final _account = Accounts.main;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(subscriptionControllerProvider);
    // Initialize with account mid
    if (_account.isLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.init(_account.mid);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('我的订阅')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return refreshIndicator(
            onRefresh: _controller.onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ViewSliverSafeArea(
                  sliver: _buildBody(_controller.loadingState),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(LoadingState<List<SubItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  final item = response[index];
                  return SubItem(
                    item: item,
                    cancelSub: () async {
                      final success = await _controller.cancelSub(item);
                      if (success && mounted) {
                        setState(() {}); // Refresh UI
                      }
                    },
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
