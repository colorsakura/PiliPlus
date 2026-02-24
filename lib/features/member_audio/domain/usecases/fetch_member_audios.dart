import 'package:PiliPlus/features/member_audio/domain/entities/member_audio_item_entity.dart';
import 'package:PiliPlus/features/member_audio/domain/repositories/member_audio_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member audios
class FetchMemberAudiosUseCase {
  const FetchMemberAudiosUseCase(this._repository);

  final MemberAudioRepository _repository;

  /// Execute the use case
  ///
  /// [mid] - Member ID
  /// [page] - Page number (1-indexed)
  Future<LoadingState<List<MemberAudioItemEntity>>> call({
    required int mid,
    required int page,
  }) {
    return _repository.fetchMemberAudios(mid: mid, page: page);
  }
}
