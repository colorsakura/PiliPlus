import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/dynamics_mention/domain/usecases/search_mentions.dart';
import 'package:PiliPlus/features/dynamics_mention/presentation/providers/dyn_mention_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/item.dart';

part 'dyn_mention_controller_v2.g.dart';

/// State for dynamics mention functionality
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

/// Controller for dynamics mention functionality (Riverpod version)
///
/// Manages searching for users to mention and tracking selected mentions.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.
@riverpod
class DynMentionController extends _$DynMentionController {
  @override
  DynMentionState build() {
    return DynMentionState(
      searchResults: LoadingState.loading(),
    );
  }

  /// Search for users to mention
  ///
  /// [keyword] - The search keyword
  Future<void> searchMentions([String? keyword]) async {
    final searchMentions = ref.read(searchMentionsProvider);
    final result = await searchMentions(keyword: keyword);
    state = state.copyWith(searchResults: result);
  }

  /// Toggle mention selection
  ///
  /// [item] - The mention item to toggle
  /// [value] - Whether the item is selected
  void toggleMention(MentionItem item, bool? value) {
    final selected = Set<MentionItem>.from(state.selectedMentions ?? {});

    if (value == true) {
      selected.add(item);
    } else {
      selected.remove(item);
    }

    state = state.copyWith(
      selectedMentions: selected,
      showConfirmButton: selected.isNotEmpty,
    );
  }

  /// Clear selected mentions
  void clearSelection() {
    state = state.copyWith(
      selectedMentions: {},
      showConfirmButton: false,
    );
  }

  /// Refresh search with current keyword
  Future<void> onRefresh(String keyword) async {
    clearSelection();
    await searchMentions(keyword);
  }

  /// Get selected mentions
  Set<MentionItem>? get selectedMentions => state.selectedMentions;
}
