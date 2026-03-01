import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/music/bgm_recommend_list.dart';
import 'package:PiliPlus/features/music/presentation/providers/music_recommend_controller.dart';
import 'package:PiliPlus/features/music/presentation/widgets/music_video_card_h.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

class MusicRecommendPage extends StatefulWidget {
  const MusicRecommendPage({super.key});

  @override
  State<MusicRecommendPage> createState() => _MusicRecommendPageState();
}

class _MusicRecommendPageState extends State<MusicRecommendPage> {
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
  final MusicRecommendController _controller = Get.putOrFind(
    MusicRecommendController.new,
    tag: (Get.arguments as MusicRecommendArgs).id,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);
    return Material(
      color: theme.colorScheme.surface,
      child: refreshIndicator(
        onRefresh: _controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(theme, padding),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 7,
                left: padding.left,
                right: padding.right,
                bottom: padding.bottom + 100,
              ),
              sliver: Obx(
                () => _buildBody(_controller.loadingState.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<BgmRecommend>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) =>
                    MusicVideoCardH(videoItem: response[index]),
                itemCount: response.length,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _buildAppBar(ThemeData theme, EdgeInsets padding) {
    final info = _controller.musicDetail;
    return SliverAppBar(
      pinned: true,
      title: Row(
        spacing: 12,
        children: [
          NetworkImgLayer(
            width: 40,
            height: 40,
            src: info.mvCover,
            type: ImageType.avatar,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.musicTitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              Obx(() {
                final count = _controller.loadingState.value.dataOrNull?.length;
                return count == null
                    ? const SizedBox.shrink()
                    : Text(
                        '共$count条视频',
                        style: theme.textTheme.labelMedium,
                      );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
