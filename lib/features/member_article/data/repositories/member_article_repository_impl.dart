import 'package:PiliPlus/features/member_article/domain/entities/member_article_item_entity.dart';
import 'package:PiliPlus/features/member_article/domain/repositories/member_article_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member article repository
class MemberArticleRepositoryImpl implements MemberArticleRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberArticleRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberArticleItemEntity>>> fetchMemberArticles({
    required int mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.spaceArticle(mid: mid, page: page);
      final items = data.item ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
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
