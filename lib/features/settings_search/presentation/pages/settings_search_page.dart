import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/features/search/presentation/pages/search_controller.dart'
    show DebounceStreamState;
import 'package:PiliPlus/features/setting/presentation/pages/models/extra_settings.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/model.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/play_settings.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/privacy_settings.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/recommend_settings.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/style_settings.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/video_settings.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:waterfall_flow/waterfall_flow.dart'
    hide SliverWaterfallFlowDelegateWithMaxCrossAxisExtent;

class SettingsSearchPage extends StatefulWidget {
  const SettingsSearchPage({super.key});

  @override
  State<SettingsSearchPage> createState() => _SettingsSearchPageState();
}

class _SettingsSearchPageState
    extends DebounceStreamState<SettingsSearchPage, String> {
  final _textEditingController = TextEditingController();
  final RxList<SettingsModel> _list = <SettingsModel>[].obs;
  late final _settings = [
    ...extraSettings,
    ...privacySettings,
    ...recommendSettings,
    ...videoSettings,
    ...playSettings,
    ...styleSettings,
  ];

  @override
  void onValueChanged(String value) {
    if (value.isEmpty) {
      _list.clear();
    } else {
      value = value.toLowerCase();
      _list.value = _settings
          .where(
            (item) =>
                item.effectiveTitle.toLowerCase().contains(value) ||
                item.effectiveSubtitle?.toLowerCase().contains(value) == true,
          )
          .toList();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                _textEditingController.clear();
                _list.clear();
              } else {
                PageUtils.pop();
              }
            },
            icon: const Icon(Icons.clear),
          ),
          const SizedBox(width: 10),
        ],
        title: TextField(
          autofocus: true,
          controller: _textEditingController,
          textAlignVertical: TextAlignVertical.center,
          onChanged: ctr!.add,
          decoration: const InputDecoration(
            isDense: true,
            hintText: '搜索',
            visualDensity: .standard,
            border: InputBorder.none,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          ViewSliverSafeArea(
            sliver: Obx(
              () => _list.isEmpty
                  ? const HttpError()
                  : SliverWaterfallFlow(
                      gridDelegate:
                          SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: Pref.smallCardWidth * 2,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) => _list[index].widget,
                        childCount: _list.length,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
