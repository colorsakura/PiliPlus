import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:PiliPlus/features/dynamics/domain/entities/dynamics_tab.dart';
import 'package:PiliPlus/features/dynamics/presentation/providers/dynamics_tab_controller.dart';
import 'package:PiliPlus/features/dynamics/presentation/pages/dynamics_tab_page.dart';
import 'package:PiliPlus/features/dynamics/presentation/widgets/up_panel_widget.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/common/dynamic/up_panel_position.dart';
import 'package:PiliPlus/features/dynamics_create/dynamics_create.dart';

/// Main dynamics page with clean architecture.
///
/// This page displays the dynamics feed with tabs for different content types
/// and an optional UP panel showing followed creators.
class DynamicsPage extends ConsumerStatefulWidget {
  const DynamicsPage({super.key});

  @override
  ConsumerState<DynamicsPage> createState() => _DynamicsPageState();
}

class _DynamicsPageState extends ConsumerState<DynamicsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabConfig = ref.read(dynamicsTabControllerProvider);
    _tabController = TabController(
      length: DynamicsTabType.values.length,
      vsync: this,
      initialIndex: tabConfig.defaultTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _createDynamicBtn(ThemeData theme, {bool isRight = true}) => Center(
        child: Container(
          width: 34,
          height: 34,
          margin: EdgeInsets.only(
            left: !isRight ? 16 : 0,
            right: isRight ? 16 : 0,
          ),
          child: IconButton(
            tooltip: '发布动态',
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              backgroundColor: WidgetStatePropertyAll(
                theme.colorScheme.secondaryContainer,
              ),
            ),
            onPressed: () {
              // TODO: Check login status
              CreateDynPanel.onCreateDyn(context);
            },
            icon: Icon(
              Icons.add,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      );

  Widget upPanelPart(ThemeData theme, UpPanelPosition position) {
    final isTop = position == UpPanelPosition.top;
    final needBg = position.index > 2;
    return Material(
      type: needBg ? MaterialType.canvas : MaterialType.transparency,
      color: needBg ? theme.colorScheme.surface : null,
      child: SizedBox(
        width: isTop ? null : 64,
        height: isTop ? 76 : null,
        child: UpPanelWidget(
          tabController: _tabController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upPanelPositionStr = ref.watch(
      dynamicsTabControllerProvider.select((config) => config.getUpPanelPosition()),
    );

    final upPanelPosition = UpPanelPosition.values.firstWhere(
      (e) => e.name == upPanelPositionStr,
      orElse: () => UpPanelPosition.top,
    );

    Widget? drawer;
    Widget? endDrawer;
    Widget? leading;
    List<Widget>? actions;

    Widget child = TabBarView(
      controller: _tabController,
      children: DynamicsTabType.values
          .map((type) => DynamicsTabPage(dynamicsType: type))
          .toList(),
    );

    switch (upPanelPosition) {
      case UpPanelPosition.top:
        child = Column(
          children: [
            upPanelPart(theme, upPanelPosition),
            Expanded(child: child),
          ],
        );
        actions = [_createDynamicBtn(theme)];
      case UpPanelPosition.leftFixed:
        child = Row(
          children: [
            upPanelPart(theme, upPanelPosition),
            Expanded(child: child),
          ],
        );
        actions = [_createDynamicBtn(theme)];
      case UpPanelPosition.rightFixed:
        child = Row(
          children: [
            Expanded(child: child),
            upPanelPart(theme, upPanelPosition),
          ],
        );
        actions = [_createDynamicBtn(theme)];
      case UpPanelPosition.leftDrawer:
        drawer = upPanelPart(theme, upPanelPosition);
        actions = [_createDynamicBtn(theme)];
      case UpPanelPosition.rightDrawer:
        endDrawer = upPanelPart(theme, upPanelPosition);
        leading = _createDynamicBtn(theme, isRight: false);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        primary: false,
        leading: leading,
        leadingWidth: 50,
        toolbarHeight: 50,
        backgroundColor: Colors.transparent,
        title: SizedBox(
          height: 50,
          child: TabBar(
            dividerHeight: 0,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            dividerColor: Colors.transparent,
            labelColor: theme.colorScheme.primary,
            indicatorColor: theme.colorScheme.primary,
            controller: _tabController,
            unselectedLabelColor: theme.colorScheme.onSurface,
            labelStyle:
                TabBarTheme.of(context).labelStyle?.copyWith(fontSize: 13) ??
                    const TextStyle(fontSize: 13),
            tabs: DynamicsTabType.values
                .map((e) => Tab(text: e.label))
                .toList(),
            onTap: (index) {
              if (!_tabController.indexIsChanging) {
                // TODO: Scroll to top
              }
            },
          ),
        ),
        actions: actions,
      ),
      drawer: drawer,
      endDrawer: endDrawer,
      body: child,
    );
  }
}
