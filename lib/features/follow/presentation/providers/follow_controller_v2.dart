import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/follow/domain/usecases/get_member_card_info_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/get_follow_up_tags_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/create_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/update_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/delete_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_state.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_providers.dart';

part 'follow_controller_v2.g.dart';

/// Controller for follow page functionality (Riverpod version)
///
/// Manages follow-up tags with CRUD operations:
/// - Query follow-up tags for current user
/// - Create new tags
/// - Update tag names
/// - Delete tags
@riverpod
class FollowController extends _$FollowController {
  late int mid;
  late bool isOwner;
  String? userName;

  @override
  FollowState build(int mid, bool isOwner, String? userName) {
    this.mid = mid;
    this.isOwner = isOwner;
    this.userName = userName;

    final initialState = FollowState(tabsState: LoadingState.loading());

    // Query data based on ownership
    if (!isOwner && userName == null) {
      queryUserName();
    }
    if (isOwner) {
      queryFollowUpTags();
    }

    return initialState;
  }

  /// Get tabs list
  List<MemberTagItemModel>? get tabs {
    if (state.tabsState case Success(:final response)) {
      return response;
    }
    return null;
  }

  /// Query user name (for non-owner view)
  Future<void> queryUserName() async {
    final getMemberCardInfoUseCase = ref.read(getMemberCardInfoUseCaseProvider);
    final result = await getMemberCardInfoUseCase(mid);
    if (result case Success(:final response)) {
      state = state.copyWith(
        userName: response.card?.name,
      );
    }
  }

  /// Query follow-up tags (for owner)
  Future<void> queryFollowUpTags() async {
    final getFollowUpTagsUseCase = ref.read(getFollowUpTagsUseCaseProvider);
    final result = await getFollowUpTagsUseCase();
    state = state.copyWith(tabsState: result);
  }

  /// Create a new follow tag
  Future<bool> createTag(String tagName) async {
    final createFollowTagUseCase = ref.read(createFollowTagUseCaseProvider);
    final result = await createFollowTagUseCase(tagName);
    if (result.isSuccess) {
      state = state.copyWith(tabsState: LoadingState.loading());
      await queryFollowUpTags();
      return true;
    }
    return false;
  }

  /// Update a follow tag name
  Future<bool> updateTag(MemberTagItemModel item, String tagName) async {
    final updateFollowTagUseCase = ref.read(updateFollowTagUseCaseProvider);
    final result = await updateFollowTagUseCase(item.tagid!, tagName);
    if (result.isSuccess) {
      // Update local state - just refresh tags since copyWith isn't available
      await queryFollowUpTags();
      return true;
    }
    return false;
  }

  /// Delete a follow tag
  Future<bool> deleteTag(int tagId) async {
    final deleteFollowTagUseCase = ref.read(deleteFollowTagUseCaseProvider);
    final result = await deleteFollowTagUseCase(tagId);
    if (result.isSuccess) {
      state = state.copyWith(tabsState: LoadingState.loading());
      await queryFollowUpTags();
      return true;
    }
    return false;
  }
}
