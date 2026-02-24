import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/item.dart';

/// State for dynamics mention functionality
///
/// Manages the UI state for user mentions in dynamic posts,
/// including search results and selected mentions.
class DynMentionState {
  final LoadingState<List<MentionGroup>?> searchResults;
  final Set<MentionItem>? selectedMentions;
  final bool showConfirmButton;

  const DynMentionState({
    required this.searchResults,
    this.selectedMentions,
    this.showConfirmButton = false,
  });

  DynMentionState copyWith({
    LoadingState<List<MentionGroup>?>? searchResults,
    Set<MentionItem>? selectedMentions,
    bool? showConfirmButton,
  }) {
    return DynMentionState(
      searchResults: searchResults ?? this.searchResults,
      selectedMentions: selectedMentions ?? this.selectedMentions,
      showConfirmButton: showConfirmButton ?? this.showConfirmButton,
    );
  }
}
