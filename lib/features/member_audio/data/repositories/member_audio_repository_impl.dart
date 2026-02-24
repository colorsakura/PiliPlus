import 'package:PiliPlus/features/member_audio/domain/entities/member_audio_item_entity.dart';
import 'package:PiliPlus/features/member_audio/domain/repositories/member_audio_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/space/space_audio/data.dart';

/// Implementation of member audio repository
class MemberAudioRepositoryImpl implements MemberAudioRepository {
  const MemberAudioRepositoryImpl();

  @override
  Future<LoadingState<List<MemberAudioItemEntity>>> fetchMemberAudios({
    required int mid,
    required int page,
  }) async {
    // Call the existing API
    final result = await MemberHttp.spaceAudio(mid: mid, page: page);

    // Transform LoadingState<SpaceAudioData> to LoadingState<List<MemberAudioItemEntity>>
    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.items ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}

/// Extension on LoadingState to provide pattern matching
extension LoadingStateExtension<T> on LoadingState<T> {
  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String? errMsg, {int? code}) error,
  }) {
    if (this is Loading) {
      return loading();
    } else if (this is Success<T>) {
      return success((this as Success<T>).response);
    } else if (this is Error) {
      final err = this as Error;
      return error(err.errMsg, code: err.code);
    }
    throw StateError('Invalid LoadingState type');
  }
}
