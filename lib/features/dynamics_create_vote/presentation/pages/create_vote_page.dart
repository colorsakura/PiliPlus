import 'dart:io' show File;

import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/time_picker.dart';
import 'package:PiliPlus/features/dynamics_create_vote/presentation/providers/vote_providers.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart' hide showTimePicker;
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Page for creating or editing a vote for a dynamic post
class CreateVotePage extends ConsumerWidget {
  const CreateVotePage({super.key, this.voteId});

  final int? voteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final divider = Divider(
      height: 20,
      thickness: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${voteId != null ? '' : '发起'}投票'),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: padding.left + 16,
          right: padding.right + 16,
          bottom: padding.bottom + 100,
        ),
        children: [
          const Text(
            '投票类型',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          _VoteTypeSelector(
            voteId: voteId,
          ),
          const SizedBox(height: 40),
          _VoteInput(
            voteId: voteId,
            label: 'title',
            desc: '投票标题',
            hintText: '请填写标题',
            inputFormatters: [LengthLimitingTextInputFormatter(32)],
          ),
          divider,
          _VoteInput(
            voteId: voteId,
            label: 'desc',
            desc: '投票说明',
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
          ),
          divider,
          const SizedBox(height: 40),
          _VoteOptionsList(voteId: voteId),
          const SizedBox(height: 40),
          _VoteChoiceSelector(voteId: voteId),
          divider,
          _VoteEndTimePicker(voteId: voteId),
          divider,
          const SizedBox(height: 40),
          _CreateVoteButton(voteId: voteId),
        ],
      ),
    );
  }
}

class _VoteTypeSelector extends ConsumerWidget {
  const _VoteTypeSelector({
    required this.voteId,
  });

  final int? voteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(voteControllerProvider(voteId));
    final state = controller.state;

    return Row(
      spacing: 16,
      children: List.generate(
        2,
        (index) {
          final isEnable = index == state.voteType;
          final style = TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isEnable
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            backgroundColor: isEnable
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent,
            foregroundColor: isEnable
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
          );
          Widget child = TextButton(
            style: style,
            onPressed: () {
              ref.read(voteControllerProvider(voteId)).updateVoteType(index);
            },
            child: Text(
              '${const ['文字', '图片'][index]}投票',
              style: const TextStyle(fontSize: 14, height: 1),
              strutStyle: const StrutStyle(
                height: 1,
                leading: 0,
                fontSize: 14,
              ),
            ),
          );
          if (isEnable) {
            child = Stack(
              clipBehavior: Clip.none,
              children: [
                child,
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(6),
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    child: Icon(
                      size: 10,
                      Icons.check,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          }
          return child;
        },
      ),
    );
  }
}

class _VoteInput extends ConsumerWidget {
  const _VoteInput({
    required this.voteId,
    required this.label,
    required this.desc,
    this.hintText,
    this.inputFormatters,
  });

  final int? voteId;
  final String label;
  final String desc;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(voteControllerProvider(voteId));
    final state = controller.state;
    final leadingStyle = TextStyle(
      fontSize: 15,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    );

    final value = label == 'title' ? state.title : state.description;

