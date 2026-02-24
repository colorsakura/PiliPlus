import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:PiliPlus/features/dynamics/domain/entities/dynamic_item.dart';
import 'package:PiliPlus/features/dynamics/presentation/widgets/dynamic_panel.dart';

/// Widget displaying a single dynamic post.
///
/// This widget delegates to the existing DynamicPanel widget.
/// TODO: Migrate DynamicPanel to clean architecture
class DynamicPanelWidget extends ConsumerWidget {
  const DynamicPanelWidget({
    super.key,
    required this.item,
    this.onRemove,
    this.onBlock,
    this.maxWidth,
    this.onUnfold,
  });

  final DynamicItemEntity item;
  final void Function(String idStr)? onRemove;
  final void Function()? onBlock;
  final double? maxWidth;
  final VoidCallback? onUnfold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DynamicPanel(
        item: item.model,
        onRemove: (idStr) => onRemove?.call(idStr.toString()),
        onBlock: onBlock,
        onUnfold: onUnfold,
        maxWidth: maxWidth ?? 800,
      ),
    );
  }
}
