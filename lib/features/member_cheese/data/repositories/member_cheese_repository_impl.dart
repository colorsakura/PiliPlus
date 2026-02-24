import 'package:PiliPlus/features/member_cheese/domain/entities/member_cheese_item_entity.dart';
import 'package:PiliPlus/features/member_cheese/domain/repositories/member_cheese_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';

/// Implementation of member cheese repository
class MemberCheeseRepositoryImpl implements MemberCheeseRepository {
  const MemberCheeseRepositoryImpl();

  @override
  Future<LoadingState<List<MemberCheeseItemEntity>>> fetchMemberCheeses({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.spaceCheese(
      page: page,
      mid: mid,
    );

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
