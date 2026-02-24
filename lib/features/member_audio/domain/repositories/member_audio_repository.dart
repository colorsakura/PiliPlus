import 'package:PiliPlus/features/member_audio/domain/entities/member_audio_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for fetching member audios
abstract class MemberAudioRepository {
  /// Fetch audios for a member
  ///
  /// [mid] - Member ID
  /// [page] - Page number (1-indexed)
  Future<LoadingState<List<MemberAudioItemEntity>>> fetchMemberAudios({
    required int mid,
    required int page,
  });
}
