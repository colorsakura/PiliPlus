import 'package:PiliPlus/common/widgets/scroll_physics.dart';
import 'package:PiliPlus/common/widgets/view_safe_area.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/pages/search_panel/article/view.dart';
import 'package:PiliPlus/pages/search_panel/live/view.dart';
import 'package:PiliPlus/pages/search_panel/pgc/view.dart';
import 'package:PiliPlus/pages/search_panel/user/view.dart';
import 'package:PiliPlus/pages/search_panel/video/view.dart';
import 'package:flutter/material.dart';

/// Search result page (Clean Architecture with Riverpod)
///
/// Note: This page still uses GetX for search panels which haven't been migrated yet.
/// The controller has been migrated to Riverpod but the page maintains GetX
/// for compatibility with the underlying search panels.
class SearchResultPageV2 extends StatefulWidget {
  const SearchResultPageV2({
    super.key,
    required this.keyword,
    this.initialIndex = 0,
    this.isFromSearch = false,
  });

  final String keyword;
  final int initialIndex;
  final bool isFromSearch;

  @override
  State<SearchResultPageV2> createState() => _SearchResultPageV2State();
}

class _SearchResultPageV2State extends State<SearchResultPageV2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Counts for each search type
  final List<int> _counts = List.filled(SearchType.values.length, -1);

  // To-top tracking index
  int _toTopIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      initialIndex: widget.initialIndex,
      length: SearchType.values.length,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabTap(int index) {
    setState(() {
      if (_toTopIndex == index) {
        // Refresh scroll to top (same index to trigger refresh)
        _toTopIndex = -1;
        // Trigger scroll to top in child panels via tag
      } else {
        _toTopIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = DateTime.now().millisecondsSinceEpoch.toString();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: GestureDetector(
          onTap: () {
            // Navigate to search page
            // Note: This uses GetX navigation for now
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              widget.keyword,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
            ),
          ),
        ),
      ),
      body: ViewSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              controller: _tabController,
              tabs: SearchType.values
                  .map(
                    (item) => Tab(
                      text:
                          '${item.label}${_counts[item.index] != -1 ? ' ${_counts[item.index] > 99 ? '99+' : _counts[item.index]}' : ''}',
                    ),
                  )
                  .toList(),
              isScrollable: true,
              indicatorWeight: 0,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 8,
              ),
              indicator: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: theme.colorScheme.onSecondaryContainer,
              labelStyle:
                  TabBarTheme.of(
                    context,
                  ).labelStyle?.copyWith(fontSize: 13) ??
                  const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              unselectedLabelColor: theme.colorScheme.outline,
              tabAlignment: TabAlignment.start,
              onTap: _handleTabTap,
            ),
            Expanded(
              child: tabBarView(
                controller: _tabController,
                children: SearchType.values
                    .map(
                      (item) => switch (item) {
                        SearchType.video => SearchVideoPanel(
                          tag: tag,
                          searchType: item,
                          keyword: widget.keyword,
                        ),
                        SearchType.media_bangumi ||
                        SearchType.media_ft => SearchPgcPanel(
                          tag: tag,
                          searchType: item,
                          keyword: widget.keyword,
                        ),
                        SearchType.live_room => SearchLivePanel(
                          tag: tag,
                          searchType: item,
                          keyword: widget.keyword,
                        ),
                        SearchType.bili_user => SearchUserPanel(
                          tag: tag,
                          searchType: item,
                          keyword: widget.keyword,
                        ),
                        SearchType.article => SearchArticlePanel(
                          tag: tag,
                          searchType: item,
                          keyword: widget.keyword,
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
