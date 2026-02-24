import 'package:PiliPlus/features/member_article/domain/entities/member_article_item_entity.dart';
import 'package:PiliPlus/features/member_article/domain/repositories/member_article_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/space/space_article/data.dart';

/// Implementation of member article repository
class MemberArticleRepositoryImpl implements MemberArticleRepository {
  const MemberArticleRepositoryImpl();

  @override
  Future<LoadingState<List<MemberArticleItemEntity>>> fetchMemberArticles({
    required int mid,
    required int page,
  }) async {
    // Call the existing API
    final result = await MemberHttp.spaceArticle(mid: mid, page: page);

    // Transform LoadingState<SpaceArticleData> to LoadingState<List<MemberArticleItemEntity>>
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
