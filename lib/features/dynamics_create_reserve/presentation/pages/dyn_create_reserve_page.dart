import 'package:PiliPlus/shared/widgets/time_picker.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/presentation/providers/dyn_create_reserve_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:flutter/material.dart' hide showTimePicker;
import 'package:flutter/services.dart'
    show TextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:PiliPlus/utils/toast_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dynamics create reserve page
class DynCreateReservePage extends ConsumerStatefulWidget {
  const DynCreateReservePage({super.key, this.sid});

  final int? sid;

  @override
  ConsumerState<DynCreateReservePage> createState() =>
      _DynCreateReservePageState();
}

class _DynCreateReservePageState extends ConsumerState<DynCreateReservePage> {
  late final TextStyle _leadingStyle;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(
      dynCreateReserveControllerProvider(widget.sid),
    );
    final theme = Theme.of(context);

    _leadingStyle = TextStyle(
      fontSize: 15,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    );
    final padding = MediaQuery.viewPaddingOf(context);
    final divider = [
      const SizedBox(height: 10),
      Divider(
        height: 1,
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
      ),
      const SizedBox(height: 10),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('添加直播预约')),
      body: ListView(
        padding: EdgeInsets.only(
          top: 16,
          left: padding.left + 16,
          right: padding.right + 16,
          bottom: padding.bottom + 100,
        ),
        children: [
          Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 65,
                child: Text('类型', style: _leadingStyle),
              ),
              PopupMenuButton(
                requestFocus: false,
                initialValue: controller.state.subType,
                onSelected: (value) => ref
                    .read(dynCreateReserveControllerProvider(widget.sid))
                    .updateSubType(value),
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 0,
                      child: Text('公开直播'),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text('大航海直播'),
                    ),
                  ];
                },
                child: Text(
                  controller.state.subType == 0 ? '公开直播' : '大航海直播',
                ),
              ),
            ],
          ),
          ...divider,
          Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 65,
                child: Text('时间', style: _leadingStyle),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: controller.state.date,
                      firstDate: controller.now,
                      lastDate: controller.end,
                    );
                    if (newDate != null && context.mounted) {
                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          controller.state.date,
                        ),
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
                              .read(
                                dynCreateReserveControllerProvider(widget.sid),
                              )
                              .updateDate(newEndtime);
                        } else {
                          ToastUtils.showToast('至少选择5分钟之后');
                        }
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      DateFormatUtils.longFormatD.format(controller.state.date),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ...divider,
          _buildInput(
            theme,
            key: ValueKey(controller.key),
            initialValue: controller.state.title,
            onChanged: (value) => ref
                .read(dynCreateReserveControllerProvider(widget.sid))
                .updateTitle(value),
            desc: '标题',
            hintText: '请填写标题，最多14字',
            inputFormatters: [LengthLimitingTextInputFormatter(14)],
          ),
          ...divider,
          const SizedBox(height: 25),
          FilledButton.tonal(
            onPressed: controller.state.canCreate ? _onCreate : null,
            child: const Text('添加预约'),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    ThemeData theme, {
    Key? key,
    String? initialValue,
    required ValueChanged<String> onChanged,
    required String desc,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Row(
      spacing: 12,
      children: [
        SizedBox(
          width: 65,
          child: Text(
            desc,
            style: _leadingStyle,
          ),
        ),
        Expanded(
          child: TextFormField(
            key: key,
            initialValue: initialValue,
            onChanged: onChanged,
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

  Future<void> _onCreate() async {
    final result = await ref
        .read(dynCreateReserveControllerProvider(widget.sid))
        .onCreate();

    if (result case Success(:final response)) {
      final controller = ref.read(
        dynCreateReserveControllerProvider(widget.sid),
      );
      Navigator.of(context).pop(
        ReserveInfoData(
          id: widget.sid ?? response as int,
          title: controller.state.title,
          livePlanStartTime:
              controller.state.date.millisecondsSinceEpoch ~/ 1000,
        ),
      );
    } else {
      result.toast();
    }
  }
}
