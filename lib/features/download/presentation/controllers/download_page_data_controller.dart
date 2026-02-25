import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:PiliPlus/models/download/download_info.dart';
import 'package:PiliPlus/services/download/download_service.dart';

/// Download page data controller V2 - Riverpod version
///
/// Manages the list of downloaded items
class DownloadPageDataControllerV2 extends ChangeNotifier {
  DownloadPageDataControllerV2(this._downloadService);

  final DownloadService _downloadService;
  List<DownloadPageInfo> _pages = [];
  int _flag = 0;

  List<DownloadPageInfo> get pages => _pages;
  int get flag => _flag;

  @override
  void dispose() {
    _downloadService.flagNotifier.removeListener(_loadList);
    super.dispose();
  }

  void init() {
    _loadList();
    _downloadService.flagNotifier.addListener(_loadList);
  }

  Future<void> _loadList() async {
    await _downloadService.waitForInitialization;

    if (_downloadService.downloadList.isEmpty) {
      _pages = [];
      _flag++;
      notifyListeners();
      return;
    }

    final list = <DownloadPageInfo>[];
    for (final entry in _downloadService.downloadList) {
      final pageId = entry.pageId;
      final page = list.firstWhereOrNull((e) => e.pageId == pageId);
      if (page != null) {
        final aSortKey = entry.sortKey;
        final bSortKey = page.sortKey;
        if (aSortKey < bSortKey) {
          page
            ..cover = entry.cover
            ..sortKey = aSortKey;
        }
        page.entries.add(entry);
      } else {
        list.add(
          DownloadPageInfo(
            pageId: pageId,
            dirPath: entry.pageDirPath,
            title: entry.title,
            cover: entry.cover,
            sortKey: entry.sortKey,
            seasonType: entry.ep?.seasonType,
            entries: [entry],
          ),
        );
      }
    }
    _pages = list;
    _flag++;
    notifyListeners();
  }

  void refreshList() {
    _downloadService.flagNotifier.refresh();
  }
}
