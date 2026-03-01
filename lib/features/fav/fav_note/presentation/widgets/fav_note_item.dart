import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/select_mask.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';
import 'package:PiliPlus/features/fav/fav_note/presentation/providers/fav_note_list_controller.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart';

class FavNoteItem extends StatelessWidget {
  const FavNoteItem({
    super.key,
    required this.item,
    required this.controller,
    required this.onSelect,
  });

  final FavNoteItemModel item;
  final FavNoteController controller;
  final VoidCallback onSelect;

  void onLongPress() {
    if (!controller.enableMultiSelect) {
      controller.setMultiSelectMode(true);
      onSelect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          if (controller.enableMultiSelect) {
            onSelect();
            return;
          }
          if (item.webUrl?.isNotEmpty == true) {
            PageUtils.handleWebview(
              item.webUrl!,
              inApp: true,
            );
          }
        },
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: StyleString.safeSpace,
            vertical: 5,
          ),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.pic?.isNotEmpty == true)
                AspectRatio(
                  aspectRatio: (16 / 9),
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          NetworkImgLayer(
                            src: item.pic,
                            width: boxConstraints.maxWidth,
                            height: boxConstraints.maxHeight,
                          ),
                          Positioned.fill(
                            child: selectMask(
                              theme,
                              item.checked,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.summary ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.message ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
