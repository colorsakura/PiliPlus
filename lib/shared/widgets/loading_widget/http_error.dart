import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HttpError extends StatelessWidget {
  const HttpError({
    this.isSliver = true,
    this.errMsg,
    this.onReload,
    this.btnText,
    super.key,
  });

  final bool isSliver;
  final String? errMsg;
  final VoidCallback? onReload;
  final String? btnText;

  @override
  Widget build(BuildContext context) {
    return isSliver
        ? SliverToBoxAdapter(child: content(context))
        : SizedBox(width: double.infinity, child: content(context));
  }

  Widget content(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height and scale image accordingly
        final availableHeight = constraints.maxHeight;
        final imageHeight = availableHeight < 300 ? 120.0 : 200.0;
        final topPadding = availableHeight < 300 ? 20.0 : 40.0;
        final middlePadding = availableHeight < 300 ? 15.0 : 30.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: topPadding),
            SvgPicture.asset(
              "assets/images/error.svg",
              height: imageHeight,
            ),
            SizedBox(height: middlePadding),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: SelectableText(
                  errMsg ?? '没有数据',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ),
            if (onReload != null)
              FilledButton.tonal(
                onPressed: onReload,
                style: FilledButton.styleFrom(
                  tapTargetSize: .padded,
                  backgroundColor: theme.colorScheme.primary.withAlpha(20),
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  btnText ?? '点击重试',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            SizedBox(height: 20 + MediaQuery.viewPaddingOf(context).bottom),
          ],
        );
      },
    );
  }
}
