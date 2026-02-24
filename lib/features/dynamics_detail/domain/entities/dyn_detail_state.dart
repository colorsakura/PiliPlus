import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/result.dart';

/// State for dynamics detail page
///
/// Contains the dynamic item, comment list state, and UI state.
class DynDetailState {
  final DynamicItemModel dynItem;
  final LoadingState<List<dynamic>> replyState;
  final bool showTitle;
  final int? oid;
  final int? replyType;
  final bool showDynActionBar;

  const DynDetailState({
    required this.dynItem,
    required this.replyState,
    this.showTitle = false,
    this.oid,
    this.replyType,
    required this.showDynActionBar,
  });

  DynDetailState copyWith({
    DynamicItemModel? dynItem,
    LoadingState<List<dynamic>>? replyState,
    bool? showTitle,
    int? oid,
    int? replyType,
    bool? showDynActionBar,
  }) {
    return DynDetailState(
      dynItem: dynItem ?? this.dynItem,
      replyState: replyState ?? this.replyState,
      showTitle: showTitle ?? this.showTitle,
      oid: oid ?? this.oid,
      replyType: replyType ?? this.replyType,
      showDynActionBar: showDynActionBar ?? this.showDynActionBar,
    );
  }
}
