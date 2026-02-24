import 'package:PiliPlus/features/member_like_arc/domain/entities/member_like_arc_item_entity.dart';
import 'package:PiliPlus/features/member_like_arc/domain/repositories/member_like_arc_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';

/// Implementation of member like arc repository
class MemberLikeArcRepositoryImpl implements MemberLikeArcRepository {
  const MemberLikeArcRepositoryImpl();

  @override
  Future<LoadingState<List<MemberLikeArcItemEntity>>> fetchMemberLikeArcs({
    required dynamic mid,
    required int page,
  }) async {
    final result = await MemberHttp.likeArc(mid: mid, page: page);

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.item ?? [];
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
