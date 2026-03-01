import 'package:PiliPlus/shared/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/member_audio/domain/entities/member_audio_item_entity.dart';
import 'package:PiliPlus/features/member_audio/presentation/providers/member_audio_controller.dart';
import 'package:PiliPlus/features/member_audio/presentation/widgets/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pbenum.dart'
    show PlaylistSource;

/// Member audio page using Riverpod
class MemberAudioPage extends ConsumerStatefulWidget {
  const MemberAudioPage({
    super.key,
    required this.mid,
  });

  final int mid;

  @override
  ConsumerState<MemberAudioPage> createState() => _MemberAudioPageState();
}

class _MemberAudioPageState extends ConsumerState<MemberAudioPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(memberAudioControllerProvider(widget.mid));
    final controller = ref.read(memberAudioControllerProvider(widget.mid).notifier);
    final listState = state.listState;
    final colorScheme = ColorScheme.of(context);

    return refreshIndicator(
      onRefresh: () => controller.onRefresh(widget.mid),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: _buildBody(colorScheme, listState, state, controller),
          ),
        ],
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: 2,
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    childAspectRatio: (16 / 9) * 2.6,
    minHeight: MediaQuery.textScalerOf(context).scale(90),
  );

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState listState,
    MemberAudioState state,
    MemberAudioController controller,
  ) {
    return switch (listState) {
      Loading() => linearLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    floating: true,
                    delegate: CustomSliverPersistentHeaderDelegate(
                      extent: 40,
                      bgColor: colorScheme.surface,
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                '共${state.totalSize ?? 0}首',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Container(
                              height: 35,
                              padding: const EdgeInsets.only(left: 6),
                              child: TextButton.icon(
                                onPressed: () => _toViewPlayAll(state),
                                icon: Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 16,
                                  color: colorScheme.secondary,
                                ),
                                label: Text(
                                  '播放全部',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverGrid.builder(
                    gridDelegate: gridDelegate,
                    itemBuilder: (context, index) {
                      if (index == response.length - 1) {
                        controller.onLoadMore(widget.mid);
                      }
                      return MemberAudioItem(
                        item: response[index],
                      );
                    },
                    itemCount: response.length,
                  ),
                ],
              )
            : HttpError(onReload: () => controller.onReload(widget.mid)),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: () => controller.onReload(widget.mid),
      ),
    };
  }

  void _toViewPlayAll(MemberAudioState state) {
    final listState = state.listState;
    if (listState is Success<List<MemberAudioItemEntity>?>) {
      final items = listState.response;
      if (items != null && items.isNotEmpty) {
        final item = items.first;
        AudioPage.toAudioPage(
          itemType: 3,
          id: item.uid!,
          oid: item.id!,
          from: PlaylistSource.MEM_SPACE,
        );
      }
    }
  }
}
