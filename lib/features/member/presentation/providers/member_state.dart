part of 'member_controller.dart';

class MemberState {
  final LoadingState<SpaceData?> loadingState;
  final String? username;
  final int? isFollowed;
  final int relation;
  final SpaceSetting? spaceSetting;
  final List<SpaceTab2>? tab2;
  final List<Tab>? tabs;
  final int contributeInitialIndex;
  final bool? hasSeasonOrSeries;
  final Live? live;
  final int? silence;
  final bool isLoading;

  const MemberState({
    required this.loadingState,
    this.username,
    this.isFollowed,
    this.relation = 0,
    this.spaceSetting,
    this.tab2,
    this.tabs,
    this.contributeInitialIndex = 0,
    this.hasSeasonOrSeries,
    this.live,
    this.silence,
    this.isLoading = false,
  });

  factory MemberState.initial() {
    return MemberState(
      loadingState: LoadingState.loading(),
    );
  }

  MemberState copyWith({
    LoadingState<SpaceData?>? loadingState,
    String? username,
    int? isFollowed,
    int? relation,
    SpaceSetting? spaceSetting,
    List<SpaceTab2>? tab2,
    List<Tab>? tabs,
    int? contributeInitialIndex,
    bool? hasSeasonOrSeries,
    Live? live,
    int? silence,
    bool? isLoading,
  }) {
    return MemberState(
      loadingState: loadingState ?? this.loadingState,
      username: username ?? this.username,
      isFollowed: isFollowed ?? this.isFollowed,
      relation: relation ?? this.relation,
      spaceSetting: spaceSetting ?? this.spaceSetting,
      tab2: tab2 ?? this.tab2,
      tabs: tabs ?? this.tabs,
      contributeInitialIndex:
          contributeInitialIndex ?? this.contributeInitialIndex,
      hasSeasonOrSeries: hasSeasonOrSeries ?? this.hasSeasonOrSeries,
      live: live ?? this.live,
      silence: silence ?? this.silence,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
