import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/features/fav/fav_note/presentation/providers/fav_note_list_controller.dart';
import 'package:PiliPlus/features/fav/fav_note/presentation/providers/fav_note_providers.dart';
import 'package:PiliPlus/features/fav/fav_note/presentation/pages/fav_note_child_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite notes page with tabs (unpublished/published)
class FavNotePage extends ConsumerStatefulWidget {
  const FavNotePage({super.key});

  @override
  ConsumerState<FavNotePage> createState() => _FavNotePageState();
}

class _FavNotePageState extends ConsumerState<FavNotePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                dividerHeight: 0,
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
                labelStyle:
                    TabBarTheme.of(context).labelStyle?.copyWith(fontSize: 14) ??
                        const TextStyle(fontSize: 14),
                labelColor: theme.colorScheme.onSecondaryContainer,
                unselectedLabelColor: theme.colorScheme.outline,
                tabs: const [
                  Tab(text: '未发布笔记'),
                  Tab(text: '公开笔记'),
                ],
                onTap: (index) {
                  if (!_tabController.indexIsChanging) {
                    final isPublish = index == 1;
                    final controller = ref.read(favNoteControllerProvider(isPublish));
                    controller.scrollController.animToTop();
                  }
                },
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              FavNoteChildPage(isPublish: false),
              FavNoteChildPage(isPublish: true),
            ],
          ),
        ),
      ],
    );
  }
}
