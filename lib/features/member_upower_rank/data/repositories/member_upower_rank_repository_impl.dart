import 'package:PiliPlus/features/member_upower_rank/domain/entities/member_upower_rank_item_entity.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/repositories/member_upower_rank_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';

/// Implementation of member upower rank repository
class MemberUpowerRankRepositoryImpl
    implements MemberUpowerRankRepository {
  const MemberUpowerRankRepositoryImpl();

  @override
  Future<LoadingState<List<MemberUpowerRankItemEntity>>> fetchMemberUpowerRank({
    required String upMid,
    required int page,
    int? privilegeType,
  }) async {
    final result = await MemberHttp.upowerRank(
      upMid: upMid,
      page: page,
      privilegeType: privilegeType,
    );

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.rankInfo ?? [];
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
