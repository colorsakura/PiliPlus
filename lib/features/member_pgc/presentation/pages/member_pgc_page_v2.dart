import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_archive/item.dart';
import 'package:PiliPlus/models/space/space/data.dart';
import 'package:PiliPlus/features/member_pgc/presentation/providers/member_pgc_providers.dart';
import 'package:PiliPlus/features/member_pgc/presentation/providers/member_pgc_controller.dart';
import 'package:PiliPlus/features/member_pgc/presentation/widgets/pgc_card_v_member_pgc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Member PGC (Bangumi) page - V2 with Riverpod
class MemberPgcPageV2 extends ConsumerStatefulWidget {
  const MemberPgcPageV2({
    super.key,
    required this.mid,
    this.initialData,
  });

  final int mid;
  final SpaceData? initialData;

  @override
  ConsumerState<MemberPgcPageV2> createState() => _MemberPgcPageV2State();
}

class _MemberPgcPageV2State extends ConsumerState<MemberPgcPageV2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final MemberPgcController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(
      memberPgcControllerProvider(
        MemberPgcParams(
          mid: widget.mid,
          initialData: widget.initialData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return refreshIndicator(
          onRefresh: _controller.onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  left: StyleString.safeSpace,
                  right: StyleString.safeSpace,
                  top: StyleString.safeSpace,
                  bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
                ),
                sliver: _buildBody(_controller.loadingState),
              ),
            ],
          ),
        );
      },
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth * 0.6,
    childAspectRatio: 0.75,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(52),
  );

  Widget _buildBody(LoadingState<List<SpaceArchiveItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => const SliverToBoxAdapter(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return PgcCardVMemberPgc(
                    item: response[index],
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
