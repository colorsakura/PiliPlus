import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';

/// State for follow page
class FollowState {
  const FollowState({
    required this.tabsState,
    this.userName,
  });

  final LoadingState<List<MemberTagItemModel>> tabsState;
  final String? userName;

  FollowState copyWith({
    LoadingState<List<MemberTagItemModel>>? tabsState,
    String? userName,
  }) {
    return FollowState(
      tabsState: tabsState ?? this.tabsState,
      userName: userName ?? this.userName,
    );
  }
}
