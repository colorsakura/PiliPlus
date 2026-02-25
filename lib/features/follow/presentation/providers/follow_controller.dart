import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/follow/domain/usecases/get_member_card_info_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/get_follow_up_tags_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/create_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/update_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/delete_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_state.dart';

/// Controller for follow page (Clean Architecture with Riverpod)
///
/// Manages follow-up tags with CRUD operations:
/// - Query follow-up tags for current user
/// - Create new tags
/// - Update tag names
/// - Delete tags
class FollowController extends ChangeNotifier {
  FollowController({
    required this.mid,
    required this.isOwner,
    this.userName,
    required GetMemberCardInfoUseCase getMemberCardInfoUseCase,
    required GetFollowUpTagsUseCase getFollowUpTagsUseCase,
    required CreateFollowTagUseCase createFollowTagUseCase,
    required UpdateFollowTagUseCase updateFollowTagUseCase,
    required DeleteFollowTagUseCase deleteFollowTagUseCase,
  }) : _getMemberCardInfoUseCase = getMemberCardInfoUseCase,
       _getFollowUpTagsUseCase = getFollowUpTagsUseCase,
       _createFollowTagUseCase = createFollowTagUseCase,
       _updateFollowTagUseCase = updateFollowTagUseCase,
       _deleteFollowTagUseCase = deleteFollowTagUseCase,
       _state = FollowState(tabsState: LoadingState.loading()) {
    if (!isOwner && userName == null) {
      queryUserName();
    }
    if (isOwner) {
      queryFollowUpTags();
    }
  }

  final int mid;
  final bool isOwner;
  final String? userName;

  final GetMemberCardInfoUseCase _getMemberCardInfoUseCase;
  final GetFollowUpTagsUseCase _getFollowUpTagsUseCase;
  final CreateFollowTagUseCase _createFollowTagUseCase;
  final UpdateFollowTagUseCase _updateFollowTagUseCase;
  final DeleteFollowTagUseCase _deleteFollowTagUseCase;

  FollowState _state;
  FollowState get state => _state;

  void _updateState(FollowState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Get tabs list
  List<MemberTagItemModel>? get tabs {
    if (_state.tabsState case Success(:final response)) {
      return response;
    }
    return null;
  }

  /// Query user name (for non-owner view)
  Future<void> queryUserName() async {
    final result = await _getMemberCardInfoUseCase(mid);
    if (result case Success(:final response)) {
      _updateState(
        _state.copyWith(
          userName: response.card?.name,
        ),
      );
    }
  }

  /// Query follow-up tags (for owner)
  Future<void> queryFollowUpTags() async {
    final result = await _getFollowUpTagsUseCase();
    _updateState(_state.copyWith(tabsState: result));
  }

  /// Create a new follow tag
  Future<bool> createTag(String tagName) async {
    final result = await _createFollowTagUseCase(tagName);
    if (result.isSuccess) {
      _updateState(_state.copyWith(tabsState: LoadingState.loading()));
      await queryFollowUpTags();
      return true;
    }
    return false;
  }

  /// Update a follow tag name
  Future<bool> updateTag(MemberTagItemModel item, String tagName) async {
    final result = await _updateFollowTagUseCase(item.tagid!, tagName);
    if (result.isSuccess) {
      // Update local state - just refresh tags since copyWith isn't available
      await queryFollowUpTags();
      return true;
    }
    return false;
  }

  /// Delete a follow tag
  Future<bool> deleteTag(int tagId) async {
    final result = await _deleteFollowTagUseCase(tagId);
    if (result.isSuccess) {
      _updateState(_state.copyWith(tabsState: LoadingState.loading()));
      await queryFollowUpTags();
      return true;
    }
    return false;
  }
}