    return Row(
      spacing: 12,
      children: [
        SizedBox(
          width: 65,
          child: Text(
            desc,
            style: leadingStyle,
          ),
        ),
        Expanded(
          child: TextFormField(
            key: ValueKey('${state.formKey}$label'),
            initialValue: value,
            onChanged: (v) {
              if (label == 'title') {
                ref.read(voteControllerProvider(voteId)).updateTitle(v);
              } else {
                ref.read(voteControllerProvider(voteId)).updateDescription(v);
              }
            },
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hintText ?? desc,
              hintStyle: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.outline.withValues(alpha: 0.7),
              ),
            ),
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}

class _VoteOptionsList extends ConsumerWidget {
  const _VoteOptionsList({
    required this.voteId,
  });

  final int? voteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(voteControllerProvider(voteId));
    final state = controller.state;
    final leadingStyle = TextStyle(
      fontSize: 15,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    );
    final divider = Divider(
      height: 20,
      thickness: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
    final showImg = state.voteType == 1;
    final showDel = state.options.length > 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < state.options.length; i++)
          Column(
            children: [
              Row(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 65,
                    child: Text(
                      '选项${i + 1}',
                      style: leadingStyle,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      key: ObjectKey(state.options[i]),
                      initialValue: state.options[i].optDesc,
                      onChanged: (value) {
                        ref
                            .read(voteControllerProvider(voteId))
                            .updateOptionDesc(i, value);
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: '选项内容，最多20字',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                  ),
                  if (showImg)
                    GestureDetector(
                      onTap: () => _onPickImg(context, ref, voteId, i),
                      child: NetworkImgLayer(
                        src: state.options[i].imgUrl,
                        width: 40,
                        height: 40,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                    ),
                  if (showDel)
                    iconButton(
                      size: 26,
                      iconSize: 18,
                      tooltip: '移除',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        ref
                            .read(voteControllerProvider(voteId))
                            .removeOption(i);
                      },
                      iconColor: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              if (i < state.options.length - 1) divider,
            ],
          ),
        if (state.options.length < 20)
          FilledButton(
            onPressed: () {
              ref.read(voteControllerProvider(voteId)).addOption();
            },
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.only(
                left: 10,
                right: 14,
                top: 4,
                bottom: 4,
              ),
              visualDensity: .standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              backgroundColor: theme.colorScheme.onInverseSurface,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                Text(
                  ' 添加选项',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _onPickImg(BuildContext context, WidgetRef ref, int? voteId, int index) {
    EasyThrottle.throttle(
      'imagePicker',
      const Duration(milliseconds: 500),
      () async {
        final imagePicker = ImagePicker();
        try {
          XFile? pickedFile = await imagePicker.pickImage(
            imageQuality: 100,
            source: ImageSource.gallery,
          );
          if (pickedFile != null) {
            final path = pickedFile.path;
            final controller = ref.read(voteControllerProvider(voteId));
            controller.uploadOptionImage(index, path).whenComplete(() {
              if (PlatformUtils.isMobile) {
                File(path).tryDel();
              }
            });
          }
        } catch (e) {
          SmartDialog.showToast(e.toString());
        }
      },
    );
  }
}

class _VoteChoiceSelector extends ConsumerWidget {
  const _VoteChoiceSelector({
    required this.voteId,
  });

  final int? voteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(voteControllerProvider(voteId));
    final state = controller.state;
    final leadingStyle = TextStyle(
      fontSize: 15,
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    );

    final choiceCnt = state.choiceCount;
    final choices = List.generate(
      state.options.length,
      (i) => i + 1,
    );

    return Row(
      children: [
        Listener(
          onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          child: PopupMenuButton<int>(
            initialValue: choiceCnt,
            requestFocus: false,
            child: Text(
              choiceCnt == 1 ? '单选         ' : '最多选$choiceCnt项',
            ),
            onSelected: (value) {
              ref.read(voteControllerProvider(voteId)).updateChoiceCount(value);
            },
            itemBuilder: (context) {
              return choices
                  .map(
                    (e) => PopupMenuItem(
                      value: e,
                      child: Text(e == 1 ? '单选' : '最多选$e项'),
                    ),
                  )
                  .toList();
            },
          ),
        ),
        SizedBox(
          width: 100,
          child: Text('单选/多选', style: leadingStyle),
        ),
      ],
    );
  }
}

class _VoteEndTimePicker extends ConsumerWidget {
  const _VoteEndTimePicker({
    required this.voteId,
  });

  final int? voteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(voteControllerProvider(voteId));
    final state = controller.state;
    final leadingStyle = TextStyle(
      fontSize: 15,
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    );

    return Row(
      spacing: 12,
      children: [
        SizedBox(
          width: 100,
          child: Text('投票截止时间', style: leadingStyle),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: state.endTime,
              firstDate: controller.now,
              lastDate: controller.maxEndDate,
            );
            if (newDate != null && context.mounted) {
              TimeOfDay? newTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(state.endTime),
              );
              if (newTime != null) {
                final newEndtime = DateTime(
                  newDate.year,
                  newDate.month,
                  newDate.day,
                  newTime.hour,
                  newTime.minute,
                );
                if (newEndtime.difference(DateTime.now()) >=
                    const Duration(minutes: 5)) {
                  ref
                      .read(voteControllerProvider(voteId))
                      .updateEndTime(newEndtime);
                } else {
                  SmartDialog.showToast('至少选择5分钟之后');
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              DateFormatUtils.longFormatD.format(state.endTime),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateVoteButton extends ConsumerWidget {
  const _CreateVoteButton({
    required this.voteId,
  });

  final int? voteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(voteControllerProvider(voteId));
    final canCreate = controller.state.canCreate;

    return FilledButton.tonal(
      onPressed: canCreate ? () => _onCreate(context, ref, voteId) : null,
      child: const Text('发起投票'),
    );
  }

  Future<void> _onCreate(
    BuildContext context,
    WidgetRef ref,
    int? voteId,
  ) async {
    final controller = ref.read(voteControllerProvider(voteId));
    final res = await controller.createVote();

    if (res case Success()) {
      Get.back(result: controller.voteId);
    } else {
      res.toast();
    }
  }
}
