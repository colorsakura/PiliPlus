import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show KeywordBlockingItem;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/search/presentation/widgets/search_text.dart';
import 'package:PiliPlus/features/whisper_block/domain/entities/whisper_block_state.dart';
import "package:PiliPlus/features/whisper_block/domain/entities/whisper_block_entity.dart";
import 'package:PiliPlus/features/whisper_block/presentation/providers/whisper_block_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhisperBlockPage extends ConsumerStatefulWidget {
  const WhisperBlockPage({
    super.key,
  });

  @override
  ConsumerState<WhisperBlockPage> createState() => _WhisperBlockPageState();
}

class _WhisperBlockPageState extends ConsumerState<WhisperBlockPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controllerState = ref.watch(whisperBlockControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('消息屏蔽词')),
      body: _buildBody(theme, controllerState),
    );
  }

  Widget _buildBody(ThemeData theme, WhisperBlockState controllerState) {
    return switch (controllerState.data) {
      Loading() => loadingWidget,
      Success(:final response) =>
        response == null ? _buildEmptyState() : _buildContent(theme, response),
      Error(:final errMsg) => scrollErrorWidget(
        errMsg: errMsg,
        onReload: () =>
            ref.read(whisperBlockControllerProvider.notifier).onReload(),
      ),
    };
  }

  Widget _buildEmptyState() {
    return Align(
      alignment: const Alignment(0, -0.5),
      child: Column(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/images/error.svg", height: 156),
          const Text(
            '还未添加屏蔽词',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('添加后，将不再接受包含屏蔽词的消息'),
          FilledButton.tonal(
            onPressed: _onAdd,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 22),
                Text('添加'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, WhisperBlockEntity entity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '点击屏蔽词即可删除',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.outline,
                ),
              ),
              if (entity.listLimit != null)
                Text(
                  '${entity.count}/${entity.listLimit}',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: entity.items
                  .map(
                    (e) => SearchText(
                      text: e.keyword,
                      onTap: (keyword) {
                        showConfirmDialog(
                          context: context,
                          title: '删除屏蔽词？',
                          content: '该屏蔽词将不再生效',
                          onConfirm: () => ref
                              .read(whisperBlockControllerProvider.notifier)
                              .removeKeyword(e),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            bottom: MediaQuery.viewPaddingOf(context).bottom + 10,
          ),
          child: FilledButton.tonal(
            onPressed: _onAdd,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.add, size: 22), Text('添加消息屏蔽词')],
            ),
          ),
        ),
      ],
    );
  }

  void _onAdd() {
    String keyword = '';
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final controllerState = ref.watch(whisperBlockControllerProvider);
        final charLimit = switch (controllerState.data) {
          Success(:final response) => response?.charLimit,
          _ => null,
        };

        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12) +
              EdgeInsets.only(
                bottom:
                    MediaQuery.paddingOf(context).bottom +
                    MediaQuery.viewInsetsOf(context).bottom,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '添加消息屏蔽词',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                autofocus: true,
                maxLength: charLimit,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '请输入',
                  visualDensity: VisualDensity.standard,
                  hintStyle: const TextStyle(fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.onInverseSurface,
                ),
                onChanged: (value) => keyword = value,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  if (keyword.isNotEmpty) {
                    ref
                        .read(whisperBlockControllerProvider.notifier)
                        .addKeyword(keyword)
                        .then((success) {
                          if (success) {
                            Navigator.of(context).pop();
                          }
                        });
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.add, size: 22), Text('添加消息屏蔽词')],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
