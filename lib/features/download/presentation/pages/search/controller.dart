import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/features/common/presentation/pages/multi_select/base.dart'
    show BaseMultiSelectMixin;
import 'package:PiliPlus/features/common/presentation/pages/search/common_search_controller.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DownloadSearchController
    extends
        CommonSearchController<
          List<BiliDownloadEntryInfo>,
          BiliDownloadEntryInfo
        >
    with BaseMultiSelectMixin<BiliDownloadEntryInfo> {
  final _downloadService = Get.find<DownloadService>();

  @override
  List<BiliDownloadEntryInfo> get list => loadingState.value.data!;
  @override
  Rx<LoadingState<List<BiliDownloadEntryInfo>?>> get state => loadingState;

  @override
  Future<LoadingState<List<BiliDownloadEntryInfo>>> customGetData() async {
    final text = editController.text.toLowerCase();
    return Success(
      _downloadService.downloadList
          .where(
            (e) =>
                e.title.toLowerCase().contains(text) ||
                e.showTitle.toLowerCase().contains(text),
          )
          .toList(),
    );
  }

  void onRemoveSingle(int index, BiliDownloadEntryInfo entry) {
    loadingState
      ..value.data!.removeAt(index)
      ..refresh();
    _downloadService.deleteDownload(
      entry: entry,
      removeList: true,
    );
    GStorage.watchProgressRepository.remove(entry.cid.toString());
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: Get.context!,
      title: '确定删除选中视频？',
      onConfirm: () async {
        SmartDialog.showLoading();
        final allChecked = this.allChecked.toSet();
        for (final entry in allChecked) {
          await GStorage.watchProgressRepository.remove(entry.cid.toString());
          await _downloadService.deleteDownload(
            entry: entry,
            removeList: true,
            refresh: false,
          );
        }
        loadingState
          ..value.data!.removeWhere(allChecked.contains)
          ..refresh();
        _downloadService.flagNotifier.refresh();
        if (enableMultiSelect.value) {
          rxCount.value = 0;
          enableMultiSelect.value = false;
        }
        SmartDialog.dismiss();
      },
    );
  }
}
