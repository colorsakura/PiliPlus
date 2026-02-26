import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article/domain/entities/article_content.dart';
import 'package:PiliPlus/features/article/domain/repositories/article_repository.dart';

/// Get opus detail use case
class GetOpusDetail {
  final ArticleRepository repository;

  const GetOpusDetail(this.repository);

  Future<LoadingState<OpusContentEntity>> call(String opusId) {
    return repository.getOpusDetail(opusId);
  }
}
