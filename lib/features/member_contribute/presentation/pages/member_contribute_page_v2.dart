import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/space/space/tab2.dart';
import 'package:PiliPlus/features/member_article/member_article.dart';
import 'package:PiliPlus/features/member_audio/member_audio.dart';
import 'package:PiliPlus/features/member_comic/member_comic.dart';
import 'package:PiliPlus/features/member_contribute/presentation/providers/member_contribute_controller.dart';
import 'package:PiliPlus/features/member_opus/member_opus.dart';
import 'package:PiliPlus/features/member_season_series/member_season_series.dart';
import 'package:PiliPlus/features/member_video/member_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Member contribute page (Clean Architecture with Riverpod)
///
/// Displays user's contributed content in tabbed interface:
/// - Videos, articles, opus, audio, comics, season series
class MemberContributePageV2 extends ConsumerStatefulWidget {
  const MemberContributePageV2({
    super.key,
    required this.mid,
    this.heroTag,
    this.initialIndex,
    required this.contributeTab,
    required this.hasSeasonOrSeries,
  });

  final int mid;
  final String? heroTag;
  final int? initialIndex;
  final dynamic contributeTab;
  final bool hasSeasonOrSeries;

  @override
  ConsumerState<MemberContributePageV2> createState() =>
      _MemberContributePageV2State();
}

class _MemberContributePageV2State
    extends ConsumerState<MemberContributePageV2>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  MemberContributeController? _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Create controller
    final contributeTab = widget.contributeTab as SpaceTab2?;
    if (contributeTab == null) {
      return;
    }

    _controller = MemberContributeController(
      contributeTab: contributeTab,
      hasSeasonOrSeries: widget.hasSeasonOrSeries,
      initialIndex: widget.initialIndex,
    );

    // Initialize TabController after first frame when TickerProvider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller != null) {
        _controller!.initTabController(this, widget.initialIndex);
        setState(() {}); // Rebuild to show tabs
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    if (_controller == null) {
      return const SizedBox.shrink();
    }

    final state = _controller!.state;
    final tabs = state.tabs;
    final items = state.items;

    // Single item or no items - show directly
    if (tabs == null || tabs.isEmpty) {
      if (items.isNotEmpty) {
        return _getPageFromType(items.first);
      }
      return const SizedBox.shrink();
    }

    // Multiple tabs
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          isScrollable: true,
          tabs: tabs,
          tabAlignment: TabAlignment.start,
          controller: _controller!.tabController,
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
          labelStyle: TabBarTheme.of(context).labelStyle?.copyWith(fontSize: 14) ??
              const TextStyle(fontSize: 14),
          labelColor: theme.colorScheme.onSecondaryContainer,
          unselectedLabelColor: theme.colorScheme.outline,
        ),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller!.tabController,
            children: items.map(_getPageFromType).toList(),
          ),
        ),
      ],
    );
  }

  Widget _getPageFromType(dynamic item) {
    // Handle both SpaceTab2Item and Map types
    final param = item is SpaceTab2Item ? item.param : item['param'] as String?;
    final title = item is SpaceTab2Item ? item.title : item['title'] as String?;
    final seasonId =
        item is SpaceTab2Item ? item.seasonId : item['seasonId'] as int?;
    final seriesId =
        item is SpaceTab2Item ? item.seriesId : item['seriesId'] as String?;

    return switch (param) {
      'video' => MemberVideo(
        type: ContributeType.video,
        heroTag: widget.heroTag,
        mid: widget.mid,
        title: title,
        isSingle: _controller!.state.tabs == null,
      ),
      'charging_video' => MemberVideo(
        type: ContributeType.charging,
        heroTag: widget.heroTag,
        mid: widget.mid,
        title: title,
      ),
      'article' => MemberArticlePage(
        mid: widget.mid,
      ),
      'opus' => MemberOpus(
        isSingle: _controller!.state.tabs == null,
        heroTag: widget.heroTag,
        mid: widget.mid,
      ),
      'audio' => MemberAudioPage(
        mid: widget.mid,
      ),
      'comic' => MemberComicPage(
        mid: widget.mid,
      ),
      'season_video' => MemberVideo(
        type: ContributeType.season,
        heroTag: widget.heroTag,
        mid: widget.mid,
        seasonId: seasonId is int ? seasonId : int.tryParse(seasonId?.toString() ?? ''),
        title: title,
      ),
      'series' => MemberVideo(
        type: ContributeType.series,
        heroTag: widget.heroTag,
        mid: widget.mid,
        seriesId: seriesId is int ? seriesId : int.tryParse(seriesId?.toString() ?? ''),
        title: title,
      ),
      'ugcSeason' => MemberSeasonSeriesPage(
        mid: widget.mid,
        heroTag: widget.heroTag,
      ),
      _ => Center(child: Text(title ?? '')),
    };
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
