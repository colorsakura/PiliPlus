import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/member_comic/presentation/providers/member_comic_list_provider.dart';
import 'package:PiliPlus/features/member_comic/presentation/widgets/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberComicPage extends ConsumerStatefulWidget {
  const MemberComicPage({
    super.key,
    required this.mid,
  });

  final int mid;

  @override
  ConsumerState<MemberComicPage> createState() => _MemberComicPageState();
}

class _MemberComicPageState extends ConsumerState<MemberComicPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(memberComicListControllerProvider(widget.mid));
    final listState = controller.state.listState;

    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: _buildBody(listState, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    LoadingState listState,
    dynamic controller,
  ) {
    return switch (listState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  return MemberComicItem(item: response[index]);
                },
                itemCount: response.length,
              )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
