import 'dart:convert';
import 'package:PiliPlus/utils/toast_utils.dart';

import 'package:PiliPlus/shared/widgets/pair.dart';
import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/page_utils.dart';

class BarSetPage extends StatefulWidget {
  const BarSetPage({super.key});

  @override
  State<BarSetPage> createState() => _BarSetPageState();
}

class _BarSetPageState extends State<BarSetPage> {
  late final String key;
  late final String title;
  late final List<Pair<EnumWithLabel, bool>> list;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments;
    key = args['key'];
    title = args['title'];
    final cacheJson = GStorage.settingRepository.getString(key);
    final List? cache =
        cacheJson != null ? List<dynamic>.from(jsonDecode(cacheJson)) : null;
    list = (args['defaultBars'] as List<EnumWithLabel>)
        .map((e) => Pair(first: e, second: cache?.contains(e.index) ?? true))
        .toList();
    if (cache != null && cache.isNotEmpty) {
      final cacheIndex = {for (final (k, v) in cache.indexed) v: k};
      list.sort((a, b) {
        final indexA = cacheIndex[a.first.index] ?? cacheIndex.length;
        final indexB = cacheIndex[b.first.index] ?? cacheIndex.length;
        return indexA.compareTo(indexB);
      });
    }
  }

  void saveEdit() {
    GStorage.settingRepository.setString(
      key,
      jsonEncode(list.where((e) => e.second).map((e) => e.first.index).toList()),
    );
    ToastUtils.showToast('保存成功，下次启动时生效');
  }

  void onReset() {
    PageUtils.pop();
    GStorage.settingRepository.remove(key);
    ToastUtils.showToast('重置成功，下次启动时生效');
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    list.insert(newIndex, list.removeAt(oldIndex));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('$title编辑'),
        actions: [
          TextButton(onPressed: onReset, child: const Text('重置')),
          TextButton(onPressed: saveEdit, child: const Text('保存')),
          const SizedBox(width: 12),
        ],
      ),
      body: ReorderableListView(
        onReorder: onReorder,
        footer: Padding(
          padding:
              MediaQuery.viewPaddingOf(context).copyWith(top: 0, left: 0) +
              const EdgeInsets.only(right: 34, top: 10),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Text('*长按拖动排序'),
          ),
        ),
        children: list
            .map(
              (e) => CheckboxListTile(
                key: ValueKey(e.hashCode),
                value: e.second,
                onChanged: (bool? value) {
                  e.second = value!;
                  setState(() {});
                },
                title: Text(e.first.label),
                secondary: const Icon(Icons.drag_indicator_rounded),
              ),
            )
            .toList(),
      ),
    );
  }
}
