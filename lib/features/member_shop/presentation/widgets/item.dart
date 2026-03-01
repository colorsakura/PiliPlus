import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/badge.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/space/space_shop/item.dart';
import 'package:flutter/material.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:get/get.dart';

class MemberShopItem extends StatelessWidget {
  const MemberShopItem({
    super.key,
    required this.item,
    required this.maxWidth,
  });

  final SpaceShopItem item;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final belowLabels = item.belowLabels?.map((e) => e.title).join('|');
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: InkWell(
        onTap: () {
          if (item.cardUrl case final cardUrl?) {
            PageUtils.pushNamed(AppRoutes.webview, parameters: {'url': cardUrl});
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImgLayer(
              type: .emote,
              src: item.cover?.url,
              width: maxWidth,
              height: maxWidth,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (belowLabels?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: PBadge(
                        text: belowLabels,
                        type: PBadgeType.shop,
                        size: PBadgeSize.small,
                        isStack: false,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 2,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.netPrice case final netPrice?)
                        Text.rich(
                          style: TextStyle(color: Colors.amber),
                          TextSpan(
                            children: [
                              if (netPrice.pricePrefix?.isNotEmpty == true)
                                TextSpan(
                                  text: '${netPrice.pricePrefix} ',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              TextSpan(
                                text:
                                    '${netPrice.priceSymbol}${netPrice.netPrice}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (item.benefitInfos?.isNotEmpty == true)
                        Text(
                          item.benefitInfos!
                              .map(
                                (e) =>
                                    '${e.prefix ?? ''}${e.amount ?? ''}${e.suffix ?? ''}',
                              )
                              .join('|'),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                  if (item.itemSourceName?.isNotEmpty == true)
                    Text(
                      '来自${item.itemSourceName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
