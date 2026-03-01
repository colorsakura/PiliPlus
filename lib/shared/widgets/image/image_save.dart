import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void imageSaveDialog({
  required String? title,
  required String? cover,
  dynamic aid,
  String? bvid,
}) {
  final double imgWidth = MediaQuery.sizeOf(Get.context!).shortestSide - 16;
  showDialog(
    context: Get.context!,
    builder: (context) {
      const iconSize = 20.0;
      final theme = Theme.of(context);
      return Container(
        width: imgWidth,
        margin: const .symmetric(horizontal: StyleString.safeSpace),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: StyleString.mdRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: NetworkImgLayer(
                    src: cover,
                    quality: 100,
                    width: imgWidth,
                    height: imgWidth / StyleString.aspectRatio16x9,
                    borderRadius: const .vertical(top: StyleString.imgRadius),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  width: 30,
                  height: 30,
                  child: IconButton(
                    tooltip: '关闭',
                    style: IconButton.styleFrom(
                      padding: .zero,
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: SelectableText(
                        title,
                        style: theme.textTheme.titleSmall,
                      ),
                    )
                  else
                    const Spacer(),
                  if (aid != null || bvid != null)
                    iconButton(
                      iconSize: iconSize,
                      tooltip: '稍后再看',
                      onPressed: () => {
                        Navigator.of(context).pop(),
                        UserHttp.toViewLater(aid: aid, bvid: bvid),
                      },
                      icon: const Icon(Icons.watch_later_outlined),
                    ),
                  if (cover != null && cover.isNotEmpty) ...[
                    if (PlatformUtils.isMobile)
                      iconButton(
                        iconSize: iconSize,
                        tooltip: '分享',
                        onPressed: () {
                          Navigator.of(context).pop();
                          ImageUtils.onShareImg(cover);
                        },
                        icon: const Icon(Icons.share),
                      ),
                    iconButton(
                      iconSize: iconSize,
                      tooltip: '保存封面图',
                      onPressed: () async {
                        bool saveStatus = await ImageUtils.downloadImg([cover]);
                        if (saveStatus) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
