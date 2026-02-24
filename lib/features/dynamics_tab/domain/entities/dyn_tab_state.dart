import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/result.dart';

/// State for dynamics tab page
///
/// Contains the list of dynamics and pagination info.
class DynTabState {
  final LoadingState<List<DynamicItemModel>?> dynamicsState;
  final String offset;
  final bool isLoadingMore;
  final bool isEnd;

  const DynTabState({
    required this.dynamicsState,
    this.offset = '',
    this.isLoadingMore = false,
    this.isEnd = false,
  });

  DynTabState copyWith({
    LoadingState<List<DynamicItemModel>?>? dynamicsState,
    String? offset,
    bool? isLoadingMore,
    bool? isEnd,
  }) {
    return DynTabState(
      dynamicsState: dynamicsState ?? this.dynamicsState,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}
