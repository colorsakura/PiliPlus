import 'package:PiliPlus/features/dynamics_mention/domain/entities/dyn_mention_state.dart';
import 'package:PiliPlus/features/dynamics_mention/domain/usecases/search_mentions.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/item.dart';
import 'package:flutter/material.dart';

/// Controller for dynamics mention functionality
///
/// Manages searching for users to mention and tracking selected mentions.
class DynMentionController extends ChangeNotifier {
  final SearchMentions _searchMentions;

  DynMentionState _state = DynMentionState(
    searchResults: LoadingState.loading(),
  );

  DynMentionController(this._searchMentions);

  DynMentionState get state => _state;

  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  /// Search for users to mention
  ///
  /// [keyword] - The search keyword
  Future<void> searchMentions([String? keyword]) async {
    final result = await _searchMentions.call(keyword: keyword);
    _updateState(_state.copyWith(searchResults: result));
  }

  /// Toggle mention selection
  ///
  /// [item] - The mention item to toggle
  /// [value] - Whether the item is selected
  void toggleMention(MentionItem item, bool? value) {
    final selected = Set<MentionItem>.from(_state.selectedMentions ?? {});

    if (value == true) {
      selected.add(item);
    } else {
      selected.remove(item);
    }

    _updateState(
      _state.copyWith(
        selectedMentions: selected,
        showConfirmButton: selected.isNotEmpty,
      ),
    );
  }

  /// Clear selected mentions
  void clearSelection() {
    _updateState(
      _state.copyWith(
        selectedMentions: {},
        showConfirmButton: false,
      ),
    );
  }

  /// Refresh search with current keyword
  Future<void> onRefresh() async {
    clearSelection();
    await searchMentions(controller.text);
  }

  void _updateState(DynMentionState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }
}
