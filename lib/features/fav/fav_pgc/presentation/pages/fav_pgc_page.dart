import 'package:PiliPlus/features/fav/fav_pgc/presentation/pages/fav_pgc_child_page.dart';
import 'package:PiliPlus/features/fav/fav_pgc/presentation/providers/fav_pgc_providers.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite PGC page with tabs (想看/在看/看过)
class FavPgcPage extends ConsumerStatefulWidget {
  const FavPgcPage({super.key, required this.type});

  final int type;

  @override
  ConsumerState<FavPgcPage> createState() => _FavPgcPageState();
}

class _FavPgcPageState extends ConsumerState<FavPgcPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
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
                  Tab(text: '想看'),
                  Tab(text: '在看'),
                  Tab(text: '看过'),
                ],
                onTap: (index) {
                  if (!_tabController.indexIsChanging) {
                    final followStatus = index + 1;
                    final controller = ref.read(
                      favPgcControllerProvider(
                        (type: widget.type, followStatus: followStatus),
                      ),
                    );
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
            children: List.generate(
              3,
              (index) => FavPgcChildPage(
                type: widget.type,
                followStatus: index + 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
