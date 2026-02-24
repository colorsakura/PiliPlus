import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';

/// Use case for getting follow-up tags
class GetFollowUpTagsUseCase {
  const GetFollowUpTagsUseCase(this._repository);

  final FollowRepository _repository;

  Future<LoadingState<List<MemberTagItemModel>>> call() =>
      _repository.getFollowUpTags();
}
